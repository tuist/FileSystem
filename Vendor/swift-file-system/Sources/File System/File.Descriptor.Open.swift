//
//  File.Descriptor.Open.swift
//  swift-file-system
//
//  Created by Coen ten Thije Boonkkamp on 18/12/2025.
//

// MARK: - Open Namespace

extension File.Descriptor {
    /// Namespace for scoped file descriptor open operations.
    ///
    /// This provides an ergonomic API for opening files with automatic cleanup.
    /// Use `File.Descriptor.open(path)` to get an `Open` instance, then call it
    /// directly for read access, or use `.write`, `.appending`, or `.readWrite`
    /// for other access modes.
    ///
    /// ## Example
    /// ```swift
    /// // Read-only (default)
    /// let result = try File.Descriptor.open(path) { descriptor in
    ///     // use descriptor
    /// }
    ///
    /// // Write access
    /// try File.Descriptor.open(path).write { descriptor in
    ///     // write to descriptor
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
        /// The file descriptor is automatically closed when the closure completes.
        ///
        /// - Parameter body: A closure that receives the file descriptor.
        /// - Returns: The result from the closure.
        /// - Throws: `File.Descriptor.Error` on open failure, or any error from the closure.
        @inlinable
        public func callAsFunction<Result>(
            _ body: (inout File.Descriptor) throws -> Result
        ) throws -> Result {
            try read(body)
        }

        // MARK: - Explicit Read

        /// Opens the file for reading and runs the closure.
        ///
        /// Same as `callAsFunction` - explicit method for clarity.
        ///
        /// - Parameter body: A closure that receives the file descriptor.
        /// - Returns: The result from the closure.
        /// - Throws: `File.Descriptor.Error` on open failure, or any error from the closure.
        @inlinable
        public func read<Result>(
            _ body: (inout File.Descriptor) throws -> Result
        ) throws -> Result {
            try File.Descriptor.withOpen(path, mode: .read, options: options, body: body)
        }

        // MARK: - Write

        /// Opens the file for writing and runs the closure.
        ///
        /// - Parameter body: A closure that receives the file descriptor.
        /// - Returns: The result from the closure.
        /// - Throws: `File.Descriptor.Error` on open failure, or any error from the closure.
        @inlinable
        public func write<Result>(
            _ body: (inout File.Descriptor) throws -> Result
        ) throws -> Result {
            try File.Descriptor.withOpen(path, mode: .write, options: options, body: body)
        }

        // MARK: - Appending

        /// Opens the file for appending and runs the closure.
        ///
        /// - Parameter body: A closure that receives the file descriptor.
        /// - Returns: The result from the closure.
        /// - Throws: `File.Descriptor.Error` on open failure, or any error from the closure.
        @inlinable
        public func appending<Result>(
            _ body: (inout File.Descriptor) throws -> Result
        ) throws -> Result {
            var opts = options
            opts.insert(.append)
            return try File.Descriptor.withOpen(path, mode: .write, options: opts, body: body)
        }

        // MARK: - Read-Write

        /// Opens the file for reading and writing and runs the closure.
        ///
        /// - Parameter body: A closure that receives the file descriptor.
        /// - Returns: The result from the closure.
        /// - Throws: `File.Descriptor.Error` on open failure, or any error from the closure.
        @inlinable
        public func readWrite<Result>(
            _ body: (inout File.Descriptor) throws -> Result
        ) throws -> Result {
            try File.Descriptor.withOpen(path, mode: .readWrite, options: options, body: body)
        }
    }

    /// Returns an `Open` instance for the given path.
    ///
    /// Use this to access the ergonomic file opening API:
    /// ```swift
    /// // Read (default)
    /// try File.Descriptor.open(path) { descriptor in ... }
    ///
    /// // Write
    /// try File.Descriptor.open(path).write { descriptor in ... }
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
