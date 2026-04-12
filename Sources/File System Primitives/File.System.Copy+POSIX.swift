//
//  File.System.Copy+POSIX.swift
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

    extension File.System.Copy {
        /// Copies a file using POSIX APIs with kernel-assisted fast paths.
        ///
        /// ## Fallback Ladder
        /// - **Darwin**: copyfile(CLONE_FORCE) → copyfile(ALL/DATA) → manual loop
        /// - **Linux**: sendfile → manual loop
        /// - **Other POSIX**: manual loop only
        internal static func _copyPOSIX(
            from source: File.Path,
            to destination: File.Path,
            options: Options
        ) throws(Error) {
            // Stat source (lstat when not following symlinks)
            var sourceStat = stat()
            let statResult: Int32
            if options.followSymlinks {
                statResult = stat(source.string, &sourceStat)
            } else {
                statResult = lstat(source.string, &sourceStat)
            }

            guard statResult == 0 else {
                throw _mapErrno(errno, source: source, destination: destination)
            }

            // Check if source is a directory
            if (sourceStat.st_mode & S_IFMT) == S_IFDIR {
                throw .isDirectory(source)
            }

            // Check if source is a symlink and we're not following
            let sourceIsSymlink = (sourceStat.st_mode & S_IFMT) == S_IFLNK

            // Check if destination exists (use lstat to detect symlinks)
            var destStat = stat()
            let destExists = lstat(destination.string, &destStat) == 0

            if destExists {
                if !options.overwrite {
                    throw .destinationExists(destination)
                }
                // Cannot overwrite a directory
                if (destStat.st_mode & S_IFMT) == S_IFDIR {
                    throw .isDirectory(destination)
                }
                // Unlink destination before copy to replace directory entry
                // This is critical: without this, writing to a symlink writes through to target
                _ = unlink(destination.string)
            }

            // Handle symlink copying when followSymlinks=false
            if !options.followSymlinks && sourceIsSymlink {
                try _copySymlink(from: source, to: destination)
                return
            }

            // Darwin: try kernel-assisted copy first (before opening fds)
            // Note: We only use the fast path when copyAttributes is true, because
            // copyfile() always copies permissions even with COPYFILE_DATA only
            #if canImport(Darwin)
                if options.copyAttributes {
                    if _copyDarwinFast(from: source, to: destination, options: options) {
                        return
                    }
                }
            #endif

            // Open source for reading
            let srcFd = open(source.string, O_RDONLY)
            guard srcFd >= 0 else {
                throw _mapErrno(errno, source: source, destination: destination)
            }
            defer { _ = close(srcFd) }

            // Create/truncate destination
            let dstFlags: Int32 = O_WRONLY | O_CREAT | O_TRUNC
            // When copyAttributes is true, preserve source permissions; otherwise use default (0o666 modified by umask)
            let dstMode: mode_t = options.copyAttributes ? (sourceStat.st_mode & 0o7777) : 0o666
            let dstFd = open(destination.string, dstFlags, dstMode)
            guard dstFd >= 0 else {
                throw _mapErrno(errno, source: source, destination: destination)
            }

            var success = false
            defer {
                _ = close(dstFd)
                if !success {
                    _ = unlink(destination.string)
                }
            }

            // Linux: try kernel-assisted copy (sendfile → manual)
            #if os(Linux) && canImport(Glibc)
                if try _copyLinuxFast(srcFd: srcFd, dstFd: dstFd, sourceSize: Int64(sourceStat.st_size)) {
                    if options.copyAttributes {
                        _ = fchmod(dstFd, sourceStat.st_mode & 0o7777)
                        var times = [
                            timespec(
                                tv_sec: sourceStat.st_atim.tv_sec,
                                tv_nsec: sourceStat.st_atim.tv_nsec
                            ),
                            timespec(
                                tv_sec: sourceStat.st_mtim.tv_sec,
                                tv_nsec: sourceStat.st_mtim.tv_nsec
                            ),
                        ]
                        _ = futimens(dstFd, &times)
                    }
                    success = true
                    return
                }
            #endif

            // Fallback: manual buffer copy
            try _copyManualLoop(
                srcFd: srcFd,
                dstFd: dstFd,
                source: source,
                destination: destination
            )

            // Copy attributes if requested
            if options.copyAttributes {
                _ = fchmod(dstFd, sourceStat.st_mode & 0o7777)

                #if canImport(Darwin)
                    var times = [
                        timespec(
                            tv_sec: sourceStat.st_atimespec.tv_sec,
                            tv_nsec: sourceStat.st_atimespec.tv_nsec
                        ),
                        timespec(
                            tv_sec: sourceStat.st_mtimespec.tv_sec,
                            tv_nsec: sourceStat.st_mtimespec.tv_nsec
                        ),
                    ]
                #else
                    var times = [
                        timespec(
                            tv_sec: sourceStat.st_atim.tv_sec,
                            tv_nsec: sourceStat.st_atim.tv_nsec
                        ),
                        timespec(
                            tv_sec: sourceStat.st_mtim.tv_sec,
                            tv_nsec: sourceStat.st_mtim.tv_nsec
                        ),
                    ]
                #endif
                _ = futimens(dstFd, &times)
            }

            success = true
        }

        // MARK: - Manual Loop Fallback

        /// Copies data using a manual read/write loop (64KB buffer).
        internal static func _copyManualLoop(
            srcFd: Int32,
            dstFd: Int32,
            source: File.Path,
            destination: File.Path
        ) throws(Error) {
            let bufferSize = 64 * 1024
            var buffer = [UInt8](repeating: 0, count: bufferSize)

            while true {
                let bytesRead: Int = buffer.withUnsafeMutableBufferPointer { ptr in
                    guard let base = ptr.baseAddress else { return 0 }
                    return read(srcFd, base, bufferSize)
                }

                if bytesRead < 0 {
                    if errno == EINTR { continue }
                    throw _mapErrno(errno, source: source, destination: destination)
                }

                if bytesRead == 0 {
                    return  // EOF
                }

                var written = 0
                while written < bytesRead {
                    let w: Int = buffer.withUnsafeBufferPointer { ptr in
                        guard let base = ptr.baseAddress else { return 0 }
                        return write(dstFd, base.advanced(by: written), bytesRead - written)
                    }

                    if w < 0 {
                        if errno == EINTR { continue }
                        throw _mapErrno(errno, source: source, destination: destination)
                    }

                    written += w
                }
            }
        }

        // MARK: - Symlink Copy

        /// Copies a symlink by reading its target and creating a new symlink.
        ///
        /// This is used when `followSymlinks=false` and the source is a symlink.
        /// We replicate the link itself rather than copying the target's contents.
        private static func _copySymlink(
            from source: File.Path,
            to destination: File.Path
        ) throws(Error) {
            // Read the symlink target
            var buffer = [CChar](repeating: 0, count: Int(PATH_MAX) + 1)
            let len = readlink(source.string, &buffer, buffer.count - 1)
            guard len >= 0 else {
                throw _mapErrno(errno, source: source, destination: destination)
            }
            // Create symlink at destination - convert CChar to UInt8 for String decoding
            let target = buffer.prefix(len).withUnsafeBufferPointer { ptr in
                String(decoding: UnsafeRawBufferPointer(ptr), as: UTF8.self)
            }
            guard symlink(target, destination.string) == 0 else {
                throw _mapErrno(errno, source: source, destination: destination)
            }
        }

        // MARK: - Darwin Fast Path

        #if canImport(Darwin)
            /// Attempts kernel-assisted copy using Darwin copyfile().
            ///
            /// - Returns: `true` if copy succeeded, `false` if fallback needed.
            internal static func _copyDarwinFast(
                from source: File.Path,
                to destination: File.Path,
                options: Options
            ) -> Bool {
                var flags: copyfile_flags_t = copyfile_flags_t(
                    options.copyAttributes ? COPYFILE_ALL : COPYFILE_DATA
                )
                if !options.followSymlinks {
                    flags |= copyfile_flags_t(COPYFILE_NOFOLLOW)
                }
                if options.overwrite {
                    flags |= copyfile_flags_t(COPYFILE_UNLINK)
                }

                // Try clone first (APFS instant copy) - but only when copying attributes,
                // because clone always preserves metadata regardless of COPYFILE_DATA flag
                if options.copyAttributes {
                    if copyfile(
                        source.string,
                        destination.string,
                        nil,
                        flags | copyfile_flags_t(COPYFILE_CLONE_FORCE)
                    ) == 0 {
                        return true
                    }
                }

                // Fall back to full kernel copy (COPYFILE_DATA or COPYFILE_ALL)
                if copyfile(source.string, destination.string, nil, flags) == 0 {
                    return true
                }

                return false
            }
        #endif

        // MARK: - Linux Fast Path

        #if os(Linux) && canImport(Glibc)
            /// Attempts kernel-assisted copy using Linux sendfile.
            ///
            /// Uses sendfile for kernel-assisted copy. Falls back to manual loop
            /// if sendfile is unavailable or fails.
            ///
            /// Note: copy_file_range would be faster for same-filesystem copies
            /// but requires a C shim to access reliably. Planned for future release.
            ///
            /// - Returns: `true` if copy succeeded, `false` if fallback needed.
            internal static func _copyLinuxFast(
                srcFd: Int32,
                dstFd: Int32,
                sourceSize: Int64
            ) throws(Error) -> Bool {
                var remaining = sourceSize

                while remaining > 0 {
                    let chunk = remaining > Int64(Int.max) ? Int.max : Int(remaining)
                    let sent = sendfile(dstFd, srcFd, nil, chunk)
                    if sent < 0 {
                        if errno == ENOSYS || errno == EINVAL {
                            return false  // Fall back to manual loop
                        }
                        throw .copyFailed(errno: errno, message: String(cString: strerror(errno)))
                    }
                    if sent == 0 {
                        break
                    }
                    remaining -= Int64(sent)
                }

                return remaining == 0
            }
        #endif

        // MARK: - Error Mapping

        /// Maps errno to copy error.
        private static func _mapErrno(
            _ errno: Int32,
            source: File.Path,
            destination: File.Path
        ) -> Error {
            switch errno {
            case ENOENT:
                return .sourceNotFound(source)
            case EEXIST:
                return .destinationExists(destination)
            case EACCES, EPERM:
                return .permissionDenied(source)
            case EISDIR:
                return .isDirectory(source)
            default:
                let message: String
                if let cString = strerror(errno) {
                    message = String(cString: cString)
                } else {
                    message = "Unknown error"
                }
                return .copyFailed(errno: errno, message: message)
            }
        }
    }

#endif
