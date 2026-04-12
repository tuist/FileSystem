//
//  File.System.Read.Full+Windows.swift
//  swift-file-system
//
//  Created by Coen ten Thije Boonkkamp on 18/12/2025.
//

#if os(Windows)

    import WinSDK

    extension File.System.Read.Full {
        /// Reads file contents using Windows APIs.
        internal static func _readWindows(from path: File.Path) throws(Error) -> [UInt8] {
            // Open file for reading
            let handle = path.string.withCString(encodedAs: UTF16.self) { wpath in
                CreateFileW(
                    wpath,
                    GENERIC_READ,
                    FILE_SHARE_READ,
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

            // Get file size
            var fileSize: LARGE_INTEGER = LARGE_INTEGER()
            guard GetFileSizeEx(handle, &fileSize) else {
                throw _mapWindowsError(GetLastError(), path: path)
            }

            let size = Int(fileSize.QuadPart)

            // Handle empty file
            if size == 0 {
                return []
            }

            // Allocate buffer and read
            var buffer = [UInt8](repeating: 0, count: size)
            var totalRead: DWORD = 0

            let success = buffer.withUnsafeMutableBufferPointer { ptr in
                ReadFile(
                    handle,
                    ptr.baseAddress,
                    DWORD(size),
                    &totalRead,
                    nil
                )
            }

            guard success else {
                throw _mapWindowsError(GetLastError(), path: path)
            }

            // Trim buffer if we read less than expected
            if Int(totalRead) < size {
                buffer.removeLast(size - Int(totalRead))
            }

            return buffer
        }

        /// Maps Windows error to read error.
        private static func _mapWindowsError(_ error: DWORD, path: File.Path) -> Error {
            switch error {
            case DWORD(ERROR_FILE_NOT_FOUND), DWORD(ERROR_PATH_NOT_FOUND):
                return .pathNotFound(path)
            case DWORD(ERROR_ACCESS_DENIED):
                return .permissionDenied(path)
            case DWORD(ERROR_TOO_MANY_OPEN_FILES):
                return .tooManyOpenFiles
            default:
                return .readFailed(errno: Int32(error), message: "Windows error \(error)")
            }
        }
    }

#endif
