import Foundation
import Logging
import NIOFileSystem
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
    func exists(_ path: AbsolutePath) async throws -> Bool
    func exists(_ path: AbsolutePath, isDirectory: Bool) -> Bool
    func touch(_ path: AbsolutePath) throws

//    /// Returns the current path.
//       var currentPath: AbsolutePath { get }
//
//       /// Returns `AbsolutePath` to home directory
//       var homeDirectory: AbsolutePath { get }
//
//       func replace(_ to: AbsolutePath, with: AbsolutePath) throws
//       func move(from: AbsolutePath, to: AbsolutePath) throws
//       func copy(from: AbsolutePath, to: AbsolutePath) throws
//       func readFile(_ at: AbsolutePath) throws -> Data
//       func readTextFile(_ at: AbsolutePath) throws -> String
//       func readPlistFile<T: Decodable>(_ at: AbsolutePath) throws -> T
//       /// Determine temporary directory either default for user or specified by ENV variable
//       func determineTemporaryDirectory() throws -> AbsolutePath
//       func temporaryDirectory() throws -> AbsolutePath
//       func inTemporaryDirectory(_ closure: @escaping (AbsolutePath) async throws -> Void) async throws
//       func inTemporaryDirectory(_ closure: (AbsolutePath) throws -> Void) throws
//       func inTemporaryDirectory(removeOnCompletion: Bool, _ closure: (AbsolutePath) throws -> Void) throws
//       func inTemporaryDirectory<Result>(_ closure: (AbsolutePath) throws -> Result) throws -> Result
//       func inTemporaryDirectory<Result>(removeOnCompletion: Bool, _ closure: (AbsolutePath) throws -> Result) throws -> Result
//       func write(_ content: String, path: AbsolutePath, atomically: Bool) throws
//       func locateDirectoryTraversingParents(from: AbsolutePath, path: String) -> AbsolutePath?
//       func locateDirectory(_ path: String, traversingFrom from: AbsolutePath) throws -> AbsolutePath?
//       func files(in path: AbsolutePath, nameFilter: Set<String>?, extensionFilter: Set<String>?) -> Set<AbsolutePath>
//       func glob(_ path: AbsolutePath, glob: String) -> [AbsolutePath]
//       func throwingGlob(_ path: AbsolutePath, glob: String) throws -> [AbsolutePath]
//       func linkFile(atPath: AbsolutePath, toPath: AbsolutePath) throws
//       func createFolder(_ path: AbsolutePath) throws
//       func delete(_ path: AbsolutePath) throws
//       func isFolder(_ path: AbsolutePath) -> Bool
//       func touch(_ path: AbsolutePath) throws
//       func contentsOfDirectory(_ path: AbsolutePath) throws -> [AbsolutePath]
//       func urlSafeBase64MD5(path: AbsolutePath) throws -> String
//       func fileSize(path: AbsolutePath) throws -> UInt64
//       func changeExtension(path: AbsolutePath, to newExtension: String) throws -> AbsolutePath
//       func resolveSymlinks(_ path: AbsolutePath) throws -> AbsolutePath
//       func fileAttributes(at path: AbsolutePath) throws -> [FileAttributeKey: Any]
//       func filesAndDirectoriesContained(in path: AbsolutePath) throws -> [AbsolutePath]?
//       func zipItem(at sourcePath: AbsolutePath, to destinationPath: AbsolutePath) throws
//       func unzipItem(at sourcePath: AbsolutePath, to destinationPath: AbsolutePath) throws
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

    public func exists(_ path: AbsolutePath) async throws -> Bool {
        logger?.debug("Checking if a file or directory exists at path \(path.pathString)")
        let info = try await NIOFileSystem.FileSystem.shared.info(forFileAt: .init(path.pathString))
        return info != nil
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
