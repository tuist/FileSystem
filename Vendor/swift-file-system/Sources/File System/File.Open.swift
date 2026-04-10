//
//  File.Open.swift
//  swift-file-system
//
//  Created by Coen ten Thije Boonkkamp on 18/12/2025.
//

// MARK: - Open Namespace

extension File {
    /// Namespace for scoped file open operations.
    ///
    /// This provides an ergonomic API for opening files with automatic cleanup.
    /// Use `File.open(path)` or `file.open` to get an `Open` instance, then call it
    /// directly for read access, or use `.write`, `.appending`, or `.readWrite`
    /// for other access modes.
    ///
    /// ## Example
    /// ```swift
    /// // Static API
    /// let data = try File.open(path) { handle in
    ///     try handle.read(count: 100)
    /// }
    ///
    /// // Instance API
    /// let file: File = "/tmp/data.txt"
    /// try file.open.write { handle in
    ///     try handle.write(bytes)
    /// }
    /// ```
    public struct Open: Sendable {
        /// The path to open.
        public let path: File.Path
        /// Options for opening.
        public let options: File.Handle.Options

        /// Creates an Open instance.
        @usableFromInline
        internal init(path: File.Path, options: File.Handle.Options) {
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
}

// MARK: - Static API

extension File {
    /// Returns an `Open` instance for the given path.
    ///
    /// Use this to access the ergonomic file opening API:
    /// ```swift
    /// // Read (default)
    /// try File.open(path) { handle in ... }
    ///
    /// // Write
    /// try File.open(path).write { handle in ... }
    /// ```
    ///
    /// - Parameters:
    ///   - path: The path to the file.
    ///   - options: Options for opening the file.
    /// - Returns: An `Open` instance.
    @inlinable
    public static func open(_ path: File.Path, options: File.Handle.Options = []) -> Open {
        Open(path: path, options: options)
    }
}

// MARK: - Instance API

extension File {
    /// Returns an `Open` instance for this file.
    ///
    /// Use this to access the ergonomic file opening API:
    /// ```swift
    /// let file: File = "/tmp/data.txt"
    ///
    /// // Read (default)
    /// try file.open { handle in ... }
    ///
    /// // Write
    /// try file.open.write { handle in ... }
    ///
    /// // With options
    /// try file.open(options: [.create]).write { handle in ... }
    /// ```
    public var open: Open {
        Open(path: path, options: [])
    }

    /// Returns an `Open` instance for this file with the given options.
    ///
    /// - Parameter options: Options for opening the file.
    /// - Returns: An `Open` instance.
    @inlinable
    public func open(options: File.Handle.Options) -> Open {
        Open(path: path, options: options)
    }
}
