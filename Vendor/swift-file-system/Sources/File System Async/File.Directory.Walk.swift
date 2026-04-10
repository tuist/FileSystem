//
//  File.Directory.Walk.swift
//  swift-file-system
//
//  Created by Coen ten Thije Boonkkamp on 18/12/2025.
//

import AsyncAlgorithms
import Synchronization

// MARK: - Walk Options

extension File.Directory.Async {
    /// Options for recursive directory walking.
    public struct WalkOptions: Sendable {
        /// Maximum concurrent directory reads.
        public var maxConcurrency: Int

        /// Whether to follow symbolic links.
        ///
        /// When `true`, cycle detection via inode tracking is enabled.
        public var followSymlinks: Bool

        /// Creates walk options.
        ///
        /// - Parameters:
        ///   - maxConcurrency: Maximum concurrent reads (default: 8).
        ///   - followSymlinks: Follow symlinks (default: false).
        public init(
            maxConcurrency: Int = 8,
            followSymlinks: Bool = false
        ) {
            self.maxConcurrency = max(1, maxConcurrency)
            self.followSymlinks = followSymlinks
        }
    }
}

// MARK: - Walk API

extension File.Directory.Async {
    /// Recursively walks a directory tree.
    ///
    /// ## Example
    /// ```swift
    /// let dir = File.Directory.Async(io: executor)
    /// for try await path in dir.walk(at: root) {
    ///     print(path)
    /// }
    /// ```
    ///
    /// ## Error Handling
    /// First error wins - stops the walk and propagates to consumer.
    ///
    /// ## Cycle Detection
    /// When `followSymlinks` is true, tracks visited inodes to prevent infinite loops.
    public func walk(
        at root: File.Path,
        options: WalkOptions = WalkOptions()
    ) -> WalkSequence {
        WalkSequence(root: root, options: options, io: io)
    }
}

// MARK: - WalkSequence

extension File.Directory.Async {
    /// An AsyncSequence that recursively yields all paths in a directory tree.
    ///
    /// ## State Machine
    /// Uses a completion authority to ensure exactly one terminal state:
    /// `running` → `failed(Error)` | `cancelled` | `finished`
    ///
    /// ## Bounded Concurrency
    /// Concurrent directory reads are bounded by `maxConcurrency`.
    public struct WalkSequence: AsyncSequence, Sendable {
        public typealias Element = File.Path

        let root: File.Path
        let options: WalkOptions
        let io: File.IO.Executor

        public func makeAsyncIterator() -> AsyncIterator {
            AsyncIterator(root: root, options: options, io: io)
        }
    }
}

// MARK: - AsyncIterator

extension File.Directory.Async.WalkSequence {
    /// The async iterator for directory walk.
    public final class AsyncIterator: AsyncIteratorProtocol, @unchecked Sendable {
        private let channel: AsyncThrowingChannel<Element, any Error>
        private var channelIterator: AsyncThrowingChannel<Element, any Error>.AsyncIterator
        private let producerTask: Task<Void, Never>
        private var isFinished = false

        init(root: File.Path, options: File.Directory.Async.WalkOptions, io: File.IO.Executor) {
            let channel = AsyncThrowingChannel<Element, any Error>()
            self.channel = channel
            self.channelIterator = channel.makeAsyncIterator()

            self.producerTask = Task {
                await Self.runWalk(root: root, options: options, io: io, channel: channel)
            }
        }

        deinit {
            producerTask.cancel()
        }

        public func next() async throws -> Element? {
            guard !isFinished else { return nil }

            do {
                try Task.checkCancellation()
                let result = try await channelIterator.next()
                if result == nil {
                    isFinished = true
                }
                return result
            } catch {
                isFinished = true
                producerTask.cancel()
                throw error
            }
        }

        /// Explicitly terminate the walk.
        public func terminate() {
            guard !isFinished else { return }
            isFinished = true
            producerTask.cancel()
            channel.finish()  // Consumer's next() returns nil immediately
        }

        // MARK: - Walk Implementation

        private static func runWalk(
            root: File.Path,
            options: File.Directory.Async.WalkOptions,
            io: File.IO.Executor,
            channel: AsyncThrowingChannel<Element, any Error>
        ) async {
            let state = _WalkState(maxConcurrency: options.maxConcurrency)
            let authority = _CompletionAuthority()

            // Enqueue root
            await state.enqueue(root)

            // Process directories until done
            await withTaskGroup(of: Void.self) { group in
                while await state.hasWork {
                    // Check for cancellation
                    if Task.isCancelled {
                        break
                    }

                    // Check for completion
                    if await authority.isComplete {
                        break
                    }

                    // Try to get a directory to process
                    guard let dir = await state.dequeue() else {
                        // No dirs in queue - wait for active workers
                        await state.waitForWorkOrCompletion()
                        continue
                    }

                    // Acquire semaphore slot
                    await state.acquireSemaphore()

                    // Spawn worker task
                    group.addTask {
                        await Self.processDirectory(
                            dir,
                            options: options,
                            io: io,
                            state: state,
                            authority: authority,
                            channel: channel
                        )
                        await state.releaseSemaphore()
                    }
                }

                // Cancel remaining work if authority completed with error
                group.cancelAll()
            }

            // Finish channel based on final state
            let finalState = await authority.complete()
            switch finalState {
            case .finished, .cancelled:
                channel.finish()
            case .failed(let error):
                channel.fail(error)
            case .running:
                // Should not happen - treat as finished
                channel.finish()
            }
        }

        private static func processDirectory(
            _ dir: File.Path,
            options: File.Directory.Async.WalkOptions,
            io: File.IO.Executor,
            state: _WalkState,
            authority: _CompletionAuthority,
            channel: AsyncThrowingChannel<Element, any Error>
        ) async {
            // Check if already done
            guard await !authority.isComplete else {
                await state.decrementActive()  // Don't leak worker count
                return
            }

            // Open iterator
            let boxResult: Result<IteratorBox, any Error> = await {
                do {
                    let box = try await io.run {
                        let iterator = try File.Directory.Iterator.open(at: dir)
                        return IteratorBox(iterator)
                    }
                    return .success(box)
                } catch {
                    return .failure(error)
                }
            }()

            guard case .success(let box) = boxResult else {
                if case .failure(let error) = boxResult {
                    await authority.fail(with: error)
                }
                await state.decrementActive()
                return
            }

            defer {
                Task {
                    _ = try? await io.run { box.close() }
                }
            }

            // Iterate directory with batching to reduce executor overhead
            do {
                let batchSize = 64

                while true {
                    // Check cancellation
                    if Task.isCancelled {
                        break
                    }

                    // Check completion
                    if await authority.isComplete {
                        break
                    }

                    // Read batch of entries via single io.run call
                    let batch: [File.Directory.Entry] = try await io.run {
                        var entries: [File.Directory.Entry] = []
                        entries.reserveCapacity(batchSize)
                        for _ in 0..<batchSize {
                            guard let entry = try box.next() else { break }
                            entries.append(entry)
                        }
                        return entries
                    }

                    guard !batch.isEmpty else { break }

                    // Process batch entries
                    for entry in batch {
                        // Send path to consumer
                        await channel.send(entry.path)

                        // Check if we should recurse
                        let shouldRecurse: Bool
                        if entry.type == .directory {
                            shouldRecurse = true
                        } else if options.followSymlinks && entry.type == .symbolicLink {
                            // Get inode for cycle detection
                            if let inode = await getInode(entry.path, io: io) {
                                shouldRecurse = await state.markVisited(inode)
                            } else {
                                shouldRecurse = false
                            }
                        } else {
                            shouldRecurse = false
                        }

                        if shouldRecurse {
                            await state.enqueue(entry.path)
                        }
                    }
                }
            } catch {
                await authority.fail(with: error)
            }

            await state.decrementActive()
        }

        private static func getInode(_ path: File.Path, io: File.IO.Executor) async -> _InodeKey? {
            do {
                return try await io.run {
                    // Use lstat to get the symlink's own inode, not its target's
                    let info = try File.System.Stat.lstatInfo(at: path)
                    return _InodeKey(device: info.deviceId, inode: info.inode)
                }
            } catch {
                return nil
            }
        }
    }
}

// MARK: - Completion Authority

/// State machine ensuring exactly one terminal state.
///
/// States: `running` → `failed(Error)` | `cancelled` | `finished`
/// First transition out of `running` wins.
private actor _CompletionAuthority {
    enum State {
        case running
        case failed(any Error)
        case cancelled
        case finished
    }

    private var state: State = .running

    var isComplete: Bool {
        if case .running = state { return false }
        return true
    }

    /// Attempt to transition to failed. First error wins.
    func fail(with error: any Error) {
        guard case .running = state else { return }
        state = .failed(error)
    }

    /// Attempt to transition to cancelled.
    func cancel() {
        guard case .running = state else { return }
        state = .cancelled
    }

    /// Complete and return final state.
    func complete() -> State {
        if case .running = state {
            state = .finished
        }
        return state
    }
}

// MARK: - Walk State

/// Actor-protected state for the walk algorithm.
private actor _WalkState {
    private var queue: [File.Path] = []
    private var activeWorkers: Int = 0
    private var visited: Set<_InodeKey> = []

    private let maxConcurrency: Int
    private var semaphoreValue: Int
    private var semaphoreWaiters: [CheckedContinuation<Void, Never>] = []
    private var completionWaiters: [CheckedContinuation<Void, Never>] = []

    init(maxConcurrency: Int) {
        self.maxConcurrency = maxConcurrency
        self.semaphoreValue = maxConcurrency
    }

    var hasWork: Bool {
        !queue.isEmpty || activeWorkers > 0
    }

    func enqueue(_ path: File.Path) {
        queue.append(path)
        activeWorkers += 1
        // Wake one completion waiter
        if let waiter = completionWaiters.first {
            completionWaiters.removeFirst()
            waiter.resume()
        }
    }

    func dequeue() -> File.Path? {
        guard !queue.isEmpty else { return nil }
        return queue.removeFirst()
    }

    func decrementActive() {
        activeWorkers = max(0, activeWorkers - 1)
        // Wake completion waiters
        if let waiter = completionWaiters.first {
            completionWaiters.removeFirst()
            waiter.resume()
        }
    }

    func waitForWorkOrCompletion() async {
        guard queue.isEmpty && activeWorkers > 0 else { return }
        await withCheckedContinuation { continuation in
            completionWaiters.append(continuation)
        }
    }

    /// Returns true if this is the first visit (should recurse), false if already visited (cycle).
    func markVisited(_ inode: _InodeKey) -> Bool {
        visited.insert(inode).inserted
    }

    func acquireSemaphore() async {
        if semaphoreValue > 0 {
            semaphoreValue -= 1
        } else {
            await withCheckedContinuation { continuation in
                semaphoreWaiters.append(continuation)
            }
        }
    }

    func releaseSemaphore() {
        if !semaphoreWaiters.isEmpty {
            semaphoreWaiters.removeFirst().resume()
        } else {
            semaphoreValue += 1
        }
    }
}

// MARK: - Inode Key

/// Unique identifier for a file (device + inode).
private struct _InodeKey: Hashable, Sendable {
    let device: UInt64
    let inode: UInt64
}

// MARK: - Iterator Box

extension File.Directory.Async.WalkSequence {
    /// Heap-allocated box for the non-copyable iterator.
    ///
    /// ## Safety Invariant (for @unchecked Sendable)
    /// - Only accessed from within `io.run` closures (single-threaded access)
    /// - Never accessed concurrently
    /// - Caller ensures sequential access pattern
    fileprivate final class IteratorBox: @unchecked Sendable {
        private var storage: UnsafeMutablePointer<File.Directory.Iterator>?

        init(_ iterator: consuming File.Directory.Iterator) {
            self.storage = .allocate(capacity: 1)
            self.storage!.initialize(to: consume iterator)
        }

        deinit {
            if let ptr = storage {
                let it = ptr.move()
                ptr.deallocate()
                it.close()
            }
        }

        func next() throws -> File.Directory.Entry? {
            guard let ptr = storage else { return nil }
            return try ptr.pointee.next()
        }

        func close() {
            guard let ptr = storage else { return }
            let it = ptr.move()
            ptr.deallocate()
            storage = nil
            it.close()
        }
    }
}
