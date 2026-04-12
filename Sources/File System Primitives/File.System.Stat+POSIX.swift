//
//  File.System.Stat+POSIX.swift
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

    @_spi(Internal) import StandardTime

    extension File.System.Stat {
        /// Gets file info using POSIX stat (follows symlinks).
        internal static func _infoPOSIX(
            at path: File.Path
        ) throws(Error) -> File.System.Metadata.Info {
            var statBuf = stat()

            guard stat(path.string, &statBuf) == 0 else {
                throw _mapErrno(errno, path: path)
            }

            return _makeInfo(from: statBuf)
        }

        /// Gets file info using POSIX lstat (does not follow symlinks).
        ///
        /// Returns info about the symlink itself rather than its target.
        internal static func _lstatInfoPOSIX(
            at path: File.Path
        ) throws(Error) -> File.System.Metadata.Info {
            var statBuf = stat()

            guard lstat(path.string, &statBuf) == 0 else {
                throw _mapErrno(errno, path: path)
            }

            return _makeInfo(from: statBuf)
        }

        /// Checks if path exists using POSIX access.
        internal static func _existsPOSIX(at path: File.Path) -> Bool {
            access(path.string, F_OK) == 0
        }

        /// Checks if path is a symlink using POSIX lstat.
        internal static func _isSymlinkPOSIX(at path: File.Path) -> Bool {
            var statBuf = stat()
            guard lstat(path.string, &statBuf) == 0 else {
                return false
            }
            return (statBuf.st_mode & S_IFMT) == S_IFLNK
        }

        /// Creates Info from stat buffer.
        private static func _makeInfo(from statBuf: stat) -> File.System.Metadata.Info {
            let fileType: File.System.Metadata.FileType
            switch statBuf.st_mode & S_IFMT {
            case S_IFREG:
                fileType = .regular
            case S_IFDIR:
                fileType = .directory
            case S_IFLNK:
                fileType = .symbolicLink
            case S_IFBLK:
                fileType = .blockDevice
            case S_IFCHR:
                fileType = .characterDevice
            case S_IFIFO:
                fileType = .fifo
            case S_IFSOCK:
                fileType = .socket
            default:
                fileType = .regular
            }

            let permissions = File.System.Metadata.Permissions(
                rawValue: UInt16(statBuf.st_mode & 0o7777)
            )

            let ownership = File.System.Metadata.Ownership(
                uid: statBuf.st_uid,
                gid: statBuf.st_gid
            )

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
                let timestamps = File.System.Metadata.Timestamps(
                    accessTime: accessTime,
                    modificationTime: modificationTime,
                    changeTime: changeTime,
                    creationTime: creationTime
                )
            #else
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
                let timestamps = File.System.Metadata.Timestamps(
                    accessTime: accessTime,
                    modificationTime: modificationTime,
                    changeTime: changeTime,
                    creationTime: nil
                )
            #endif

            return File.System.Metadata.Info(
                size: Int64(statBuf.st_size),
                permissions: permissions,
                owner: ownership,
                timestamps: timestamps,
                type: fileType,
                inode: UInt64(statBuf.st_ino),
                deviceId: UInt64(statBuf.st_dev),
                linkCount: UInt32(statBuf.st_nlink)
            )
        }

        /// Maps errno to stat error.
        internal static func _mapErrno(_ errno: Int32, path: File.Path) -> Error {
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
                return .statFailed(errno: errno, message: message)
            }
        }
    }

#endif
