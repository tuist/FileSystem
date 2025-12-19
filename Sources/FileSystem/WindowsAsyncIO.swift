#if os(Windows)
    import Foundation
    import WinSDK

    /// Windows I/O errors
    enum WindowsIOError: LocalizedError {
        case openFailed(DWORD)
        case readFailed(DWORD)
        case writeFailed(DWORD)
        case associationFailed(DWORD)
        case operationFailed(DWORD)
        case invalidHandle
        case getFileSizeFailed(DWORD)

        var errorDescription: String? {
            switch self {
            case let .openFailed(code):
                return "Failed to open file (error code: \(code))"
            case let .readFailed(code):
                return "Failed to read file (error code: \(code))"
            case let .writeFailed(code):
                return "Failed to write file (error code: \(code))"
            case let .associationFailed(code):
                return "Failed to associate handle with IOCP (error code: \(code))"
            case let .operationFailed(code):
                return "I/O operation failed (error code: \(code))"
            case .invalidHandle:
                return "Invalid file handle"
            case let .getFileSizeFailed(code):
                return "Failed to get file size (error code: \(code))"
            }
        }
    }

    /// Async file handle for Windows
    struct WindowsAsyncFileHandle: Sendable {
        let handle: HANDLE

        /// Opens a file for async reading
        static func openForReading(path: String) throws -> WindowsAsyncFileHandle {
            let handle = path.withCString(encodedAs: UTF16.self) { pathPtr in
                CreateFileW(
                    pathPtr,
                    DWORD(GENERIC_READ),
                    DWORD(FILE_SHARE_READ),
                    nil,
                    DWORD(OPEN_EXISTING),
                    DWORD(FILE_FLAG_OVERLAPPED),
                    nil
                )
            }

            if handle == INVALID_HANDLE_VALUE {
                throw WindowsIOError.openFailed(GetLastError())
            }

            return WindowsAsyncFileHandle(handle: handle)
        }

        /// Opens a file for async writing (creates if not exists)
        static func openForWriting(path: String) throws -> WindowsAsyncFileHandle {
            let handle = path.withCString(encodedAs: UTF16.self) { pathPtr in
                CreateFileW(
                    pathPtr,
                    DWORD(GENERIC_WRITE),
                    0,
                    nil,
                    DWORD(CREATE_ALWAYS),
                    DWORD(FILE_FLAG_OVERLAPPED),
                    nil
                )
            }

            if handle == INVALID_HANDLE_VALUE {
                throw WindowsIOError.openFailed(GetLastError())
            }

            return WindowsAsyncFileHandle(handle: handle)
        }

        /// Gets the file size
        func getFileSize() throws -> Int64 {
            var size: LARGE_INTEGER = LARGE_INTEGER()
            if !GetFileSizeEx(handle, &size) {
                throw WindowsIOError.getFileSizeFailed(GetLastError())
            }
            return size.QuadPart
        }

        /// Closes the file handle
        func close() {
            CloseHandle(handle)
        }
    }

    /// High-level async file operations for Windows
    enum WindowsAsyncFileOperations {
        /// Reads a file asynchronously using overlapped I/O
        static func readFile(at path: String) async throws -> Data {
            let handle = try WindowsAsyncFileHandle.openForReading(path: path)
            defer { handle.close() }

            let fileSize = try handle.getFileSize()
            if fileSize == 0 {
                return Data()
            }

            return try await withCheckedThrowingContinuation { continuation in
                Task.detached {
                    do {
                        var buffer = [UInt8](repeating: 0, count: Int(fileSize))
                        var bytesRead: DWORD = 0
                        var overlapped = OVERLAPPED()

                        let success = buffer.withUnsafeMutableBufferPointer { bufferPtr in
                            ReadFile(
                                handle.handle,
                                bufferPtr.baseAddress,
                                DWORD(fileSize),
                                &bytesRead,
                                &overlapped
                            )
                        }

                        // Wait for completion if pending
                        if !success && GetLastError() == DWORD(ERROR_IO_PENDING) {
                            var transferred: DWORD = 0
                            if !GetOverlappedResult(handle.handle, &overlapped, &transferred, true) {
                                throw WindowsIOError.readFailed(GetLastError())
                            }
                            bytesRead = transferred
                        } else if !success {
                            throw WindowsIOError.readFailed(GetLastError())
                        }

                        continuation.resume(returning: Data(buffer[0 ..< Int(bytesRead)]))
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
            }
        }

        /// Writes data to a file asynchronously using overlapped I/O
        static func writeFile(at path: String, data: Data) async throws {
            let handle = try WindowsAsyncFileHandle.openForWriting(path: path)
            defer { handle.close() }

            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                Task.detached {
                    do {
                        var overlapped = OVERLAPPED()
                        var bytesWritten: DWORD = 0

                        let success = data.withUnsafeBytes { buffer in
                            WriteFile(
                                handle.handle,
                                buffer.baseAddress,
                                DWORD(data.count),
                                &bytesWritten,
                                &overlapped
                            )
                        }

                        // Wait for completion if pending
                        if !success && GetLastError() == DWORD(ERROR_IO_PENDING) {
                            var transferred: DWORD = 0
                            if !GetOverlappedResult(handle.handle, &overlapped, &transferred, true) {
                                throw WindowsIOError.writeFailed(GetLastError())
                            }
                        } else if !success {
                            throw WindowsIOError.writeFailed(GetLastError())
                        }

                        continuation.resume()
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
            }
        }

        /// Copies a file asynchronously
        static func copyFile(from source: String, to destination: String) async throws {
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                Task.detached {
                    let success = source.withCString(encodedAs: UTF16.self) { sourcePtr in
                        destination.withCString(encodedAs: UTF16.self) { destPtr in
                            CopyFileW(sourcePtr, destPtr, false)
                        }
                    }

                    if !success {
                        continuation.resume(throwing: WindowsIOError.operationFailed(GetLastError()))
                    } else {
                        continuation.resume()
                    }
                }
            }
        }

        /// Moves a file asynchronously
        static func moveFile(from source: String, to destination: String) async throws {
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                Task.detached {
                    let success = source.withCString(encodedAs: UTF16.self) { sourcePtr in
                        destination.withCString(encodedAs: UTF16.self) { destPtr in
                            MoveFileExW(sourcePtr, destPtr, DWORD(MOVEFILE_REPLACE_EXISTING | MOVEFILE_COPY_ALLOWED))
                        }
                    }

                    if !success {
                        continuation.resume(throwing: WindowsIOError.operationFailed(GetLastError()))
                    } else {
                        continuation.resume()
                    }
                }
            }
        }

        /// Deletes a file asynchronously
        static func deleteFile(at path: String) async throws {
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                Task.detached {
                    let success = path.withCString(encodedAs: UTF16.self) { pathPtr in
                        DeleteFileW(pathPtr)
                    }

                    if !success {
                        let error = GetLastError()
                        // ERROR_FILE_NOT_FOUND is not an error for delete
                        if error != DWORD(ERROR_FILE_NOT_FOUND) {
                            continuation.resume(throwing: WindowsIOError.operationFailed(error))
                            return
                        }
                    }
                    continuation.resume()
                }
            }
        }

        /// Deletes a directory asynchronously
        static func deleteDirectory(at path: String) async throws {
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                Task.detached {
                    let success = path.withCString(encodedAs: UTF16.self) { pathPtr in
                        RemoveDirectoryW(pathPtr)
                    }

                    if !success {
                        let error = GetLastError()
                        if error != DWORD(ERROR_FILE_NOT_FOUND) && error != DWORD(ERROR_PATH_NOT_FOUND) {
                            continuation.resume(throwing: WindowsIOError.operationFailed(error))
                            return
                        }
                    }
                    continuation.resume()
                }
            }
        }

        /// Creates a directory asynchronously
        static func createDirectory(at path: String, withIntermediateDirectories: Bool) async throws {
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                Task.detached {
                    if withIntermediateDirectories {
                        // Create intermediate directories
                        var currentPath = ""
                        let components = path.replacingOccurrences(of: "\\", with: "/").split(separator: "/")

                        for (index, component) in components.enumerated() {
                            if index == 0 && component.contains(":") {
                                // Drive letter (e.g., "C:")
                                currentPath = String(component)
                            } else {
                                currentPath += "\\" + component
                            }

                            let success = currentPath.withCString(encodedAs: UTF16.self) { pathPtr in
                                CreateDirectoryW(pathPtr, nil)
                            }

                            if !success {
                                let error = GetLastError()
                                // ERROR_ALREADY_EXISTS is not an error
                                if error != DWORD(ERROR_ALREADY_EXISTS) && error != DWORD(ERROR_ACCESS_DENIED) {
                                    // ERROR_ACCESS_DENIED can happen for drive root
                                    if !(index == 0 && component.contains(":")) {
                                        continuation.resume(throwing: WindowsIOError.operationFailed(error))
                                        return
                                    }
                                }
                            }
                        }
                    } else {
                        let success = path.withCString(encodedAs: UTF16.self) { pathPtr in
                            CreateDirectoryW(pathPtr, nil)
                        }

                        if !success {
                            let error = GetLastError()
                            if error != DWORD(ERROR_ALREADY_EXISTS) {
                                continuation.resume(throwing: WindowsIOError.operationFailed(error))
                                return
                            }
                        }
                    }
                    continuation.resume()
                }
            }
        }

        /// Gets file attributes asynchronously
        static func getFileAttributes(at path: String) async throws -> WIN32_FILE_ATTRIBUTE_DATA {
            try await withCheckedThrowingContinuation { continuation in
                Task.detached {
                    var attributeData = WIN32_FILE_ATTRIBUTE_DATA()
                    let success = path.withCString(encodedAs: UTF16.self) { pathPtr in
                        GetFileAttributesExW(pathPtr, GetFileExInfoStandard, &attributeData)
                    }

                    if !success {
                        continuation.resume(throwing: WindowsIOError.operationFailed(GetLastError()))
                    } else {
                        continuation.resume(returning: attributeData)
                    }
                }
            }
        }

        /// Lists directory contents asynchronously
        static func listDirectory(at path: String) async throws -> [String] {
            try await withCheckedThrowingContinuation { continuation in
                Task.detached {
                    var results: [String] = []
                    var findData = WIN32_FIND_DATAW()

                    let searchPath = path + "\\*"
                    let handle = searchPath.withCString(encodedAs: UTF16.self) { pathPtr in
                        FindFirstFileW(pathPtr, &findData)
                    }

                    if handle == INVALID_HANDLE_VALUE {
                        let error = GetLastError()
                        if error == DWORD(ERROR_FILE_NOT_FOUND) || error == DWORD(ERROR_PATH_NOT_FOUND) {
                            continuation.resume(returning: [])
                        } else {
                            continuation.resume(throwing: WindowsIOError.operationFailed(error))
                        }
                        return
                    }

                    defer { FindClose(handle) }

                    repeat {
                        let fileName = withUnsafePointer(to: findData.cFileName) { ptr in
                            ptr.withMemoryRebound(to: UInt16.self, capacity: 260) { wcharPtr in
                                String(decodingCString: wcharPtr, as: UTF16.self)
                            }
                        }

                        if fileName != "." && fileName != ".." {
                            results.append(fileName)
                        }
                    } while FindNextFileW(handle, &findData)

                    continuation.resume(returning: results)
                }
            }
        }

        /// Creates a symbolic link asynchronously
        static func createSymbolicLink(from source: String, to destination: String, isDirectory: Bool) async throws {
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                Task.detached {
                    let flags: DWORD = isDirectory
                        ? DWORD(SYMBOLIC_LINK_FLAG_DIRECTORY | SYMBOLIC_LINK_FLAG_ALLOW_UNPRIVILEGED_CREATE)
                        : DWORD(SYMBOLIC_LINK_FLAG_ALLOW_UNPRIVILEGED_CREATE)

                    let result = source.withCString(encodedAs: UTF16.self) { sourcePtr in
                        destination.withCString(encodedAs: UTF16.self) { destPtr in
                            CreateSymbolicLinkW(sourcePtr, destPtr, flags)
                        }
                    }

                    // CreateSymbolicLinkW returns BOOLEAN (which is UInt8), non-zero on success
                    if result == 0 {
                        continuation.resume(throwing: WindowsIOError.operationFailed(GetLastError()))
                    } else {
                        continuation.resume()
                    }
                }
            }
        }
    }
#endif
