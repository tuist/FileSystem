import Foundation
import Logging
import Path

public enum FileSystemItemType: CaseIterable, Equatable {
    case directory
    case file
}

public protocol FileSysteming {
    func createTemporaryDirectory(prefix: String) throws -> AbsolutePath
    func runInTemporaryDirectory<T>(
        prefix: String,
        _ action: @Sendable (_ temporaryDirectory: AbsolutePath) async throws -> T
    ) async throws -> T
    func exists(_ path: AbsolutePath) -> Bool
    func exists(_ path: AbsolutePath, isDirectory: Bool) -> Bool
    func touch(_ path: AbsolutePath) throws
}

public struct FileSystem: FileSysteming {
    fileprivate let logger: Logger?
    fileprivate let environmentVariables: [String: String]

    public init(environmentVariables: [String: String] = ProcessInfo.processInfo.environment, logger: Logger? = nil) {
        self.environmentVariables = environmentVariables
        self.logger = logger
    }

    public func createTemporaryDirectory(prefix: String) throws -> AbsolutePath {
        let systemTemporaryDirectory = NSTemporaryDirectory()
        let temporaryDirectory = try AbsolutePath(validating: systemTemporaryDirectory)
            .appending(component: "\(prefix)-\(UUID().uuidString)")
        logger?.debug("Creating a temporary directory at path \(temporaryDirectory.pathString)")
        try FileManager.default.createDirectory(
            at: URL(fileURLWithPath: temporaryDirectory.pathString),
            withIntermediateDirectories: true
        )
        return temporaryDirectory
    }

    public func exists(_ path: AbsolutePath) -> Bool {
        logger?.debug("Checking if a file or directory exists at path \(path.pathString)")
        return FileManager.default.fileExists(atPath: path.pathString)
    }

    public func exists(_ path: AbsolutePath, isDirectory: Bool) -> Bool {
        if isDirectory {
            logger?.debug("Checking if a directory exists at path \(path.pathString)")
        } else {
            logger?.debug("Checking if a file exists at path \(path.pathString)")
        }
        var checkedIsDirectory: ObjCBool = false
        let exists = FileManager.default.fileExists(atPath: path.pathString, isDirectory: &checkedIsDirectory)
        return exists && checkedIsDirectory.boolValue == isDirectory
    }

    public func runInTemporaryDirectory<T>(
        prefix: String,
        _ action: @Sendable (_ temporaryDirectory: AbsolutePath) async throws -> T
    ) async throws -> T {
        let temporaryDirectory = try createTemporaryDirectory(prefix: prefix)
        defer {
            try? self.remove(temporaryDirectory)
        }
        return try await action(temporaryDirectory)
    }

    public func remove(_ path: AbsolutePath) throws {
        logger?.debug("Removing directory or file at path: \(path.pathString)")
        try FileManager.default.removeItem(atPath: path.pathString)
    }

    public func touch(_ path: Path.AbsolutePath) throws {
        logger?.debug("Touching a file at path \(path.pathString)")
        try "".write(toFile: path.pathString, atomically: true, encoding: .utf8)
    }
}
