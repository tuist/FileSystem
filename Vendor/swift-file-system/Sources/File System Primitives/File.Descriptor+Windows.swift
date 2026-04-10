//
//  File.Descriptor+Windows.swift
//  swift-file-system
//
//  Created by Coen ten Thije Boonkkamp on 18/12/2025.
//

#if os(Windows)

    import WinSDK

    extension File.Descriptor {
        /// Opens a file using Windows APIs.
        @usableFromInline
        internal static func _openWindows(
            _ path: File.Path,
            mode: Mode,
            options: Options
        ) throws(Error) -> File.Descriptor {
            var desiredAccess: DWORD = 0
            // Include FILE_SHARE_DELETE for POSIX-like rename/unlink semantics
            var shareMode: DWORD = FILE_SHARE_READ | FILE_SHARE_WRITE | FILE_SHARE_DELETE
            var creationDisposition: DWORD = OPEN_EXISTING
            var flagsAndAttributes: DWORD = FILE_ATTRIBUTE_NORMAL

            // Set access mode
            switch mode {
            case .read:
                desiredAccess = GENERIC_READ
            case .write:
                desiredAccess = GENERIC_WRITE
            case .readWrite:
                desiredAccess = GENERIC_READ | GENERIC_WRITE
            }

            // Set creation disposition based on options
            if options.contains(.create) {
                if options.contains(.exclusive) {
                    creationDisposition = CREATE_NEW
                } else if options.contains(.truncate) {
                    creationDisposition = CREATE_ALWAYS
                } else {
                    creationDisposition = OPEN_ALWAYS
                }
            } else if options.contains(.truncate) {
                creationDisposition = TRUNCATE_EXISTING
            }

            // Append mode - combine with existing access, don't clobber
            if options.contains(.append) {
                desiredAccess |= FILE_APPEND_DATA
            }

            // No follow symlinks
            if options.contains(.noFollow) {
                flagsAndAttributes |= FILE_FLAG_OPEN_REPARSE_POINT
            }

            let handle = path.string.withCString(encodedAs: UTF16.self) { wpath in
                CreateFileW(
                    wpath,
                    desiredAccess,
                    shareMode,
                    nil,
                    creationDisposition,
                    flagsAndAttributes,
                    nil
                )
            }

            guard let handle = handle, handle != INVALID_HANDLE_VALUE else {
                throw _mapWindowsError(GetLastError(), path: path)
            }

            // Close on exec - prevent handle inheritance
            if options.contains(.closeOnExec) {
                guard SetHandleInformation(handle, DWORD(HANDLE_FLAG_INHERIT), 0) else {
                    let error = GetLastError()
                    CloseHandle(handle)
                    throw .openFailed(
                        errno: Int32(error),
                        message: "SetHandleInformation failed: \(_formatWindowsError(error))"
                    )
                }
            }

            return File.Descriptor(__unchecked: handle)
        }

        /// Maps Windows error code to a descriptor error.
        @usableFromInline
        internal static func _mapWindowsError(_ error: DWORD, path: File.Path) -> Error {
            switch error {
            case DWORD(ERROR_FILE_NOT_FOUND), DWORD(ERROR_PATH_NOT_FOUND):
                return .pathNotFound(path)
            case DWORD(ERROR_ACCESS_DENIED):
                return .permissionDenied(path)
            case DWORD(ERROR_FILE_EXISTS), DWORD(ERROR_ALREADY_EXISTS):
                return .alreadyExists(path)
            case DWORD(ERROR_TOO_MANY_OPEN_FILES):
                return .tooManyOpenFiles
            default:
                return .openFailed(errno: Int32(error), message: _formatWindowsError(error))
            }
        }

        /// Formats a Windows error code into a human-readable message.
        @usableFromInline
        internal static func _formatWindowsError(_ errorCode: DWORD) -> String {
            var buffer: LPWSTR? = nil
            let length = FormatMessageW(
                DWORD(
                    FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM
                        | FORMAT_MESSAGE_IGNORE_INSERTS
                ),
                nil,
                errorCode,
                0,
                &buffer,
                0,
                nil
            )
            guard length > 0, let buffer = buffer else {
                return "Windows error \(errorCode)"
            }
            defer { LocalFree(buffer) }
            return String(decodingCString: buffer, as: UTF16.self)
                .trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }

#endif
