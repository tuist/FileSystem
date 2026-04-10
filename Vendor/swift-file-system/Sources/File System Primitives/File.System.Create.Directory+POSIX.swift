//
//  File.System.Create.Directory+POSIX.swift
//  swift-file-system
//
//  Created by Coen ten Thije Boonkkamp on 18/12/2025.
//

#if !os(Windows)

    #if canImport(Darwin)
        import Darwin
    #elseif canImport(Glibc)
        import Glibc
    #elseif canImport(Musl)
        import Musl
    #endif

    extension File.System.Create.Directory {
        /// Creates a directory using POSIX APIs.
        internal static func _createPOSIX(at path: File.Path, options: Options) throws(Error) {
            let mode =
                options.permissions?.rawValue
                ?? File.System.Metadata.Permissions.defaultDirectory.rawValue

            if options.createIntermediates {
                try _createIntermediates(at: path, mode: mode_t(mode))
            } else {
                guard mkdir(path.string, mode_t(mode)) == 0 else {
                    throw _mapErrno(errno, path: path)
                }
            }
        }

        /// Creates a directory and all intermediate directories.
        private static func _createIntermediates(at path: File.Path, mode: mode_t) throws(Error) {
            // Check if directory already exists
            var statBuf = stat()
            if stat(path.string, &statBuf) == 0 {
                if (statBuf.st_mode & S_IFMT) == S_IFDIR {
                    // Already exists as directory - success
                    return
                } else {
                    throw .alreadyExists(path)
                }
            }

            // Try to create parent directory first
            let pathString = path.string
            if let lastSlash = pathString.lastIndex(of: "/"), lastSlash != pathString.startIndex {
                let parentString = String(pathString[..<lastSlash])
                if !parentString.isEmpty {
                    if let parentPath = try? File.Path(parentString) {
                        try _createIntermediates(at: parentPath, mode: mode)
                    }
                }
            }

            // Now create this directory
            if mkdir(path.string, mode) != 0 {
                let error = errno
                // Check if it was created by another process/thread in the meantime
                if error == EEXIST {
                    if stat(path.string, &statBuf) == 0 && (statBuf.st_mode & S_IFMT) == S_IFDIR {
                        return
                    }
                }
                throw _mapErrno(error, path: path)
            }
        }

        /// Maps errno to create error.
        private static func _mapErrno(_ errno: Int32, path: File.Path) -> Error {
            switch errno {
            case EEXIST:
                return .alreadyExists(path)
            case EACCES, EPERM:
                return .permissionDenied(path)
            case ENOENT:
                return .parentDirectoryNotFound(path)
            default:
                let message: String
                if let cString = strerror(errno) {
                    message = String(cString: cString)
                } else {
                    message = "Unknown error"
                }
                return .createFailed(errno: errno, message: message)
            }
        }
    }

#endif
