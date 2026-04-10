//
//  File.Handle.swift
//  swift-file-system
//
//  Created by Coen ten Thije Boonkkamp on 17/12/2025.
//

#if canImport(Darwin)
    import Darwin
#elseif canImport(Glibc)
    import Glibc
#elseif canImport(Musl)
    import Musl
#elseif os(Windows)
    import WinSDK
#endif

extension File {
    /// A managed file handle for reading and writing.
    ///
    /// `File.Handle` is a non-copyable type that owns a file descriptor
    /// along with metadata about how the file was opened. It provides
    /// read, write, and seek operations.
    ///
    /// ## Example
    /// ```swift
    /// var handle = try File.Handle.open(path, mode: .readWrite)
    /// try handle.write(bytes)
    /// try handle.seek(to: 0)
    /// let data = try handle.read(count: 100)
    /// handle.close()
    /// ```
    /// A non-Sendable owning handle. For cross-task usage, move into an actor.
    public struct Handle: ~Copyable {
        /// The underlying file descriptor.
        private var _descriptor: File.Descriptor
        /// The mode this handle was opened with.
        public let mode: Mode
        /// The path this handle was opened for.
        public let path: File.Path

        /// Creates a handle from an existing descriptor.
        internal init(descriptor: consuming File.Descriptor, mode: Mode, path: File.Path) {
            self._descriptor = descriptor
            self.mode = mode
            self.path = path
        }
    }
}

// MARK: - Error

extension File.Handle {
    /// Errors that can occur during handle operations.
    public enum Error: Swift.Error, Equatable, Sendable {
        case pathNotFound(File.Path)
        case permissionDenied(File.Path)
        case alreadyExists(File.Path)
        case isDirectory(File.Path)
        case invalidHandle
        case alreadyClosed
        case seekFailed(errno: Int32, message: String)
        case readFailed(errno: Int32, message: String)
        case writeFailed(errno: Int32, message: String)
        case closeFailed(errno: Int32, message: String)
        case openFailed(errno: Int32, message: String)
    }
}

// MARK: - SeekOrigin

extension File.Handle {
    /// The origin for seek operations.
    public enum SeekOrigin: Sendable {
        /// Seek from the beginning of the file.
        case start
        /// Seek from the current position.
        case current
        /// Seek from the end of the file.
        case end
    }
}

// MARK: - Core API

extension File.Handle {
    /// Opens a file and returns a handle.
    ///
    /// - Parameters:
    ///   - path: The path to the file.
    ///   - mode: The access mode.
    ///   - options: Additional options.
    /// - Returns: A file handle.
    /// - Throws: `File.Handle.Error` on failure.
    public static func open(
        _ path: File.Path,
        mode: Mode,
        options: Options = [.closeOnExec]
    ) throws(Error) -> File.Handle {
        let descriptorMode: File.Descriptor.Mode
        var descriptorOptions: File.Descriptor.Options = []

        switch mode {
        case .read:
            descriptorMode = .read
        case .write:
            descriptorMode = .write
        case .readWrite:
            descriptorMode = .readWrite
        case .append:
            descriptorMode = .write
            descriptorOptions.insert(.append)
        }

        if options.contains(.create) {
            descriptorOptions.insert(.create)
        }
        if options.contains(.truncate) {
            descriptorOptions.insert(.truncate)
        }
        if options.contains(.exclusive) {
            descriptorOptions.insert(.exclusive)
        }
        if options.contains(.noFollow) {
            descriptorOptions.insert(.noFollow)
        }
        if options.contains(.closeOnExec) {
            descriptorOptions.insert(.closeOnExec)
        }

        let descriptor: File.Descriptor
        do {
            descriptor = try File.Descriptor.open(
                path,
                mode: descriptorMode,
                options: descriptorOptions
            )
        } catch let error {
            switch error {
            case .pathNotFound(let p):
                throw .pathNotFound(p)
            case .permissionDenied(let p):
                throw .permissionDenied(p)
            case .alreadyExists(let p):
                throw .alreadyExists(p)
            case .isDirectory(let p):
                throw .isDirectory(p)
            case .openFailed(let errno, let message):
                throw .openFailed(errno: errno, message: message)
            default:
                throw .openFailed(errno: 0, message: "\(error)")
            }
        }

        return File.Handle(descriptor: descriptor, mode: mode, path: path)
    }

    /// Reads up to `count` bytes from the file.
    ///
    /// - Parameter count: Maximum number of bytes to read.
    /// - Returns: The bytes read (may be fewer than requested at EOF).
    /// - Throws: `File.Handle.Error` on failure.
    public mutating func read(count: Int) throws(Error) -> [UInt8] {
        guard _descriptor.isValid else {
            throw .invalidHandle
        }

        var buffer = [UInt8](repeating: 0, count: count)

        #if os(Windows)
            var bytesRead: DWORD = 0
            let success = buffer.withUnsafeMutableBufferPointer { ptr -> Bool in
                guard let base = ptr.baseAddress, let handle = _descriptor.rawHandle else {
                    return false
                }
                return ReadFile(handle, base, DWORD(count), &bytesRead, nil)
            }
            guard success else {
                throw .readFailed(errno: Int32(GetLastError()), message: "ReadFile failed")
            }
            if Int(bytesRead) < count {
                buffer.removeLast(count - Int(bytesRead))
            }
        #elseif canImport(Darwin)
            let bytesRead = buffer.withUnsafeMutableBufferPointer { ptr -> Int in
                guard let base = ptr.baseAddress else { return 0 }
                return Darwin.read(_descriptor.rawValue, base, count)
            }
            if bytesRead < 0 {
                throw .readFailed(errno: errno, message: String(cString: strerror(errno)))
            }
            if bytesRead < count {
                buffer.removeLast(count - bytesRead)
            }
        #elseif canImport(Glibc)
            let bytesRead = buffer.withUnsafeMutableBufferPointer { ptr -> Int in
                guard let base = ptr.baseAddress else { return 0 }
                return Glibc.read(_descriptor.rawValue, base, count)
            }
            if bytesRead < 0 {
                throw .readFailed(errno: errno, message: String(cString: strerror(errno)))
            }
            if bytesRead < count {
                buffer.removeLast(count - bytesRead)
            }
        #endif

        return buffer
    }

    /// Reads bytes into a caller-provided buffer.
    ///
    /// This is the canonical zero-allocation read API. Callers provide the destination buffer.
    ///
    /// - Parameter buffer: Destination buffer. Must remain valid for duration of call.
    /// - Returns: Number of bytes read (0 at EOF).
    /// - Note: May return fewer bytes than buffer size (partial read).
    public mutating func read(into buffer: UnsafeMutableRawBufferPointer) throws(Error) -> Int {
        guard _descriptor.isValid else { throw .invalidHandle }
        guard !buffer.isEmpty else { return 0 }

        #if os(Windows)
            var bytesRead: DWORD = 0
            guard
                ReadFile(
                    _descriptor.rawHandle!,
                    buffer.baseAddress,
                    DWORD(buffer.count),
                    &bytesRead,
                    nil
                )
            else {
                throw .readFailed(errno: Int32(GetLastError()), message: "ReadFile failed")
            }
            return Int(bytesRead)
        #elseif canImport(Darwin)
            let result = Darwin.read(_descriptor.rawValue, buffer.baseAddress!, buffer.count)
            if result < 0 {
                throw .readFailed(errno: errno, message: String(cString: strerror(errno)))
            }
            return result
        #elseif canImport(Glibc)
            let result = Glibc.read(_descriptor.rawValue, buffer.baseAddress!, buffer.count)
            if result < 0 {
                throw .readFailed(errno: errno, message: String(cString: strerror(errno)))
            }
            return result
        #endif
    }

    /// Writes bytes to the file.
    ///
    /// - Parameter bytes: The bytes to write.
    /// - Throws: `File.Handle.Error` on failure.
    public mutating func write(_ bytes: borrowing Span<UInt8>) throws(Error) {
        guard _descriptor.isValid else {
            throw .invalidHandle
        }

        let count = bytes.count
        if count == 0 { return }

        try bytes.withUnsafeBufferPointer { buffer throws(Error) in
            guard let base = buffer.baseAddress else { return }

            #if os(Windows)
                // Loop for partial writes - WriteFile may return fewer bytes than requested
                var totalWritten: Int = 0
                while totalWritten < count {
                    var written: DWORD = 0
                    let remaining = count - totalWritten
                    let ptr = base.advanced(by: totalWritten)
                    let success = WriteFile(
                        _descriptor.rawHandle!,
                        ptr,
                        DWORD(remaining),
                        &written,
                        nil
                    )
                    guard success else {
                        throw .writeFailed(
                            errno: Int32(GetLastError()),
                            message: "WriteFile failed"
                        )
                    }
                    totalWritten += Int(written)
                }
            #elseif canImport(Darwin)
                var totalWritten = 0
                while totalWritten < count {
                    let remaining = count - totalWritten
                    let w = Darwin.write(
                        _descriptor.rawValue,
                        base.advanced(by: totalWritten),
                        remaining
                    )
                    if w > 0 {
                        totalWritten += w
                    } else if w < 0 {
                        if errno == EINTR { continue }
                        throw .writeFailed(errno: errno, message: String(cString: strerror(errno)))
                    }
                }
            #elseif canImport(Glibc)
                var totalWritten = 0
                while totalWritten < count {
                    let remaining = count - totalWritten
                    let w = Glibc.write(
                        _descriptor.rawValue,
                        base.advanced(by: totalWritten),
                        remaining
                    )
                    if w > 0 {
                        totalWritten += w
                    } else if w < 0 {
                        if errno == EINTR { continue }
                        throw .writeFailed(errno: errno, message: String(cString: strerror(errno)))
                    }
                }
            #endif
        }
    }

    /// Seeks to a position in the file.
    ///
    /// - Parameters:
    ///   - offset: The offset to seek to.
    ///   - origin: The origin for the seek.
    /// - Returns: The new position in the file.
    /// - Throws: `File.Handle.Error` on failure.
    @discardableResult
    public mutating func seek(
        to offset: Int64,
        from origin: SeekOrigin = .start
    ) throws(Error) -> Int64 {
        guard _descriptor.isValid else {
            throw .invalidHandle
        }

        #if os(Windows)
            var newPosition: LARGE_INTEGER = LARGE_INTEGER()
            var distance: LARGE_INTEGER = LARGE_INTEGER()
            distance.QuadPart = offset

            let whence: DWORD
            switch origin {
            case .start: whence = DWORD(FILE_BEGIN)
            case .current: whence = DWORD(FILE_CURRENT)
            case .end: whence = DWORD(FILE_END)
            }

            guard SetFilePointerEx(_descriptor.rawHandle!, distance, &newPosition, whence) else {
                throw .seekFailed(errno: Int32(GetLastError()), message: "SetFilePointerEx failed")
            }
            return newPosition.QuadPart
        #else
            let whence: Int32
            switch origin {
            case .start: whence = SEEK_SET
            case .current: whence = SEEK_CUR
            case .end: whence = SEEK_END
            }

            let result = lseek(_descriptor.rawValue, off_t(offset), whence)
            guard result >= 0 else {
                throw .seekFailed(errno: errno, message: String(cString: strerror(errno)))
            }
            return Int64(result)
        #endif
    }

    /// Syncs the file to disk.
    ///
    /// - Throws: `File.Handle.Error` on failure.
    public mutating func sync() throws(Error) {
        guard _descriptor.isValid else {
            throw .invalidHandle
        }

        #if os(Windows)
            guard FlushFileBuffers(_descriptor.rawHandle!) else {
                throw .writeFailed(errno: Int32(GetLastError()), message: "FlushFileBuffers failed")
            }
        #else
            guard fsync(_descriptor.rawValue) == 0 else {
                throw .writeFailed(errno: errno, message: String(cString: strerror(errno)))
            }
        #endif
    }

    /// Closes the handle.
    ///
    /// - Postcondition: `isValid == false`
    /// - Idempotent: second close throws `.alreadyClosed`
    /// - Throws: `File.Handle.Error` on close failure
    public consuming func close() throws(Error) {
        guard _descriptor.isValid else {
            throw .alreadyClosed
        }
        do {
            try _descriptor.close()
        } catch let error {
            switch error {
            case .alreadyClosed:
                throw .alreadyClosed
            case .closeFailed(let errno, let message):
                throw .closeFailed(errno: errno, message: message)
            default:
                throw .closeFailed(errno: 0, message: "\(error)")
            }
        }
    }
}

// MARK: - Properties

extension File.Handle {
    /// Whether this handle is valid (not closed).
    public var isValid: Bool {
        _descriptor.isValid
    }
}

// MARK: - CustomStringConvertible for Error

extension File.Handle.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .pathNotFound(let path):
            return "Path not found: \(path)"
        case .permissionDenied(let path):
            return "Permission denied: \(path)"
        case .alreadyExists(let path):
            return "File already exists: \(path)"
        case .isDirectory(let path):
            return "Is a directory: \(path)"
        case .invalidHandle:
            return "Invalid file handle"
        case .alreadyClosed:
            return "Handle already closed"
        case .seekFailed(let errno, let message):
            return "Seek failed: \(message) (errno=\(errno))"
        case .readFailed(let errno, let message):
            return "Read failed: \(message) (errno=\(errno))"
        case .writeFailed(let errno, let message):
            return "Write failed: \(message) (errno=\(errno))"
        case .closeFailed(let errno, let message):
            return "Close failed: \(message) (errno=\(errno))"
        case .openFailed(let errno, let message):
            return "Open failed: \(message) (errno=\(errno))"
        }
    }
}
