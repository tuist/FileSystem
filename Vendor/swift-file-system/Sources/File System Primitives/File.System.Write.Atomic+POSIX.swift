// File.System.Write.Atomic+POSIX.swift
// POSIX implementation of atomic file writes (macOS, Linux, BSD)

#if !os(Windows)

    #if canImport(Darwin)
        import Darwin
    #elseif canImport(Glibc)
        import CFileSystemShims
        import Glibc
    #elseif canImport(Musl)
        import Musl
    #endif

    import RFC_4648

    // MARK: - POSIX Implementation

    enum POSIXAtomic {

        static func writeSpan(
            _ bytes: borrowing Swift.Span<UInt8>,
            to path: borrowing String,
            options: borrowing File.System.Write.Atomic.Options
        ) throws(File.System.Write.Atomic.Error) {

            // 1. Resolve and validate parent directory
            let resolvedPath = resolvePath(path)
            let parent = parentDirectory(of: resolvedPath)
            try verifyParentDirectory(parent)

            // 2. Generate unique temp file path in same directory
            let tempPath = generateTempPath(in: parent, for: resolvedPath)

            // 3. Stat destination if it exists (for metadata preservation)
            let destStat = try statIfExists(resolvedPath)

            // 4. Create temp file
            let fd = try createTempFile(at: tempPath)

            // Track state for cleanup
            var didClose = false
            var didRename = false

            defer {
                if !didClose {
                    _ = close(fd)
                }
                if !didRename {
                    _ = unlink(tempPath)
                }
            }

            // 5. Write all data
            try writeAll(bytes, to: fd)

            // 6. Sync file to disk
            try syncFile(fd, durability: options.durability)

            // 7. Apply metadata from destination if requested
            if let st = destStat {
                try applyMetadata(from: st, to: fd, options: options, destPath: resolvedPath)
            }

            // 8. Close file (required before rename on some systems)
            try closeFile(fd)
            didClose = true

            // 9. Atomic rename
            switch options.strategy {
            case .replaceExisting:
                try atomicRename(from: tempPath, to: resolvedPath)
            case .noClobber:
                try atomicRenameNoClobber(from: tempPath, to: resolvedPath)
            }
            didRename = true

            // 10. Sync directory to persist the rename
            try syncDirectory(parent)
        }
    }

    // MARK: - Path Handling

    extension POSIXAtomic {

        /// Resolves a path, expanding ~ and making relative paths absolute.
        private static func resolvePath(_ path: String) -> String {
            var result = path

            // Expand ~ to home directory
            if result.hasPrefix("~/") {
                if let home = getenv("HOME") {
                    result = String(cString: home) + String(result.dropFirst())
                }
            } else if result == "~" {
                if let home = getenv("HOME") {
                    result = String(cString: home)
                }
            }

            // Make relative paths absolute using current working directory
            if !result.hasPrefix("/") {
                var cwd = [CChar](repeating: 0, count: Int(PATH_MAX))
                if getcwd(&cwd, cwd.count) != nil {
                    let cwdStr = cwd.withUnsafeBufferPointer { buffer in
                        // Find null terminator
                        let length = buffer.firstIndex(of: 0) ?? buffer.count
                        return String(
                            decoding: buffer[..<length].map { UInt8(bitPattern: $0) },
                            as: UTF8.self
                        )
                    }
                    if result == "." {
                        result = cwdStr
                    } else if result.hasPrefix("./") {
                        result = cwdStr + String(result.dropFirst())
                    } else {
                        result = cwdStr + "/" + result
                    }
                }
            }

            // Normalize: remove trailing slashes (except root)
            while result.count > 1 && result.hasSuffix("/") {
                result.removeLast()
            }

            return result
        }

        /// Extracts the parent directory from a path.
        private static func parentDirectory(of path: String) -> String {
            // Root has no parent
            if path == "/" { return "/" }

            // Find last slash
            guard let lastSlash = path.lastIndex(of: "/") else {
                // No slash means current directory (shouldn't happen after resolvePath)
                return "."
            }

            if lastSlash == path.startIndex {
                // Path like "/file" - parent is root
                return "/"
            }

            return String(path[..<lastSlash])
        }

        /// Extracts the filename from a path.
        private static func fileName(of path: String) -> String {
            if let lastSlash = path.lastIndex(of: "/") {
                return String(path[path.index(after: lastSlash)...])
            }
            return path
        }

        /// Verifies the parent directory exists and is accessible.
        private static func verifyParentDirectory(
            _ dir: String
        ) throws(File.System.Write.Atomic.Error) {
            var st = stat()
            let rc = dir.withCString { stat($0, &st) }

            if rc != 0 {
                let e = errno
                if e == EACCES {
                    throw .parentAccessDenied(path: dir)
                }
                throw .parentNotFound(path: dir)
            }

            if (st.st_mode & S_IFMT) != S_IFDIR {
                throw .parentNotDirectory(path: dir)
            }
        }

        /// Generates a unique temp file path in the same directory as the destination.
        private static func generateTempPath(in parent: String, for destPath: String) -> String {
            let baseName = fileName(of: destPath)
            let random = randomToken(length: 12)
            return "\(parent)/.\(baseName).atomic.\(random).tmp"
        }

        /// Generates a random hex token.
        private static func randomToken(length: Int) -> String {
            var bytes = [UInt8](repeating: 0, count: length)
            for i in 0..<length {
                bytes[i] = UInt8.random(in: 0...255)
            }
            return bytes.hex.encoded()
        }
    }

    // MARK: - File Operations

    extension POSIXAtomic {

        /// Stats a file, returning nil if it doesn't exist.
        private static func statIfExists(
            _ path: String
        ) throws(File.System.Write.Atomic.Error) -> stat? {
            var st = stat()
            let rc = path.withCString { lstat($0, &st) }

            if rc == 0 {
                return st
            }

            let e = errno
            if e == ENOENT {
                return nil
            }

            throw .destinationStatFailed(
                path: path,
                errno: e,
                message: File.System.Write.Atomic.errorMessage(for: e)
            )
        }

        /// Creates a new temp file with exclusive access.
        private static func createTempFile(
            at path: String
        ) throws(File.System.Write.Atomic.Error) -> Int32 {
            let flags: Int32 = O_CREAT | O_EXCL | O_RDWR | O_CLOEXEC
            let mode: mode_t = 0o600  // Owner read/write only initially

            let fd = path.withCString { open($0, flags, mode) }

            if fd < 0 {
                let e = errno
                throw .tempFileCreationFailed(
                    directory: parentDirectory(of: path),
                    errno: e,
                    message: File.System.Write.Atomic.errorMessage(for: e)
                )
            }

            return fd
        }

        /// Writes all bytes to the file descriptor, handling partial writes and interrupts.
        private static func writeAll(
            _ bytes: borrowing Swift.Span<UInt8>,
            to fd: Int32
        ) throws(File.System.Write.Atomic.Error) {
            let total = bytes.count
            if total == 0 { return }

            var written = 0

            try bytes.withUnsafeBufferPointer { buffer throws(File.System.Write.Atomic.Error) in
                guard let base = buffer.baseAddress else {
                    throw .writeFailed(
                        bytesWritten: 0,
                        bytesExpected: total,
                        errno: 0,
                        message: "nil buffer"
                    )
                }

                while written < total {
                    let remaining = total - written
                    let rc = write(fd, base.advanced(by: written), remaining)

                    if rc > 0 {
                        written += rc
                        continue
                    }

                    if rc == 0 {
                        // Shouldn't happen with regular files, but handle it
                        throw .writeFailed(
                            bytesWritten: written,
                            bytesExpected: total,
                            errno: 0,
                            message: "write returned 0"
                        )
                    }

                    let e = errno
                    // Retry on interrupt or would-block
                    if e == EINTR || e == EAGAIN {
                        continue
                    }

                    throw .writeFailed(
                        bytesWritten: written,
                        bytesExpected: total,
                        errno: e,
                        message: File.System.Write.Atomic.errorMessage(for: e)
                    )
                }
            }
        }

        /// Syncs file data to disk based on durability mode.
        private static func syncFile(
            _ fd: Int32,
            durability: File.System.Write.Atomic.Durability
        ) throws(File.System.Write.Atomic.Error) {
            switch durability {
            case .full:
                // Full durability: F_FULLFSYNC on macOS, fsync elsewhere
                #if canImport(Darwin)
                    // On macOS, use F_FULLFSYNC for true durability
                    if fcntl(fd, F_FULLFSYNC) != 0 {
                        // Fall back to fsync if F_FULLFSYNC fails
                        if fsync(fd) != 0 {
                            let e = errno
                            throw .syncFailed(
                                errno: e,
                                message: File.System.Write.Atomic.errorMessage(for: e)
                            )
                        }
                    }
                #else
                    if fsync(fd) != 0 {
                        let e = errno
                        throw .syncFailed(
                            errno: e,
                            message: File.System.Write.Atomic.errorMessage(for: e)
                        )
                    }
                #endif

            case .dataOnly:
                // Data-only sync: fdatasync on Linux, F_BARRIERFSYNC on macOS, fallback to fsync
                #if canImport(Darwin)
                    // Try F_BARRIERFSYNC first (faster than F_FULLFSYNC)
                    #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
                        if fcntl(fd, F_BARRIERFSYNC) != 0 {
                            // Fall back to fsync if F_BARRIERFSYNC fails
                            if fsync(fd) != 0 {
                                let e = errno
                                throw .syncFailed(
                                    errno: e,
                                    message: File.System.Write.Atomic.errorMessage(for: e)
                                )
                            }
                        }
                    #else
                        // Darwin platform without F_BARRIERFSYNC, use fsync
                        if fsync(fd) != 0 {
                            let e = errno
                            throw .syncFailed(
                                errno: e,
                                message: File.System.Write.Atomic.errorMessage(for: e)
                            )
                        }
                    #endif
                #elseif os(Linux)
                    // Use fdatasync on Linux (syncs data but not all metadata)
                    if fdatasync(fd) != 0 {
                        let e = errno
                        throw .syncFailed(
                            errno: e,
                            message: File.System.Write.Atomic.errorMessage(for: e)
                        )
                    }
                #else
                    // Fallback to fsync for other platforms
                    if fsync(fd) != 0 {
                        let e = errno
                        throw .syncFailed(
                            errno: e,
                            message: File.System.Write.Atomic.errorMessage(for: e)
                        )
                    }
                #endif

            case .none:
                // No sync - fastest but no crash-safety guarantees
                // Data may remain in OS buffers and be lost on power failure
                break
            }
        }

        /// Closes a file descriptor.
        private static func closeFile(_ fd: Int32) throws(File.System.Write.Atomic.Error) {
            // Handle EINTR - close may need retry on some systems
            while true {
                if close(fd) == 0 {
                    return
                }
                let e = errno
                if e == EINTR {
                    continue
                }
                throw .closeFailed(errno: e, message: File.System.Write.Atomic.errorMessage(for: e))
            }
        }
    }

    // MARK: - Atomic Rename

    extension POSIXAtomic {

        /// Performs an atomic rename (replace if exists).
        private static func atomicRename(
            from: String,
            to: String
        ) throws(File.System.Write.Atomic.Error) {
            let rc = from.withCString { fromPtr in
                to.withCString { toPtr in
                    rename(fromPtr, toPtr)
                }
            }

            if rc != 0 {
                let e = errno
                throw .renameFailed(
                    from: from,
                    to: to,
                    errno: e,
                    message: File.System.Write.Atomic.errorMessage(for: e)
                )
            }
        }

        /// Performs an atomic rename that fails if destination exists.
        private static func atomicRenameNoClobber(
            from: String,
            to: String
        ) throws(File.System.Write.Atomic.Error) {
            #if os(Linux)
                // Try renameat2 with RENAME_NOREPLACE for true atomicity
                if let result = tryRenameat2NoClobber(from: from, to: to) {
                    if case .failure(let error) = result {
                        throw error
                    }
                    return  // Success
                }
            // renameat2 not available, fall through to TOCTOU fallback
            #endif

            // Fallback: check-then-rename (has TOCTOU race, but best we can do)
            // The race window is small, and this matches behavior of most file APIs.
            var st = stat()
            let exists = to.withCString { lstat($0, &st) } == 0

            if exists {
                throw .destinationExists(path: to)
            }

            try atomicRename(from: from, to: to)
        }

        #if os(Linux)
            /// Tries to use renameat2(RENAME_NOREPLACE) on Linux.
            /// Returns nil if the syscall isn't available.
            private static func tryRenameat2NoClobber(
                from: String,
                to: String
            ) -> Result<Void, File.System.Write.Atomic.Error>? {
                var outErrno: Int32 = 0

                let rc = from.withCString { fromPtr in
                    to.withCString { toPtr in
                        atomicfilewrite_renameat2_noreplace(fromPtr, toPtr, &outErrno)
                    }
                }

                if rc == 0 {
                    return .success(())
                }

                if outErrno == ENOSYS {
                    // Syscall not available
                    return nil
                }

                if outErrno == EEXIST {
                    return .failure(.destinationExists(path: to))
                }

                return .failure(
                    .renameFailed(
                        from: from,
                        to: to,
                        errno: outErrno,
                        message: File.System.Write.Atomic.errorMessage(for: outErrno)
                    )
                )
            }
        #endif

        /// Syncs a directory to persist rename operations.
        private static func syncDirectory(_ path: String) throws(File.System.Write.Atomic.Error) {
            var flags: Int32 = O_RDONLY | O_CLOEXEC
            #if os(Linux)
                flags |= O_DIRECTORY
            #endif

            let fd = path.withCString { open($0, flags) }

            if fd < 0 {
                let e = errno
                throw .directorySyncFailed(
                    path: path,
                    errno: e,
                    message: File.System.Write.Atomic.errorMessage(for: e)
                )
            }

            defer { _ = close(fd) }

            if fsync(fd) != 0 {
                let e = errno
                throw .directorySyncFailed(
                    path: path,
                    errno: e,
                    message: File.System.Write.Atomic.errorMessage(for: e)
                )
            }
        }
    }

    // MARK: - Metadata Preservation

    extension POSIXAtomic {

        /// Applies metadata from the original file to the temp file.
        private static func applyMetadata(
            from st: stat,
            to fd: Int32,
            options: File.System.Write.Atomic.Options,
            destPath: String
        ) throws(File.System.Write.Atomic.Error) {

            // Permissions (mode)
            if options.preservePermissions {
                let mode = st.st_mode & 0o7777
                if fchmod(fd, mode) != 0 {
                    let e = errno
                    throw .metadataPreservationFailed(
                        operation: "fchmod",
                        errno: e,
                        message: File.System.Write.Atomic.errorMessage(for: e)
                    )
                }
            }

            // Ownership (uid/gid)
            if options.preserveOwnership {
                if fchown(fd, st.st_uid, st.st_gid) != 0 {
                    let e = errno
                    // Ownership changes often fail for non-root users
                    if options.strictOwnership {
                        throw .metadataPreservationFailed(
                            operation: "fchown",
                            errno: e,
                            message: File.System.Write.Atomic.errorMessage(for: e)
                        )
                    }
                    // Otherwise silently ignore - this is expected for normal users
                }
            }

            // Timestamps
            if options.preserveTimestamps {
                try copyTimestamps(from: st, to: fd)
            }

            // Extended attributes
            if options.preserveExtendedAttributes {
                try copyExtendedAttributes(from: destPath, to: fd)
            }

            // ACLs
            if options.preserveACLs {
                try copyACL(from: destPath, to: fd)
            }
        }

        /// Copies atime/mtime from stat to file descriptor.
        private static func copyTimestamps(
            from st: stat,
            to fd: Int32
        ) throws(File.System.Write.Atomic.Error) {
            #if canImport(Darwin)
                var times = [
                    timespec(tv_sec: st.st_atimespec.tv_sec, tv_nsec: st.st_atimespec.tv_nsec),
                    timespec(tv_sec: st.st_mtimespec.tv_sec, tv_nsec: st.st_mtimespec.tv_nsec),
                ]
            #else
                var times = [
                    timespec(tv_sec: st.st_atim.tv_sec, tv_nsec: st.st_atim.tv_nsec),
                    timespec(tv_sec: st.st_mtim.tv_sec, tv_nsec: st.st_mtim.tv_nsec),
                ]
            #endif

            let rc = times.withUnsafeBufferPointer { futimens(fd, $0.baseAddress) }

            if rc != 0 {
                let e = errno
                throw .metadataPreservationFailed(
                    operation: "futimens",
                    errno: e,
                    message: File.System.Write.Atomic.errorMessage(for: e)
                )
            }
        }
    }

    // MARK: - Extended Attributes

    extension POSIXAtomic {

        /// Copies extended attributes from source path to destination fd.
        private static func copyExtendedAttributes(
            from srcPath: String,
            to dstFd: Int32
        ) throws(File.System.Write.Atomic.Error) {
            #if canImport(Darwin)
                try copyXattrsDarwin(from: srcPath, to: dstFd)
            #else
                // Linux xattr requires C shim (planned for future release)
                // Other platforms - silently skip
                _ = (srcPath, dstFd)
            #endif
        }

        #if canImport(Darwin)
            private static func copyXattrsDarwin(
                from srcPath: String,
                to dstFd: Int32
            ) throws(File.System.Write.Atomic.Error) {
                // Get list of xattr names
                let listSize = srcPath.withCString { listxattr($0, nil, 0, 0) }

                if listSize < 0 {
                    let e = errno
                    if e == ENOTSUP || e == ENOENT { return }  // No xattr support or file gone
                    throw .metadataPreservationFailed(
                        operation: "listxattr",
                        errno: e,
                        message: File.System.Write.Atomic.errorMessage(for: e)
                    )
                }

                if listSize == 0 { return }  // No xattrs

                // Read the name list
                var nameList = [CChar](repeating: 0, count: listSize)
                let gotSize = srcPath.withCString { path in
                    nameList.withUnsafeMutableBufferPointer { buf in
                        listxattr(path, buf.baseAddress, listSize, 0)
                    }
                }

                if gotSize < 0 {
                    let e = errno
                    throw .metadataPreservationFailed(
                        operation: "listxattr(read)",
                        errno: e,
                        message: File.System.Write.Atomic.errorMessage(for: e)
                    )
                }

                // Parse null-terminated names and copy each xattr
                var offset = 0
                while offset < gotSize {
                    // Find end of this name
                    var end = offset
                    while end < gotSize && nameList[end] != 0 { end += 1 }

                    let name = String(
                        decoding: nameList[offset..<end].map { UInt8(bitPattern: $0) },
                        as: UTF8.self
                    )
                    offset = end + 1

                    // Get xattr value
                    let valueSize = srcPath.withCString { path in
                        name.withCString { n in
                            getxattr(path, n, nil, 0, 0, 0)
                        }
                    }

                    if valueSize < 0 {
                        let e = errno
                        if e == ENOATTR { continue }  // Attribute disappeared
                        throw .metadataPreservationFailed(
                            operation: "getxattr(\(name))",
                            errno: e,
                            message: File.System.Write.Atomic.errorMessage(for: e)
                        )
                    }

                    var value = [UInt8](repeating: 0, count: valueSize)
                    let gotValue = srcPath.withCString { path in
                        name.withCString { n in
                            value.withUnsafeMutableBufferPointer { buf in
                                getxattr(path, n, buf.baseAddress, valueSize, 0, 0)
                            }
                        }
                    }

                    if gotValue < 0 {
                        let e = errno
                        throw .metadataPreservationFailed(
                            operation: "getxattr(\(name),read)",
                            errno: e,
                            message: File.System.Write.Atomic.errorMessage(for: e)
                        )
                    }

                    // Set xattr on destination
                    let setRc = name.withCString { n in
                        value.withUnsafeBufferPointer { buf in
                            fsetxattr(dstFd, n, buf.baseAddress, gotValue, 0, 0)
                        }
                    }

                    if setRc != 0 {
                        let e = errno
                        if e == ENOTSUP { continue }  // Destination doesn't support this xattr
                        throw .metadataPreservationFailed(
                            operation: "fsetxattr(\(name))",
                            errno: e,
                            message: File.System.Write.Atomic.errorMessage(for: e)
                        )
                    }
                }
            }
        #endif

        // Note: Linux xattr preservation requires C shim for llistxattr/lgetxattr/fsetxattr.
        // These functions are not reliably exposed in Swift's Glibc overlay.
        // Planned for future release with proper C interop target.
    }

    // MARK: - ACL Support

    extension POSIXAtomic {

        /// Copies ACL from source path to destination fd.
        private static func copyACL(
            from srcPath: String,
            to dstFd: Int32
        ) throws(File.System.Write.Atomic.Error) {
            #if ATOMICFILEWRITE_HAS_ACL_SHIMS
                var outErrno: Int32 = 0
                let rc = srcPath.withCString { path in
                    atomicfilewrite_copy_acl_from_path_to_fd(path, dstFd, &outErrno)
                }

                if rc != 0 {
                    // ENOENT means no ACL exists - that's fine
                    if outErrno == ENOENT || outErrno == EOPNOTSUPP || outErrno == ENOTSUP {
                        return
                    }
                    throw .metadataPreservationFailed(
                        operation: "acl_copy",
                        errno: outErrno,
                        message: File.System.Write.Atomic.errorMessage(for: outErrno)
                    )
                }
            #else
                // ACL shims not compiled - silently skip
                // (User requested ACL preservation but it's not available)
                _ = (srcPath, dstFd)
            #endif
        }

        #if ATOMICFILEWRITE_HAS_ACL_SHIMS
            @_silgen_name("atomicfilewrite_copy_acl_from_path_to_fd")
            private static func atomicfilewrite_copy_acl_from_path_to_fd(
                _ srcPath: UnsafePointer<CChar>,
                _ dstFd: Int32,
                _ outErrno: UnsafeMutablePointer<Int32>
            ) -> Int32
        #endif
    }

#endif  // !os(Windows)
