// File.System.Write.Atomic.swift
// Atomic file writing with crash-safety guarantees
//
// This module provides atomic file writes using the standard pattern:
//   1. Write to a temporary file in the same directory
//   2. Sync the file to disk (fsync)
//   3. Atomically rename temp → destination (rename is atomic on POSIX/NTFS)
//   4. Sync the directory to ensure the rename is persisted
//
// This guarantees that on any crash or power failure, you either have:
//   - The complete new file, or
//   - The complete old file (or no file if it didn't exist)
// You never get a partial/corrupted file.

#if canImport(Darwin)
    import Darwin
#elseif canImport(Glibc)
    import Glibc
#elseif canImport(Musl)
    import Musl
#elseif os(Windows)
    import WinSDK
#endif

extension File.System.Write {
    /// Atomic file writing with crash-safety guarantees.
    public enum Atomic {

        // MARK: - Strategy

        /// Controls behavior when the destination file already exists.
        public enum Strategy: Sendable {
            /// Replace the existing file atomically (default).
            case replaceExisting

            /// Fail if the destination already exists.
            case noClobber
        }

        // MARK: - Durability

        /// Controls the durability guarantees for file synchronization.
        ///
        /// Higher durability modes provide stronger crash-safety but slower performance.
        public enum Durability: Sendable {
            /// Full synchronization with F_FULLFSYNC on macOS (default).
            ///
            /// Guarantees data is written to physical storage and survives power loss.
            /// Slowest but safest option.
            case full

            /// Data-only synchronization without metadata sync where available.
            ///
            /// Uses fdatasync() on Linux or F_BARRIERFSYNC on macOS if available.
            /// Faster than `.full` but still durable for most use cases.
            /// Falls back to fsync if platform-specific optimizations unavailable.
            case dataOnly

            /// No synchronization - data may be buffered in OS caches.
            ///
            /// Fastest option but provides no crash-safety guarantees.
            /// Suitable for caches, temporary files, or build artifacts.
            case none
        }

        // MARK: - Options

        /// Options controlling atomic write behavior.
        public struct Options: Sendable {
            public var strategy: Strategy
            public var durability: Durability
            public var preservePermissions: Bool
            public var preserveOwnership: Bool
            public var strictOwnership: Bool
            public var preserveTimestamps: Bool
            public var preserveExtendedAttributes: Bool
            public var preserveACLs: Bool

            public init(
                strategy: Strategy = .replaceExisting,
                durability: Durability = .full,
                preservePermissions: Bool = true,
                preserveOwnership: Bool = false,
                strictOwnership: Bool = false,
                preserveTimestamps: Bool = false,
                preserveExtendedAttributes: Bool = false,
                preserveACLs: Bool = false
            ) {
                self.strategy = strategy
                self.durability = durability
                self.preservePermissions = preservePermissions
                self.preserveOwnership = preserveOwnership
                self.strictOwnership = strictOwnership
                self.preserveTimestamps = preserveTimestamps
                self.preserveExtendedAttributes = preserveExtendedAttributes
                self.preserveACLs = preserveACLs
            }
        }

        // MARK: - Error

        public enum Error: Swift.Error, Equatable, Sendable {
            case parentNotFound(path: String)
            case parentNotDirectory(path: String)
            case parentAccessDenied(path: String)
            case destinationStatFailed(path: String, errno: Int32, message: String)
            case tempFileCreationFailed(directory: String, errno: Int32, message: String)
            case writeFailed(bytesWritten: Int, bytesExpected: Int, errno: Int32, message: String)
            case syncFailed(errno: Int32, message: String)
            case closeFailed(errno: Int32, message: String)
            case metadataPreservationFailed(operation: String, errno: Int32, message: String)
            case renameFailed(from: String, to: String, errno: Int32, message: String)
            case destinationExists(path: String)
            case directorySyncFailed(path: String, errno: Int32, message: String)
        }

        // MARK: - Core API

        /// Atomically writes bytes to a file path.
        ///
        /// This is the core primitive - all other write operations compose on top of this.
        ///
        /// ## Guarantees
        /// - Either the file exists with complete contents, or the original state is preserved
        /// - On success, data is synced to physical storage (survives power loss)
        /// - Safe to call concurrently for different paths
        ///
        /// ## Requirements
        /// - Parent directory must exist and be writable
        ///
        /// - Parameters:
        ///   - bytes: The data to write (borrowed, zero-copy)
        ///   - path: Destination file path
        ///   - options: Write options
        /// - Throws: `File.System.Write.Atomic.Error` on failure
        public static func write(
            _ bytes: borrowing Span<UInt8>,
            to path: File.Path,
            options: borrowing Options = Options()
        ) throws(Error) {
            #if os(Windows)
                try WindowsAtomic.writeSpan(bytes, to: path.string, options: options)
            #else
                try POSIXAtomic.writeSpan(bytes, to: path.string, options: options)
            #endif
        }

    }
}

// MARK: - Binary.Serializable

extension File.System.Write.Atomic {
    /// Atomically writes a Binary.Serializable value to a file path.
    ///
    /// Uses `withSerializedBytes` for zero-copy access when the type supports it.
    ///
    /// - Parameters:
    ///   - value: The serializable value to write
    ///   - path: Destination file path
    ///   - options: Write options
    /// - Throws: `File.System.Write.Atomic.Error` on failure
    public static func write<S: Binary.Serializable>(
        _ value: S,
        to path: File.Path,
        options: Options = Options()
    ) throws(Error) {
        try S.withSerializedBytes(value) { (span: borrowing Span<UInt8>) throws(Error) in
            try write(span, to: path, options: options)
        }
    }
}

// MARK: - Internal Helpers

extension File.System.Write.Atomic {
    @usableFromInline
    static func errorMessage(for errno: Int32) -> String {
        #if os(Windows)
            return "error \(errno)"
        #else
            if let cString = strerror(errno) {
                return String(cString: cString)
            }
            return "error \(errno)"
        #endif
    }
}

// MARK: - CustomStringConvertible

extension File.System.Write.Atomic.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .parentNotFound(let path):
            return "Parent directory not found: \(path)"
        case .parentNotDirectory(let path):
            return "Parent path is not a directory: \(path)"
        case .parentAccessDenied(let path):
            return "Access denied to parent directory: \(path)"
        case .destinationStatFailed(let path, let errno, let message):
            return "Failed to stat destination '\(path)': \(message) (errno=\(errno))"
        case .tempFileCreationFailed(let directory, let errno, let message):
            return "Failed to create temp file in '\(directory)': \(message) (errno=\(errno))"
        case .writeFailed(let written, let expected, let errno, let message):
            return "Write failed after \(written)/\(expected) bytes: \(message) (errno=\(errno))"
        case .syncFailed(let errno, let message):
            return "Sync failed: \(message) (errno=\(errno))"
        case .closeFailed(let errno, let message):
            return "Close failed: \(message) (errno=\(errno))"
        case .metadataPreservationFailed(let op, let errno, let message):
            return "Metadata preservation failed (\(op)): \(message) (errno=\(errno))"
        case .renameFailed(let from, let to, let errno, let message):
            return "Rename failed '\(from)' → '\(to)': \(message) (errno=\(errno))"
        case .destinationExists(let path):
            return "Destination already exists (noClobber): \(path)"
        case .directorySyncFailed(let path, let errno, let message):
            return "Directory sync failed '\(path)': \(message) (errno=\(errno))"
        }
    }
}
