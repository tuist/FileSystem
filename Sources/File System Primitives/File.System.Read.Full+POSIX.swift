//
//  File.System.Read.Full+POSIX.swift
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

    extension File.System.Read.Full {
        /// Reads file contents using POSIX APIs.
        internal static func _readPOSIX(from path: File.Path) throws(Error) -> [UInt8] {
            // Open file for reading
            let fd = open(path.string, O_RDONLY)
            guard fd >= 0 else {
                throw _mapErrno(errno, path: path)
            }

            defer { _ = close(fd) }

            // Get file size via fstat
            var statBuf = stat()
            guard fstat(fd, &statBuf) == 0 else {
                throw _mapErrno(errno, path: path)
            }

            // Check if it's a directory
            if (statBuf.st_mode & S_IFMT) == S_IFDIR {
                throw .isDirectory(path)
            }

            let fileSize = Int(statBuf.st_size)

            // Handle empty file
            if fileSize == 0 {
                return []
            }

            // Allocate buffer and read
            var buffer = [UInt8](repeating: 0, count: fileSize)
            var totalRead = 0

            while totalRead < fileSize {
                let remaining = fileSize - totalRead
                #if canImport(Darwin)
                    let bytesRead = buffer.withUnsafeMutableBufferPointer { ptr -> Int in
                        guard let base = ptr.baseAddress else { return 0 }
                        return Darwin.read(fd, base.advanced(by: totalRead), remaining)
                    }
                #elseif canImport(Glibc)
                    let bytesRead = buffer.withUnsafeMutableBufferPointer { ptr -> Int in
                        guard let base = ptr.baseAddress else { return 0 }
                        return Glibc.read(fd, base.advanced(by: totalRead), remaining)
                    }
                #elseif canImport(Musl)
                    let bytesRead = buffer.withUnsafeMutableBufferPointer { ptr -> Int in
                        guard let base = ptr.baseAddress else { return 0 }
                        return Musl.read(fd, base.advanced(by: totalRead), remaining)
                    }
                #endif

                if bytesRead > 0 {
                    totalRead += bytesRead
                } else if bytesRead == 0 {
                    // EOF reached earlier than expected
                    buffer.removeLast(fileSize - totalRead)
                    break
                } else {
                    // Error
                    if errno == EINTR {
                        continue  // Interrupted, retry
                    }
                    throw _mapErrno(errno, path: path)
                }
            }

            return buffer
        }

        /// Maps errno to read error.
        private static func _mapErrno(_ errno: Int32, path: File.Path) -> Error {
            switch errno {
            case ENOENT:
                return .pathNotFound(path)
            case EACCES, EPERM:
                return .permissionDenied(path)
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
                return .readFailed(errno: errno, message: message)
            }
        }
    }

#endif
