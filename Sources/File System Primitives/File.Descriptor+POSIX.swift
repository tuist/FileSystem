//
//  File.Descriptor+POSIX.swift
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

    extension File.Descriptor {
        /// Opens a file using POSIX APIs.
        @usableFromInline
        internal static func _openPOSIX(
            _ path: File.Path,
            mode: Mode,
            options: Options
        ) throws(Error) -> File.Descriptor {
            var flags: Int32 = 0

            // Set access mode
            switch mode {
            case .read:
                flags |= O_RDONLY
            case .write:
                flags |= O_WRONLY
            case .readWrite:
                flags |= O_RDWR
            }

            // Set options
            if options.contains(.create) {
                flags |= O_CREAT
            }
            if options.contains(.truncate) {
                flags |= O_TRUNC
            }
            if options.contains(.exclusive) {
                flags |= O_EXCL
            }
            if options.contains(.append) {
                flags |= O_APPEND
            }
            #if canImport(Darwin) || canImport(Glibc) || canImport(Musl)
                if options.contains(.noFollow) {
                    flags |= O_NOFOLLOW
                }
            #endif
            #if canImport(Darwin)
                if options.contains(.closeOnExec) {
                    flags |= O_CLOEXEC
                }
            #elseif canImport(Glibc) || canImport(Musl)
                if options.contains(.closeOnExec) {
                    flags |= O_CLOEXEC
                }
            #endif

            // Default permissions for new files: 0644
            let defaultMode: mode_t = S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH

            #if canImport(Darwin)
                let fd = Darwin.open(path.string, flags, defaultMode)
            #elseif canImport(Glibc)
                let fd = Glibc.open(path.string, flags, defaultMode)
            #elseif canImport(Musl)
                let fd = Musl.open(path.string, flags, defaultMode)
            #endif

            guard fd >= 0 else {
                throw _mapErrno(errno, path: path)
            }

            return File.Descriptor(__unchecked: fd)
        }

        /// Maps errno to a descriptor error.
        @usableFromInline
        internal static func _mapErrno(_ errno: Int32, path: File.Path) -> Error {
            switch errno {
            case ENOENT:
                return .pathNotFound(path)
            case EACCES, EPERM:
                return .permissionDenied(path)
            case EEXIST:
                return .alreadyExists(path)
            case EISDIR:
                return .isDirectory(path)
            case EMFILE, ENFILE:
                return .tooManyOpenFiles
            default:
                let message: String
                if let cString = strerror(errno) {
                    message = String(cString: cString)
                } else {
                    message = "Unknown error"
                }
                return .openFailed(errno: errno, message: message)
            }
        }
    }

#endif
