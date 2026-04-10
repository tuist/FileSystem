//
//  File.Handle+Convenience.swift
//  swift-file-system
//
//  Created by Coen ten Thije Boonkkamp on 18/12/2025.
//

// MARK: - Seek Conveniences

extension File.Handle {
    /// Returns the current position in the file.
    ///
    /// Equivalent to `seek(to: 0, from: .current)`.
    ///
    /// - Returns: The current file position.
    /// - Throws: `File.Handle.Error` on failure.
    public mutating func position() throws(Error) -> Int64 {
        try seek(to: 0, from: .current)
    }

    /// Seeks to the beginning of the file.
    ///
    /// Equivalent to `seek(to: 0, from: .start)`.
    ///
    /// ## Example
    /// ```swift
    /// try handle.rewind()
    /// let data = try handle.read(count: 100)  // Read from start
    /// ```
    ///
    /// - Returns: The new position (always 0).
    /// - Throws: `File.Handle.Error` on failure.
    @discardableResult
    public mutating func rewind() throws(Error) -> Int64 {
        try seek(to: 0, from: .start)
    }

    /// Seeks to the end of the file.
    ///
    /// Useful for determining file size or appending data.
    ///
    /// ## Example
    /// ```swift
    /// let size = try handle.seekToEnd()  // Returns file size
    /// ```
    ///
    /// - Returns: The new position (file size).
    /// - Throws: `File.Handle.Error` on failure.
    @discardableResult
    public mutating func seekToEnd() throws(Error) -> Int64 {
        try seek(to: 0, from: .end)
    }
}

// MARK: - withOpen

extension File.Handle {
    /// Opens a file, runs a closure, and ensures the handle is closed.
    ///
    /// This convenience method handles resource cleanup automatically,
    /// ensuring the file handle is closed when the closure completes,
    /// whether normally or by throwing an error.
    ///
    /// ## Example
    /// ```swift
    /// let content = try File.Handle.withOpen(path, mode: .read) { handle in
    ///     try handle.read(count: 1024)
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - path: The path to the file.
    ///   - mode: The access mode.
    ///   - options: Additional options.
    ///   - body: A closure that receives an inout handle and returns a result.
    /// - Returns: The result from the closure.
    /// - Throws: `File.Handle.Error` on open failure, or any error thrown by the closure.
    public static func withOpen<Result>(
        _ path: File.Path,
        mode: Mode,
        options: Options = [],
        body: (inout File.Handle) throws -> Result
    ) throws -> Result {
        var handle = try open(path, mode: mode, options: options)
        do {
            let result = try body(&handle)
            try? handle.close()  // Best-effort close after success
            return result
        } catch {
            try? handle.close()  // Best-effort close after error
            throw error
        }
    }

    /// Opens a file, runs an async closure, and ensures the handle is closed.
    ///
    /// This is the async variant of `withOpen` for use in async contexts.
    ///
    /// - Parameters:
    ///   - path: The path to the file.
    ///   - mode: The access mode.
    ///   - options: Additional options.
    ///   - body: An async closure that receives an inout handle and returns a result.
    /// - Returns: The result from the closure.
    /// - Throws: `File.Handle.Error` on open failure, or any error thrown by the closure.
    public static func withOpen<Result>(
        _ path: File.Path,
        mode: Mode,
        options: Options = [],
        body: (inout File.Handle) async throws -> Result
    ) async throws -> Result {
        var handle = try open(path, mode: mode, options: options)
        do {
            let result = try await body(&handle)
            try? handle.close()  // Best-effort close after success
            return result
        } catch {
            try? handle.close()  // Best-effort close after error
            throw error
        }
    }
}
