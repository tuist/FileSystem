//
//  File.System.Read.Full.swift
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

extension File.System.Read {
    /// Read entire file contents into memory.
    public enum Full {}
}

// MARK: - Error

extension File.System.Read.Full {
    /// Errors that can occur during full file read operations.
    public enum Error: Swift.Error, Equatable, Sendable {
        case pathNotFound(File.Path)
        case permissionDenied(File.Path)
        case isDirectory(File.Path)
        case readFailed(errno: Int32, message: String)
        case tooManyOpenFiles
    }
}

// MARK: - Core API

extension File.System.Read.Full {
    /// Reads the entire contents of a file into memory.
    ///
    /// This is the core read primitive - reads all bytes from a file.
    ///
    /// - Parameter path: The path to the file to read.
    /// - Returns: The file contents as an array of bytes.
    /// - Throws: `File.System.Read.Full.Error` on failure.
    public static func read(from path: File.Path) throws(Error) -> [UInt8] {
        #if os(Windows)
            return try _readWindows(from: path)
        #else
            return try _readPOSIX(from: path)
        #endif
    }

}

// MARK: - CustomStringConvertible for Error

extension File.System.Read.Full.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .pathNotFound(let path):
            return "Path not found: \(path)"
        case .permissionDenied(let path):
            return "Permission denied: \(path)"
        case .isDirectory(let path):
            return "Is a directory: \(path)"
        case .readFailed(let errno, let message):
            return "Read failed: \(message) (errno=\(errno))"
        case .tooManyOpenFiles:
            return "Too many open files"
        }
    }
}
