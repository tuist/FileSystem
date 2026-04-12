//
//  File.System.Delete+POSIX.swift
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

    extension File.System.Delete {
        /// Deletes a file or directory using POSIX APIs.
        internal static func _deletePOSIX(at path: File.Path, options: Options) throws(Error) {
            // Use lstat so symlinks are removed as links instead of following targets.
            var statBuf = stat()
            guard lstat(path.string, &statBuf) == 0 else {
                throw _mapErrno(errno, path: path)
            }

            let isDir = (statBuf.st_mode & S_IFMT) == S_IFDIR

            if isDir {
                if options.recursive {
                    try _deleteDirectoryRecursive(at: path)
                } else {
                    // Try to remove empty directory
                    guard rmdir(path.string) == 0 else {
                        throw _mapErrno(errno, path: path)
                    }
                }
            } else {
                // Remove file
                guard unlink(path.string) == 0 else {
                    throw _mapErrno(errno, path: path)
                }
            }
        }

        /// Recursively deletes a directory and all its contents.
        private static func _deleteDirectoryRecursive(at path: File.Path) throws(Error) {
            // Open directory
            guard let dir = opendir(path.string) else {
                throw _mapErrno(errno, path: path)
            }
            defer { closedir(dir) }

            // Iterate through entries
            while let entry = readdir(dir) {
                let name = String(posixDirectoryEntryName: entry.pointee.d_name)

                // Skip . and ..
                if name == "." || name == ".." {
                    continue
                }

                // Construct full path using proper path composition
                let childPath = path.appending(name)

                // Use lstat so recursive delete unlinks symlinks instead of following them.
                var childStat = stat()
                guard lstat(childPath.string, &childStat) == 0 else {
                    throw _mapErrno(errno, path: childPath)
                }

                if (childStat.st_mode & S_IFMT) == S_IFDIR {
                    // Recursively delete subdirectory
                    try _deleteDirectoryRecursive(at: childPath)
                } else {
                    // Delete file
                    guard unlink(childPath.string) == 0 else {
                        throw _mapErrno(errno, path: childPath)
                    }
                }
            }

            // Now delete the empty directory
            guard rmdir(path.string) == 0 else {
                throw _mapErrno(errno, path: path)
            }
        }

        /// Maps errno to delete error.
        private static func _mapErrno(_ errno: Int32, path: File.Path) -> Error {
            switch errno {
            case ENOENT:
                return .pathNotFound(path)
            case EACCES, EPERM:
                return .permissionDenied(path)
            case EISDIR:
                return .isDirectory(path)
            case ENOTEMPTY:
                return .directoryNotEmpty(path)
            default:
                let message: String
                if let cString = strerror(errno) {
                    message = String(cString: cString)
                } else {
                    message = "Unknown error"
                }
                return .deleteFailed(errno: errno, message: message)
            }
        }
    }

#endif
