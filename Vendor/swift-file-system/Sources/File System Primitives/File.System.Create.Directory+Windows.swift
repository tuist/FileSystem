//
//  File.System.Create.Directory+Windows.swift
//  swift-file-system
//
//  Created by Coen ten Thije Boonkkamp on 18/12/2025.
//

#if os(Windows)

    import WinSDK

    extension File.System.Create.Directory {
        /// Creates a directory using Windows APIs.
        internal static func _createWindows(at path: File.Path, options: Options) throws(Error) {
            if options.createIntermediates {
                try _createIntermediates(at: path)
            } else {
                let success = path.string.withCString(encodedAs: UTF16.self) { wpath in
                    CreateDirectoryW(wpath, nil)
                }
                guard success else {
                    throw _mapWindowsError(GetLastError(), path: path)
                }
            }
        }

        /// Creates a directory and all intermediate directories.
        private static func _createIntermediates(at path: File.Path) throws(Error) {
            // Check if directory already exists
            let attrs = path.string.withCString(encodedAs: UTF16.self) { wpath in
                GetFileAttributesW(wpath)
            }

            if attrs != INVALID_FILE_ATTRIBUTES {
                if (attrs & FILE_ATTRIBUTE_DIRECTORY) != 0 {
                    // Already exists as directory - success
                    return
                } else {
                    throw .alreadyExists(path)
                }
            }

            // Try to create parent directory first
            let pathString = path.string
            if let lastSlash = pathString.lastIndex(where: { $0 == "/" || $0 == "\\" }),
                lastSlash != pathString.startIndex
            {
                let parentString = String(pathString[..<lastSlash])
                if !parentString.isEmpty && !parentString.hasSuffix(":") {
                    if let parentPath = try? File.Path(parentString) {
                        try _createIntermediates(at: parentPath)
                    }
                }
            }

            // Now create this directory
            let success = path.string.withCString(encodedAs: UTF16.self) { wpath in
                CreateDirectoryW(wpath, nil)
            }

            if !success {
                let error = GetLastError()
                // Check if it was created by another process/thread in the meantime
                if error == DWORD(ERROR_ALREADY_EXISTS) {
                    let attrs = path.string.withCString(encodedAs: UTF16.self) { wpath in
                        GetFileAttributesW(wpath)
                    }
                    if attrs != INVALID_FILE_ATTRIBUTES && (attrs & FILE_ATTRIBUTE_DIRECTORY) != 0 {
                        return
                    }
                }
                throw _mapWindowsError(error, path: path)
            }
        }

        /// Maps Windows error to create error.
        private static func _mapWindowsError(_ error: DWORD, path: File.Path) -> Error {
            switch error {
            case DWORD(ERROR_ALREADY_EXISTS), DWORD(ERROR_FILE_EXISTS):
                return .alreadyExists(path)
            case DWORD(ERROR_ACCESS_DENIED):
                return .permissionDenied(path)
            case DWORD(ERROR_PATH_NOT_FOUND):
                return .parentDirectoryNotFound(path)
            default:
                return .createFailed(errno: Int32(error), message: "Windows error \(error)")
            }
        }
    }

#endif
