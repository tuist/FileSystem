//
//  File.Handle.Async.swift
//  swift-file-system
//
//  Created by Coen ten Thije Boonkkamp on 18/12/2025.
//

// MARK: - Buffer Wrapper

/// Wrapper to pass buffer pointers across Sendable boundaries.
///
/// SAFETY: The caller MUST ensure the underlying buffer remains valid
/// for the entire duration of the async call. This wrapper exists because
/// Swift's Sendable checking is more conservative than necessary for our
/// specific use case where the buffer is used synchronously within io.run.
struct _SendableBuffer: @unchecked Sendable {
    let pointer: UnsafeMutableRawBufferPointer
}

extension File.Handle {
    /// An async-safe file handle wrapper.
    ///
    /// This actor provides async methods for file I/O operations while ensuring
    /// proper resource management and thread safety.
    ///
    /// ## Architecture
    /// The actor does NOT directly own the `File.Handle`. Instead:
    /// - The primitive `File.Handle` lives in the executor's handle store
    /// - This actor holds only a `HandleID` (Sendable token)
    /// - All operations go through `io.withHandle(id) { ... }`
    ///
    /// This design solves Swift 6's restrictions on non-Sendable, non-copyable
    /// types in actors by keeping the linear resource in a thread-safe store
    /// and never moving it across async boundaries.
    ///
    /// ## Close Contract
    /// - `close()` must be called explicitly for deterministic release
    /// - If actor deinitializes without `close()`, best-effort cleanup only
    /// - Close errors from deinit cleanup are discarded
    ///
    /// ## Example
    /// ```swift
    /// let handle = try await File.Handle.Async.open(path, mode: .read, io: executor)
    /// let data = try await handle.read(count: 1024)
    /// try await handle.close()
    /// ```
    public actor Async {
        /// The handle ID in the executor's store.
        private let id: File.IO.HandleID

        /// The executor that owns the handle store.
        private let io: File.IO.Executor

        /// Whether the handle has been closed.
        private var isClosed: Bool = false

        /// The path this handle was opened for (for diagnostics).
        public nonisolated let path: File.Path

        /// The mode this handle was opened with.
        public nonisolated let mode: File.Handle.Mode

        /// Creates an async handle by registering a primitive handle with the executor.
        ///
        /// - Parameters:
        ///   - handle: The primitive handle (ownership transferred to executor store).
        ///   - io: The executor that will manage this handle.
        /// - Throws: `ExecutorError.shutdownInProgress` if executor is shut down.
        public init(_ handle: consuming File.Handle, io: File.IO.Executor) throws {
            self.path = handle.path
            self.mode = handle.mode
            self.io = io
            self.id = try io.registerHandle(handle)
        }

        /// Internal initializer for when handle is already registered.
        internal init(
            id: File.IO.HandleID,
            path: File.Path,
            mode: File.Handle.Mode,
            io: File.IO.Executor
        ) {
            self.id = id
            self.path = path
            self.mode = mode
            self.io = io
        }

        deinit {
            if !isClosed {
                #if DEBUG
                    print(
                        "Warning: File.Handle.Async deallocated without close() for path: \(path)"
                    )
                #endif
                // Best-effort cleanup - fire and forget
                // May be skipped during shutdown; errors discarded
                let io = self.io
                let id = self.id
                Task.detached {
                    try? await io.destroyHandle(id)
                }
            }
        }

        // MARK: - Opening

        /// Opens a file and returns an async handle.
        ///
        /// - Parameters:
        ///   - path: The path to the file.
        ///   - mode: The access mode.
        ///   - options: Additional options.
        ///   - io: The executor to use.
        /// - Returns: An async file handle.
        /// - Throws: `File.Handle.Error` on failure.
        public static func open(
            _ path: File.Path,
            mode: File.Handle.Mode,
            options: File.Handle.Options = [],
            io: File.IO.Executor
        ) async throws -> File.Handle.Async {
            // Open synchronously on the I/O executor, register immediately
            let id = try await io.run {
                let handle = try File.Handle.open(path, mode: mode, options: options)
                return try io.registerHandle(handle)
            }
            // Create the async wrapper with the registered ID
            return File.Handle.Async(id: id, path: path, mode: mode, io: io)
        }

        // MARK: - Reading

        /// Read into a caller-provided buffer.
        ///
        /// - Parameter destination: The buffer to read into.
        /// - Returns: Number of bytes read (0 at EOF).
        /// - Important: The buffer must remain valid until this call returns.
        public func read(into destination: UnsafeMutableRawBufferPointer) async throws -> Int {
            guard !isClosed else {
                throw File.Handle.Error.invalidHandle
            }
            // Wrap for Sendable - safe because buffer used synchronously in io.run
            let buffer = _SendableBuffer(pointer: destination)
            return try await io.withHandle(id) { handle in
                try handle.read(into: buffer.pointer)
            }
        }

        /// Convenience: read into a new array (allocates).
        ///
        /// - Parameter count: Maximum bytes to read.
        /// - Returns: The bytes read.
        public func read(count: Int) async throws -> [UInt8] {
            guard !isClosed else {
                throw File.Handle.Error.invalidHandle
            }
            return try await io.withHandle(id) { handle in
                try handle.read(count: count)
            }
        }

        // MARK: - Writing

        /// Write bytes from an array.
        ///
        /// - Parameter bytes: The bytes to write.
        public func write(_ bytes: [UInt8]) async throws {
            guard !isClosed else {
                throw File.Handle.Error.invalidHandle
            }
            try await io.withHandle(id) { handle in
                try bytes.withUnsafeBufferPointer { buffer in
                    let span = Span<UInt8>(_unsafeElements: buffer)
                    try handle.write(span)
                }
            }
        }

        // MARK: - Seeking

        /// Seek to a position.
        ///
        /// - Parameters:
        ///   - offset: The offset to seek to.
        ///   - origin: The origin for the seek.
        /// - Returns: The new position.
        @discardableResult
        public func seek(
            to offset: Int64,
            from origin: File.Handle.SeekOrigin = .start
        ) async throws -> Int64 {
            guard !isClosed else {
                throw File.Handle.Error.invalidHandle
            }
            return try await io.withHandle(id) { handle in
                try handle.seek(to: offset, from: origin)
            }
        }

        /// Get the current position.
        ///
        /// - Returns: The current file position.
        public func position() async throws -> Int64 {
            try await seek(to: 0, from: .current)
        }

        /// Seek to the beginning.
        ///
        /// - Returns: The new position (always 0).
        @discardableResult
        public func rewind() async throws -> Int64 {
            try await seek(to: 0, from: .start)
        }

        /// Seek to the end.
        ///
        /// - Returns: The new position (file size).
        @discardableResult
        public func seekToEnd() async throws -> Int64 {
            try await seek(to: 0, from: .end)
        }

        // MARK: - Sync

        /// Sync the file to disk.
        public func sync() async throws {
            guard !isClosed else {
                throw File.Handle.Error.invalidHandle
            }
            try await io.withHandle(id) { handle in
                try handle.sync()
            }
        }

        // MARK: - Close

        /// Close the handle.
        ///
        /// - Important: Must be called for deterministic release.
        /// - Note: Safe to call multiple times (idempotent).
        public func close() async throws {
            guard !isClosed else {
                return  // Already closed - idempotent
            }
            isClosed = true
            try await io.destroyHandle(id)
        }

        /// Whether the handle is still open.
        public var isOpen: Bool {
            !isClosed && io.isHandleValid(id)
        }
    }
}
