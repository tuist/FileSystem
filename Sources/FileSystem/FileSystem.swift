import Foundation
import Logging
import NIOCore
import NIOFileSystem
import Path
import ZIPFoundation
import Glob

public enum FileSystemItemType: CaseIterable, Equatable {
    case directory
    case file
}

public enum FileSystemError: Equatable, Error, CustomStringConvertible {
    case moveNotFound(from: AbsolutePath, to: AbsolutePath)
    case makeDirectoryAbsentParent(AbsolutePath)
    case readInvalidEncoding(String.Encoding, path: AbsolutePath)
    case cantEncodeText(String, String.Encoding)
    case replacingItemAbsent(replacingPath: AbsolutePath, replacedPath: AbsolutePath)
    case copiedItemAbsent(copiedPath: AbsolutePath, intoPath: AbsolutePath)
    case absentSymbolicLink(AbsolutePath)

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
        case let .replacingItemAbsent(replacingPath, replacedPath):
            return "Couldn't replace file or directory at \(replacedPath.pathString) with item at \(replacingPath.pathString) because the latter doesn't exist."
        case let .copiedItemAbsent(copiedPath, intoPath):
            return "Couldn't copy the file or directory at \(copiedPath.pathString) to \(intoPath.pathString) because the former doesn't exist."
        case let .absentSymbolicLink(path):
            return "Couldn't resolve the symbolic link at path \(path.pathString) because it doesn't exist."
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

    /// Returns the size of a file at a given path. If the file doesn't exist, it returns nil.
    /// - Parameter at: Path to the file whose size will be returned.
    /// - Returns: The file size, otherwise `nil`
    func fileSizeInBytes(at: AbsolutePath) async throws -> Int64?

    /// Given a path, it replaces it with the file or directory at the other path.
    /// - Parameters:
    ///   - to: The path to be replaced.
    ///   - with: The path to the directory or file to replace the other path with.
    func replace(_ to: AbsolutePath, with: AbsolutePath) async throws

    /// Given a path, it copies the file or directory to another path.
    /// - Parameters:
    ///   - to: The path to the file or directory to be copied.
    ///   - with: The path to copy the file or directory to.
    func copy(_ to: AbsolutePath, to: AbsolutePath) async throws

    /// Given a path, it traverses the hierarcy until it finds a file or directory whose absolute path is formed by concatenating
    /// the looked up path and the given relative path. The search stops when the file-system root path, `/`, is reached.
    ///
    /// - Parameters:
    ///   - from: The path to traverse plan. This one will also be checked against.
    ///   - relativePath: The relative path to append to every traversed path.
    ///
    /// - Returns: The found path. Otherwise it returns `nil`.
    func locateTraversingUp(from: AbsolutePath, relativePath: RelativePath) async throws -> AbsolutePath?

    /// Creates a symlink.
    /// - Parameters:
    ///   - from: The path where the symlink is created.
    ///   - to: The path the symlink points to.
    func createSymbolicLink(from: AbsolutePath, to: AbsolutePath) async throws

    /// Given a symlink, it resolves it returning the path to the file or directory the symlink is pointing to.
    /// - Parameter symlinkPath: The absolute path to the symlink.
    /// - Returns: The resolved path.
    func resolveSymbolicLink(_ symlinkPath: AbsolutePath) async throws -> AbsolutePath

    /// Zips a file or the content of a given directory.
    /// - Parameters:
    ///   - path: Path to file or directory. When the path to a file is provided, the file is zipped. When the path points to a directory, the content of the directory is zipped.
    ///   - to: Path to where the zip file will be created.
    func zipFileOrDirectoryContent(at path: AbsolutePath, to: AbsolutePath) async throws
    
    /// Unzips a zip file.
    /// - Parameters:
    ///   - zipPath: Path to the zip file.
    ///   - to: Path to the directory into which the content will be unzipped.
    func unzip(_ zipPath: AbsolutePath, to: AbsolutePath) async throws
    
    
    /// Looks up files and directories that match a set of glob patterns.
    /// - Parameters:
    ///   - directory: Base absolute directory that glob patterns are relative to.
    ///   - include: A list of glob patterns.
    /// - Returns: An async sequence to get the results.
    func glob(directory: Path.AbsolutePath, include: [String]) throws -> AnyThrowingAsyncSequenceable<Path.AbsolutePath>
    
    /// Looks up files and directories that match a set of glob patterns.
    /// By default it skips hidden files.
    ///
    /// - Parameters:
    ///   - directory: Base absolute directory that glob patterns are relative to.
    ///   - include: A list of glob patterns.
    ///   - include: A list of glob patterns to exclude results.
    ///   - skipHiddenFiles: When true, it skips hidden files.
    /// - Returns: An async sequence to get the results.
    func glob(directory: Path.AbsolutePath,
                     include: [String],
                     exclude: [String],
                     skipHiddenFiles: Bool) throws -> AnyThrowingAsyncSequenceable<Path.AbsolutePath>
    
    
    // TODO:
    //       func changeExtension(path: AbsolutePath, to newExtension: String) throws -> AbsolutePath
    //       func urlSafeBase64MD5(path: AbsolutePath) throws -> String
    //       func fileAttributes(at path: AbsolutePath) throws -> [FileAttributeKey: Any]
    //       func files(in path: AbsolutePath, nameFilter: Set<String>?, extensionFilter: Set<String>?) -> Set<AbsolutePath>
    //       func contentsOfDirectory(_ path: AbsolutePath) throws -> [AbsolutePath]
    //       func filesAndDirectoriesContained(in path: AbsolutePath) throws -> [AbsolutePath]?
}

public struct FileSystem: FileSysteming, Sendable {
    fileprivate let logger: Logger?
    fileprivate let environmentVariables: [String: String]

    public init(environmentVariables: [String: String] = ProcessInfo.processInfo.environment, logger: Logger? = nil) {
        self.environmentVariables = environmentVariables
        self.logger = logger
    }

    public func exists(_ path: AbsolutePath) async throws -> Bool {
        logger?.debug("Checking if a file or directory exists at path \(path.pathString).")
        let info = try await NIOFileSystem.FileSystem.shared.info(forFileAt: .init(path.pathString))
        return info != nil
    }

    public func exists(_ path: AbsolutePath, isDirectory: Bool) async throws -> Bool {
        if isDirectory {
            logger?.debug("Checking if a directory exists at path \(path.pathString).")
        } else {
            logger?.debug("Checking if a file exists at path \(path.pathString).")
        }
        guard let info = try await NIOFileSystem.FileSystem.shared.info(forFileAt: .init(path.pathString)) else {
            return false
        }
        return info.type == (isDirectory ? .directory : .regular)
    }

    public func touch(_ path: Path.AbsolutePath) async throws {
        logger?.debug("Touching a file at path \(path.pathString).")
        _ = try await NIOFileSystem.FileSystem.shared.withFileHandle(forWritingAt: .init(path.pathString)) { writer in
            try await writer.write(contentsOf: "".data(using: .utf8)!, toAbsoluteOffset: 0)
        }
    }

    public func remove(_ path: Path.AbsolutePath) async throws {
        try await remove(path, recursively: true)
    }

    public func remove(_ path: AbsolutePath, recursively: Bool) async throws {
        if recursively {
            logger?.debug("Removing the directory at path recursively: \(path.pathString).")
        } else {
            logger?.debug("Removing the file or directory at path: \(path.pathString).")
        }
        try await NIOFileSystem.FileSystem.shared.removeItem(at: .init(path.pathString), recursively: recursively)
    }

    public func makeTemporaryDirectory(prefix: String) async throws -> AbsolutePath {
        var systemTemporaryDirectory = NSTemporaryDirectory()
        
        /// The path to the directory /var is a symlink to /var/private.
        /// NSTemporaryDirectory() returns the path to the symlink, so the logic here removes the symlink from it.
        if systemTemporaryDirectory.starts(with: "/var/") {
            systemTemporaryDirectory = "/private\(systemTemporaryDirectory)"
        }
        let temporaryDirectory = try AbsolutePath(validating: systemTemporaryDirectory)
            .appending(component: "\(prefix)-\(UUID().uuidString)")
        logger?.debug("Creating a temporary directory at path \(temporaryDirectory.pathString).")
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
            logger?.debug("Moving the file or directory from path \(from.pathString) to \(to.pathString).")
        } else {
            logger?
                .debug(
                    "Moving the file or directory from path \(from.pathString) to \(to.pathString) with options: \(options.map(\.rawValue).joined(separator: ", "))."
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
                    "Creating directory at path \(at.pathString) with options: \(options.map(\.rawValue).joined(separator: ", "))."
                )
        } else {
            logger?.debug("Creating directory at path \(at.pathString).")
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
            logger?.debug("Reading file at path \(path.pathString).")
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
        logger?.debug("Reading text file at path \(path.pathString) using encoding \(encoding.description).")
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
        logger?.debug("Writing text at path \(path.pathString).")
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
        logger?.debug("Reading .plist file at path \(path.pathString).")
        let data = try await readFile(at: path)
        return try decoder.decode(T.self, from: data)
    }

    public func writeAsPlist(_ item: some Encodable, at path: AbsolutePath) async throws {
        try await writeAsPlist(item, at: path, encoder: PropertyListEncoder())
    }

    public func writeAsPlist(_ item: some Encodable, at path: AbsolutePath, encoder: PropertyListEncoder) async throws {
        logger?.debug("Writing .plist at path \(path.pathString).")

        let json = try encoder.encode(item)
        _ = try await NIOFileSystem.FileSystem.shared.withFileHandle(forWritingAt: .init(path.pathString)) { handler in
            try await handler.write(contentsOf: json, toAbsoluteOffset: 0)
        }
    }

    public func readJSONFile<T>(at path: Path.AbsolutePath) async throws -> T where T: Decodable {
        try await readJSONFile(at: path, decoder: JSONDecoder())
    }

    public func readJSONFile<T>(at path: Path.AbsolutePath, decoder: JSONDecoder) async throws -> T where T: Decodable {
        logger?.debug("Reading .json file at path \(path.pathString).")
        let data = try await readFile(at: path)
        return try decoder.decode(T.self, from: data)
    }

    public func writeAsJSON(_ item: some Encodable, at path: AbsolutePath) async throws {
        try await writeAsJSON(item, at: path, encoder: JSONEncoder())
    }

    public func writeAsJSON(_ item: some Encodable, at path: AbsolutePath, encoder: JSONEncoder) async throws {
        logger?.debug("Writing .json at path \(path.pathString).")

        let json = try encoder.encode(item)
        _ = try await NIOFileSystem.FileSystem.shared.withFileHandle(forWritingAt: .init(path.pathString)) { handler in
            try await handler.write(contentsOf: json, toAbsoluteOffset: 0)
        }
    }

    public func replace(_ to: AbsolutePath, with path: AbsolutePath) async throws {
        logger?.debug("Replacing file or directory at path \(path.pathString) with item at path \(to.pathString).")
        if !(try await exists(path)) {
            throw FileSystemError.replacingItemAbsent(replacingPath: path, replacedPath: to)
        }
        if !(try await exists(to.parentDirectory)) {
            try await makeDirectory(at: to.parentDirectory)
        }
        try await NIOFileSystem.FileSystem.shared.replaceItem(at: .init(to.pathString), withItemAt: .init(path.pathString))
    }

    public func copy(_ from: AbsolutePath, to: AbsolutePath) async throws {
        logger?.debug("Copying file or directory at path \(from.pathString) to \(to.pathString).")
        if !(try await exists(from)) {
            throw FileSystemError.copiedItemAbsent(copiedPath: from, intoPath: to)
        }
        if !(try await exists(to.parentDirectory)) {
            try await makeDirectory(at: to.parentDirectory)
        }
        try await NIOFileSystem.FileSystem.shared.copyItem(at: .init(from.pathString), to: .init(to.pathString))
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

    public func fileSizeInBytes(at path: AbsolutePath) async throws -> Int64? {
        logger?.debug("Getting the size in bytes of file at path \(path.pathString).")
        guard let info = try await NIOFileSystem.FileSystem.shared.info(
            forFileAt: .init(path.pathString),
            infoAboutSymbolicLink: true
        ) else { return nil }
        return info.size
    }

    public func locateTraversingUp(from: AbsolutePath, relativePath: RelativePath) async throws -> AbsolutePath? {
        logger?.debug("Locating the relative path \(relativePath.pathString) by traversing up from \(from.pathString).")
        let path = from.appending(relativePath)
        if try await exists(path) {
            return path
        }
        if from == .root { return nil }
        return try await locateTraversingUp(from: from.parentDirectory, relativePath: relativePath)
    }

    public func createSymbolicLink(from: AbsolutePath, to: AbsolutePath) async throws {
        logger?.debug("Creating symbolic link from \(from.pathString) to \(to.pathString).")
        try await NIOFileSystem.FileSystem.shared.createSymbolicLink(
            at: FilePath(from.pathString),
            withDestination: FilePath(to.pathString)
        )
    }

    public func resolveSymbolicLink(_ symlinkPath: AbsolutePath) async throws -> AbsolutePath {
        logger?.debug("Resolving symbolink link at path \(symlinkPath.pathString).")
        if !(try await exists(symlinkPath)) {
            throw FileSystemError.absentSymbolicLink(symlinkPath)
        }
        let path = try await NIOFileSystem.FileSystem.shared.destinationOfSymbolicLink(at: FilePath(symlinkPath.pathString))
        return try AbsolutePath(validating: path.string)
    }

    public func zipFileOrDirectoryContent(at path: Path.AbsolutePath, to: Path.AbsolutePath) async throws {
        logger?.debug("Zipping the file or contents of directory at path \(path.pathString) into \(to.pathString)")
        try await NIOSingletons.posixBlockingThreadPool.runIfActive {
            try FileManager.default.zipItem(
                at: URL(fileURLWithPath: path.pathString),
                to: URL(fileURLWithPath: to.pathString),
                shouldKeepParent: false
            )
        }
    }

    public func unzip(_ zipPath: Path.AbsolutePath, to: Path.AbsolutePath) async throws {
        logger?.debug("Unzipping the file at path \(zipPath.pathString) to \(to.pathString)")
        try await NIOSingletons.posixBlockingThreadPool.runIfActive {
            try FileManager.default.unzipItem(
                at: URL(fileURLWithPath: zipPath.pathString),
                to: URL(fileURLWithPath: to.pathString)
            )
        }
    }
    
    public func glob(directory: Path.AbsolutePath, include: [String]) throws -> AnyThrowingAsyncSequenceable<Path.AbsolutePath> {
        try self.glob(directory: directory,
                      include: include,
                      exclude: [],
                      skipHiddenFiles: true)
    }
    
    public func glob(directory: Path.AbsolutePath,
                     include: [String],
                     exclude: [String],
                     skipHiddenFiles: Bool) throws -> AnyThrowingAsyncSequenceable<Path.AbsolutePath> {
        var logMessage = "Looking up files and directories from \(directory.pathString) that match the glob patterns \(include.joined(separator: ", ")) excluding the ones that match the glob patterns \(exclude.joined(separator: ", "))."
        if skipHiddenFiles {
            logMessage = "\(logMessage). Hidden files are skipped."
        }
        logger?.debug("\(logMessage)")
        let stream = try Glob.search(directory: URL.init(string: directory.pathString)!,
                                     include: include.map({ try .init($0) }),
                                     exclude: exclude.map({ try .init($0) }),
                                     skipHiddenFiles: skipHiddenFiles)
        return stream.map({ try! Path.AbsolutePath.init(validating: $0.path()) }).eraseToAnyThrowingAsyncSequenceable()
    }
}

public extension AnyThrowingAsyncSequenceable where Element == Path.AbsolutePath {
    func collect() async throws -> [Path.AbsolutePath] {
        return try await self.reduce(into: Array<Path.AbsolutePath>(), { $0.append($1) })
    }
}
