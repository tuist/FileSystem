//
//  File.Descriptor.swift
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
    /// A low-level file descriptor wrapper.
    ///
    /// `File.Descriptor` is a non-copyable type that owns a file descriptor
    /// and ensures it is properly closed when the descriptor goes out of scope.
    ///
    /// This is the core primitive for file I/O. Higher-level types like
    /// `File.Handle` build on top of this.
    ///
    /// ## Example
    /// ```swift
    /// let descriptor = try File.Descriptor.open(path, mode: .read)
    /// defer { try? descriptor.close() }
    /// // use descriptor...
    /// ```
    /// A non-Sendable owning handle. For cross-task usage, either:
    /// - Move into an actor for serialized access
    /// - Use `duplicated()` to create an independent copy
    public struct Descriptor: ~Copyable {
        #if os(Windows)
            @usableFromInline
            internal var _handle: UnsafeSendable<HANDLE?>
        #else
            @usableFromInline
            internal var _fd: Int32
        #endif

        #if os(Windows)
            /// Creates a descriptor from a raw Windows HANDLE.
            @usableFromInline
            internal init(__unchecked handle: HANDLE) {
                self._handle = UnsafeSendable(handle)
            }
        #else
            /// Creates a descriptor from a raw POSIX file descriptor.
            @usableFromInline
            internal init(__unchecked fd: Int32) {
                self._fd = fd
            }
        #endif

        deinit {
            #if os(Windows)
                if let handle = _handle.value, handle != INVALID_HANDLE_VALUE {
                    CloseHandle(handle)
                }
            #else
                if _fd >= 0 {
                    _ = _posixClose(_fd)
                }
            #endif
        }
    }
}

// MARK: - Error

extension File.Descriptor {
    /// Errors that can occur during descriptor operations.
    public enum Error: Swift.Error, Equatable, Sendable {
        case pathNotFound(File.Path)
        case permissionDenied(File.Path)
        case alreadyExists(File.Path)
        case isDirectory(File.Path)
        case tooManyOpenFiles
        case invalidDescriptor
        case openFailed(errno: Int32, message: String)
        case closeFailed(errno: Int32, message: String)
        case duplicateFailed(errno: Int32, message: String)
        case alreadyClosed
    }
}

// MARK: - Mode

extension File.Descriptor {
    /// The mode in which to open a file descriptor.
    public enum Mode: Sendable {
        /// Read-only access.
        case read
        /// Write-only access.
        case write
        /// Read and write access.
        case readWrite
    }
}

// MARK: - Options

extension File.Descriptor {
    /// Options for opening a file descriptor.
    public struct Options: OptionSet, Sendable {
        public let rawValue: UInt32

        public init(rawValue: UInt32) {
            self.rawValue = rawValue
        }

        /// Create the file if it doesn't exist.
        public static let create = Options(rawValue: 1 << 0)

        /// Truncate the file to zero length if it exists.
        public static let truncate = Options(rawValue: 1 << 1)

        /// Fail if the file already exists (used with `.create`).
        public static let exclusive = Options(rawValue: 1 << 2)

        /// Append to the file.
        public static let append = Options(rawValue: 1 << 3)

        /// Do not follow symbolic links.
        public static let noFollow = Options(rawValue: 1 << 4)

        /// Close the file descriptor on exec.
        public static let closeOnExec = Options(rawValue: 1 << 5)
    }
}

// MARK: - Properties

extension File.Descriptor {
    #if os(Windows)
        /// The raw Windows HANDLE, or `nil` if closed.
        @inlinable
        public var rawHandle: HANDLE? {
            _handle.value
        }

        /// Whether this descriptor is valid (not closed).
        @inlinable
        public var isValid: Bool {
            if let handle = _handle.value {
                return handle != INVALID_HANDLE_VALUE
            }
            return false
        }
    #else
        /// The raw POSIX file descriptor, or -1 if closed.
        @inlinable
        public var rawValue: Int32 {
            _fd
        }

        /// Whether this descriptor is valid (not closed).
        @inlinable
        public var isValid: Bool {
            _fd >= 0
        }
    #endif
}

// MARK: - Core API

extension File.Descriptor {
    /// Opens a file and returns a descriptor.
    ///
    /// - Parameters:
    ///   - path: The path to the file.
    ///   - mode: The access mode.
    ///   - options: Additional options.
    /// - Returns: A file descriptor.
    /// - Throws: `File.Descriptor.Error` on failure.
    public static func open(
        _ path: File.Path,
        mode: Mode,
        options: Options = [.closeOnExec]
    ) throws(Error) -> File.Descriptor {
        #if os(Windows)
            return try _openWindows(path, mode: mode, options: options)
        #else
            return try _openPOSIX(path, mode: mode, options: options)
        #endif
    }

    /// Closes the file descriptor.
    ///
    /// After calling this method, the descriptor is invalid and cannot be used.
    ///
    /// - Throws: `File.Descriptor.Error` on failure.
    public consuming func close() throws(Error) {
        #if os(Windows)
            guard let handle = _handle.value, handle != INVALID_HANDLE_VALUE else {
                throw .alreadyClosed
            }
            guard CloseHandle(handle) else {
                let error = GetLastError()
                throw .closeFailed(errno: Int32(error), message: Self._formatWindowsError(error))
            }
            _handle = UnsafeSendable(INVALID_HANDLE_VALUE)  // Only invalidate after successful close
        #else
            guard _fd >= 0 else {
                throw .alreadyClosed
            }
            let fd = _fd
            _fd = -1  // Invalidate first - fd is consumed regardless of close() result
            let closeResult = _posixClose(fd)
            guard closeResult == 0 else {
                throw .closeFailed(errno: errno, message: String(cString: strerror(errno)))
            }
        #endif
    }

    /// Duplicates the file descriptor.
    ///
    /// Creates a new file descriptor that refers to the same open file.
    /// Both descriptors can be used independently and must be closed separately.
    ///
    /// ## Example
    /// ```swift
    /// let original = try File.Descriptor.open(path, mode: .read)
    /// let duplicate = try original.duplicated()
    /// // Both can be used independently
    /// ```
    ///
    /// - Returns: A new file descriptor referring to the same file.
    /// - Throws: `File.Descriptor.Error.duplicateFailed` on failure.
    public func duplicated() throws(Error) -> File.Descriptor {
        #if os(Windows)
            guard let handle = _handle.value, handle != INVALID_HANDLE_VALUE else {
                throw .invalidDescriptor
            }

            var duplicateHandle: HANDLE?
            let currentProcess = GetCurrentProcess()

            guard
                DuplicateHandle(
                    currentProcess,
                    handle,
                    currentProcess,
                    &duplicateHandle,
                    0,
                    false,
                    DWORD(DUPLICATE_SAME_ACCESS)
                )
            else {
                throw .duplicateFailed(
                    errno: Int32(GetLastError()),
                    message: "DuplicateHandle failed"
                )
            }

            guard let newHandle = duplicateHandle else {
                throw .duplicateFailed(errno: 0, message: "DuplicateHandle returned nil")
            }

            return File.Descriptor(__unchecked: newHandle)
        #else
            guard _fd >= 0 else {
                throw .invalidDescriptor
            }

            let newFd = dup(_fd)
            guard newFd >= 0 else {
                throw .duplicateFailed(errno: errno, message: String(cString: strerror(errno)))
            }

            return File.Descriptor(__unchecked: newFd)
        #endif
    }
}

// MARK: - CustomStringConvertible for Error

extension File.Descriptor.Error: CustomStringConvertible {
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
        case .tooManyOpenFiles:
            return "Too many open files"
        case .invalidDescriptor:
            return "Invalid file descriptor"
        case .openFailed(let errno, let message):
            return "Open failed: \(message) (errno=\(errno))"
        case .closeFailed(let errno, let message):
            return "Close failed: \(message) (errno=\(errno))"
        case .duplicateFailed(let errno, let message):
            return "Duplicate failed: \(message) (errno=\(errno))"
        case .alreadyClosed:
            return "Descriptor already closed"
        }
    }
}

// MARK: - POSIX Close Helper

#if !os(Windows)
    /// Close a file descriptor with POSIX semantics.
    ///
    /// Treats EINTR as "closed" - the file descriptor is consumed
    /// regardless of whether the kernel completed all cleanup.
    /// This follows the POSIX.1-2008 specification where a descriptor
    /// is always invalid after close(), even if EINTR occurs.
    ///
    /// - Parameter fd: The file descriptor to close.
    /// - Returns: 0 on success, -1 on error (with errno set).
    @inline(__always)
    internal func _posixClose(_ fd: Int32) -> Int32 {
        #if canImport(Darwin)
            let result = Darwin.close(fd)
        #else
            let result = close(fd)
        #endif

        // EINTR on close is treated as closed - the fd is now invalid
        // and must not be retried (which would potentially close a recycled fd)
        if result == -1 && errno == EINTR {
            return 0
        }
        return result
    }
#endif

// MARK: - UnsafeSendable Helper

/// A wrapper to make non-Sendable types sendable when we know it's safe.
@usableFromInline
internal struct UnsafeSendable<T>: @unchecked Sendable {
    @usableFromInline
    var value: T

    @usableFromInline
    init(_ value: T) {
        self.value = value
    }
}
