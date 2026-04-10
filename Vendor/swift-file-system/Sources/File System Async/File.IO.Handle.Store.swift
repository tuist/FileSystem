//
//  File.IO.Handle.Store.swift
//  swift-file-system
//
//  Created by Coen ten Thije Boonkkamp on 18/12/2025.
//

import Synchronization

// MARK: - Atomic Counter

/// Thread-safe counter for generating unique IDs.
///
/// ## Safety Invariant
/// All mutations of `value` occur inside `withLock`, ensuring exclusive access.
final class _AtomicCounter: @unchecked Sendable {
    private let state: Mutex<UInt64>

    init() {
        self.state = Mutex(0)
    }

    func next() -> UInt64 {
        state.withLock { value in
            let result = value
            value += 1
            return result
        }
    }
}

// MARK: - HandleID

extension File.IO {
    /// A unique identifier for a registered file handle.
    ///
    /// HandleIDs are:
    /// - Scoped to a specific executor/store instance (prevents cross-executor misuse)
    /// - Never reused within an executor's lifetime
    /// - Sendable and Hashable for use as dictionary keys
    public struct HandleID: Hashable, Sendable {
        /// The unique identifier within the store.
        let raw: UInt64
        /// The scope identifier (unique per store instance).
        let scope: UInt64
    }
}

// MARK: - Handle Errors

extension File.IO {
    /// Errors related to handle operations in the store.
    public enum HandleError: Error, Sendable {
        /// The handle ID does not exist in the store (already closed or never existed).
        case invalidHandleID
        /// The handle ID belongs to a different executor/store.
        case scopeMismatch
        /// The handle has already been closed.
        case handleClosed
    }
}

// MARK: - HandleBox

extension File.IO {
    /// A heap-allocated box that owns a File.Handle with its own lock.
    ///
    /// This design enables:
    /// - Per-handle locking (parallelism across different handles)
    /// - Stable storage address (dictionary rehashing doesn't invalidate inout)
    /// - Safe concurrent access patterns
    ///
    /// ## Safety Invariant (for @unchecked Sendable)
    /// - All access to `storage` occurs within `state.withLock { }`.
    /// - The `UnsafeMutablePointer` provides a stable address for inout access
    ///   to the ~Copyable File.Handle.
    /// - No closure passed to withLock is async or escaping.
    final class HandleBox: @unchecked Sendable {
        /// State protecting the handle storage.
        /// - `true`: handle is open (storage is valid)
        /// - `false`: handle is closed (storage is nil)
        private let state: Mutex<Bool>

        /// Pointer to the handle storage. Only accessed under state lock.
        /// Nil means closed.
        private var storage: UnsafeMutablePointer<File.Handle>?

        /// The path (for diagnostics).
        let path: File.Path
        /// The mode (for diagnostics).
        let mode: File.Handle.Mode

        init(_ handle: consuming File.Handle) {
            self.path = handle.path
            self.mode = handle.mode
            // Allocate and initialize storage
            self.storage = .allocate(capacity: 1)
            self.storage!.initialize(to: consume handle)
            self.state = Mutex(true)
        }

        deinit {
            // If storage still exists, we need to clean up.
            // Note: Close errors are intentionally discarded in deinit
            // (deinit is leak prevention only).
            if let ptr = storage {
                let handle = ptr.move()
                ptr.deallocate()
                _ = try? handle.close()
            }
        }

        /// Whether the handle is still open.
        var isOpen: Bool {
            state.withLock { $0 }
        }

        /// Execute a closure with exclusive access to the handle.
        ///
        /// - Parameter body: Closure receiving inout access to the handle.
        ///   Must be synchronous and non-escaping.
        /// - Returns: The result of the closure.
        /// - Throws: `HandleError.handleClosed` if handle was already closed.
        func withHandle<T>(_ body: (inout File.Handle) throws -> T) throws -> T {
            try state.withLock { isOpen in
                guard isOpen, let ptr = storage else {
                    throw HandleError.handleClosed
                }
                // Access via pointer - stable address, no move required
                return try body(&ptr.pointee)
            }
        }

        /// Close the handle and return any error.
        ///
        /// - Returns: The close error, if any.
        /// - Note: Idempotent - second call returns nil.
        func close() -> (any Error)? {
            // First, atomically mark as closed and get storage
            let ptr: UnsafeMutablePointer<File.Handle>? = state.withLock { isOpen in
                guard isOpen, let ptr = storage else {
                    return nil  // Already closed
                }
                isOpen = false
                storage = nil
                return ptr
            }

            // If already closed, return nil
            guard let ptr else {
                return nil
            }

            // Move out, deallocate, close (outside lock)
            let handle = ptr.move()
            ptr.deallocate()

            do {
                try handle.close()
                return nil
            } catch {
                return error
            }
        }
    }
}

// MARK: - Handle Store State

extension File.IO {
    /// Internal state protected by the store's mutex.
    struct HandleStoreState: ~Copyable {
        /// The handle storage.
        var handles: [HandleID: HandleBox] = [:]
        /// Counter for generating unique IDs.
        var nextID: UInt64 = 0
        /// Whether the store has been shut down.
        var isShutdown: Bool = false
    }
}

// MARK: - Handle Store

extension File.IO {
    /// Thread-safe storage for file handles, owned by an executor.
    ///
    /// ## Design
    /// - Dictionary maps HandleID → HandleBox
    /// - Store mutex guards map mutations and shutdown state
    /// - Per-handle locks (in HandleBox) guard handle operations
    /// - This enables parallelism across different handles
    ///
    /// ## Safety Invariant (for @unchecked Sendable)
    /// - All mutation of `state` contents occurs inside `state.withLock { }`.
    /// - Boxes are never returned to users; only accessed inside io.run jobs.
    /// - No closure passed to withLock is async or escaping.
    ///
    /// ## Lifecycle
    /// - Store lifetime = Executor lifetime
    /// - Shutdown forcibly closes remaining handles
    final class HandleStore: @unchecked Sendable {
        /// Protected state containing dictionary and metadata.
        private let state: Mutex<HandleStoreState>

        /// Unique scope identifier for this store instance.
        let scope: UInt64

        /// Global counter for generating unique scope IDs.
        private static let scopeCounter = _AtomicCounter()

        init() {
            // Generate a unique scope ID for this store instance
            self.scope = Self.scopeCounter.next()
            self.state = Mutex(HandleStoreState())
        }

        /// Register a handle and return its ID.
        ///
        /// - Parameter handle: The handle to register (ownership transferred).
        /// - Returns: The handle ID for future operations.
        /// - Throws: `ExecutorError.shutdownInProgress` if store is shut down.
        ///
        /// ## Implementation Note
        /// The handle is consumed outside the lock because `Mutex.withLock` takes
        /// an escaping closure, and noncopyable types cannot be consumed inside
        /// escaping closures. We use a two-phase approach:
        /// 1. Quick check if shutdown in progress (return early if so)
        /// 2. Create HandleBox (consumes handle)
        /// 3. Atomically register under lock (with double-check for shutdown race)
        ///
        /// If shutdown races between phase 1 and 3, the HandleBox's deinit will
        /// close the handle as a safety net.
        func register(_ handle: consuming File.Handle) throws -> HandleID {
            let scope = self.scope

            // Phase 1: Quick shutdown check (avoid creating box if already shutdown)
            let alreadyShutdown = state.withLock { $0.isShutdown }
            if alreadyShutdown {
                _ = try? handle.close()
                throw ExecutorError.shutdownInProgress
            }

            // Phase 2: Create box (consumes handle) - outside lock
            let box = HandleBox(handle)

            // Phase 3: Atomically register (with double-check)
            return try state.withLock { state in
                guard !state.isShutdown else {
                    // Race: shutdown started after our check
                    // box.deinit will close the handle
                    throw ExecutorError.shutdownInProgress
                }

                let id = HandleID(raw: state.nextID, scope: scope)
                state.nextID += 1
                state.handles[id] = box
                return id
            }
        }

        /// Execute a closure with exclusive access to a handle.
        ///
        /// - Parameters:
        ///   - id: The handle ID.
        ///   - body: Closure receiving inout access to the handle.
        /// - Returns: The result of the closure.
        /// - Throws: `HandleError.scopeMismatch` if ID belongs to different store.
        /// - Throws: `HandleError.invalidHandleID` if ID not found.
        /// - Throws: `HandleError.handleClosed` if handle was closed.
        func withHandle<T>(_ id: HandleID, _ body: (inout File.Handle) throws -> T) throws -> T {
            // Validate scope first
            guard id.scope == scope else {
                throw HandleError.scopeMismatch
            }

            // Find the box (short lock on dictionary)
            let box: HandleBox? = state.withLock { state in
                state.handles[id]
            }

            guard let box else {
                throw HandleError.invalidHandleID
            }

            // Execute with per-handle lock (box has its own Mutex)
            return try box.withHandle(body)
        }

        /// Close and remove a handle.
        ///
        /// - Parameter id: The handle ID.
        /// - Throws: `HandleError.scopeMismatch` if ID belongs to different store.
        /// - Throws: Close errors from the underlying handle.
        /// - Note: Idempotent for same-scope IDs that were already closed.
        func destroy(_ id: HandleID) throws {
            // Validate scope first - scope mismatch is always an error
            guard id.scope == scope else {
                throw HandleError.scopeMismatch
            }

            // Remove from dictionary (short lock)
            let box: HandleBox? = state.withLock { state in
                state.handles.removeValue(forKey: id)
            }

            // If not found, treat as already closed (idempotent)
            guard let box else {
                return
            }

            // Close the handle (may throw)
            if let error = box.close() {
                throw error
            }
        }

        /// Shutdown the store: close all remaining handles.
        ///
        /// - Note: Close errors are logged but not propagated.
        /// - Postcondition: All handles closed, store rejects new registrations.
        func shutdown() {
            // Atomically mark shutdown and extract remaining handles
            let remainingHandles: [HandleID: HandleBox] = state.withLock { state in
                state.isShutdown = true
                let handles = state.handles
                state.handles.removeAll()
                return handles
            }

            // Close all remaining handles (best-effort, outside lock)
            for (id, box) in remainingHandles {
                if let error = box.close() {
                    #if DEBUG
                        print("Warning: Error closing handle \(id.raw) during shutdown: \(error)")
                    #endif
                }
            }
        }

        /// Check if a handle ID is valid (for diagnostics).
        func isValid(_ id: HandleID) -> Bool {
            guard id.scope == scope else { return false }
            return state.withLock { state in
                state.handles[id] != nil
            }
        }

        /// The number of registered handles (for testing).
        var count: Int {
            state.withLock { state in
                state.handles.count
            }
        }
    }
}
