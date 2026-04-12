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
        case containsControlCharacters
    }
}

// MARK: - CustomStringConvertible

extension File.Path.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .empty:
            return "Path is empty"
        case .containsControlCharacters:
            return "Path contains control characters"
        }
    }
}
