//
//  File.Stream.Async.swift
//  swift-file-system
//
//  Created by Coen ten Thije Boonkkamp on 18/12/2025.
//

extension File {
    /// Namespace for streaming file APIs.
    public enum Stream {}
}

extension File.Stream {
    /// Internal async streaming implementation.
    ///
    /// Use the static methods instead:
    /// ```swift
    /// for try await chunk in File.Stream.bytes(from: path) {
    ///     process(chunk)
    /// }
    /// ```
    public struct Async: Sendable {
        let io: File.IO.Executor

        /// Creates an async stream API with the given executor.
        init(io: File.IO.Executor = .default) {
            self.io = io
        }
    }

    // MARK: - Static Convenience Methods

    /// Stream file bytes asynchronously.
    ///
    /// ## Example
    /// ```swift
    /// for try await chunk in File.Stream.bytes(from: path) {
    ///     process(chunk)
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - path: The file path.
    ///   - options: Byte streaming options.
    ///   - io: The I/O executor (defaults to `.default`).
    /// - Returns: An async sequence of byte chunks.
    public static func bytes(
        from path: File.Path,
        options: Async.BytesOptions = .init(),
        io: File.IO.Executor = .default
    ) -> Async.ByteSequence {
        Async(io: io).bytes(from: path, options: options)
    }
}
