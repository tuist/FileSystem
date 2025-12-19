#if os(Windows)
    import Foundation
    import WinSDK

    /// Windows I/O errors with descriptive path information
    enum WindowsIOError: LocalizedError {
        case openFailed(path: String, code: DWORD)
        case readFailed(path: String, code: DWORD)
        case writeFailed(path: String, code: DWORD)
        case operationFailed(path: String, operation: String, code: DWORD)
        case copyFailed(from: String, to: String, code: DWORD)
        case moveFailed(from: String, to: String, code: DWORD)
        case deleteFailed(path: String, code: DWORD)
        case createDirectoryFailed(path: String, code: DWORD)
        case listDirectoryFailed(path: String, code: DWORD)
        case getAttributesFailed(path: String, code: DWORD)
        case createSymlinkFailed(from: String, to: String, code: DWORD)

        var errorDescription: String? {
            switch self {
            case let .openFailed(path, code):
                return "Failed to open file at '\(path)' (error code: \(code))"
            case let .readFailed(path, code):
                return "Failed to read file at '\(path)' (error code: \(code))"
            case let .writeFailed(path, code):
                return "Failed to write file at '\(path)' (error code: \(code))"
            case let .operationFailed(path, operation, code):
                return "Failed to \(operation) at '\(path)' (error code: \(code))"
            case let .copyFailed(from, to, code):
                return "Failed to copy from '\(from)' to '\(to)' (error code: \(code))"
            case let .moveFailed(from, to, code):
                return "Failed to move from '\(from)' to '\(to)' (error code: \(code))"
            case let .deleteFailed(path, code):
                return "Failed to delete '\(path)' (error code: \(code))"
            case let .createDirectoryFailed(path, code):
                return "Failed to create directory at '\(path)' (error code: \(code))"
            case let .listDirectoryFailed(path, code):
                return "Failed to list directory at '\(path)' (error code: \(code))"
            case let .getAttributesFailed(path, code):
                return "Failed to get attributes for '\(path)' (error code: \(code))"
            case let .createSymlinkFailed(from, to, code):
                return "Failed to create symbolic link from '\(from)' to '\(to)' (error code: \(code))"
            }
        }
    }

    /// Windows file operations using Foundation's synchronous APIs.
    /// These are wrapped to provide async/await interface while using
    /// Foundation's well-tested Windows implementations.
    enum WindowsFileOperations {

        /// Reads a file synchronously using Foundation
        static func readFile(at path: String) throws -> Data {
            let url = URL(fileURLWithPath: path)
            do {
                return try Data(contentsOf: url)
            } catch {
                throw WindowsIOError.readFailed(path: path, code: DWORD(GetLastError()))
            }
        }

        /// Writes data to a file synchronously using Foundation
        static func writeFile(at path: String, data: Data) throws {
            let url = URL(fileURLWithPath: path)
            do {
                try data.write(to: url)
            } catch {
                throw WindowsIOError.writeFailed(path: path, code: DWORD(GetLastError()))
            }
        }

        /// Copies a file using WinSDK
        static func copyFile(from source: String, to destination: String) throws {
            let success = source.withCString(encodedAs: UTF16.self) { sourcePtr in
                destination.withCString(encodedAs: UTF16.self) { destPtr in
                    CopyFileW(sourcePtr, destPtr, false)
                }
            }
            if !success {
                throw WindowsIOError.copyFailed(from: source, to: destination, code: GetLastError())
            }
        }

        /// Moves a file using WinSDK
        static func moveFile(from source: String, to destination: String) throws {
            let success = source.withCString(encodedAs: UTF16.self) { sourcePtr in
                destination.withCString(encodedAs: UTF16.self) { destPtr in
                    MoveFileExW(sourcePtr, destPtr, DWORD(MOVEFILE_REPLACE_EXISTING | MOVEFILE_COPY_ALLOWED))
                }
            }
            if !success {
                throw WindowsIOError.moveFailed(from: source, to: destination, code: GetLastError())
            }
        }

        /// Deletes a file using WinSDK
        static func deleteFile(at path: String) throws {
            let success = path.withCString(encodedAs: UTF16.self) { pathPtr in
                DeleteFileW(pathPtr)
            }
            if !success {
                let error = GetLastError()
                // ERROR_FILE_NOT_FOUND is acceptable for delete
                if error != DWORD(ERROR_FILE_NOT_FOUND) {
                    throw WindowsIOError.deleteFailed(path: path, code: error)
                }
            }
        }

        /// Deletes a directory using WinSDK
        static func deleteDirectory(at path: String) throws {
            let success = path.withCString(encodedAs: UTF16.self) { pathPtr in
                RemoveDirectoryW(pathPtr)
            }
            if !success {
                let error = GetLastError()
                if error != DWORD(ERROR_FILE_NOT_FOUND) && error != DWORD(ERROR_PATH_NOT_FOUND) {
                    throw WindowsIOError.deleteFailed(path: path, code: error)
                }
            }
        }

        /// Creates a directory using WinSDK
        static func createDirectory(at path: String, withIntermediateDirectories: Bool) throws {
            if withIntermediateDirectories {
                var currentPath = ""
                let components = path.replacingOccurrences(of: "\\", with: "/").split(separator: "/")

                for (index, component) in components.enumerated() {
                    if index == 0 && component.contains(":") {
                        currentPath = String(component)
                    } else {
                        currentPath += "\\" + component
                    }

                    let success = currentPath.withCString(encodedAs: UTF16.self) { pathPtr in
                        CreateDirectoryW(pathPtr, nil)
                    }

                    if !success {
                        let error = GetLastError()
                        if error != DWORD(ERROR_ALREADY_EXISTS) && error != DWORD(ERROR_ACCESS_DENIED) {
                            if !(index == 0 && component.contains(":")) {
                                throw WindowsIOError.createDirectoryFailed(path: currentPath, code: error)
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
                        throw WindowsIOError.createDirectoryFailed(path: path, code: error)
                    }
                }
            }
        }

        /// Gets file attributes using WinSDK
        static func getFileAttributes(at path: String) throws -> WIN32_FILE_ATTRIBUTE_DATA {
            var attributeData = WIN32_FILE_ATTRIBUTE_DATA()
            let success = path.withCString(encodedAs: UTF16.self) { pathPtr in
                GetFileAttributesExW(pathPtr, GetFileExInfoStandard, &attributeData)
            }
            if !success {
                throw WindowsIOError.getAttributesFailed(path: path, code: GetLastError())
            }
            return attributeData
        }

        /// Lists directory contents using WinSDK
        static func listDirectory(at path: String) throws -> [String] {
            var results: [String] = []
            var findData = WIN32_FIND_DATAW()

            let searchPath = path + "\\*"
            let handle: HANDLE? = searchPath.withCString(encodedAs: UTF16.self) { pathPtr in
                FindFirstFileW(pathPtr, &findData)
            }

            guard let handle, handle != INVALID_HANDLE_VALUE else {
                let error = GetLastError()
                if error == DWORD(ERROR_FILE_NOT_FOUND) || error == DWORD(ERROR_PATH_NOT_FOUND) {
                    return []
                }
                throw WindowsIOError.listDirectoryFailed(path: path, code: error)
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

            return results
        }

        /// Creates a symbolic link using WinSDK
        static func createSymbolicLink(from source: String, to destination: String, isDirectory: Bool) throws {
            let flags: DWORD = isDirectory
                ? DWORD(SYMBOLIC_LINK_FLAG_DIRECTORY | SYMBOLIC_LINK_FLAG_ALLOW_UNPRIVILEGED_CREATE)
                : DWORD(SYMBOLIC_LINK_FLAG_ALLOW_UNPRIVILEGED_CREATE)

            let result = source.withCString(encodedAs: UTF16.self) { sourcePtr in
                destination.withCString(encodedAs: UTF16.self) { destPtr in
                    CreateSymbolicLinkW(sourcePtr, destPtr, flags)
                }
            }

            if result == 0 {
                throw WindowsIOError.createSymlinkFailed(from: source, to: destination, code: GetLastError())
            }
        }
    }

    /// Async wrappers that run synchronous operations without blocking Swift's cooperative thread pool.
    /// Uses a dedicated serial DispatchQueue to ensure I/O operations don't starve the async runtime.
    enum WindowsAsyncFileOperations {
        /// Dedicated queue for Windows I/O operations.
        /// This ensures blocking I/O never exhausts Swift's cooperative thread pool.
        private static let ioQueue = DispatchQueue(
            label: "tuist.filesystem.windows.io",
            qos: .userInitiated
        )

        /// Runs a blocking operation on the dedicated I/O queue and bridges to async/await
        private static func runOnIOQueue<T: Sendable>(
            _ operation: @escaping @Sendable () throws -> T
        ) async throws -> T {
            try await withCheckedThrowingContinuation { continuation in
                ioQueue.async {
                    do {
                        let result = try operation()
                        continuation.resume(returning: result)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
            }
        }

        /// Runs a blocking void operation on the dedicated I/O queue
        private static func runOnIOQueue(
            _ operation: @escaping @Sendable () throws -> Void
        ) async throws {
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                ioQueue.async {
                    do {
                        try operation()
                        continuation.resume()
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
            }
        }

        /// Reads a file asynchronously
        static func readFile(at path: String) async throws -> Data {
            try await runOnIOQueue {
                try WindowsFileOperations.readFile(at: path)
            }
        }

        /// Writes data to a file asynchronously
        static func writeFile(at path: String, data: Data) async throws {
            try await runOnIOQueue {
                try WindowsFileOperations.writeFile(at: path, data: data)
            }
        }

        /// Copies a file asynchronously
        static func copyFile(from source: String, to destination: String) async throws {
            try await runOnIOQueue {
                try WindowsFileOperations.copyFile(from: source, to: destination)
            }
        }

        /// Moves a file asynchronously
        static func moveFile(from source: String, to destination: String) async throws {
            try await runOnIOQueue {
                try WindowsFileOperations.moveFile(from: source, to: destination)
            }
        }

        /// Deletes a file asynchronously
        static func deleteFile(at path: String) async throws {
            try await runOnIOQueue {
                try WindowsFileOperations.deleteFile(at: path)
            }
        }

        /// Deletes a directory asynchronously
        static func deleteDirectory(at path: String) async throws {
            try await runOnIOQueue {
                try WindowsFileOperations.deleteDirectory(at: path)
            }
        }

        /// Creates a directory asynchronously
        static func createDirectory(at path: String, withIntermediateDirectories: Bool) async throws {
            try await runOnIOQueue {
                try WindowsFileOperations.createDirectory(at: path, withIntermediateDirectories: withIntermediateDirectories)
            }
        }

        /// Gets file attributes asynchronously
        static func getFileAttributes(at path: String) async throws -> WIN32_FILE_ATTRIBUTE_DATA {
            try await runOnIOQueue {
                try WindowsFileOperations.getFileAttributes(at: path)
            }
        }

        /// Lists directory contents asynchronously
        static func listDirectory(at path: String) async throws -> [String] {
            try await runOnIOQueue {
                try WindowsFileOperations.listDirectory(at: path)
            }
        }

        /// Creates a symbolic link asynchronously
        static func createSymbolicLink(from source: String, to destination: String, isDirectory: Bool) async throws {
            try await runOnIOQueue {
                try WindowsFileOperations.createSymbolicLink(from: source, to: destination, isDirectory: isDirectory)
            }
        }
    }
#endif
