//
//  File.System.Delete.swift
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
    /// Namespace for file deletion operations.
    public enum Delete {}
}

// MARK: - Options

extension File.System.Delete {
    /// Options for delete operations.
    public struct Options: Sendable {
        /// Delete directories recursively.
        public var recursive: Bool

        public init(recursive: Bool = false) {
            self.recursive = recursive
        }
    }
}

// MARK: - Error

extension File.System.Delete {
    /// Errors that can occur during delete operations.
    public enum Error: Swift.Error, Equatable, Sendable {
        case pathNotFound(File.Path)
        case permissionDenied(File.Path)
        case isDirectory(File.Path)
        case directoryNotEmpty(File.Path)
        case deleteFailed(errno: Int32, message: String)
    }
}

// MARK: - Core API

extension File.System.Delete {
    /// Deletes a file or directory at the specified path with options.
    ///
    /// - Parameters:
    ///   - path: The path to delete.
    ///   - options: Delete options (e.g., recursive).
    /// - Throws: `File.System.Delete.Error` on failure.
    public static func delete(at path: File.Path, options: Options = .init()) throws(Error) {
        #if os(Windows)
            try _deleteWindows(at: path, options: options)
        #else
            try _deletePOSIX(at: path, options: options)
        #endif
    }

}

// MARK: - CustomStringConvertible for Error

extension File.System.Delete.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .pathNotFound(let path):
            return "Path not found: \(path)"
        case .permissionDenied(let path):
            return "Permission denied: \(path)"
        case .isDirectory(let path):
            return "Is a directory (use recursive option): \(path)"
        case .directoryNotEmpty(let path):
            return "Directory not empty (use recursive option): \(path)"
        case .deleteFailed(let errno, let message):
            return "Delete failed: \(message) (errno=\(errno))"
        }
    }
}
