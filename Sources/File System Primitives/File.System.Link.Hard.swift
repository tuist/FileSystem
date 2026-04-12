//
//  File.System.Link.Hard.swift
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

extension File.System.Link {
    /// Hard link operations.
    public enum Hard {}
}

// MARK: - Error

extension File.System.Link.Hard {
    /// Errors that can occur during hard link operations.
    public enum Error: Swift.Error, Equatable, Sendable {
        case sourceNotFound(File.Path)
        case permissionDenied(File.Path)
        case alreadyExists(File.Path)
        case crossDevice(source: File.Path, destination: File.Path)
        case isDirectory(File.Path)
        case linkFailed(errno: Int32, message: String)
    }
}

// MARK: - Core API

extension File.System.Link.Hard {
    /// Creates a hard link at the specified path to an existing file.
    ///
    /// - Parameters:
    ///   - path: The path where the hard link will be created.
    ///   - existing: The path to the existing file.
    /// - Throws: `File.System.Link.Hard.Error` on failure.
    public static func create(at path: File.Path, to existing: File.Path) throws(Error) {
        #if os(Windows)
            try _createWindows(at: path, to: existing)
        #else
            try _createPOSIX(at: path, to: existing)
        #endif
    }

}

// MARK: - POSIX Implementation

#if !os(Windows)
    extension File.System.Link.Hard {
        internal static func _createPOSIX(at path: File.Path, to existing: File.Path) throws(Error)
        {
            guard link(existing.string, path.string) == 0 else {
                throw _mapErrno(errno, path: path, existing: existing)
            }
        }

        private static func _mapErrno(_ errno: Int32, path: File.Path, existing: File.Path) -> Error
        {
            switch errno {
            case ENOENT:
                return .sourceNotFound(existing)
            case EEXIST:
                return .alreadyExists(path)
            case EACCES, EPERM:
                return .permissionDenied(path)
            case EXDEV:
                return .crossDevice(source: existing, destination: path)
            case EISDIR:
                return .isDirectory(existing)
            default:
                let message: String
                if let cString = strerror(errno) {
                    message = String(cString: cString)
                } else {
                    message = "Unknown error"
                }
                return .linkFailed(errno: errno, message: message)
            }
        }
    }
#endif

// MARK: - Windows Implementation

#if os(Windows)
    extension File.System.Link.Hard {
        internal static func _createWindows(
            at path: File.Path,
            to existing: File.Path
        ) throws(Error) {
            let success = existing.string.withCString(encodedAs: UTF16.self) { wexisting in
                path.string.withCString(encodedAs: UTF16.self) { wpath in
                    CreateHardLinkW(wpath, wexisting, nil)
                }
            }

            guard success else {
                throw _mapWindowsError(GetLastError(), path: path, existing: existing)
            }
        }

        private static func _mapWindowsError(
            _ error: DWORD,
            path: File.Path,
            existing: File.Path
        ) -> Error {
            switch error {
            case DWORD(ERROR_FILE_NOT_FOUND), DWORD(ERROR_PATH_NOT_FOUND):
                return .sourceNotFound(existing)
            case DWORD(ERROR_ALREADY_EXISTS), DWORD(ERROR_FILE_EXISTS):
                return .alreadyExists(path)
            case DWORD(ERROR_ACCESS_DENIED):
                return .permissionDenied(path)
            case DWORD(ERROR_NOT_SAME_DEVICE):
                return .crossDevice(source: existing, destination: path)
            default:
                return .linkFailed(errno: Int32(error), message: "Windows error \(error)")
            }
        }
    }
#endif

// MARK: - CustomStringConvertible for Error

extension File.System.Link.Hard.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .sourceNotFound(let path):
            return "Source not found: \(path)"
        case .permissionDenied(let path):
            return "Permission denied: \(path)"
        case .alreadyExists(let path):
            return "Link already exists: \(path)"
        case .crossDevice(let source, let destination):
            return "Cross-device link not allowed: \(source) → \(destination)"
        case .isDirectory(let path):
            return "Cannot create hard link to directory: \(path)"
        case .linkFailed(let errno, let message):
            return "Hard link creation failed: \(message) (errno=\(errno))"
        }
    }
}
