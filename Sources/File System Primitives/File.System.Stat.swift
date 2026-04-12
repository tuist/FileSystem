//
//  File.System.Stat.swift
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
    /// File status and existence checks.
    public enum Stat {}
}

// MARK: - Error

extension File.System.Stat {
    /// Errors that can occur during stat operations.
    public enum Error: Swift.Error, Equatable, Sendable {
        case pathNotFound(File.Path)
        case permissionDenied(File.Path)
        case statFailed(errno: Int32, message: String)
    }
}

// MARK: - Core API

extension File.System.Stat {
    /// Gets file metadata information (follows symlinks).
    ///
    /// - Parameter path: The path to stat.
    /// - Returns: File metadata information.
    /// - Throws: `File.System.Stat.Error` on failure.
    public static func info(at path: File.Path) throws(Error) -> File.System.Metadata.Info {
        #if os(Windows)
            return try _infoWindows(at: path)
        #else
            return try _infoPOSIX(at: path)
        #endif
    }

    /// Gets file metadata information without following symlinks.
    ///
    /// For symlinks, returns info about the link itself rather than its target.
    /// Useful for cycle detection when walking directories with `followSymlinks`.
    ///
    /// - Parameter path: The path to stat.
    /// - Returns: File metadata information for the link itself.
    /// - Throws: `File.System.Stat.Error` on failure.
    public static func lstatInfo(at path: File.Path) throws(Error) -> File.System.Metadata.Info {
        #if os(Windows)
            // Windows: GetFileAttributesEx doesn't follow symlinks by default
            return try _infoWindows(at: path)
        #else
            return try _lstatInfoPOSIX(at: path)
        #endif
    }

    /// Checks if a path exists.
    ///
    /// - Parameter path: The path to check.
    /// - Returns: `true` if the path exists, `false` otherwise.
    public static func exists(at path: File.Path) -> Bool {
        #if os(Windows)
            return _existsWindows(at: path)
        #else
            return _existsPOSIX(at: path)
        #endif
    }

}

// MARK: - CustomStringConvertible for Error

extension File.System.Stat.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .pathNotFound(let path):
            return "Path not found: \(path)"
        case .permissionDenied(let path):
            return "Permission denied: \(path)"
        case .statFailed(let errno, let message):
            return "Stat failed: \(message) (errno=\(errno))"
        }
    }
}
