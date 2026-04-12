//
//  File.System.Metadata.Timestamps.swift
//  swift-file-system
//
//  Created by Coen ten Thije Boonkkamp on 17/12/2025.
//

@_spi(Internal) import StandardTime

#if canImport(Darwin)
    import Darwin
#elseif canImport(Glibc)
    import Glibc
#elseif canImport(Musl)
    import Musl
#elseif os(Windows)
    import WinSDK
#endif

extension File.System.Metadata {
    /// File timestamp information.
    ///
    /// Contains access, modification, change, and optionally creation times
    /// using `Time` from StandardTime for type-safe calendar representation.
    public struct Timestamps: Sendable, Equatable {
        /// Last access time.
        public var accessTime: Time

        /// Last modification time.
        public var modificationTime: Time

        /// Status change time (ctime on POSIX, same as modification on Windows).
        public var changeTime: Time

        /// Creation time (birthtime), if available.
        ///
        /// Available on macOS and Windows. Returns `nil` on Linux.
        public var creationTime: Time?

        public init(
            accessTime: Time,
            modificationTime: Time,
            changeTime: Time,
            creationTime: Time? = nil
        ) {
            self.accessTime = accessTime
            self.modificationTime = modificationTime
            self.changeTime = changeTime
            self.creationTime = creationTime
        }
    }
}

// MARK: - Error

extension File.System.Metadata.Timestamps {
    /// Errors that can occur during timestamp operations.
    public enum Error: Swift.Error, Equatable, Sendable {
        case pathNotFound(File.Path)
        case permissionDenied(File.Path)
        case operationFailed(errno: Int32, message: String)
    }
}

// MARK: - Get/Set API

extension File.System.Metadata.Timestamps {
    /// Gets the timestamps of a file.
    ///
    /// - Parameter path: The path to the file.
    /// - Returns: The file timestamps.
    /// - Throws: `File.System.Metadata.Timestamps.Error` on failure.
    public static func get(at path: File.Path) throws(Error) -> Self {
        #if os(Windows)
            return try _getWindows(path)
        #else
            return try _getPOSIX(path)
        #endif
    }

    /// Sets the timestamps of a file.
    ///
    /// Only access and modification times can be set. Change time is
    /// automatically updated by the system.
    ///
    /// - Parameters:
    ///   - timestamps: The timestamps to set.
    ///   - path: The path to the file.
    /// - Throws: `File.System.Metadata.Timestamps.Error` on failure.
    public static func set(_ timestamps: Self, at path: File.Path) throws(Error) {
        #if os(Windows)
            try _setWindows(timestamps, at: path)
        #else
            try _setPOSIX(timestamps, at: path)
        #endif
    }

}

// MARK: - POSIX Implementation

#if !os(Windows)
    extension File.System.Metadata.Timestamps {
        internal static func _getPOSIX(_ path: File.Path) throws(Error) -> Self {
            var statBuf = stat()
            guard stat(path.string, &statBuf) == 0 else {
                throw _mapErrno(errno, path: path)
            }

            #if canImport(Darwin)
                let accessTime = Time(
                    __unchecked: (),
                    secondsSinceEpoch: Int(statBuf.st_atimespec.tv_sec),
                    nanoseconds: Int(statBuf.st_atimespec.tv_nsec)
                )
                let modificationTime = Time(
                    __unchecked: (),
                    secondsSinceEpoch: Int(statBuf.st_mtimespec.tv_sec),
                    nanoseconds: Int(statBuf.st_mtimespec.tv_nsec)
                )
                let changeTime = Time(
                    __unchecked: (),
                    secondsSinceEpoch: Int(statBuf.st_ctimespec.tv_sec),
                    nanoseconds: Int(statBuf.st_ctimespec.tv_nsec)
                )
                let creationTime = Time(
                    __unchecked: (),
                    secondsSinceEpoch: Int(statBuf.st_birthtimespec.tv_sec),
                    nanoseconds: Int(statBuf.st_birthtimespec.tv_nsec)
                )
                return Self(
                    accessTime: accessTime,
                    modificationTime: modificationTime,
                    changeTime: changeTime,
                    creationTime: creationTime
                )
            #else
                // Linux: no birthtime
                let accessTime = Time(
                    __unchecked: (),
                    secondsSinceEpoch: Int(statBuf.st_atim.tv_sec),
                    nanoseconds: Int(statBuf.st_atim.tv_nsec)
                )
                let modificationTime = Time(
                    __unchecked: (),
                    secondsSinceEpoch: Int(statBuf.st_mtim.tv_sec),
                    nanoseconds: Int(statBuf.st_mtim.tv_nsec)
                )
                let changeTime = Time(
                    __unchecked: (),
                    secondsSinceEpoch: Int(statBuf.st_ctim.tv_sec),
                    nanoseconds: Int(statBuf.st_ctim.tv_nsec)
                )
                return Self(
                    accessTime: accessTime,
                    modificationTime: modificationTime,
                    changeTime: changeTime,
                    creationTime: nil
                )
            #endif
        }

        internal static func _setPOSIX(_ timestamps: Self, at path: File.Path) throws(Error) {
            var times = [timespec](repeating: timespec(), count: 2)

            // Access time
            times[0].tv_sec = time_t(timestamps.accessTime.secondsSinceEpoch)
            times[0].tv_nsec = Int(timestamps.accessTime.totalNanoseconds)

            // Modification time
            times[1].tv_sec = time_t(timestamps.modificationTime.secondsSinceEpoch)
            times[1].tv_nsec = Int(timestamps.modificationTime.totalNanoseconds)

            guard utimensat(AT_FDCWD, path.string, &times, 0) == 0 else {
                throw _mapErrno(errno, path: path)
            }
        }

        private static func _mapErrno(_ errno: Int32, path: File.Path) -> Error {
            switch errno {
            case ENOENT:
                return .pathNotFound(path)
            case EACCES, EPERM:
                return .permissionDenied(path)
            default:
                let message: String
                if let cString = strerror(errno) {
                    message = String(cString: cString)
                } else {
                    message = "Unknown error"
                }
                return .operationFailed(errno: errno, message: message)
            }
        }
    }
#endif

// MARK: - Windows Implementation

#if os(Windows)
    extension File.System.Metadata.Timestamps {
        internal static func _getWindows(_ path: File.Path) throws(Error) -> Self {
            let handle = path.string.withCString(encodedAs: UTF16.self) { wpath in
                CreateFileW(
                    wpath,
                    FILE_READ_ATTRIBUTES,
                    FILE_SHARE_READ | FILE_SHARE_WRITE,
                    nil,
                    OPEN_EXISTING,
                    FILE_ATTRIBUTE_NORMAL,
                    nil
                )
            }

            guard let handle = handle, handle != INVALID_HANDLE_VALUE else {
                throw _mapWindowsError(GetLastError(), path: path)
            }
            defer { CloseHandle(handle) }

            var creationFT = FILETIME()
            var accessFT = FILETIME()
            var writeFT = FILETIME()

            guard GetFileTime(handle, &creationFT, &accessFT, &writeFT) else {
                throw _mapWindowsError(GetLastError(), path: path)
            }

            let creation = _fileTimeToTime(creationFT)
            let access = _fileTimeToTime(accessFT)
            let modification = _fileTimeToTime(writeFT)

            return Self(
                accessTime: access,
                modificationTime: modification,
                changeTime: modification,  // Windows doesn't have ctime
                creationTime: creation
            )
        }

        internal static func _setWindows(_ timestamps: Self, at path: File.Path) throws(Error) {
            let handle = path.string.withCString(encodedAs: UTF16.self) { wpath in
                CreateFileW(
                    wpath,
                    FILE_WRITE_ATTRIBUTES,
                    FILE_SHARE_READ | FILE_SHARE_WRITE,
                    nil,
                    OPEN_EXISTING,
                    FILE_ATTRIBUTE_NORMAL,
                    nil
                )
            }

            guard let handle = handle, handle != INVALID_HANDLE_VALUE else {
                throw _mapWindowsError(GetLastError(), path: path)
            }
            defer { CloseHandle(handle) }

            var accessFT = _timeToFileTime(timestamps.accessTime)
            var writeFT = _timeToFileTime(timestamps.modificationTime)

            // Pass nil for creation time to leave it unchanged
            guard SetFileTime(handle, nil, &accessFT, &writeFT) else {
                throw _mapWindowsError(GetLastError(), path: path)
            }
        }

        /// Converts Windows FILETIME to Time.
        ///
        /// FILETIME is 100-nanosecond intervals since 1601-01-01.
        private static func _fileTimeToTime(_ ft: FILETIME) -> Time {
            // FILETIME is 100-nanosecond intervals since January 1, 1601
            // Unix epoch is January 1, 1970
            let intervals = Int64(ft.dwHighDateTime) << 32 | Int64(ft.dwLowDateTime)
            let unixIntervals = intervals - 116_444_736_000_000_000  // Difference between 1601 and 1970 in 100ns
            let seconds = Int(unixIntervals / 10_000_000)
            let nanoseconds = Int((unixIntervals % 10_000_000) * 100)
            return Time(__unchecked: (), secondsSinceEpoch: seconds, nanoseconds: nanoseconds)
        }

        /// Converts Time to Windows FILETIME.
        private static func _timeToFileTime(_ time: Time) -> FILETIME {
            let seconds = Int64(time.secondsSinceEpoch)
            let nanoseconds = Int64(time.totalNanoseconds)
            let intervals = (seconds * 10_000_000) + (nanoseconds / 100) + 116_444_736_000_000_000
            return FILETIME(
                dwLowDateTime: DWORD(intervals & 0xFFFF_FFFF),
                dwHighDateTime: DWORD((intervals >> 32) & 0xFFFF_FFFF)
            )
        }

        private static func _mapWindowsError(_ error: DWORD, path: File.Path) -> Error {
            switch error {
            case DWORD(ERROR_FILE_NOT_FOUND), DWORD(ERROR_PATH_NOT_FOUND):
                return .pathNotFound(path)
            case DWORD(ERROR_ACCESS_DENIED):
                return .permissionDenied(path)
            default:
                return .operationFailed(errno: Int32(error), message: "Windows error \(error)")
            }
        }
    }
#endif

// MARK: - CustomStringConvertible for Error

extension File.System.Metadata.Timestamps.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .pathNotFound(let path):
            return "Path not found: \(path)"
        case .permissionDenied(let path):
            return "Permission denied: \(path)"
        case .operationFailed(let errno, let message):
            return "Operation failed: \(message) (errno=\(errno))"
        }
    }
}
