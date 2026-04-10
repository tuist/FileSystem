//
//  File.Directory.Async.swift
//  swift-file-system
//
//  Created by Coen ten Thije Boonkkamp on 18/12/2025.
//

extension File.Directory {
    /// Internal async directory implementation.
    ///
    /// Use the static methods instead:
    /// ```swift
    /// for try await entry in File.Directory.entries(at: path) {
    ///     print(entry.name)
    /// }
    /// ```
    public struct Async: Sendable {
        let io: File.IO.Executor

        /// Creates an async directory API with the given executor.
        init(io: File.IO.Executor = .default) {
            self.io = io
        }

        /// Lists directory contents (non-streaming).
        func contents(at path: File.Path) async throws -> [File.Directory.Entry] {
            try await io.run { try File.Directory.Contents.list(at: path) }
        }
    }

    // MARK: - Static Convenience Methods

    /// Stream directory entries asynchronously.
    ///
    /// ## Example
    /// ```swift
    /// for try await entry in File.Directory.entries(at: path) {
    ///     print(entry.name)
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - path: The directory path.
    ///   - io: The I/O executor (defaults to `.default`).
    /// - Returns: An async sequence of directory entries.
    public static func entries(
        at path: File.Path,
        io: File.IO.Executor = .default
    ) -> Async.Entries {
        Async(io: io).entries(at: path)
    }

    /// Lists directory contents asynchronously (non-streaming).
    ///
    /// - Parameters:
    ///   - path: The directory path.
    ///   - io: The I/O executor (defaults to `.default`).
    /// - Returns: Array of directory entries.
    /// - Throws: `File.Directory.Contents.Error` on failure.
    public static func contents(
        at path: File.Path,
        io: File.IO.Executor = .default
    ) async throws -> [File.Directory.Entry] {
        try await Async(io: io).contents(at: path)
    }

    /// Walk directory tree recursively asynchronously.
    ///
    /// ## Example
    /// ```swift
    /// for try await entry in File.Directory.walk(at: path) {
    ///     print(entry.path)
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - path: The root directory path.
    ///   - options: Walk options.
    ///   - io: The I/O executor (defaults to `.default`).
    /// - Returns: An async sequence of walk entries.
    public static func walk(
        at path: File.Path,
        options: Async.WalkOptions = .init(),
        io: File.IO.Executor = .default
    ) -> Async.WalkSequence {
        Async(io: io).walk(at: path, options: options)
    }
}
