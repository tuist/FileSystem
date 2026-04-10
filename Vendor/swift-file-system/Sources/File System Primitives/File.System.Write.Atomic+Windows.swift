// File.System.Write.Atomic+Windows.swift
// Windows implementation of atomic file writes

#if os(Windows)

    import WinSDK
    import RFC_4648

    // MARK: - Windows Implementation

    enum WindowsAtomic {

        static func writeSpan(
            _ bytes: borrowing Swift.Span<UInt8>,
            to path: borrowing String,
            options: borrowing File.System.Write.Atomic.Options
        ) throws(File.System.Write.Atomic.Error) {

            // 1. Resolve and validate parent directory
            let resolvedPath = normalizePath(path)
            let parent = parentDirectory(of: resolvedPath)
            try verifyParentDirectory(parent)

            // 2. Generate unique temp file path
            let tempPath = generateTempPath(in: parent, for: resolvedPath)

            // 3. Open destination for metadata if it exists
            let (destExists, destHandle) = try openDestinationForMetadata(
                path: resolvedPath,
                options: options
            )
            defer { if let h = destHandle { _ = CloseHandle(h) } }

            // 4. Create temp file
            let tempHandle = try createTempFile(at: tempPath)
            var tempHandleClosed = false
            var renamed = false

            defer {
                if !tempHandleClosed { _ = CloseHandle(tempHandle) }
                if !renamed { _ = deleteFile(tempPath) }
            }

            // 5. Write all data
            try writeAll(bytes, to: tempHandle)

            // 6. Flush to disk
            try flushFile(tempHandle, durability: options.durability)

            // 7. Copy metadata if requested
            if destExists, let srcHandle = destHandle {
                try copyMetadata(from: srcHandle, to: tempHandle, options: options)
            }

            // 8. Close temp file before rename
            guard CloseHandle(tempHandle) else {
                throw .closeFailed(
                    errno: Int32(GetLastError()),
                    message: "CloseHandle failed"
                )
            }
            tempHandleClosed = true

            // 9. Atomic rename
            try atomicRename(from: tempPath, to: resolvedPath, options: options)
            renamed = true

            // 10. Flush directory
            try flushDirectory(parent)
        }
    }

    // MARK: - Path Handling

    extension WindowsAtomic {

        /// Normalizes a Windows path.
        private static func normalizePath(_ path: String) -> String {
            var result = path

            // Convert forward slashes to backslashes
            result = result.replacingOccurrences(of: "/", with: "\\")

            // Remove trailing backslashes (except for root like "C:\")
            while result.count > 3 && result.hasSuffix("\\") {
                result.removeLast()
            }

            return result
        }

        /// Extracts parent directory from a Windows path.
        private static func parentDirectory(of path: String) -> String {
            // Handle UNC paths, drive letters, etc.
            if let lastSep = path.lastIndex(of: "\\") {
                if lastSep == path.startIndex {
                    return String(path[...lastSep])
                }
                // Check for "C:\" case
                let prefix = String(path[..<lastSep])
                if prefix.count == 2 && prefix.last == ":" {
                    return prefix + "\\"
                }
                return prefix
            }
            return "."
        }

        /// Extracts filename from a path.
        private static func fileName(of path: String) -> String {
            if let lastSep = path.lastIndex(of: "\\") {
                return String(path[path.index(after: lastSep)...])
            }
            return path
        }

        /// Verifies parent directory exists.
        private static func verifyParentDirectory(
            _ dir: String
        ) throws(File.System.Write.Atomic.Error) {
            let attrs = withWideString(dir) { GetFileAttributesW($0) }

            if attrs == INVALID_FILE_ATTRIBUTES {
                let err = GetLastError()
                if err == DWORD(ERROR_ACCESS_DENIED) {
                    throw .parentAccessDenied(path: dir)
                }
                throw .parentNotFound(path: dir)
            }

            if (attrs & DWORD(FILE_ATTRIBUTE_DIRECTORY)) == 0 {
                throw .parentNotDirectory(path: dir)
            }
        }

        /// Generates a unique temp file path.
        private static func generateTempPath(in parent: String, for destPath: String) -> String {
            let baseName = fileName(of: destPath)
            let random = randomHex(12)
            return "\(parent)\\\(baseName).atomic.\(random).tmp"
        }

        /// Generates random hex string.
        private static func randomHex(_ byteCount: Int) -> String {
            var bytes = [UInt8](repeating: 0, count: byteCount)
            _ = withUnsafeMutablePointer(to: &bytes[0]) { ptr in
                SystemFunction036(ptr, ULONG(byteCount))
            }
            return bytes.hex.encoded()
        }
    }

    // MARK: - File Operations

    extension WindowsAtomic {

        /// Opens destination file for reading metadata, if it exists.
        private static func openDestinationForMetadata(
            path: String,
            options: File.System.Write.Atomic.Options
        ) throws(File.System.Write.Atomic.Error) -> (exists: Bool, handle: HANDLE?) {

            let attrs = withWideString(path) { GetFileAttributesW($0) }
            let exists = (attrs != INVALID_FILE_ATTRIBUTES)

            if !exists {
                return (false, nil)
            }

            // Only open if we need metadata
            if !options.preservePermissions && !options.preserveTimestamps {
                return (true, nil)
            }

            let handle = withWideString(path) { wPath in
                CreateFileW(
                    wPath,
                    DWORD(READ_CONTROL | FILE_READ_ATTRIBUTES),
                    DWORD(FILE_SHARE_READ | FILE_SHARE_WRITE | FILE_SHARE_DELETE),
                    nil,
                    DWORD(OPEN_EXISTING),
                    DWORD(FILE_FLAG_BACKUP_SEMANTICS),
                    nil
                )
            }

            if handle == INVALID_HANDLE_VALUE {
                // Can't read metadata, but file exists
                return (true, nil)
            }

            return (true, handle)
        }

        /// Creates a new temp file for writing.
        private static func createTempFile(
            at path: String
        ) throws(File.System.Write.Atomic.Error) -> HANDLE {
            let handle = withWideString(path) { wPath in
                CreateFileW(
                    wPath,
                    DWORD(GENERIC_WRITE | GENERIC_READ),
                    DWORD(FILE_SHARE_READ),
                    nil,
                    DWORD(CREATE_NEW),
                    DWORD(FILE_ATTRIBUTE_TEMPORARY),
                    nil
                )
            }

            if handle == INVALID_HANDLE_VALUE {
                let err = GetLastError()
                throw .tempFileCreationFailed(
                    directory: parentDirectory(of: path),
                    errno: Int32(err),
                    message: "CreateFileW failed with error \(err)"
                )
            }

            return handle
        }

        /// Writes all bytes to handle.
        private static func writeAll(
            _ bytes: borrowing Swift.Span<UInt8>,
            to handle: HANDLE
        ) throws(File.System.Write.Atomic.Error) {
            let total = bytes.count
            if total == 0 { return }

            var written = 0

            bytes.withUnsafeBufferPointer { buffer throws(File.System.Write.Atomic.Error) in
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
                    var bytesWritten: DWORD = 0

                    let success = WriteFile(
                        handle,
                        UnsafeRawPointer(base.advanced(by: written)),
                        DWORD(remaining),
                        &bytesWritten,
                        nil
                    )

                    if !success {
                        let err = GetLastError()
                        throw .writeFailed(
                            bytesWritten: written,
                            bytesExpected: total,
                            errno: Int32(err),
                            message: "WriteFile failed with error \(err)"
                        )
                    }

                    if bytesWritten == 0 {
                        throw .writeFailed(
                            bytesWritten: written,
                            bytesExpected: total,
                            errno: 0,
                            message: "WriteFile wrote 0 bytes"
                        )
                    }

                    written += Int(bytesWritten)
                }
            }
        }

        /// Flushes file buffers to disk based on durability mode.
        private static func flushFile(
            _ handle: HANDLE,
            durability: File.System.Write.Atomic.Durability
        ) throws(File.System.Write.Atomic.Error) {
            switch durability {
            case .full, .dataOnly:
                // Windows FlushFileBuffers is equivalent to full sync
                // (there's no separate metadata-only sync on Windows like fdatasync)
                if !FlushFileBuffers(handle) {
                    let err = GetLastError()
                    throw .syncFailed(
                        errno: Int32(err),
                        message: "FlushFileBuffers failed with error \(err)"
                    )
                }
            case .none:
                // No sync - fastest but no crash-safety guarantees
                break
            }
        }

        /// Deletes a file.
        private static func deleteFile(_ path: String) -> Bool {
            return withWideString(path) { DeleteFileW($0) } != 0
        }
    }

    // MARK: - Atomic Rename

    extension WindowsAtomic {

        /// Performs atomic rename, optionally replacing existing file.
        private static func atomicRename(
            from tempPath: String,
            to destPath: String,
            options: File.System.Write.Atomic.Options
        ) throws(File.System.Write.Atomic.Error) {

            let replace = (options.strategy == .replaceExisting)

            // Try modern SetFileInformationByHandle first
            if trySetFileInfoRename(from: tempPath, to: destPath, replace: replace) {
                return
            }

            // Fallback to MoveFileExW
            let flags: DWORD =
                replace
                ? DWORD(MOVEFILE_REPLACE_EXISTING | MOVEFILE_WRITE_THROUGH)
                : DWORD(MOVEFILE_WRITE_THROUGH)

            let success = withWideString(tempPath) { wTemp in
                withWideString(destPath) { wDest in
                    MoveFileExW(wTemp, wDest, flags) != 0
                }
            }

            if !success {
                let err = GetLastError()

                // Check for destination exists in noClobber mode
                if !replace && err == DWORD(ERROR_ALREADY_EXISTS) {
                    throw .destinationExists(path: destPath)
                }

                throw .renameFailed(
                    from: tempPath,
                    to: destPath,
                    errno: Int32(err),
                    message: "MoveFileExW failed with error \(err)"
                )
            }
        }

        /// Tries to use SetFileInformationByHandle for rename.
        private static func trySetFileInfoRename(
            from tempPath: String,
            to destPath: String,
            replace: Bool
        ) -> Bool {
            // Open temp file for rename operation
            let tempHandle = withWideString(tempPath) { wTemp in
                CreateFileW(
                    wTemp,
                    DWORD(DELETE | SYNCHRONIZE),
                    DWORD(FILE_SHARE_READ | FILE_SHARE_WRITE | FILE_SHARE_DELETE),
                    nil,
                    DWORD(OPEN_EXISTING),
                    DWORD(FILE_FLAG_BACKUP_SEMANTICS),
                    nil
                )
            }

            if tempHandle == INVALID_HANDLE_VALUE {
                return false
            }
            defer { _ = CloseHandle(tempHandle) }

            // Build FILE_RENAME_INFO structure
            var destWide = Array(destPath.utf16) + [0]
            let nameByteCount = destWide.count * MemoryLayout<WCHAR>.size

            // Allocate buffer for the variable-length structure
            // FILE_RENAME_INFO has: BOOLEAN ReplaceIfExists, HANDLE RootDirectory, ULONG FileNameLength, WCHAR FileName[1]
            let structSize = MemoryLayout<FILE_RENAME_INFO>.stride
            let totalSize = structSize + nameByteCount

            let buffer = UnsafeMutableRawPointer.allocate(
                byteCount: totalSize,
                alignment: MemoryLayout<Int>.alignment
            )
            defer { buffer.deallocate() }

            // Zero initialize
            buffer.initializeMemory(as: UInt8.self, repeating: 0, count: totalSize)

            // Fill in the structure using proper offsets
            let info = buffer.assumingMemoryBound(to: FILE_RENAME_INFO.self)
            info.pointee.Flags = replace ? DWORD(FILE_RENAME_FLAG_REPLACE_IF_EXISTS) : 0
            info.pointee.RootDirectory = nil
            info.pointee.FileNameLength = DWORD(nameByteCount - MemoryLayout<WCHAR>.size)  // Exclude null terminator

            // Copy filename after the fixed part of the structure
            let fileNameOffset = MemoryLayout.offset(of: \FILE_RENAME_INFO.FileName)!
            let fileNamePtr = buffer.advanced(by: fileNameOffset).assumingMemoryBound(
                to: WCHAR.self
            )
            destWide.withUnsafeBufferPointer { src in
                guard let srcBase = src.baseAddress else { return }
                fileNamePtr.update(from: srcBase, count: destWide.count)
            }

            let success = SetFileInformationByHandle(
                tempHandle,
                FileRenameInfoEx,
                buffer,
                DWORD(totalSize)
            )

            return success != 0
        }

        /// Flushes directory to persist rename.
        private static func flushDirectory(_ path: String) throws(File.System.Write.Atomic.Error) {
            let handle = withWideString(path) { wPath in
                CreateFileW(
                    wPath,
                    DWORD(GENERIC_READ),
                    DWORD(FILE_SHARE_READ | FILE_SHARE_WRITE | FILE_SHARE_DELETE),
                    nil,
                    DWORD(OPEN_EXISTING),
                    DWORD(FILE_FLAG_BACKUP_SEMANTICS),
                    nil
                )
            }

            if handle == INVALID_HANDLE_VALUE {
                let err = GetLastError()
                throw .directorySyncFailed(
                    path: path,
                    errno: Int32(err),
                    message: "CreateFileW(directory) failed with error \(err)"
                )
            }
            defer { _ = CloseHandle(handle) }

            if !FlushFileBuffers(handle) {
                let err = GetLastError()
                throw .directorySyncFailed(
                    path: path,
                    errno: Int32(err),
                    message: "FlushFileBuffers(directory) failed with error \(err)"
                )
            }
        }
    }

    // MARK: - Metadata Preservation

    extension WindowsAtomic {

        /// Copies metadata from source handle to destination handle.
        private static func copyMetadata(
            from srcHandle: HANDLE,
            to dstHandle: HANDLE,
            options: File.System.Write.Atomic.Options
        ) throws(File.System.Write.Atomic.Error) {

            // Copy timestamps (includes creation time, access time, write time)
            if options.preserveTimestamps {
                var basicInfo = FILE_BASIC_INFO()

                let getSuccess = GetFileInformationByHandleEx(
                    srcHandle,
                    FileBasicInfo,
                    &basicInfo,
                    DWORD(MemoryLayout<FILE_BASIC_INFO>.size)
                )

                if getSuccess == 0 {
                    let err = GetLastError()
                    throw .metadataPreservationFailed(
                        operation: "GetFileInformationByHandleEx",
                        errno: Int32(err),
                        message: "Failed to get file info with error \(err)"
                    )
                }

                let setSuccess = SetFileInformationByHandle(
                    dstHandle,
                    FileBasicInfo,
                    &basicInfo,
                    DWORD(MemoryLayout<FILE_BASIC_INFO>.size)
                )

                if setSuccess == 0 {
                    let err = GetLastError()
                    throw .metadataPreservationFailed(
                        operation: "SetFileInformationByHandle",
                        errno: Int32(err),
                        message: "Failed to set file info with error \(err)"
                    )
                }
            }

            // Windows security descriptors (ACLs, owner, etc.)
            #if ATOMICFILEWRITE_HAS_WINDOWS_SECURITY_SHIM
                if options.preservePermissions {
                    var winErr: DWORD = 0
                    if atomicfilewrite_copy_security_descriptor(srcHandle, dstHandle, &winErr) == 0
                    {
                        throw .metadataPreservationFailed(
                            operation: "SecurityDescriptor",
                            errno: Int32(winErr),
                            message: "Security descriptor copy failed with error \(winErr)"
                        )
                    }
                }
            #endif
        }

        #if ATOMICFILEWRITE_HAS_WINDOWS_SECURITY_SHIM
            @_silgen_name("atomicfilewrite_copy_security_descriptor")
            private static func atomicfilewrite_copy_security_descriptor(
                _ srcHandle: HANDLE,
                _ dstHandle: HANDLE,
                _ outWinErr: UnsafeMutablePointer<DWORD>
            ) -> Int32
        #endif
    }

    // MARK: - Utilities

    extension WindowsAtomic {

        /// Executes a closure with a wide (UTF-16) string.
        private static func withWideString<T>(
            _ string: String,
            _ body: (UnsafePointer<WCHAR>) -> T
        ) -> T {
            var wideChars = Array(string.utf16) + [0]
            return wideChars.withUnsafeBufferPointer { buffer in
                // Buffer always has at least 1 element (null terminator)
                guard let base = buffer.baseAddress else {
                    preconditionFailure("Buffer with count \(buffer.count) has nil baseAddress")
                }
                return base.withMemoryRebound(to: WCHAR.self, capacity: buffer.count) { ptr in
                    body(ptr)
                }
            }
        }
    }

#endif  // os(Windows)
