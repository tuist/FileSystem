import Foundation
import Logging
import NIOFileSystem
import Path

public enum FileSystemItemType: CaseIterable, Equatable {
    case directory
    case file
}

public enum FileSystemError: Equatable, Error, CustomStringConvertible {
    case moveNotFound(from: AbsolutePath, to: AbsolutePath)
    case makeDirectoryAbsentParent(AbsolutePath)

    public var description: String {
        switch self {
        case let .moveNotFound(from, to):
            return "The file or directory at path \(from.pathString) couldn't be moved to \(to.parentDirectory.pathString). Ensure the source file or directory and the target's parent directory exist."
        case let .makeDirectoryAbsentParent(path):
            return "Couldn't create the directory at path \(path.pathString) because its parent directory doesn't exists."
        }
    }
}

/// Options to configure the move operation.
public enum MoveOptions: String {
    /// When passed, it creates the parent directories of the target path if needed.
    case createTargetParentDirectories
}

/// Options to configure the make directory operation.
public enum MakeDirectoryOptions: String {
    /// When passed, it creates the parent directories if needed.
    case createTargetParentDirectories
}

public protocol FileSysteming {
    func runInTemporaryDirectory<T>(
        prefix: String,
        _ action: @Sendable (_ temporaryDirectory: AbsolutePath) async throws -> T
    ) async throws -> T

    /// It checks for the presence of a file or directory.
    /// - Parameter path: The path to be checked.
    /// - Returns: Returns true if a file or directory exists.
    func exists(_ path: AbsolutePath) async throws -> Bool

    /// It checks for the presence of files and directories.
    /// - Parameters:
    ///   - path: The path to be checked.
    ///   - isDirectory: True if it should be checked that the path represents a directory.
    /// - Returns: Returns true if a file or directory (depending on the `isDirectory` argument) is present.
    func exists(_ path: AbsolutePath, isDirectory: Bool) async throws -> Bool

    /// Creates a file at the given path
    /// - Parameter path: Path where an empty file will be created.
    func touch(_ path: AbsolutePath) async throws

    /// It removes the file or directory at the given path.
    /// - Parameter path: The path to the file or directory to remove.
    func remove(_ path: AbsolutePath) async throws

    /// It removes the file or directory at the given path.
    /// - Parameters:
    ///   - path: The path to the file or directory to remove.
    ///   - recursively: When removing a directory, it removes the sub-directories recursively.
    func remove(_ path: AbsolutePath, recursively: Bool) async throws

    /// Creates a temporary directory and returns its path.
    /// - Parameter prefix: Prefix for the randomly-generated directory name.
    /// - Returns: The path to the directory.
    func makeTemporaryDirectory(prefix: String) async throws -> AbsolutePath

    /// Moves a file or directory from one path to another.
    /// If the parent directory of the target path doesn't exist, it creates it by default.
    /// - Parameters:
    ///   - from: The path to move the file or directory from.
    ///   - to: The path to move the file or directory to.
    func move(from: AbsolutePath, to: AbsolutePath) async throws

    /// Moves a file or directory from one path to another.
    /// - Parameters:
    ///   - from: The path to move the file or directory from.
    ///   - to: The path to move the file or directory to.
    ///   - options: Options to configure the moving operation.
    func move(from: AbsolutePath, to: AbsolutePath, options: [MoveOptions]) async throws

    /// Makes a directory at the given path.
    /// - Parameter at: The path at which the directory will be created
    func makeDirectory(at: AbsolutePath) async throws

    /// Makes a directory at the given path.
    /// - Parameters:
    ///   - at: The path at which the directory will be created
    ///   - options: Options to configure the operation.
    func makeDirectory(at: AbsolutePath, options: [MakeDirectoryOptions]) async throws

    /// Reads the file at path and returns it as data.
    /// - Parameter at: Path to the file to read.
    /// - Returns: The content of the file as data.
    func readFile(at: AbsolutePath) async throws -> Data

    /// Reads the file at a given path, decodes its content using UTF-8 encoding, and returns the content as a String.
    /// - Parameter at: Path to the file to read.
    /// - Returns: The content of the file.
    func readTextFile(at: AbsolutePath) async throws -> String

    /// Reads the file at a given path, decodes its content using the provided encoding, and returns the content as a String.
    /// - Parameters:
    ///   - at: Path to the file to read.
    ///   - encoding: The encoding of the content represented by the data.
    /// - Returns: The content of the file.
    func readTextFile(at: Path.AbsolutePath, encoding: String.Encoding) async throws -> String

    /// Reads a property list file at a given path, and decodes it into the provided decodable type.
    /// - Parameter at: The path to the property list file.
    /// - Returns: The decoded structure.
    func readPlistFile<T: Decodable>(at: AbsolutePath) async throws -> T

    /// Reads a property list file at a given path, and decodes it into the provided decodable type.
    /// - Parameters:
    ///   - at: The path to the property list file.
    ///   - decoder: The property list decoder to use.
    /// - Returns: The decoded instance.
    func readPlistFile<T: Decodable>(at: AbsolutePath, decoder: PropertyListDecoder) async throws -> T

    /// Reads a JSON  file at a given path, and decodes it into the provided decodable type.
    /// - Parameter at: The path to the property list file.
    /// - Returns: The decoded structure.
    func readJSONFile<T: Decodable>(at: AbsolutePath) async throws -> T

    /// Reads a JSON file at a given path, and decodes it into the provided decodable type.
    /// - Parameters:
    ///   - at: The path to the property list file.
    ///   - decoder: The JSON decoder to use.
    /// - Returns: The decoded instance.
    func readJSONFile<T: Decodable>(at: AbsolutePath, decoder: JSONDecoder) async throws -> T

//    /// Returns the current path.
    //       func inTemporaryDirectory(_ closure: @escaping (AbsolutePath) async throws -> Void) async throws
    //       func inTemporaryDirectory(_ closure: (AbsolutePath) throws -> Void) throws
    //       func inTemporaryDirectory(removeOnCompletion: Bool, _ closure: (AbsolutePath) throws -> Void) throws
    //       func inTemporaryDirectory<Result>(_ closure: (AbsolutePath) throws -> Result) throws -> Result
    //       func inTemporaryDirectory<Result>(removeOnCompletion: Bool, _ closure: (AbsolutePath) throws -> Result) throws ->
    //       Result
//
//       func replace(_ to: AbsolutePath, with: AbsolutePath) throws
//       func copy(from: AbsolutePath, to: AbsolutePath) throws
//       /// Determine temporary directory either default for user or specified by ENV variable
//       func write(_ content: String, path: AbsolutePath, atomically: Bool) throws
//       func locateDirectoryTraversingParents(from: AbsolutePath, path: String) -> AbsolutePath?
//       func locateDirectory(_ path: String, traversingFrom from: AbsolutePath) throws -> AbsolutePath?
//       func files(in path: AbsolutePath, nameFilter: Set<String>?, extensionFilter: Set<String>?) -> Set<AbsolutePath>
//       func glob(_ path: AbsolutePath, glob: String) -> [AbsolutePath]
//       func throwingGlob(_ path: AbsolutePath, glob: String) throws -> [AbsolutePath]
//       func linkFile(atPath: AbsolutePath, toPath: AbsolutePath) throws
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

    public func exists(_ path: AbsolutePath) async throws -> Bool {
        logger?.debug("Checking if a file or directory exists at path \(path.pathString)")
        let info = try await NIOFileSystem.FileSystem.shared.info(forFileAt: .init(path.pathString))
        return info != nil
    }

    public func exists(_ path: AbsolutePath, isDirectory: Bool) async throws -> Bool {
        if isDirectory {
            logger?.debug("Checking if a directory exists at path \(path.pathString)")
        } else {
            logger?.debug("Checking if a file exists at path \(path.pathString)")
        }
        guard let info = try await NIOFileSystem.FileSystem.shared.info(forFileAt: .init(path.pathString)) else {
            return false
        }
        return info.type == (isDirectory ? .directory : .regular)
    }

    public func touch(_ path: Path.AbsolutePath) async throws {
        logger?.debug("Touching a file at path \(path.pathString)")
        _ = try await NIOFileSystem.FileSystem.shared.withFileHandle(forWritingAt: .init(path.pathString)) { writer in
            try await writer.write(contentsOf: "".data(using: .utf8)!, toAbsoluteOffset: 0)
        }
    }

    public func remove(_ path: Path.AbsolutePath) async throws {
        try await remove(path, recursively: true)
    }

    public func remove(_ path: AbsolutePath, recursively: Bool) async throws {
        if recursively {
            logger?.debug("Removing the directory at path recursively: \(path.pathString)")
        } else {
            logger?.debug("Removing the file or directory at path: \(path.pathString)")
        }
        try await NIOFileSystem.FileSystem.shared.removeItem(at: .init(path.pathString), recursively: recursively)
    }

    public func makeTemporaryDirectory(prefix: String) async throws -> AbsolutePath {
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

    public func move(from: Path.AbsolutePath, to: Path.AbsolutePath) async throws {
        try await move(from: from, to: to, options: [.createTargetParentDirectories])
    }

    public func move(from: AbsolutePath, to: AbsolutePath, options: [MoveOptions]) async throws {
        if options.isEmpty {
            logger?.debug("Moving the file or directory from path \(from.pathString) to \(to.pathString)")
        } else {
            logger?
                .debug(
                    "Moving the file or directory from path \(from.pathString) to \(to.pathString) with options: \(options.map(\.rawValue).joined(separator: ", "))"
                )
        }
        do {
            if options.contains(.createTargetParentDirectories) {
                if !(try await exists(to.parentDirectory, isDirectory: true)) {
                    try await makeDirectory(at: to.parentDirectory, options: [.createTargetParentDirectories])
                }
            }
            try await NIOFileSystem.FileSystem.shared.moveItem(at: .init(from.pathString), to: .init(to.pathString))
        } catch let error as NIOFileSystem.FileSystemError {
            if error.code == .notFound {
                throw FileSystemError.moveNotFound(from: from, to: to)
            } else {
                throw error
            }
        }
    }

    public func makeDirectory(at: Path.AbsolutePath) async throws {
        try await makeDirectory(at: at, options: [.createTargetParentDirectories])
    }

    public func makeDirectory(at: Path.AbsolutePath, options: [MakeDirectoryOptions]) async throws {
        if options.isEmpty {
            logger?
                .debug(
                    "Creating directory at path \(at.pathString) with options: \(options.map(\.rawValue).joined(separator: ", "))"
                )
        } else {
            logger?.debug("Creating directory at path \(at.pathString)")
        }
        do {
            try await NIOFileSystem.FileSystem.shared.createDirectory(
                at: .init(at.pathString),
                withIntermediateDirectories: options
                    .contains(.createTargetParentDirectories)
            )
        } catch let error as NIOFileSystem.FileSystemError {
            if error.code == .invalidArgument {
                throw FileSystemError.makeDirectoryAbsentParent(at)
            } else {
                throw error
            }
        }
    }

    public func readFile(at: Path.AbsolutePath) async throws -> Data {
        let handle = try await NIOFileSystem.FileSystem.shared.openFile(forReadingAt: .init(at.pathString), options: .init())
        let result: Result<Data, Error>
        do {
            var bytes: [UInt8] = []
            for try await var chunk in handle.readChunks() {
                let chunkBytes = chunk.readBytes(length: chunk.capacity) ?? []
                bytes.append(contentsOf: chunkBytes)
            }
            result = .success(Data(bytes))
        } catch {
            result = .failure(error)
        }
        try await handle.close()
        switch result {
        case let .success(data): return data
        case let .failure(error): throw error
        }
    }

    public func readTextFile(at: Path.AbsolutePath) async throws -> String {
        try await readTextFile(at: at, encoding: .utf8)
    }

    public func readTextFile(at: Path.AbsolutePath, encoding: String.Encoding) async throws -> String {
        let data = try await readFile(at: at)
        guard let string = String(data: data, encoding: encoding) else {
            return "TODO"
        }
        return string
    }

    public func readPlistFile<T>(at _: Path.AbsolutePath) async throws -> T where T: Decodable {
        // swiftlint:disable:next force_cast
        "TODO" as! T
    }

    public func readPlistFile<T>(at _: Path.AbsolutePath, decoder _: PropertyListDecoder) async throws -> T where T: Decodable {
        // swiftlint:disable:next force_cast
        "TODO" as! T
    }

    public func readJSONFile<T>(at _: Path.AbsolutePath) async throws -> T where T: Decodable {
        // swiftlint:disable:next force_cast
        "TODO" as! T
    }

    public func readJSONFile<T>(at _: Path.AbsolutePath, decoder _: JSONDecoder) async throws -> T where T: Decodable {
        // swiftlint:disable:next force_cast
        "TODO" as! T
    }

    public func runInTemporaryDirectory<T>(
        prefix: String,
        _ action: @Sendable (_ temporaryDirectory: AbsolutePath) async throws -> T
    ) async throws -> T {
        var temporaryDirectory: AbsolutePath! = nil
        var result: Result<T, Error>!
        do {
            temporaryDirectory = try await makeTemporaryDirectory(prefix: prefix)
            result = .success(try await action(temporaryDirectory))
        } catch {
            result = .failure(error)
        }
        if let temporaryDirectory {
            try await remove(temporaryDirectory)
        }
        switch result! {
        case let .success(value): return value
        case let .failure(error): throw error
        }
    }
}
