//
//  File.Path.Error.swift
//  swift-file-system
//
//  Created by Coen ten Thije Boonkkamp on 18/12/2025.
//

extension File.Path {
    /// Errors that can occur during path construction.
    public enum Error: Swift.Error, Equatable, Sendable {
        /// The path string is empty.
        case empty

        /// The path contains control characters (NUL, LF, CR, etc.).
        ///
        /// Control characters are invalid in file paths and can cause
        /// security issues or unexpected behavior with system calls.
        ///
        /// The associated value is the original, unmodified path string so
        /// callers can identify which path was rejected.
        case containsControlCharacters(String)
    }
}

// MARK: - CustomStringConvertible

extension File.Path.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .empty:
            return "Path is empty"
        case let .containsControlCharacters(path):
            // Use the escaped representation so the offending characters are
            // visible instead of being rendered (a bare "\n" would split the
            // message and a bare "\r" would overwrite part of it).
            return "Path contains control characters: \(path.debugDescription)"
        }
    }
}
