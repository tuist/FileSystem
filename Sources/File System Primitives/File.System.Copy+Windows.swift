//
//  File.System.Copy+Windows.swift
//  swift-file-system
//
//  Created by Coen ten Thije Boonkkamp on 18/12/2025.
//

#if os(Windows)

    import WinSDK

    extension File.System.Copy {
        /// Copies a file using Windows APIs.
        internal static func _copyWindows(
            from source: File.Path,
            to destination: File.Path,
            options: Options
        ) throws(Error) {
            // Check if source exists and is not a directory
            let srcAttrs = source.string.withCString(encodedAs: UTF16.self) { wpath in
                GetFileAttributesW(wpath)
            }

            guard srcAttrs != INVALID_FILE_ATTRIBUTES else {
                throw .sourceNotFound(source)
            }

            if (srcAttrs & FILE_ATTRIBUTE_DIRECTORY) != 0 {
                throw .isDirectory(source)
            }

            // Check destination
            let dstAttrs = destination.string.withCString(encodedAs: UTF16.self) { wpath in
                GetFileAttributesW(wpath)
            }

            if dstAttrs != INVALID_FILE_ATTRIBUTES && !options.overwrite {
                throw .destinationExists(destination)
            }

            // Use CopyFileW for simple copy
            let failIfExists: BOOL = options.overwrite ? false : true

            let success = source.string.withCString(encodedAs: UTF16.self) { wsrc in
                destination.string.withCString(encodedAs: UTF16.self) { wdst in
                    CopyFileW(wsrc, wdst, failIfExists)
                }
            }

            guard success else {
                throw _mapWindowsError(GetLastError(), source: source, destination: destination)
            }
        }

        /// Maps Windows error to copy error.
        private static func _mapWindowsError(
            _ error: DWORD,
            source: File.Path,
            destination: File.Path
        ) -> Error {
            switch error {
            case DWORD(ERROR_FILE_NOT_FOUND), DWORD(ERROR_PATH_NOT_FOUND):
                return .sourceNotFound(source)
            case DWORD(ERROR_FILE_EXISTS), DWORD(ERROR_ALREADY_EXISTS):
                return .destinationExists(destination)
            case DWORD(ERROR_ACCESS_DENIED):
                return .permissionDenied(source)
            default:
                return .copyFailed(errno: Int32(error), message: "Windows error \(error)")
            }
        }
    }

#endif
