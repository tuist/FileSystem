//
//  File.Handle.Open.swift
//  swift-file-system
//
//  Created by Coen ten Thije Boonkkamp on 18/12/2025.
//

// MARK: - Open Namespace

extension File.Handle {
    /// Namespace for scoped file open operations.
    ///
    /// This provides an ergonomic API for opening files with automatic cleanup.
    /// Use `File.Handle.open(path)` to get an `Open` instance, then call it
    /// directly for read access, or use `.write`, `.appending`, or `.readWrite`
    /// for other access modes.
    ///
    /// ## Example
    /// ```swift
    /// // Read-only (default)
    /// let data = try File.Handle.open(path) { handle in
    ///     try handle.read(count: 100)
    /// }
    ///
    /// // Write access
    /// try File.Handle.open(path).write { handle in
    ///     try handle.write(bytes)
    /// }
    ///
    /// // Append access
    /// try File.Handle.open(path).appending { handle in
    ///     try handle.write(moreBytes)
    /// }
    ///
    /// // Read-write access
    /// try File.Handle.open(path).readWrite { handle in
    ///     try handle.seek(to: 0)
    ///     try handle.write(bytes)
    /// }
    /// ```
    public struct Open: Sendable {
        /// The path to open.
        public let path: File.Path
        /// Options for opening.
        public let options: Options

        /// Creates an Open instance.
        @usableFromInline
        internal init(path: File.Path, options: Options) {
            self.path = path
            self.options = options
        }

        // MARK: - callAsFunction (Read-only default)

        /// Opens the file for reading and runs the closure.
        ///
        /// This is the default access mode when calling an `Open` instance directly.
        /// The file handle is automatically closed when the closure completes.
        ///
        /// - Parameter body: A closure that receives the file handle.
        /// - Returns: The result from the closure.
        /// - Throws: `File.Handle.Error` on open failure, or any error from the closure.
        @inlinable
        public func callAsFunction<Result>(
            _ body: (inout File.Handle) throws -> Result
        ) throws -> Result {
            try read(body)
        }

        // MARK: - Explicit Read

        /// Opens the file for reading and runs the closure.
        ///
        /// Same as `callAsFunction` - explicit method for clarity.
        ///
        /// - Parameter body: A closure that receives the file handle.
        /// - Returns: The result from the closure.
        /// - Throws: `File.Handle.Error` on open failure, or any error from the closure.
        @inlinable
        public func read<Result>(
            _ body: (inout File.Handle) throws -> Result
        ) throws -> Result {
            try File.Handle.withOpen(path, mode: .read, options: options, body: body)
        }

        // MARK: - Write

        /// Opens the file for writing and runs the closure.
        ///
        /// - Parameter body: A closure that receives the file handle.
        /// - Returns: The result from the closure.
        /// - Throws: `File.Handle.Error` on open failure, or any error from the closure.
        @inlinable
        public func write<Result>(
            _ body: (inout File.Handle) throws -> Result
        ) throws -> Result {
            try File.Handle.withOpen(path, mode: .write, options: options, body: body)
        }

        // MARK: - Appending

        /// Opens the file for appending and runs the closure.
        ///
        /// - Parameter body: A closure that receives the file handle.
        /// - Returns: The result from the closure.
        /// - Throws: `File.Handle.Error` on open failure, or any error from the closure.
        @inlinable
        public func appending<Result>(
            _ body: (inout File.Handle) throws -> Result
        ) throws -> Result {
            try File.Handle.withOpen(path, mode: .append, options: options, body: body)
        }

        // MARK: - Read-Write

        /// Opens the file for reading and writing and runs the closure.
        ///
        /// - Parameter body: A closure that receives the file handle.
        /// - Returns: The result from the closure.
        /// - Throws: `File.Handle.Error` on open failure, or any error from the closure.
        @inlinable
        public func readWrite<Result>(
            _ body: (inout File.Handle) throws -> Result
        ) throws -> Result {
            try File.Handle.withOpen(path, mode: .readWrite, options: options, body: body)
        }
    }

    /// Returns an `Open` instance for the given path.
    ///
    /// Use this to access the ergonomic file opening API:
    /// ```swift
    /// // Read (default)
    /// try File.Handle.open(path) { handle in ... }
    ///
    /// // Write
    /// try File.Handle.open(path).write { handle in ... }
    /// ```
    ///
    /// - Parameters:
    ///   - path: The path to the file.
    ///   - options: Options for opening the file.
    /// - Returns: An `Open` instance.
    @inlinable
    public static func open(_ path: File.Path, options: Options = []) -> Open {
        Open(path: path, options: options)
    }
}
