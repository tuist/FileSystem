//
//  File.System.Write.Append.swift
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

extension File.System.Write {
    /// Append data to existing files.
    public enum Append {}
}

// MARK: - Error

extension File.System.Write.Append {
    /// Errors that can occur during append operations.
    public enum Error: Swift.Error, Equatable, Sendable {
        case pathNotFound(File.Path)
        case permissionDenied(File.Path)
        case isDirectory(File.Path)
        case writeFailed(errno: Int32, message: String)
    }
}

// MARK: - Core API

extension File.System.Write.Append {
    /// Appends bytes to a file.
    ///
    /// Creates the file if it doesn't exist.
    ///
    /// - Parameters:
    ///   - bytes: The bytes to append.
    ///   - path: The file path.
    /// - Throws: `File.System.Write.Append.Error` on failure.
    public static func append(
        _ bytes: borrowing Span<UInt8>,
        to path: File.Path
    ) throws(Error) {
        #if os(Windows)
            try _appendWindows(bytes, to: path)
        #else
            try _appendPOSIX(bytes, to: path)
        #endif
    }

}

// MARK: - Binary.Serializable

extension File.System.Write.Append {
    /// Appends a Binary.Serializable value to a file.
    ///
    /// - Parameters:
    ///   - value: The serializable value to append.
    ///   - path: The file path.
    /// - Throws: `File.System.Write.Append.Error` on failure.
    public static func append<S: Binary.Serializable>(
        _ value: S,
        to path: File.Path
    ) throws(Error) {
        try S.withSerializedBytes(value) { (span: borrowing Span<UInt8>) throws(Error) in
            try append(span, to: path)
        }
    }

}

// MARK: - POSIX Implementation

#if !os(Windows)
    extension File.System.Write.Append {
        internal static func _appendPOSIX(
            _ bytes: borrowing Span<UInt8>,
            to path: File.Path
        ) throws(Error) {
            let fd = open(path.string, O_WRONLY | O_CREAT | O_APPEND, 0o644)
            guard fd >= 0 else {
                throw _mapErrno(errno, path: path)
            }
            defer { _ = close(fd) }

            let count = bytes.count
            if count == 0 { return }

            try bytes.withUnsafeBufferPointer { buffer throws(Error) in
                guard let base = buffer.baseAddress else { return }

                var written = 0
                while written < count {
                    let remaining = count - written
                    #if canImport(Darwin)
                        let w = Darwin.write(fd, base.advanced(by: written), remaining)
                    #elseif canImport(Glibc)
                        let w = Glibc.write(fd, base.advanced(by: written), remaining)
                    #endif

                    if w > 0 {
                        written += w
                    } else if w < 0 {
                        if errno == EINTR { continue }
                        throw _mapErrno(errno, path: path)
                    }
                }
            }
        }

        private static func _mapErrno(_ errno: Int32, path: File.Path) -> Error {
            switch errno {
            case ENOENT:
                return .pathNotFound(path)
            case EACCES, EPERM:
                return .permissionDenied(path)
            case EISDIR:
                return .isDirectory(path)
            default:
                let message: String
                if let cString = strerror(errno) {
                    message = String(cString: cString)
                } else {
                    message = "Unknown error"
                }
                return .writeFailed(errno: errno, message: message)
            }
        }
    }
#endif

// MARK: - Windows Implementation

#if os(Windows)
    extension File.System.Write.Append {
        internal static func _appendWindows(
            _ bytes: borrowing Span<UInt8>,
            to path: File.Path
        ) throws(Error) {
            let handle = path.string.withCString(encodedAs: UTF16.self) { wpath in
                CreateFileW(
                    wpath,
                    FILE_APPEND_DATA,
                    FILE_SHARE_READ,
                    nil,
                    OPEN_ALWAYS,
                    FILE_ATTRIBUTE_NORMAL,
                    nil
                )
            }

            guard let handle = handle, handle != INVALID_HANDLE_VALUE else {
                throw _mapWindowsError(GetLastError(), path: path)
            }
            defer { CloseHandle(handle) }

            let count = bytes.count
            if count == 0 { return }

            try bytes.withUnsafeBufferPointer { buffer throws(Error) in
                guard let base = buffer.baseAddress else { return }

                var written: DWORD = 0
                let success = WriteFile(
                    handle,
                    base,
                    DWORD(count),
                    &written,
                    nil
                )

                guard success && written == count else {
                    throw _mapWindowsError(GetLastError(), path: path)
                }
            }
        }

        private static func _mapWindowsError(_ error: DWORD, path: File.Path) -> Error {
            switch error {
            case DWORD(ERROR_FILE_NOT_FOUND), DWORD(ERROR_PATH_NOT_FOUND):
                return .pathNotFound(path)
            case DWORD(ERROR_ACCESS_DENIED):
                return .permissionDenied(path)
            default:
                return .writeFailed(errno: Int32(error), message: "Windows error \(error)")
            }
        }
    }
#endif

// MARK: - CustomStringConvertible for Error

extension File.System.Write.Append.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .pathNotFound(let path):
            return "Path not found: \(path)"
        case .permissionDenied(let path):
            return "Permission denied: \(path)"
        case .isDirectory(let path):
            return "Is a directory: \(path)"
        case .writeFailed(let errno, let message):
            return "Write failed: \(message) (errno=\(errno))"
        }
    }
}
