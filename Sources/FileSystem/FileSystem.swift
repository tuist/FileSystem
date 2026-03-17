import File_System
import File_System_Primitives
import Foundation
import Glob
import Logging
import Path

#if canImport(Darwin)
    import Darwin
#elseif canImport(Glibc)
    import Glibc
#elseif canImport(Musl)
    import Musl
#elseif os(Windows)
    import WinSDK
#endif

#if !os(Windows)
    import ZIPFoundation
#endif

public enum FileSystemItemType: CaseIterable, Equatable {
    case directory
    case file
}

/// A struct containing information about a particular file.
public struct FileMetadata {
    /// The size of the file in bytes.
    public let size: Int64

    /// The date the file was last modified.
    public let lastModificationDate: Date
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

/// Options to configure the writing of text files.
public enum WriteTextOptions {
    /// When passed, it overwrites any existing files.
    case overwrite
}

/// Options to configure the writing of Plist files.
public enum WritePlistOptions {
    /// When passed, it overwrites any existing files.
    case overwrite
}

/// Options to configure the writing of JSON files.
public enum WriteJSONOptions {
    /// When passed, it overwrites any existing files.
    case overwrite
}

public protocol FileSysteming: Sendable {
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

    /// It writes the text at the given path.
    /// - Parameters:
    ///   - text: Text to be written.
    ///   - at: Path at which the text will be written.
    ///   - encoding: The encoding to encode the text as data.
    ///   - options: Options to configure the writing of the file.
    func writeText(_ text: String, at: AbsolutePath, encoding: String.Encoding, options: Set<WriteTextOptions>) async throws

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

    /// Given an `Encodable` instance, it encodes it as a Plist, and writes it at the given path.
    /// - Parameters:
    ///   - item: Item to be encoded as Plist.
    ///   - at: Path at which the Plist will be written.
    ///   - encoder: The PropertyListEncoder instance to encode the item.
    ///   - options: Options to configure the writing of the plist file.
    func writeAsPlist<T: Encodable>(
        _ item: T,
        at: AbsolutePath,
        encoder: PropertyListEncoder,
        options: Set<WritePlistOptions>
    ) async throws

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

    /// Given an `Encodable` instance, it encodes it as a JSON, and writes it at the given path.
    /// - Parameters:
    ///   - item: Item to be encoded as JSON.
    ///   - at: Path at which the JSON will be written.
    ///   - encoder: The JSONEncoder instance to encode the item.
    ///   - options: Options to configure the writing of the JSON file.
    func writeAsJSON<T: Encodable>(_ item: T, at: AbsolutePath, encoder: JSONEncoder, options: Set<WriteJSONOptions>) async throws

    /// Returns the size of a file at a given path. If the file doesn't exist, it returns nil.
    /// - Parameter at: Path to the file whose size will be returned.
    /// - Returns: The file size, otherwise `nil`
    @available(
        *,
        deprecated,
        renamed: "fileMetadata",
        message: "Read the file size from the metadata, which contains other attributes"
    )
    func fileSizeInBytes(at: AbsolutePath) async throws -> Int64?

    /// Returns metadata of a file at a given path.
    /// - Parameter path: Absolute path to the file.
    /// - Returns: The file metadata.
    func fileMetadata(at path: AbsolutePath) async throws -> FileMetadata?

    /// Sets the last access and modification times of a file or directory.
    /// - Parameters:
    ///   - path: The absolute path to the file or directory.
    ///   - lastAccessDate: The last access date. Pass `nil` to leave unchanged.
    ///   - lastModificationDate: The last modification date. Pass `nil` to leave unchanged.
    func setFileTimes(
        of path: AbsolutePath,
        lastAccessDate: Date?,
        lastModificationDate: Date?
    ) async throws

    /// Given a path, it replaces it with the file or directory at the other path.
    /// - Parameters:
    ///   - to: The path to be replaced.
    ///   - with: The path to the directory or file to replace the other path with.
    func replace(_ to: AbsolutePath, with: AbsolutePath) async throws

    /// Given a path, it copies the file or directory to another path.
    /// - Parameters:
    ///   - from: The path to the file or directory to be copied.
    ///   - to: The path to copy the file or directory to.
    func copy(_ from: AbsolutePath, to: AbsolutePath) async throws

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

    /// Creates a relative symlink.
    /// - Parameters:
    ///   - from: The path where the symlink is created.
    ///   - to: The relative path the symlink points to.
    func createSymbolicLink(from: AbsolutePath, to: RelativePath) async throws

    /// Given a symlink, it resolves it returning the path to the file or directory the symlink is pointing to.
    /// - Parameter symlinkPath: The absolute path to the symlink.
    /// - Returns: The resolved path.
    func resolveSymbolicLink(_ symlinkPath: AbsolutePath) async throws -> AbsolutePath

    #if !os(Windows)
        /// Zips a file or the content of a given directory.
        /// - Parameters:
        ///   - path: Path to file or directory. When the path to a file is provided, the file is zipped. When the path points to
        /// a
        /// directory, the content of the directory is zipped.
        ///   - to: Path to where the zip file will be created.
        func zipFileOrDirectoryContent(at path: AbsolutePath, to: AbsolutePath) async throws

        /// Unzips a zip file.
        /// - Parameters:
        ///   - zipPath: Path to the zip file.
        ///   - to: Path to the directory into which the content will be unzipped.
        func unzip(_ zipPath: AbsolutePath, to: AbsolutePath) async throws
    #endif

    /// Looks up files and directories that match a set of glob patterns.
    /// - Parameters:
    ///   - directory: Base absolute directory that glob patterns are relative to.
    ///   - include: A list of glob patterns.
    /// - Returns: An async sequence to get the results.
    func glob(directory: Path.AbsolutePath, include: [String]) throws -> AnyThrowingAsyncSequenceable<Path.AbsolutePath>

    /// Returns the path of the current working directory.
    func currentWorkingDirectory() async throws -> AbsolutePath

    /// Returns the contents of a directory as an array of absolute paths.
    ///
    /// - Parameter path: The absolute path to the directory whose contents should be listed.
    /// - Returns: An array of `AbsolutePath` objects representing all items in the directory.
    /// - Throws: An error if the directory cannot be read or accessed.
    func contentsOfDirectory(_ path: AbsolutePath) async throws -> [AbsolutePath]
}

// MARK: - FileSystem

public struct FileSystem: FileSysteming, Sendable {
    fileprivate let logger: Logger?
    fileprivate let environmentVariables: [String: String]

    public init(environmentVariables: [String: String] = ProcessInfo.processInfo.environment, logger: Logger? = nil) {
        self.environmentVariables = environmentVariables
        self.logger = logger
    }

    public func currentWorkingDirectory() async throws -> AbsolutePath {
        try AbsolutePath(validating: FileManager.default.currentDirectoryPath)
    }

    public func contentsOfDirectory(_ path: AbsolutePath) async throws -> [AbsolutePath] {
        let directory = File.Directory(try filePath(path))
        return try await File.Directory.Contents.list(at: directory).compactMap { entry in
            guard let entryPath = entry.pathIfValid else { return nil }
            return try absolutePath(entryPath)
        }
    }

    public func exists(_ path: AbsolutePath) async throws -> Bool {
        logger?.debug("Checking if a file or directory exists at path \(path.pathString).")
        return await File.System.Stat.exists(at: try filePath(path))
    }

    public func exists(_ path: AbsolutePath, isDirectory: Bool) async throws -> Bool {
        if isDirectory {
            logger?.debug("Checking if a directory exists at path \(path.pathString).")
        } else {
            logger?.debug("Checking if a file exists at path \(path.pathString).")
        }
        let fp = try filePath(path)
        if isDirectory {
            return await File.System.Stat.isDirectory(at: fp)
        } else {
            return await File.System.Stat.isFile(at: fp)
        }
    }

    public func touch(_ path: Path.AbsolutePath) async throws {
        logger?.debug("Touching a file at path \(path.pathString).")
        if try await exists(path) {
            let now = Date()
            try await setFileTimes(of: path, lastAccessDate: now, lastModificationDate: now)
            return
        }

        guard try await exists(path.parentDirectory, isDirectory: true) else {
            throw CocoaError(.fileNoSuchFile)
        }

        try await writeFileBytes(Data(), to: path)
    }

    public func remove(_ path: AbsolutePath) async throws {
        logger?.debug("Removing the file or directory at path: \(path.pathString).")
        let fp = try filePath(path)
        try removeItem(at: fp)
    }

    public func makeTemporaryDirectory(prefix: String) async throws -> AbsolutePath {
        var systemTemporaryDirectory = NSTemporaryDirectory()

        #if os(macOS)
            if systemTemporaryDirectory.starts(with: "/var/") {
                systemTemporaryDirectory = "/private\(systemTemporaryDirectory)"
            }
        #endif

        let temporaryDirectory = try AbsolutePath(validating: systemTemporaryDirectory)
            .appending(component: "\(prefix)-\(UUID().uuidString)")
        logger?.debug("Creating a temporary directory at path \(temporaryDirectory.pathString).")
        try await File.System.Create.Directory.create(
            at: try filePath(temporaryDirectory),
            options: .init(createIntermediates: true)
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
        if options.contains(.createTargetParentDirectories) {
            if !(try await exists(to.parentDirectory, isDirectory: true)) {
                try? await makeDirectory(at: to.parentDirectory, options: [.createTargetParentDirectories])
            }
        }
        let sourcePath = try filePath(from)
        guard await File.System.Stat.exists(at: sourcePath) else {
            throw FileSystemError.moveNotFound(from: from, to: to)
        }
        try await File.System.Move.move(from: sourcePath, to: try filePath(to))
    }

    public func makeDirectory(at: Path.AbsolutePath) async throws {
        try await makeDirectory(at: at, options: [.createTargetParentDirectories])
    }

    public func makeDirectory(at: Path.AbsolutePath, options: [MakeDirectoryOptions]) async throws {
        if options.isEmpty {
            logger?.debug("Creating directory at path \(at.pathString).")
        } else {
            logger?
                .debug(
                    "Creating directory at path \(at.pathString) with options: \(options.map(\.rawValue).joined(separator: ", "))."
                )
        }
        let createIntermediates = options.contains(.createTargetParentDirectories)
        if !createIntermediates, !(try await exists(at.parentDirectory, isDirectory: true)) {
            throw FileSystemError.makeDirectoryAbsentParent(at)
        }
        try await File.System.Create.Directory.create(
            at: try filePath(at),
            options: .init(createIntermediates: createIntermediates)
        )
    }

    public func readFile(at path: Path.AbsolutePath) async throws -> Data {
        logger?.debug("Reading file at path \(path.pathString).")
        return Data(try await File.System.Read.Full.read(from: try filePath(path)))
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
        try await writeText(text, at: path, encoding: encoding, options: Set())
    }

    public func writeText(
        _ text: String,
        at path: AbsolutePath,
        encoding: String.Encoding,
        options: Set<WriteTextOptions>
    ) async throws {
        logger?.debug("Writing text at path \(path.pathString).")
        guard let data = text.data(using: encoding) else {
            throw FileSystemError.cantEncodeText(text, encoding)
        }

        if options.contains(.overwrite), try await exists(path) {
            try await remove(path)
        }
        try await writeFileBytes(data, to: path)
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
        try await writeAsPlist(item, at: path, encoder: encoder, options: Set())
    }

    public func writeAsPlist(
        _ item: some Encodable,
        at path: AbsolutePath,
        encoder: PropertyListEncoder,
        options: Set<WritePlistOptions>
    ) async throws {
        logger?.debug("Writing .plist at path \(path.pathString).")

        if options.contains(.overwrite), try await exists(path) {
            try await remove(path)
        }

        let plistData = try encoder.encode(item)
        try await writeFileBytes(plistData, to: path)
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
        try await writeAsJSON(item, at: path, encoder: encoder, options: Set())
    }

    public func writeAsJSON(
        _ item: some Encodable,
        at path: Path.AbsolutePath,
        encoder: JSONEncoder,
        options: Set<WriteJSONOptions>
    ) async throws {
        logger?.debug("Writing .json at path \(path.pathString).")

        let json = try encoder.encode(item)
        if options.contains(.overwrite), try await exists(path) {
            try await remove(path)
        }
        try await writeFileBytes(json, to: path)
    }

    public func replace(_ to: AbsolutePath, with path: AbsolutePath) async throws {
        logger?.debug("Replacing file or directory at path \(to.pathString) with item at path \(path.pathString).")
        let sourcePath = try filePath(path)
        let destinationPath = try filePath(to)
        guard await File.System.Stat.exists(at: sourcePath) else {
            throw FileSystemError.replacingItemAbsent(replacingPath: path, replacedPath: to)
        }
        if !(try await exists(to.parentDirectory)) {
            try await makeDirectory(at: to.parentDirectory)
        }
        if await File.System.Stat.exists(at: destinationPath) {
            try removeItem(at: destinationPath)
        }
        try await copyItem(from: sourcePath, to: destinationPath)
    }

    public func copy(_ from: AbsolutePath, to: AbsolutePath) async throws {
        logger?.debug("Copying file or directory at path \(from.pathString) to \(to.pathString).")
        let sourcePath = try filePath(from)
        guard await File.System.Stat.exists(at: sourcePath) else {
            throw FileSystemError.copiedItemAbsent(copiedPath: from, intoPath: to)
        }
        if !(try await exists(to.parentDirectory)) {
            try await makeDirectory(at: to.parentDirectory)
        }
        try await copyItem(from: sourcePath, to: try filePath(to))
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

    @available(
        *,
        deprecated,
        renamed: "fileMetadata",
        message: "Read the file size from the metadata, which contains other attributes"
    )
    public func fileSizeInBytes(at path: AbsolutePath) async throws -> Int64? {
        logger?.debug("Getting the size in bytes of file at path \(path.pathString).")
        return try await fileMetadata(at: path)?.size
    }

    public func fileMetadata(at path: AbsolutePath) async throws -> FileMetadata? {
        logger?.debug("Getting the metadata of file at path \(path.pathString).")
        let fp = try filePath(path)
        guard await File.System.Stat.exists(at: fp) else { return nil }
        let info = try await File.System.Stat.info(at: fp)
        let modificationTime = info.timestamps.modificationTime
        let seconds = TimeInterval(modificationTime.secondsSinceEpoch)
        let nanoseconds = TimeInterval(modificationTime.totalNanoseconds) / 1_000_000_000
        let modificationDate = Date(timeIntervalSince1970: seconds + nanoseconds)
        return FileMetadata(size: info.size, lastModificationDate: modificationDate)
    }

    public func setFileTimes(
        of path: AbsolutePath,
        lastAccessDate: Date?,
        lastModificationDate: Date?
    ) async throws {
        logger?.debug("Setting file times at path \(path.pathString).")
        #if os(Windows)
            let handle = path.pathString
                .replacingOccurrences(of: "/", with: "\\")
                .withCString(encodedAs: UTF16.self) { wpath in
                    CreateFileW(
                        wpath,
                        DWORD(FILE_WRITE_ATTRIBUTES),
                        DWORD(FILE_SHARE_READ | FILE_SHARE_WRITE | FILE_SHARE_DELETE),
                        nil,
                        DWORD(OPEN_EXISTING),
                        DWORD(FILE_ATTRIBUTE_NORMAL),
                        nil
                    )
                }
            guard let handle, handle != INVALID_HANDLE_VALUE else {
                throw NSError(domain: "WinSDK", code: Int(GetLastError()))
            }
            defer { CloseHandle(handle) }

            let accessTime = lastAccessDate.map(Self.windowsFileTime(from:))
            let modificationTime = lastModificationDate.map(Self.windowsFileTime(from:))
            var success = true
            if var accessTime, var modificationTime {
                success = SetFileTime(handle, nil, &accessTime, &modificationTime) != 0
            } else if var accessTime {
                success = SetFileTime(handle, nil, &accessTime, nil) != 0
            } else if var modificationTime {
                success = SetFileTime(handle, nil, nil, &modificationTime) != 0
            } else {
                return
            }
            guard success else { throw NSError(domain: "WinSDK", code: Int(GetLastError())) }
        #else
            try Self.updateFileTimes(
                path: path.pathString,
                lastAccessDate: lastAccessDate,
                lastModificationDate: lastModificationDate
            )
        #endif
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
        try await createSymbolicLink(fromPathString: from.pathString, toPathString: to.pathString)
    }

    public func createSymbolicLink(from: AbsolutePath, to: RelativePath) async throws {
        try await createSymbolicLink(fromPathString: from.pathString, toPathString: to.pathString)
    }

    private func createSymbolicLink(fromPathString: String, toPathString: String) async throws {
        logger?.debug("Creating symbolic link from \(fromPathString) to \(toPathString).")
        try await File.System.Link.Symbolic.create(
            at: try File.Path(fromPathString),
            pointingTo: try File.Path(toPathString)
        )
    }

    public func resolveSymbolicLink(_ symlinkPath: AbsolutePath) async throws -> AbsolutePath {
        logger?.debug("Resolving symbolink link at path \(symlinkPath.pathString).")
        let fp = try filePath(symlinkPath)
        guard await File.System.Stat.exists(at: fp) else {
            throw FileSystemError.absentSymbolicLink(symlinkPath)
        }
        do {
            let targetPath = try await File.System.Link.Read.Target.target(of: fp)
            if targetPath.isAbsolute {
                return try absolutePath(targetPath)
            } else {
                return AbsolutePath(
                    symlinkPath.parentDirectory,
                    try RelativePath(validating: String(describing: targetPath))
                )
            }
        } catch {
            return symlinkPath
        }
    }

    #if !os(Windows)
        public func zipFileOrDirectoryContent(at path: Path.AbsolutePath, to: Path.AbsolutePath) async throws {
            logger?.debug("Zipping the file or contents of directory at path \(path.pathString) into \(to.pathString)")
            try await createArchive(
                at: URL(fileURLWithPath: path.pathString),
                to: URL(fileURLWithPath: to.pathString),
                shouldKeepParent: false
            )
        }

        public func unzip(_ zipPath: Path.AbsolutePath, to: Path.AbsolutePath) async throws {
            logger?.debug("Unzipping the file at path \(zipPath.pathString) to \(to.pathString)")
            try extractArchive(
                at: URL(fileURLWithPath: zipPath.pathString),
                to: URL(fileURLWithPath: to.pathString)
            )
        }
    #endif

    private func expandBraces(in regexString: String) throws -> [String] {
        let pattern = #"\{[^}]+\}"#
        let regex = try Regex(pattern)

        guard let match = regexString.firstMatch(of: regex) else {
            return [regexString]
        }

        return regexString[match.range]
            .dropFirst()
            .dropLast()
            .split(separator: ",")
            .map { option in
                regexString.replacingCharacters(in: match.range, with: option)
            }
    }

    public func glob(directory: Path.AbsolutePath, include: [String]) throws -> AnyThrowingAsyncSequenceable<Path.AbsolutePath> {
        let logMessage =
            "Looking up files and directories from \(directory.pathString) that match the glob patterns \(include.joined(separator: ", "))."
        logger?.debug("\(logMessage)")
        return Glob.search(
            directory: URL.with(filePath: directory.pathString),
            include: try include
                .flatMap { try expandBraces(in: $0) }
                .map { try Pattern($0) },
            exclude: [
                try Pattern("**/.DS_Store"),
                try Pattern("**/.gitkeep"),
            ],
            skipHiddenFiles: false
        )
        .map {
            let path: String
            if $0.isFileURL {
                let filePath = $0.path()
                path = filePath.removingPercentEncoding ?? filePath
            } else {
                path = $0.absoluteString.removingPercentEncoding ?? $0.absoluteString
            }
            return try Path.AbsolutePath(validating: path)
        }
        .eraseToAnyThrowingAsyncSequenceable()
    }
}

// MARK: - Collect helper

extension AnyThrowingAsyncSequenceable where Element == Path.AbsolutePath {
    public func collect() async throws -> [Path.AbsolutePath] {
        try await reduce(into: [Path.AbsolutePath]()) { $0.append($1) }
    }
}

// MARK: - Convenience overloads

extension FileSystem {
    public func runInTemporaryDirectory<T>(
        _ action: @Sendable (_ temporaryDirectory: AbsolutePath) async throws -> T
    ) async throws -> T {
        try await runInTemporaryDirectory(prefix: UUID().uuidString, action)
    }

    public func writeText(_ text: String, at path: AbsolutePath, options: Set<WriteTextOptions>) async throws {
        try await writeText(text, at: path, encoding: .utf8, options: options)
    }

    public func writeAsPlist(_ item: some Encodable, at path: AbsolutePath, options: Set<WritePlistOptions>) async throws {
        try await writeAsPlist(item, at: path, encoder: PropertyListEncoder(), options: options)
    }

    public func writeAsJSON(_ item: some Encodable, at path: Path.AbsolutePath, options: Set<WriteJSONOptions>) async throws {
        try await writeAsJSON(item, at: path, encoder: JSONEncoder(), options: options)
    }
}

// MARK: - Path conversion helpers

extension FileSystem {
    fileprivate func filePath(_ path: AbsolutePath) throws -> File.Path {
        try File.Path(path.pathString)
    }

    fileprivate func absolutePath(_ path: File.Path) throws -> AbsolutePath {
        try AbsolutePath(validating: String(describing: path))
    }
}

// MARK: - Remove helper (symlink-safe recursive delete)

extension FileSystem {
    /// Removes a file, symlink, or directory (recursively) using lstat to avoid
    /// following symlinks. This works around a bug in swift-file-system's Delete
    /// which uses stat() and fails on symlinks whose targets don't exist.
    fileprivate func removeItem(at path: File.Path) throws {
        let info: File.System.Metadata.Info
        do {
            info = try File.System.Stat.lstatInfo(at: path)
        } catch {
            return // Path doesn't exist
        }

        switch info.type {
        case .directory:
            let entries = try File.Directory.Contents.list(at: File.Directory(path))
            for entry in entries {
                guard let childPath = entry.pathIfValid else { continue }
                try removeItem(at: childPath)
            }
            #if os(Windows)
                let success = String(describing: path)
                    .replacingOccurrences(of: "/", with: "\\")
                    .withCString(encodedAs: UTF16.self) { RemoveDirectoryW($0) }
                guard success != 0 else {
                    throw NSError(domain: "WinSDK", code: Int(GetLastError()))
                }
            #else
                guard rmdir(String(describing: path)) == 0 else {
                    throw NSError(domain: NSPOSIXErrorDomain, code: Int(errno))
                }
            #endif
        default:
            // Files, symlinks, and everything else: unlink directly
            #if os(Windows)
                let success = String(describing: path)
                    .replacingOccurrences(of: "/", with: "\\")
                    .withCString(encodedAs: UTF16.self) { DeleteFileW($0) }
                guard success != 0 else {
                    throw NSError(domain: "WinSDK", code: Int(GetLastError()))
                }
            #else
                guard unlink(String(describing: path)) == 0 else {
                    throw NSError(domain: NSPOSIXErrorDomain, code: Int(errno))
                }
            #endif
        }
    }
}

// MARK: - File I/O helpers

extension FileSystem {
    fileprivate func writeFileBytes(_ data: Data, to path: AbsolutePath) async throws {
        try await File.System.Write.Atomic.write(
            [UInt8](data),
            to: try filePath(path),
            options: .init(strategy: .noClobber, createIntermediates: false)
        )
    }

    fileprivate func copyItem(from source: File.Path, to destination: File.Path) async throws {
        guard !(await File.System.Stat.exists(at: destination)) else {
            throw CocoaError(.fileWriteFileExists, userInfo: [NSFilePathErrorKey: String(describing: destination)])
        }

        let metadata = try File.System.Stat.lstatInfo(at: source)
        switch metadata.type {
        case .directory:
            try await File.System.Create.Directory.create(at: destination, options: .init(createIntermediates: false))
            let entries = try await File.Directory.Contents.list(at: File.Directory(source))
            for entry in entries {
                guard let sourceChild = entry.pathIfValid else { continue }
                guard let lastComponent = sourceChild.lastComponent else { continue }
                try await copyItem(from: sourceChild, to: destination / lastComponent)
            }
        case .symbolicLink:
            let target = try await File.System.Link.Read.Target.target(of: source)
            try await File.System.Link.Symbolic.create(at: destination, pointingTo: target)
        default:
            try await File.System.Copy.copy(
                from: source,
                to: destination,
                options: .init(overwrite: false, copyAttributes: true, followSymlinks: false)
            )
        }
    }
}

// MARK: - File time helpers (raw system calls, since StandardTime.Time is @_spi(Internal))

#if !os(Windows)
    extension FileSystem {
        fileprivate static func updateFileTimes(
            path: String,
            lastAccessDate: Date?,
            lastModificationDate: Date?
        ) throws {
            var info = stat()
            let statResult = path.withCString { stat($0, &info) }
            guard statResult == 0 else {
                throw NSError(domain: NSPOSIXErrorDomain, code: Int(errno))
            }

            var times = [
                dateToTimespec(lastAccessDate ?? date(from: accessTimespec(from: info))),
                dateToTimespec(lastModificationDate ?? date(from: modificationTimespec(from: info))),
            ]

            let result = path.withCString { pathPointer in
                utimensat(AT_FDCWD, pathPointer, &times, 0)
            }

            guard result == 0 else {
                throw NSError(domain: NSPOSIXErrorDomain, code: Int(errno))
            }
        }

        fileprivate static func dateToTimespec(_ date: Date) -> timespec {
            let seconds = Int(date.timeIntervalSince1970)
            let nanoseconds = Int((date.timeIntervalSince1970 - Double(seconds)) * 1_000_000_000)
            return timespec(tv_sec: seconds, tv_nsec: nanoseconds)
        }

        fileprivate static func date(from timespec: timespec) -> Date {
            let seconds = TimeInterval(timespec.tv_sec)
            let nanoseconds = TimeInterval(timespec.tv_nsec) / 1_000_000_000
            return Date(timeIntervalSince1970: seconds + nanoseconds)
        }

        fileprivate static func accessTimespec(from info: stat) -> timespec {
            #if canImport(Darwin)
                info.st_atimespec
            #else
                info.st_atim
            #endif
        }

        fileprivate static func modificationTimespec(from info: stat) -> timespec {
            #if canImport(Darwin)
                info.st_mtimespec
            #else
                info.st_mtim
            #endif
        }
    }
#else
    extension FileSystem {
        fileprivate static func windowsFileTime(from date: Date) -> FILETIME {
            let timeInterval = date.timeIntervalSince1970
            let wholeSeconds = Int64(timeInterval)
            let remainder = timeInterval - TimeInterval(wholeSeconds)
            let intervals = 116_444_736_000_000_000
                + (wholeSeconds * 10_000_000)
                + Int64(remainder * 10_000_000)
            return FILETIME(
                dwLowDateTime: DWORD(intervals & 0xFFFF_FFFF),
                dwHighDateTime: DWORD((intervals >> 32) & 0xFFFF_FFFF)
            )
        }
    }
#endif

// MARK: - Archive helpers

#if !os(Windows)
    extension FileSystem {
        fileprivate func createArchive(at sourceURL: URL, to destinationURL: URL, shouldKeepParent: Bool) async throws {
            let sourcePath = try AbsolutePath(validating: sourceURL.path)
            let destinationPath = try AbsolutePath(validating: destinationURL.path)
            let sourceFP = try filePath(sourcePath)
            let destinationFP = try filePath(destinationPath)
            guard await File.System.Stat.exists(at: sourceFP) else {
                throw CocoaError(.fileReadNoSuchFile, userInfo: [NSFilePathErrorKey: sourceURL.path])
            }
            guard !(await File.System.Stat.exists(at: destinationFP)) else {
                throw CocoaError(.fileWriteFileExists, userInfo: [NSFilePathErrorKey: destinationURL.path])
            }

            let archive = try Archive(url: destinationURL, accessMode: .create)
            if await File.System.Stat.isDirectory(at: sourceFP) {
                let baseURL = shouldKeepParent
                    ? URL(fileURLWithPath: sourcePath.parentDirectory.pathString)
                    : sourceURL
                let prefix = shouldKeepParent ? "\(sourcePath.basename)/" : ""
                for entryPath in try await descendantRelativePaths(of: sourcePath) {
                    try archive.addEntry(
                        with: "\(prefix)\(entryPath)",
                        relativeTo: baseURL,
                        compressionMethod: .none
                    )
                }
            } else {
                try archive.addEntry(
                    with: sourceURL.lastPathComponent,
                    relativeTo: sourceURL.deletingLastPathComponent(),
                    compressionMethod: .none
                )
            }
        }

        fileprivate func extractArchive(at sourceURL: URL, to destinationURL: URL) throws {
            let sourcePath = try AbsolutePath(validating: sourceURL.path)
            guard File.System.Stat.exists(at: try filePath(sourcePath)) else {
                throw CocoaError(.fileReadNoSuchFile, userInfo: [NSFilePathErrorKey: sourceURL.path])
            }

            let archive = try Archive(url: sourceURL, accessMode: .read)
            for entry in archive {
                let entryURL = destinationURL.appendingPathComponent(entry.path)
                let checksum = try archive.extract(entry, to: entryURL)
                if checksum != entry.checksum {
                    throw Archive.ArchiveError.invalidCRC32
                }
            }
        }

        fileprivate func descendantRelativePaths(of root: AbsolutePath) async throws -> [String] {
            try await descendantRelativePaths(of: root, prefix: "")
        }

        fileprivate func descendantRelativePaths(of directory: AbsolutePath, prefix: String) async throws -> [String] {
            var descendants: [String] = []
            let dirFP = try filePath(directory)
            let entries = try await File.Directory.Contents.list(at: File.Directory(dirFP))
            for entry in entries {
                guard let entryPath = entry.pathIfValid else { continue }
                let name = String(describing: entryPath.lastComponent ?? File.Path.Component(""))
                let relativePath = prefix.isEmpty ? name : "\(prefix)/\(name)"
                descendants.append(relativePath)

                if entry.type == .directory {
                    let childAbsPath = directory.appending(component: name)
                    descendants.append(contentsOf: try await descendantRelativePaths(of: childAbsPath, prefix: relativePath))
                }
            }
            return descendants
        }
    }
#endif
