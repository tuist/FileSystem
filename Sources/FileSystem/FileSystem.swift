import Foundation
import Logging
import NIOCore
import NIOFileSystem
import Path

public enum FileSystemItemType: CaseIterable, Equatable {
    case directory
    case file
}

public enum FileSystemError: Equatable, Error, CustomStringConvertible {
    case moveNotFound(from: AbsolutePath, to: AbsolutePath)
    case makeDirectoryAbsentParent(AbsolutePath)
    case readInvalidEncoding(String.Encoding, path: AbsolutePath)
    case cantEncodeText(String, String.Encoding)

    public var description: String {
        switch self {
        case let .moveNotFound(from, to):
            return "The file or directory at path \(from.pathString) couldn't be moved to \(to.parentDirectory.pathString). Ensure the source file or directory and the target's parent directory exist."
        case let .makeDirectoryAbsentParent(path):
            return "Couldn't create the directory at path \(path.pathString) because its parent directory doesn't exists."
        case let .readInvalidEncoding(encoding, path):
            return "Couldn't text-decode the content of the file at path \(path.pathString) using the encoding \(encoding.description). Ensure that the encoding is the right one."
        case let .cantEncodeText(text, encoding):
            return "Couldn't encode the following text using the encoding \(encoding):\n\(text)"
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

    /// It writes the text at the given path. It encodes the text using UTF-8
    /// - Parameters:
    ///   - text: Text to be written.
    ///   - at: Path at which the text will be written.
    func writeText(_ text: String, at: AbsolutePath) async throws

    /// It writes the text at the given path.
    /// - Parameters:
    ///   - text: Text to be written.
    ///   - at: Path at which the text will be written.
    ///   - encoding: The encoding to encode the text as data.
    func writeText(_ text: String, at: AbsolutePath, encoding: String.Encoding) async throws

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

    /// Given an `Encodable` instance, it encodes it as a Plist, and writes it at the given path.
    /// - Parameters:
    ///   - item: Item to be encoded as Plist.
    ///   - at: Path at which the Plist will be written.
    func writeAsPlist<T: Encodable>(_ item: T, at: AbsolutePath) async throws

    /// Given an `Encodable` instance, it encodes it as a Plist, and writes it at the given path.
    /// - Parameters:
    ///   - item: Item to be encoded as Plist.
    ///   - at: Path at which the Plist will be written.
    ///   - encoder: The PropertyListEncoder instance to encode the item.
    func writeAsPlist<T: Encodable>(_ item: T, at: AbsolutePath, encoder: PropertyListEncoder) async throws

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

    /// Given an `Encodable` instance, it encodes it as a JSON, and writes it at the given path.
    /// - Parameters:
    ///   - item: Item to be encoded as JSON.
    ///   - at: Path at which the JSON will be written.
    func writeAsJSON<T: Encodable>(_ item: T, at: AbsolutePath) async throws

    /// Given an `Encodable` instance, it encodes it as a JSON, and writes it at the given path.
    /// - Parameters:
    ///   - item: Item to be encoded as JSON.
    ///   - at: Path at which the JSON will be written.
    ///   - encoder: The JSONEncoder instance to encode the item.
    func writeAsJSON<T: Encodable>(_ item: T, at: AbsolutePath, encoder: JSONEncoder) async throws

//
//       func replace(_ to: AbsolutePath, with: AbsolutePath) throws
//       func copy(from: AbsolutePath, to: AbsolutePath) throws
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

    public func readFile(at path: Path.AbsolutePath) async throws -> Data {
        try await readFile(at: path, log: true)
    }

    private func readFile(at path: Path.AbsolutePath, log: Bool = false) async throws -> Data {
        if log {
            logger?.debug("Reading file at path \(path.pathString)")
        }
        let handle = try await NIOFileSystem.FileSystem.shared.openFile(forReadingAt: .init(path.pathString), options: .init())

        let result: Result<Data, Error>
        do {
            var bytes: [UInt8] = []
            for try await var chunk in handle.readChunks() {
                let chunkBytes = chunk.readBytes(length: chunk.readableBytes) ?? []
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

    public func readTextFile(at path: Path.AbsolutePath, encoding: String.Encoding) async throws -> String {
        logger?.debug("Reading text file at path \(path.pathString) using encoding \(encoding.description)")
        let data = try await readFile(at: path)
        guard let string = String(data: data, encoding: encoding) else {
            throw FileSystemError.readInvalidEncoding(encoding, path: path)
        }
        return string
    }

    public func writeText(_ text: String, at path: AbsolutePath) async throws {
        try await writeText(text, at: path, encoding: .utf8)
    }

    public func writeText(_ text: String, at path: AbsolutePath, encoding: String.Encoding) async throws {
        logger?.debug("Writing text at path \(path.pathString)")
        guard let data = text.data(using: encoding) else {
            throw FileSystemError.cantEncodeText(text, encoding)
        }
        _ = try await NIOFileSystem.FileSystem.shared.withFileHandle(forWritingAt: .init(path.pathString)) { handler in
            try await handler.write(contentsOf: data, toAbsoluteOffset: 0)
        }
    }

    public func readPlistFile<T>(at path: Path.AbsolutePath) async throws -> T where T: Decodable {
        try await readPlistFile(at: path, decoder: PropertyListDecoder())
    }

    public func readPlistFile<T>(at path: Path.AbsolutePath, decoder: PropertyListDecoder) async throws -> T where T: Decodable {
        logger?.debug("Reading .plist file at path \(path.pathString)")
        let data = try await readFile(at: path)
        return try decoder.decode(T.self, from: data)
    }

    public func writeAsPlist(_ item: some Encodable, at path: AbsolutePath) async throws {
        try await writeAsPlist(item, at: path, encoder: PropertyListEncoder())
    }

    public func writeAsPlist(_ item: some Encodable, at path: AbsolutePath, encoder: PropertyListEncoder) async throws {
        logger?.debug("Writing .plist at path \(path.pathString)")

        let json = try encoder.encode(item)
        _ = try await NIOFileSystem.FileSystem.shared.withFileHandle(forWritingAt: .init(path.pathString)) { handler in
            try await handler.write(contentsOf: json, toAbsoluteOffset: 0)
        }
    }

    public func readJSONFile<T>(at path: Path.AbsolutePath) async throws -> T where T: Decodable {
        try await readJSONFile(at: path, decoder: JSONDecoder())
    }

    public func readJSONFile<T>(at path: Path.AbsolutePath, decoder: JSONDecoder) async throws -> T where T: Decodable {
        logger?.debug("Reading .json file at path \(path.pathString)")
        let data = try await readFile(at: path)
        return try decoder.decode(T.self, from: data)
    }

    public func writeAsJSON(_ item: some Encodable, at path: AbsolutePath) async throws {
        try await writeAsJSON(item, at: path, encoder: JSONEncoder())
    }

    public func writeAsJSON(_ item: some Encodable, at path: AbsolutePath, encoder: JSONEncoder) async throws {
        logger?.debug("Writing .json at path \(path.pathString)")

        let json = try encoder.encode(item)
        _ = try await NIOFileSystem.FileSystem.shared.withFileHandle(forWritingAt: .init(path.pathString)) { handler in
            try await handler.write(contentsOf: json, toAbsoluteOffset: 0)
        }
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
