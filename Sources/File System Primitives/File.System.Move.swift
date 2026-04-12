//
//  File.System.Move.swift
//  swift-file-system
//
//  Created by Coen ten Thije Boonkkamp on 17/12/2025.
//

#if canImport(Darwin)
    import Darwin
#elseif canImport(Glibc)
    import Glibc
#elseif canImport(Musl)
    import Musl
#elseif os(Windows)
    import WinSDK
#endif

extension File.System {
    /// Namespace for file move/rename operations.
    public enum Move {}
}

// MARK: - Options

extension File.System.Move {
    /// Options for move operations.
    public struct Options: Sendable {
        /// Overwrite existing destination.
        public var overwrite: Bool

        public init(overwrite: Bool = false) {
            self.overwrite = overwrite
        }
    }
}

// MARK: - Error

extension File.System.Move {
    /// Errors that can occur during move operations.
    public enum Error: Swift.Error, Equatable, Sendable {
        case sourceNotFound(File.Path)
        case destinationExists(File.Path)
        case permissionDenied(File.Path)
        case moveFailed(errno: Int32, message: String)
    }
}

// MARK: - Core API

extension File.System.Move {
    /// Moves (renames) a file from source to destination with options.
    ///
    /// - Parameters:
    ///   - source: The source file path.
    ///   - destination: The destination file path.
    ///   - options: Move options.
    /// - Throws: `File.System.Move.Error` on failure.
    public static func move(
        from source: File.Path,
        to destination: File.Path,
        options: Options = .init()
    ) throws(Error) {
        #if os(Windows)
            try _moveWindows(from: source, to: destination, options: options)
        #else
            try _movePOSIX(from: source, to: destination, options: options)
        #endif
    }

}

// MARK: - CustomStringConvertible for Error

extension File.System.Move.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .sourceNotFound(let path):
            return "Source not found: \(path)"
        case .destinationExists(let path):
            return "Destination already exists: \(path)"
        case .permissionDenied(let path):
            return "Permission denied: \(path)"
        case .moveFailed(let errno, let message):
            return "Move failed: \(message) (errno=\(errno))"
        }
    }
}
