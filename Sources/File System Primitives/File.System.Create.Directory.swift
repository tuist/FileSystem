//
//  File.System.Create.Directory.swift
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

extension File.System.Create {
    /// Create new directories.
    public enum Directory {}
}

// MARK: - Options

extension File.System.Create.Directory {
    /// Options for directory creation.
    public struct Options: Sendable {
        /// Create intermediate directories as needed.
        public var createIntermediates: Bool

        /// Permissions for the new directory.
        public var permissions: File.System.Metadata.Permissions?

        public init(
            createIntermediates: Bool = false,
            permissions: File.System.Metadata.Permissions? = nil
        ) {
            self.createIntermediates = createIntermediates
            self.permissions = permissions
        }
    }
}

// MARK: - Error

extension File.System.Create.Directory {
    /// Errors that can occur during directory creation operations.
    public enum Error: Swift.Error, Equatable, Sendable {
        case alreadyExists(File.Path)
        case permissionDenied(File.Path)
        case parentDirectoryNotFound(File.Path)
        case createFailed(errno: Int32, message: String)
    }
}

// MARK: - Core API

extension File.System.Create.Directory {
    /// Creates a directory at the specified path.
    ///
    /// - Parameter path: The path where the directory should be created.
    /// - Throws: `File.System.Create.Directory.Error` on failure.
    public static func create(at path: File.Path) throws(Error) {
        #if os(Windows)
            try _createWindows(at: path, options: Options())
        #else
            try _createPOSIX(at: path, options: Options())
        #endif
    }

    /// Creates a directory at the specified path with options.
    ///
    /// - Parameters:
    ///   - path: The path where the directory should be created.
    ///   - options: Creation options (e.g., create intermediates).
    /// - Throws: `File.System.Create.Directory.Error` on failure.
    public static func create(at path: File.Path, options: Options) throws(Error) {
        #if os(Windows)
            try _createWindows(at: path, options: options)
        #else
            try _createPOSIX(at: path, options: options)
        #endif
    }

}

// MARK: - CustomStringConvertible for Error

extension File.System.Create.Directory.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .alreadyExists(let path):
            return "Directory already exists: \(path)"
        case .permissionDenied(let path):
            return "Permission denied: \(path)"
        case .parentDirectoryNotFound(let path):
            return "Parent directory not found: \(path)"
        case .createFailed(let errno, let message):
            return "Create failed: \(message) (errno=\(errno))"
        }
    }
}
