//
//  File.System.Copy.swift
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

extension File.System {
    /// Namespace for file copy operations.
    public enum Copy {}
}

// MARK: - Options

extension File.System.Copy {
    /// Options for copy operations.
    public struct Options: Sendable {
        /// Overwrite existing destination.
        public var overwrite: Bool

        /// Copy extended attributes.
        public var copyAttributes: Bool

        /// Follow symbolic links (copy target instead of link).
        public var followSymlinks: Bool

        public init(
            overwrite: Bool = false,
            copyAttributes: Bool = true,
            followSymlinks: Bool = true
        ) {
            self.overwrite = overwrite
            self.copyAttributes = copyAttributes
            self.followSymlinks = followSymlinks
        }
    }
}

// MARK: - Error

extension File.System.Copy {
    /// Errors that can occur during copy operations.
    public enum Error: Swift.Error, Equatable, Sendable {
        case sourceNotFound(File.Path)
        case destinationExists(File.Path)
        case permissionDenied(File.Path)
        case isDirectory(File.Path)
        case copyFailed(errno: Int32, message: String)
    }
}

// MARK: - Core API

extension File.System.Copy {
    /// Copies a file from source to destination with options.
    ///
    /// - Parameters:
    ///   - source: The source file path.
    ///   - destination: The destination file path.
    ///   - options: Copy options.
    /// - Throws: `File.System.Copy.Error` on failure.
    public static func copy(
        from source: File.Path,
        to destination: File.Path,
        options: Options = .init()
    ) throws(Error) {
        #if os(Windows)
            try _copyWindows(from: source, to: destination, options: options)
        #else
            try _copyPOSIX(from: source, to: destination, options: options)
        #endif
    }

}

// MARK: - CustomStringConvertible for Error

extension File.System.Copy.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .sourceNotFound(let path):
            return "Source not found: \(path)"
        case .destinationExists(let path):
            return "Destination already exists: \(path)"
        case .permissionDenied(let path):
            return "Permission denied: \(path)"
        case .isDirectory(let path):
            return "Is a directory: \(path)"
        case .copyFailed(let errno, let message):
            return "Copy failed: \(message) (errno=\(errno))"
        }
    }
}
