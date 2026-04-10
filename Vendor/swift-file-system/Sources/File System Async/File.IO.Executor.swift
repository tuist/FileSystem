//
//  File.IO.Executor.swift
//  swift-file-system
//
//  Created by Coen ten Thije Boonkkamp on 18/12/2025.
//

import Dispatch

// MARK: - Executor Errors

extension File.IO {
    /// Errors specific to the executor.
    public enum ExecutorError: Error, Sendable {
        /// The executor has been shut down.
        case shutdownInProgress
    }
}

// MARK: - Internal Job Protocol

/// Type-erased job that encapsulates work and continuation.
protocol _Job: Sendable {
    func run()
    func fail(with error: any Error)
}

/// Typed job box that preserves static typing through execution.
final class _JobBox<T: Sendable>: @unchecked Sendable, _Job {
    let operation: @Sendable () throws -> T
    private let continuation: CheckedContinuation<T, any Error>
    private var isCompleted = false  // Single-owner guard

    init(
        operation: @Sendable @escaping () throws -> T,
        continuation: CheckedContinuation<T, any Error>
    ) {
        self.operation = operation
        self.continuation = continuation
    }

    func run() {
        guard !isCompleted else { return }  // Idempotent
        isCompleted = true
        continuation.resume(with: Result { try operation() })
    }

    func fail(with error: any Error) {
        guard !isCompleted else { return }  // Idempotent
        isCompleted = true
        continuation.resume(throwing: error)
    }
}

// MARK: - Ring Buffer Queue

/// O(1) enqueue/dequeue queue using circular buffer.
struct _RingBuffer<T>: @unchecked Sendable {
    private var storage: [T?]
    private var head: Int = 0
    private var tail: Int = 0
    private var _count: Int = 0

    var count: Int { _count }
    var isEmpty: Bool { _count == 0 }

    init(capacity: Int) {
        storage = [T?](repeating: nil, count: max(capacity, 16))
    }

    mutating func enqueue(_ element: T) {
        if _count == storage.count {
            grow()
        }
        storage[tail] = element
        tail = (tail + 1) % storage.count
        _count += 1
    }

    mutating func dequeue() -> T? {
        guard _count > 0 else { return nil }
        let element = storage[head]
        storage[head] = nil
        head = (head + 1) % storage.count
        _count -= 1
        return element
    }

    /// Drain all elements.
    mutating func drainAll() -> [T] {
        var result: [T] = []
        result.reserveCapacity(_count)
        while let element = dequeue() {
            result.append(element)
        }
        return result
    }

    private mutating func grow() {
        var newStorage = [T?](repeating: nil, count: storage.count * 2)
        for i in 0..<_count {
            newStorage[i] = storage[(head + i) % storage.count]
        }
        head = 0
        tail = _count
        storage = newStorage
    }
}

// MARK: - Waiter Token with State

/// Token for cancellation-safe waiter tracking with single-owner semantics.
final class _WaiterState: @unchecked Sendable {
    enum State {
        case waiting(CheckedContinuation<Void, Never>)
        case resumed
        case cancelled
    }

    private var state: State

    init(_ continuation: CheckedContinuation<Void, Never>) {
        self.state = .waiting(continuation)
    }

    /// Resume the waiter if still waiting. Returns true if resumed.
    func resume() -> Bool {
        switch state {
        case .waiting(let continuation):
            state = .resumed
            continuation.resume()
            return true
        case .resumed, .cancelled:
            return false
        }
    }

    /// Mark as cancelled and resume if still waiting.
    @discardableResult
    func cancel() -> Bool {
        switch state {
        case .waiting(let continuation):
            state = .cancelled
            continuation.resume()
            return true
        case .resumed, .cancelled:
            return false
        }
    }
}

/// Sendable box to capture waiter state across isolation boundaries.
final class _WaiterBox: @unchecked Sendable {
    var state: _WaiterState?
}

/// Sendable box to track cancellation state across isolation boundaries.
final class _CancellationBox: @unchecked Sendable {
    var value: Bool = false
}

// MARK: - Executor

extension File.IO {
    /// A bounded pool for blocking I/O with configurable thread model.
    ///
    /// ## Thread Model
    /// The executor supports two thread models (configured via `Configuration.threadModel`):
    ///
    /// ### Cooperative (default)
    /// Uses Swift's cooperative thread pool via `Task.detached`. This means:
    /// - Blocking syscalls consume cooperative threads
    /// - Under sustained load, this can starve unrelated async work
    /// - `workers` bounds concurrency but does not provide dedicated threads
    ///
    /// ### Dedicated
    /// Uses dedicated `DispatchQueue` instances with explicit QoS:
    /// - Each worker has its own dispatch queue (user-initiated QoS)
    /// - Blocking I/O does not interfere with Swift's cooperative pool
    /// - Better isolation under sustained blocking operations
    ///
    /// ## Lifecycle
    /// - Lazy start: workers spawn on first `run()` call
    /// - **Fail-pending shutdown**: queued jobs fail with `.shutdownInProgress`
    /// - **The `.default` executor does not require shutdown** (process-scoped)
    ///
    /// ## Backpressure
    /// - Queue is bounded by `queueLimit` (ring buffer, O(1))
    /// - Callers suspend if queue is full
    /// - Cancellation while waiting removes the enqueue request
    ///
    /// ## Completion Guarantees
    /// - **Jobs run to completion once enqueued**
    /// - If caller is cancelled after enqueue, they receive `CancellationError`
    ///   (but the job still completes in the background)
    /// - `run()` after `shutdown()` throws `.shutdownInProgress`
    ///
    /// ## Handle Store
    /// The executor owns a handle store for managing stateful file handles.
    /// Use `registerHandle`, `withHandle`, and `destroyHandle` for handle operations.
    public actor Executor {
        private let configuration: Configuration
        private var queue: _RingBuffer<any _Job>
        private var capacityWaiters: [ObjectIdentifier: _WaiterState] = [:]
        private var isStarted: Bool = false
        private var isShutdown: Bool = false
        private var inFlightCount: Int = 0
        private var workerTasks: [Task<Void, Never>] = []
        private var shutdownContinuation: CheckedContinuation<Void, Never>?

        // Signal stream for workers (not polling)
        private var jobSignal: AsyncStream<Void>.Continuation?
        private var jobStream: AsyncStream<Void>?

        // Dedicated dispatch queues (only used in .dedicated thread model)
        private var dispatchQueues: [DispatchQueue] = []

        // Handle store for stateful file handle management
        private let handleStore: HandleStore

        // Whether this is the shared default executor (does not require shutdown)
        private let isDefaultExecutor: Bool

        // MARK: - Shared Default Executor

        /// The shared default executor for common use cases.
        ///
        /// This executor is lazily initialized and process-scoped:
        /// - Uses conservative default configuration
        /// - Does **not** require `shutdown()` (calling it is a no-op)
        /// - Suitable for the 80% case where you need simple async I/O
        ///
        /// For advanced use cases (dedicated threads, custom configuration,
        /// explicit lifecycle management), create your own executor instance.
        ///
        /// ## Example
        /// ```swift
        /// for try await entry in File.Directory.Async(io: .default).entries(at: path) {
        ///     print(entry.name)
        /// }
        /// ```
        public static let `default` = Executor(default: .default)

        // MARK: - Initializers

        /// Creates an executor with the given configuration.
        ///
        /// Executors created with this initializer **must** be shut down
        /// when no longer needed using `shutdown()`.
        public init(_ configuration: Configuration = .init()) {
            self.configuration = configuration
            self.queue = _RingBuffer(capacity: min(configuration.queueLimit, 1024))
            self.handleStore = HandleStore()
            self.isDefaultExecutor = false
        }

        /// Private initializer for the default executor.
        private init(default configuration: Configuration) {
            self.configuration = configuration
            self.queue = _RingBuffer(capacity: min(configuration.queueLimit, 1024))
            self.handleStore = HandleStore()
            self.isDefaultExecutor = true
        }

        /// Execute a blocking operation on a worker thread.
        ///
        /// ## Cancellation Semantics
        /// - Cancellation while waiting for queue capacity → `CancellationError`
        /// - Cancellation after enqueue → **job still runs** (mutation occurs),
        ///   but caller receives `CancellationError` instead of result
        ///
        /// - Throws: `ExecutorError.shutdownInProgress` if executor is shut down
        /// - Throws: `CancellationError` if task is cancelled
        public func run<T: Sendable>(
            _ operation: @Sendable @escaping () throws -> T
        ) async throws -> T {
            // Check cancellation upfront
            try Task.checkCancellation()

            // Reject if shutdown
            guard !isShutdown else {
                throw ExecutorError.shutdownInProgress
            }

            // Lazy start workers on first call
            if !isStarted {
                startWorkers()
                isStarted = true
            }

            // Wait for queue space if full (cancellation-safe, single-owner)
            while queue.count >= configuration.queueLimit {
                let waiterBox = _WaiterBox()

                await withTaskCancellationHandler {
                    await withCheckedContinuation {
                        (continuation: CheckedContinuation<Void, Never>) in
                        let waiterState = _WaiterState(continuation)
                        waiterBox.state = waiterState
                        capacityWaiters[ObjectIdentifier(waiterState)] = waiterState
                    }
                } onCancel: {
                    // Single-owner: cancel() returns false if already resumed
                    waiterBox.state?.cancel()
                }

                // Remove from dict (idempotent)
                if let state = waiterBox.state {
                    capacityWaiters.removeValue(forKey: ObjectIdentifier(state))
                }

                try Task.checkCancellation()

                // Re-check shutdown after waking
                guard !isShutdown else {
                    throw ExecutorError.shutdownInProgress
                }
            }

            // Track whether caller was cancelled during execution
            let wasCancelled = _CancellationBox()

            // Enqueue and wait for result
            // Note: Once enqueued, job completes regardless of caller cancellation
            let result = try await withTaskCancellationHandler {
                try await withCheckedThrowingContinuation {
                    (continuation: CheckedContinuation<T, any Error>) in
                    let job = _JobBox(operation: operation, continuation: continuation)
                    queue.enqueue(job)
                    // Signal workers that a job is available
                    jobSignal?.yield()
                }
            } onCancel: {
                wasCancelled.value = true
            }

            // If caller was cancelled while job was running, throw CancellationError
            // (even though the job completed successfully)
            if wasCancelled.value {
                throw CancellationError()
            }

            return result
        }

        /// Fail-pending shutdown.
        ///
        /// 1. Set `isShutdown = true` (rejects new `run()` calls)
        /// 2. **Fail all queued jobs** with `.shutdownInProgress`
        /// 3. Resume all capacity waiters
        /// 4. Wait for in-flight jobs to complete
        /// 5. **Close all remaining handles** (best-effort, errors logged)
        /// 6. End workers
        ///
        /// - Note: Calling `shutdown()` on the `.default` executor is a no-op.
        ///   The default executor is process-scoped and does not require shutdown.
        public func shutdown() async {
            // Default executor is process-scoped - shutdown is a no-op
            guard !isDefaultExecutor else { return }

            guard !isShutdown else { return }  // Idempotent
            isShutdown = true

            // 1. Fail all queued jobs atomically
            let pendingJobs = queue.drainAll()
            for job in pendingJobs {
                job.fail(with: ExecutorError.shutdownInProgress)
            }

            // 2. Resume all capacity waiters (single-owner: skip if already cancelled)
            for (_, waiterState) in capacityWaiters {
                _ = waiterState.resume()
            }
            capacityWaiters.removeAll()

            // 3. Wait for in-flight jobs to complete
            if inFlightCount > 0 {
                await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
                    shutdownContinuation = continuation
                }
            }

            // 4. Close all remaining handles (after in-flight jobs complete)
            handleStore.shutdown()

            // 5. End workers
            jobSignal?.finish()
            for task in workerTasks {
                task.cancel()
            }
            for task in workerTasks {
                _ = await task.result
            }
            workerTasks.removeAll()
        }

        // MARK: - Handle Management

        /// Register a file handle and return its ID.
        ///
        /// - Parameter handle: The handle to register (ownership transferred).
        /// - Returns: A unique handle ID for future operations.
        /// - Throws: `ExecutorError.shutdownInProgress` if executor is shut down.
        public nonisolated func registerHandle(_ handle: consuming File.Handle) throws -> HandleID {
            try handleStore.register(handle)
        }

        /// Execute a closure with exclusive access to a handle.
        ///
        /// The closure runs inside an `io.run` context, ensuring proper I/O scheduling.
        /// The handle is accessed via inout for in-place mutation.
        ///
        /// - Parameters:
        ///   - id: The handle ID.
        ///   - body: Closure receiving inout access to the handle.
        /// - Returns: The result of the closure.
        /// - Throws: `HandleError.scopeMismatch` if ID belongs to different executor.
        /// - Throws: `HandleError.invalidHandleID` if handle was already destroyed.
        /// - Throws: Any error from the closure.
        public func withHandle<T: Sendable>(
            _ id: HandleID,
            _ body: @Sendable @escaping (inout File.Handle) throws -> T
        ) async throws -> T {
            try await run {
                try self.handleStore.withHandle(id, body)
            }
        }

        /// Close and remove a handle.
        ///
        /// - Parameter id: The handle ID.
        /// - Throws: `HandleError.scopeMismatch` if ID belongs to different executor.
        /// - Throws: Close errors from the underlying handle.
        /// - Note: Idempotent for handles that were already destroyed.
        public func destroyHandle(_ id: HandleID) async throws {
            try await run {
                try self.handleStore.destroy(id)
            }
        }

        /// Check if a handle ID is currently valid.
        ///
        /// - Parameter id: The handle ID to check.
        /// - Returns: `true` if the handle exists and is open.
        public nonisolated func isHandleValid(_ id: HandleID) -> Bool {
            handleStore.isValid(id)
        }

        // MARK: - Private

        private func startWorkers() {
            let (stream, continuation) = AsyncStream<Void>.makeStream()
            self.jobStream = stream
            self.jobSignal = continuation

            switch configuration.threadModel {
            case .cooperative:
                // Current implementation: Task.detached uses cooperative thread pool
                for _ in 0..<configuration.workers {
                    let task = Task.detached { [weak self] in
                        guard let self else { return }
                        await self.workerLoop()
                    }
                    workerTasks.append(task)
                }

            case .dedicated:
                // Dedicated dispatch queues with explicit QoS
                for i in 0..<configuration.workers {
                    let queue = DispatchQueue(
                        label: "file.io.worker.\(i)",
                        qos: .userInitiated
                    )
                    dispatchQueues.append(queue)

                    let task = Task.detached { [weak self] in
                        guard let self else { return }
                        await self.dedicatedWorkerLoop(queue: queue)
                    }
                    workerTasks.append(task)
                }
            }
        }

        private func workerLoop() async {
            guard let stream = jobStream else { return }

            for await _ in stream {
                while !Task.isCancelled {
                    guard let job = dequeueJob() else { break }

                    // Execute OUTSIDE actor isolation
                    await executeJob(job)

                    // Track completion for shutdown
                    jobCompleted()
                }
            }
        }

        private func dedicatedWorkerLoop(queue: DispatchQueue) async {
            guard let stream = jobStream else { return }

            for await _ in stream {
                while !Task.isCancelled {
                    guard let job = dequeueJob() else { break }

                    // Execute on dedicated dispatch queue
                    await withCheckedContinuation {
                        (continuation: CheckedContinuation<Void, Never>) in
                        queue.async {
                            job.run()
                            continuation.resume()
                        }
                    }

                    // Track completion for shutdown
                    jobCompleted()
                }
            }
        }

        private func dequeueJob() -> (any _Job)? {
            guard let job = queue.dequeue() else { return nil }

            inFlightCount += 1

            // Signal ONE capacity waiter (single-owner via state)
            if let (id, waiterState) = capacityWaiters.first {
                if waiterState.resume() {
                    capacityWaiters.removeValue(forKey: id)
                }
            }
            return job
        }

        private func jobCompleted() {
            inFlightCount -= 1
            // If shutdown is waiting for in-flight to drain
            if isShutdown && inFlightCount == 0 {
                shutdownContinuation?.resume()
                shutdownContinuation = nil
            }
        }

        /// Execute job outside actor isolation.
        private nonisolated func executeJob(_ job: any _Job) async {
            job.run()
        }
    }
}
