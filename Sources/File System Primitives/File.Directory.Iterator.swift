//
//  File.Directory.Iterator.swift
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

extension File.Directory {
    /// A streaming directory iterator that yields entries one at a time.
    ///
    /// This is a ~Copyable type that owns the underlying directory handle
    /// and closes it when done.
    ///
    /// ## Thread Safety
    /// `Iterator` is **NOT** `Sendable`. It owns mutable state (the directory handle)
    /// and is not safe for concurrent use. For cross-task usage, wrap in an actor
    /// or use the async layer.
    public struct Iterator: ~Copyable /* NOT Sendable - owns mutable directory handle */ {
        #if os(Windows)
            private var _handle: HANDLE?
            private var _findData: WIN32_FIND_DATAW
            private var _hasMore: Bool
        #elseif canImport(Darwin)
            private var _dir: UnsafeMutablePointer<DIR>?
        #elseif canImport(Glibc)
            // Use OpaquePointer on Linux (DIR type not exported in Swift's Glibc overlay)
            private var _dir: OpaquePointer?
        #endif
        private let _basePath: File.Path

        deinit {
            #if os(Windows)
                if let handle = _handle, handle != INVALID_HANDLE_VALUE {
                    FindClose(handle)
                }
            #elseif canImport(Darwin)
                if let dir = _dir {
                    closedir(dir)
                }
            #elseif canImport(Glibc)
                if let dir = _dir {
                    Glibc.closedir(dir)
                }
            #endif
        }
    }
}

// MARK: - Error

extension File.Directory.Iterator {
    /// Errors that can occur during iteration.
    public enum Error: Swift.Error, Equatable, Sendable {
        case pathNotFound(File.Path)
        case permissionDenied(File.Path)
        case notADirectory(File.Path)
        case readFailed(errno: Int32, message: String)
    }
}

// MARK: - Core API

extension File.Directory.Iterator {
    /// Opens a directory for iteration.
    ///
    /// - Parameter path: The path to the directory.
    /// - Returns: An iterator for the directory.
    /// - Throws: `File.Directory.Iterator.Error` on failure.
    public static func open(at path: File.Path) throws(Error) -> File.Directory.Iterator {
        #if os(Windows)
            return try _openWindows(at: path)
        #else
            return try _openPOSIX(at: path)
        #endif
    }

    /// Returns the next entry in the directory, or nil if done.
    ///
    /// - Returns: The next directory entry, or nil if iteration is complete.
    /// - Throws: `File.Directory.Iterator.Error` on failure.
    public mutating func next() throws(Error) -> File.Directory.Entry? {
        #if os(Windows)
            return try _nextWindows()
        #else
            return try _nextPOSIX()
        #endif
    }

    /// Closes the iterator and releases resources.
    public consuming func close() {
        #if os(Windows)
            if let handle = _handle, handle != INVALID_HANDLE_VALUE {
                FindClose(handle)
                _handle = INVALID_HANDLE_VALUE
            }
        #elseif canImport(Darwin)
            if let dir = _dir {
                closedir(dir)
                _dir = nil
            }
        #elseif canImport(Glibc)
            if let dir = _dir {
                Glibc.closedir(dir)
                _dir = nil
            }
        #endif
    }
}

// MARK: - POSIX Implementation

#if canImport(Darwin)
    extension File.Directory.Iterator {
        private static func _openPOSIX(at path: File.Path) throws(Error) -> File.Directory.Iterator
        {
            // Verify it's a directory
            var statBuf = stat()
            guard stat(path.string, &statBuf) == 0 else {
                throw _mapErrno(errno, path: path)
            }

            guard (statBuf.st_mode & S_IFMT) == S_IFDIR else {
                throw .notADirectory(path)
            }

            guard let dir = opendir(path.string) else {
                throw _mapErrno(errno, path: path)
            }

            return File.Directory.Iterator(
                _dir: dir,
                _basePath: path
            )
        }

        private mutating func _nextPOSIX() throws(Error) -> File.Directory.Entry? {
            guard let dir = _dir else {
                return nil
            }

            while let entry = readdir(dir) {
                let name = String(posixDirectoryEntryName: entry.pointee.d_name)

                // Skip . and ..
                if name == "." || name == ".." {
                    continue
                }

                // Build full path using proper path composition
                let entryPath = _basePath.appending(name)

                // Determine type
                let entryType: File.Directory.EntryType
                switch Int32(entry.pointee.d_type) {
                case DT_REG:
                    entryType = .file
                case DT_DIR:
                    entryType = .directory
                case DT_LNK:
                    entryType = .symbolicLink
                default:
                    entryType = .other
                }

                return File.Directory.Entry(name: name, path: entryPath, type: entryType)
            }

            return nil
        }

        private static func _mapErrno(_ errno: Int32, path: File.Path) -> Error {
            switch errno {
            case ENOENT:
                return .pathNotFound(path)
            case EACCES, EPERM:
                return .permissionDenied(path)
            case ENOTDIR:
                return .notADirectory(path)
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
#elseif canImport(Glibc)
    extension File.Directory.Iterator {
        private static func _openPOSIX(at path: File.Path) throws(Error) -> File.Directory.Iterator
        {
            // Verify it's a directory
            var statBuf = stat()
            guard stat(path.string, &statBuf) == 0 else {
                throw _mapErrno(errno, path: path)
            }

            guard (statBuf.st_mode & S_IFMT) == S_IFDIR else {
                throw .notADirectory(path)
            }

            guard let dir = Glibc.opendir(path.string) else {
                throw _mapErrno(errno, path: path)
            }

            return File.Directory.Iterator(
                _dir: dir,
                _basePath: path
            )
        }

        private mutating func _nextPOSIX() throws(Error) -> File.Directory.Entry? {
            guard let dir = _dir else {
                return nil
            }

            while let entry = Glibc.readdir(dir) {
                let name = String(posixDirectoryEntryName: entry.pointee.d_name)

                // Skip . and ..
                if name == "." || name == ".." {
                    continue
                }

                // Build full path using proper path composition
                let entryPath = _basePath.appending(name)

                // Determine type via lstat (Glibc doesn't reliably expose d_type)
                let entryType: File.Directory.EntryType
                var entryStat = stat()
                if Glibc.lstat(entryPath.string, &entryStat) == 0 {
                    switch entryStat.st_mode & S_IFMT {
                    case S_IFREG:
                        entryType = .file
                    case S_IFDIR:
                        entryType = .directory
                    case S_IFLNK:
                        entryType = .symbolicLink
                    default:
                        entryType = .other
                    }
                } else {
                    entryType = .other
                }

                return File.Directory.Entry(name: name, path: entryPath, type: entryType)
            }

            return nil
        }

        private static func _mapErrno(_ errno: Int32, path: File.Path) -> Error {
            switch errno {
            case ENOENT:
                return .pathNotFound(path)
            case EACCES, EPERM:
                return .permissionDenied(path)
            case ENOTDIR:
                return .notADirectory(path)
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
    extension File.Directory.Iterator {
        private static func _openWindows(
            at path: File.Path
        ) throws(Error) -> File.Directory.Iterator {
            // Verify it's a directory
            let attrs = path.string.withCString(encodedAs: UTF16.self) { wpath in
                GetFileAttributesW(wpath)
            }

            guard attrs != INVALID_FILE_ATTRIBUTES else {
                throw .pathNotFound(path)
            }

            guard (attrs & FILE_ATTRIBUTE_DIRECTORY) != 0 else {
                throw .notADirectory(path)
            }

            var findData = WIN32_FIND_DATAW()
            let searchPath = path.string + "\\*"

            let handle = searchPath.withCString(encodedAs: UTF16.self) { wpath in
                FindFirstFileW(wpath, &findData)
            }

            guard handle != INVALID_HANDLE_VALUE else {
                throw _mapWindowsError(GetLastError(), path: path)
            }

            return File.Directory.Iterator(
                _handle: handle,
                _findData: findData,
                _hasMore: true,
                _basePath: path
            )
        }

        private mutating func _nextWindows() throws(Error) -> File.Directory.Entry? {
            guard let handle = _handle, handle != INVALID_HANDLE_VALUE, _hasMore else {
                return nil
            }

            while true {
                let name = String(windowsDirectoryEntryName: _findData.cFileName)

                // Advance to next entry for next call
                if !FindNextFileW(handle, &_findData) {
                    _hasMore = false
                }

                // Skip . and ..
                if name == "." || name == ".." {
                    if !_hasMore { return nil }
                    continue
                }

                // Build full path using proper path composition
                let entryPath = _basePath.appending(name)

                // Determine type (from previous findData)
                let entryType: File.Directory.EntryType
                if (_findData.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY) != 0 {
                    entryType = .directory
                } else if (_findData.dwFileAttributes & FILE_ATTRIBUTE_REPARSE_POINT) != 0 {
                    entryType = .symbolicLink
                } else {
                    entryType = .file
                }

                return File.Directory.Entry(name: name, path: entryPath, type: entryType)
            }
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

extension File.Directory.Iterator.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .pathNotFound(let path):
            return "Path not found: \(path)"
        case .permissionDenied(let path):
            return "Permission denied: \(path)"
        case .notADirectory(let path):
            return "Not a directory: \(path)"
        case .readFailed(let errno, let message):
            return "Read failed: \(message) (errno=\(errno))"
        }
    }
}
