//
//  File.System.Delete+Windows.swift
//  swift-file-system
//
//  Created by Coen ten Thije Boonkkamp on 18/12/2025.
//

#if os(Windows)

    import WinSDK

    extension File.System.Delete {
        /// Deletes a file or directory using Windows APIs.
        internal static func _deleteWindows(at path: File.Path, options: Options) throws(Error) {
            // Get file attributes to determine type
            let attrs = path.string.withCString(encodedAs: UTF16.self) { wpath in
                GetFileAttributesW(wpath)
            }

            guard attrs != INVALID_FILE_ATTRIBUTES else {
                throw _mapWindowsError(GetLastError(), path: path)
            }

            let isDir = (attrs & FILE_ATTRIBUTE_DIRECTORY) != 0

            if isDir {
                if options.recursive {
                    try _deleteDirectoryRecursive(at: path)
                } else {
                    // Try to remove empty directory
                    let success = path.string.withCString(encodedAs: UTF16.self) { wpath in
                        RemoveDirectoryW(wpath)
                    }
                    guard success else {
                        throw _mapWindowsError(GetLastError(), path: path)
                    }
                }
            } else {
                // Remove file
                let success = path.string.withCString(encodedAs: UTF16.self) { wpath in
                    DeleteFileW(wpath)
                }
                guard success else {
                    throw _mapWindowsError(GetLastError(), path: path)
                }
            }
        }

        /// Recursively deletes a directory and all its contents.
        private static func _deleteDirectoryRecursive(at path: File.Path) throws(Error) {
            var findData = WIN32_FIND_DATAW()
            let searchPath = path.string + "\\*"

            let handle = searchPath.withCString(encodedAs: UTF16.self) { wpath in
                FindFirstFileW(wpath, &findData)
            }

            guard handle != INVALID_HANDLE_VALUE else {
                throw _mapWindowsError(GetLastError(), path: path)
            }

            defer { FindClose(handle) }

            repeat {
                let name = String(windowsDirectoryEntryName: findData.cFileName)

                // Skip . and ..
                if name == "." || name == ".." {
                    continue
                }

                // Construct full path using proper path composition
                let childPath = path.appending(name)

                let isChildDir = (findData.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY) != 0

                if isChildDir {
                    // Recursively delete subdirectory
                    try _deleteDirectoryRecursive(at: childPath)
                } else {
                    // Delete file
                    let success = childPath.string.withCString(encodedAs: UTF16.self) { wpath in
                        DeleteFileW(wpath)
                    }
                    guard success else {
                        throw _mapWindowsError(GetLastError(), path: childPath)
                    }
                }
            } while FindNextFileW(handle, &findData)

            // Check if we stopped due to error or end of directory
            let lastError = GetLastError()
            if lastError != DWORD(ERROR_NO_MORE_FILES) {
                throw _mapWindowsError(lastError, path: path)
            }

            // Now delete the empty directory
            let success = path.string.withCString(encodedAs: UTF16.self) { wpath in
                RemoveDirectoryW(wpath)
            }
            guard success else {
                throw _mapWindowsError(GetLastError(), path: path)
            }
        }

        /// Maps Windows error to delete error.
        private static func _mapWindowsError(_ error: DWORD, path: File.Path) -> Error {
            switch error {
            case DWORD(ERROR_FILE_NOT_FOUND), DWORD(ERROR_PATH_NOT_FOUND):
                return .pathNotFound(path)
            case DWORD(ERROR_ACCESS_DENIED):
                return .permissionDenied(path)
            case DWORD(ERROR_DIR_NOT_EMPTY):
                return .directoryNotEmpty(path)
            default:
                return .deleteFailed(errno: Int32(error), message: "Windows error \(error)")
            }
        }
    }

#endif
