//
//  File.System.Link.ReadTarget.swift
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
    /// Read symbolic link target.
    public enum ReadTarget {}
}

// MARK: - Error

extension File.System.Link.ReadTarget {
    /// Errors that can occur during reading link target operations.
    public enum Error: Swift.Error, Equatable, Sendable {
        case notASymlink(File.Path)
        case pathNotFound(File.Path)
        case permissionDenied(File.Path)
        case readFailed(errno: Int32, message: String)
    }
}

// MARK: - Core API

extension File.System.Link.ReadTarget {
    /// Reads the target of a symbolic link.
    ///
    /// - Parameter path: The path to the symbolic link.
    /// - Returns: The target path that the symlink points to.
    /// - Throws: `File.System.Link.ReadTarget.Error` on failure.
    public static func target(of path: File.Path) throws(Error) -> File.Path {
        #if os(Windows)
            return try _targetWindows(of: path)
        #else
            return try _targetPOSIX(of: path)
        #endif
    }

}

// MARK: - POSIX Implementation

#if !os(Windows)
    extension File.System.Link.ReadTarget {
        internal static func _targetPOSIX(of path: File.Path) throws(Error) -> File.Path {
            // First check if it's a symlink
            var statBuf = stat()
            guard lstat(path.string, &statBuf) == 0 else {
                throw _mapErrno(errno, path: path)
            }

            guard (statBuf.st_mode & S_IFMT) == S_IFLNK else {
                throw .notASymlink(path)
            }

            // Read the link target
            var buffer = [CChar](repeating: 0, count: Int(PATH_MAX) + 1)
            let length = readlink(path.string, &buffer, Int(PATH_MAX))

            guard length >= 0 else {
                throw _mapErrno(errno, path: path)
            }

            let targetString = String(
                decoding: buffer.prefix(length).map { UInt8(bitPattern: $0) },
                as: UTF8.self
            )

            guard let targetPath = try? File.Path(targetString) else {
                throw .readFailed(errno: 0, message: "Invalid target path: \(targetString)")
            }

            return targetPath
        }

        private static func _mapErrno(_ errno: Int32, path: File.Path) -> Error {
            switch errno {
            case ENOENT:
                return .pathNotFound(path)
            case EACCES, EPERM:
                return .permissionDenied(path)
            case EINVAL:
                return .notASymlink(path)
            default:
                let message: String
                if let cString = strerror(errno) {
                    message = String(cString: cString)
                } else {
                    message = "Unknown error"
                }
                return .readFailed(errno: errno, message: message)
            }
        }
    }
#endif

// MARK: - Windows Implementation

#if os(Windows)
    extension File.System.Link.ReadTarget {
        internal static func _targetWindows(of path: File.Path) throws(Error) -> File.Path {
            // Check if it's a reparse point (symlink)
            let attrs = path.string.withCString(encodedAs: UTF16.self) { wpath in
                GetFileAttributesW(wpath)
            }

            guard attrs != INVALID_FILE_ATTRIBUTES else {
                throw .pathNotFound(path)
            }

            guard (attrs & FILE_ATTRIBUTE_REPARSE_POINT) != 0 else {
                throw .notASymlink(path)
            }

            // Open the file to read the reparse point
            let handle = path.string.withCString(encodedAs: UTF16.self) { wpath in
                CreateFileW(
                    wpath,
                    GENERIC_READ,
                    FILE_SHARE_READ | FILE_SHARE_WRITE | FILE_SHARE_DELETE,
                    nil,
                    OPEN_EXISTING,
                    FILE_FLAG_BACKUP_SEMANTICS | FILE_FLAG_OPEN_REPARSE_POINT,
                    nil
                )
            }

            guard let handle = handle, handle != INVALID_HANDLE_VALUE else {
                throw _mapWindowsError(GetLastError(), path: path)
            }
            defer { CloseHandle(handle) }

            // Get the final path name
            var buffer = [UInt16](repeating: 0, count: Int(MAX_PATH) + 1)
            let length = buffer.withUnsafeMutableBufferPointer { ptr -> DWORD in
                guard let base = ptr.baseAddress else { return 0 }
                return GetFinalPathNameByHandleW(
                    handle,
                    base,
                    DWORD(MAX_PATH),
                    DWORD(FILE_NAME_NORMALIZED)
                )
            }

            guard length > 0 && length < MAX_PATH else {
                throw .readFailed(
                    errno: Int32(GetLastError()),
                    message: "GetFinalPathNameByHandleW failed"
                )
            }

            var targetString = String(decodingCString: buffer, as: UTF16.self)

            // Remove \\?\ prefix if present
            if targetString.hasPrefix("\\\\?\\") {
                targetString = String(targetString.dropFirst(4))
            }

            guard let targetPath = try? File.Path(targetString) else {
                throw .readFailed(errno: 0, message: "Invalid target path: \(targetString)")
            }

            return targetPath
        }

        private static func _mapWindowsError(_ error: DWORD, path: File.Path) -> Error {
            switch error {
            case DWORD(ERROR_FILE_NOT_FOUND), DWORD(ERROR_PATH_NOT_FOUND):
                return .pathNotFound(path)
            case DWORD(ERROR_ACCESS_DENIED):
                return .permissionDenied(path)
            default:
                return .readFailed(errno: Int32(error), message: "Windows error \(error)")
            }
        }
    }
#endif

// MARK: - CustomStringConvertible for Error

extension File.System.Link.ReadTarget.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .notASymlink(let path):
            return "Not a symbolic link: \(path)"
        case .pathNotFound(let path):
            return "Path not found: \(path)"
        case .permissionDenied(let path):
            return "Permission denied: \(path)"
        case .readFailed(let errno, let message):
            return "Read link target failed: \(message) (errno=\(errno))"
        }
    }
}
