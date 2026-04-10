//
//  File.Descriptor+Convenience.swift
//  swift-file-system
//
//  Created by Coen ten Thije Boonkkamp on 18/12/2025.
//

extension File.Descriptor {
    /// Opens a file descriptor, runs a closure, and ensures the descriptor is closed.
    ///
    /// This convenience method handles resource cleanup automatically,
    /// ensuring the file descriptor is closed when the closure completes,
    /// whether normally or by throwing an error.
    ///
    /// ## Example
    /// ```swift
    /// let bytesRead = try File.Descriptor.withOpen(path, mode: .read) { descriptor in
    ///     // Use descriptor for low-level I/O
    ///     return try descriptor.read(count: 1024)
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - path: The path to the file.
    ///   - mode: The access mode.
    ///   - options: Additional options.
    ///   - body: A closure that receives an inout descriptor and returns a result.
    /// - Returns: The result from the closure.
    /// - Throws: `File.Descriptor.Error` on open failure, or any error thrown by the closure.
    public static func withOpen<Result>(
        _ path: File.Path,
        mode: Mode,
        options: Options = [],
        body: (inout File.Descriptor) throws -> Result
    ) throws -> Result {
        var descriptor = try open(path, mode: mode, options: options)
        let result: Result
        do {
            result = try body(&descriptor)
        } catch {
            // Descriptor deinit will close it
            _ = consume descriptor
            throw error
        }
        try descriptor.close()
        return result
    }

    /// Opens a file descriptor, runs an async closure, and ensures the descriptor is closed.
    ///
    /// This is the async variant of `withOpen` for use in async contexts.
    ///
    /// - Parameters:
    ///   - path: The path to the file.
    ///   - mode: The access mode.
    ///   - options: Additional options.
    ///   - body: An async closure that receives an inout descriptor and returns a result.
    /// - Returns: The result from the closure.
    /// - Throws: `File.Descriptor.Error` on open failure, or any error thrown by the closure.
    public static func withOpen<Result>(
        _ path: File.Path,
        mode: Mode,
        options: Options = [],
        body: (inout File.Descriptor) async throws -> Result
    ) async throws -> Result {
        var descriptor = try open(path, mode: mode, options: options)
        let result: Result
        do {
            result = try await body(&descriptor)
        } catch {
            // Descriptor deinit will close it
            _ = consume descriptor
            throw error
        }
        try descriptor.close()
        return result
    }
}
