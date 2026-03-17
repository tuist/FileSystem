import Foundation
import Glob
import Logging
import Path

#if os(Windows)
    import WinSDK
#elseif canImport(Darwin)
    import Darwin
#elseif canImport(Glibc)
    import Glibc
#elseif canImport(Musl)
    import Musl
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
    /// When passed, it ovewrites any existing files.
    case overwrite
}

/// Options to configure the writing of Plist files.
public enum WritePlistOptions {
    /// When passed, it ovewrites any existing files.
    case overwrite
}

/// Options to configure the writing of JSON files.
public enum WriteJSONOptions {
    /// When passed, it ovewrites any existing files.
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

    // TODO:
    //       func urlSafeBase64MD5(path: AbsolutePath) throws -> String
    //       func fileAttributes(at path: AbsolutePath) throws -> [FileAttributeKey: Any]
    //       func files(in path: AbsolutePath, nameFilter: Set<String>?, extensionFilter: Set<String>?) -> Set<AbsolutePath>
    //       func filesAndDirectoriesContained(in path: AbsolutePath) throws -> [AbsolutePath]?
}

// swiftlint:disable:next type_body_length
public struct FileSystem: FileSysteming, Sendable {
    fileprivate let logger: Logger?
    fileprivate let environmentVariables: [String: String]

    public init(environmentVariables: [String: String] = ProcessInfo.processInfo.environment, logger: Logger? = nil) {
        self.environmentVariables = environmentVariables
        self.logger = logger
    }

    public func currentWorkingDirectory() async throws -> AbsolutePath {
        return try AbsolutePath(validating: try platformCurrentWorkingDirectoryPath())
    }

    public func contentsOfDirectory(_ path: AbsolutePath) async throws -> [AbsolutePath] {
        try platformDirectoryContents(at: path)
    }

    public func exists(_ path: AbsolutePath) async throws -> Bool {
        logger?.debug("Checking if a file or directory exists at path \(path.pathString).")
        return try platformItemExists(at: path)
    }

    public func exists(_ path: AbsolutePath, isDirectory: Bool) async throws -> Bool {
        if isDirectory {
            logger?.debug("Checking if a directory exists at path \(path.pathString).")
        } else {
            logger?.debug("Checking if a file exists at path \(path.pathString).")
        }
        return try platformItemExists(at: path, isDirectory: isDirectory)
    }

    public func touch(_ path: Path.AbsolutePath) async throws {
        logger?.debug("Touching a file at path \(path.pathString).")

        if try platformItemExists(at: path) {
            let now = Date()
            try await setFileTimes(of: path, lastAccessDate: now, lastModificationDate: now)
            return
        }

        guard try platformItemExists(at: path.parentDirectory, isDirectory: true) else {
            throw CocoaError(.fileNoSuchFile)
        }

        try platformCreateEmptyFile(at: path)
    }

    public func remove(_ path: AbsolutePath) async throws {
        logger?.debug("Removing the file or directory at path: \(path.pathString).")
        guard try await exists(path) else { return }
        try platformRemoveItem(at: path)
    }

    public func makeTemporaryDirectory(prefix: String) async throws -> AbsolutePath {
        let temporaryDirectory = try platformMakeTemporaryDirectory(prefix: prefix)
        logger?.debug("Creating a temporary directory at path \(temporaryDirectory.pathString).")
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
        guard try await exists(from) else {
            throw FileSystemError.moveNotFound(from: from, to: to)
        }
        try platformMoveItem(from: from, to: to)
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
        let createIntermediates = options.contains(.createTargetParentDirectories)
        if !createIntermediates, !(try await exists(at.parentDirectory, isDirectory: true)) {
            throw FileSystemError.makeDirectoryAbsentParent(at)
        }
        try platformCreateDirectory(at: at, createIntermediates: createIntermediates)
    }

    public func readFile(at path: Path.AbsolutePath) async throws -> Data {
        try await readFile(at: path, log: true)
    }

    private func readFile(at path: Path.AbsolutePath, log: Bool = false) async throws -> Data {
        if log {
            logger?.debug("Reading file at path \(path.pathString).")
        }
        return try Data(contentsOf: URL(fileURLWithPath: path.pathString))
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
        try writeFile(data, to: path)
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
        try writeFile(plistData, to: path)
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
        try writeFile(json, to: path)
    }

    public func replace(_ to: AbsolutePath, with path: AbsolutePath) async throws {
        logger?.debug("Replacing file or directory at path \(path.pathString) with item at path \(to.pathString).")
        if !(try await exists(path)) {
            throw FileSystemError.replacingItemAbsent(replacingPath: path, replacedPath: to)
        }
        if !(try await exists(to.parentDirectory)) {
            try await makeDirectory(at: to.parentDirectory)
        }
        if try platformItemExists(at: to, followSymlinks: false) {
            try platformRemoveItem(at: to)
        }
        try platformCopyItem(from: path, to: to)
    }

    public func copy(_ from: AbsolutePath, to: AbsolutePath) async throws {
        logger?.debug("Copying file or directory at path \(from.pathString) to \(to.pathString).")
        if !(try await exists(from)) {
            throw FileSystemError.copiedItemAbsent(copiedPath: from, intoPath: to)
        }
        if !(try await exists(to.parentDirectory)) {
            try await makeDirectory(at: to.parentDirectory)
        }
        try platformCopyItem(from: from, to: to)
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
        return try platformFileMetadata(at: path)
    }

    public func setFileTimes(
        of path: AbsolutePath,
        lastAccessDate: Date?,
        lastModificationDate: Date?
    ) async throws {
        logger?.debug("Setting file times at path \(path.pathString).")
        try platformSetFileTimes(
            of: path,
            lastAccessDate: lastAccessDate,
            lastModificationDate: lastModificationDate
        )
    }

    #if !os(Windows)
        private static func updateFileTimes(
            path: String,
            lastAccessDate: Date?,
            lastModificationDate: Date?
        ) throws {
            var times = [
                timespec(tv_sec: 0, tv_nsec: Int(UTIME_OMIT)),
                timespec(tv_sec: 0, tv_nsec: Int(UTIME_OMIT)),
            ]

            if let lastAccessDate {
                times[0] = dateToTimespec(lastAccessDate)
            }

            if let lastModificationDate {
                times[1] = dateToTimespec(lastModificationDate)
            }

            let result = path.withCString { pathPointer in
                utimensat(AT_FDCWD, pathPointer, &times, 0)
            }

            guard result == 0 else {
                throw NSError(domain: NSPOSIXErrorDomain, code: Int(errno))
            }
        }

        private static func dateToTimespec(_ date: Date) -> timespec {
            let seconds = Int(date.timeIntervalSince1970)
            let nanoseconds = Int((date.timeIntervalSince1970 - Double(seconds)) * 1_000_000_000)
            return timespec(tv_sec: seconds, tv_nsec: nanoseconds)
        }
    #endif

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
        try platformCreateSymbolicLink(fromPathString: fromPathString, toPathString: toPathString)
    }

    public func resolveSymbolicLink(_ symlinkPath: AbsolutePath) async throws -> AbsolutePath {
        logger?.debug("Resolving symbolink link at path \(symlinkPath.pathString).")
        if !(try await exists(symlinkPath)) {
            throw FileSystemError.absentSymbolicLink(symlinkPath)
        }
        let destination: String
        do {
            destination = try platformReadSymbolicLink(at: symlinkPath)
        } catch {
            return symlinkPath
        }

        #if os(Windows)
            if destination.hasPrefix("/") || destination.contains(":") {
                return try AbsolutePath(validating: destination)
            }
        #else
            if destination.hasPrefix("/") {
                return try AbsolutePath(validating: destination)
            }
        #endif

        return AbsolutePath(symlinkPath.parentDirectory, try RelativePath(validating: destination))
    }

    #if !os(Windows)
        public func zipFileOrDirectoryContent(at path: Path.AbsolutePath, to: Path.AbsolutePath) async throws {
            logger?.debug("Zipping the file or contents of directory at path \(path.pathString) into \(to.pathString)")
            try createArchive(
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
        let encodedPath = directory.pathString.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? directory
            .pathString
        return Glob.search(
            directory: URL(string: encodedPath)!,
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
            let path = $0.absoluteString.removingPercentEncoding ?? $0.absoluteString
            return try Path.AbsolutePath(validating: path)
        }
        .eraseToAnyThrowingAsyncSequenceable()
    }
}

extension AnyThrowingAsyncSequenceable where Element == Path.AbsolutePath {
    public func collect() async throws -> [Path.AbsolutePath] {
        try await reduce(into: [Path.AbsolutePath]()) { $0.append($1) }
    }
}

extension FileSystem {
    private func writeFile(_ data: Data, to path: AbsolutePath) throws {
        try data.write(to: URL(fileURLWithPath: path.pathString))
    }

    /// Creates and passes a temporary directory to the given action, coupling its lifecycle to the action's.
    /// - Parameter action: The action to run with the temporary directory.
    /// - Returns: Any value returned by the action.
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

    #if !os(Windows)
        private func createArchive(at sourceURL: URL, to destinationURL: URL, shouldKeepParent: Bool) throws {
            let sourcePath = try AbsolutePath(validating: sourceURL.path)
            let destinationPath = try AbsolutePath(validating: destinationURL.path)
            guard try platformItemExists(at: sourcePath) else {
                throw CocoaError(.fileReadNoSuchFile, userInfo: [NSFilePathErrorKey: sourceURL.path])
            }
            guard try !platformItemExists(at: destinationPath, followSymlinks: false) else {
                throw CocoaError(.fileWriteFileExists, userInfo: [NSFilePathErrorKey: destinationURL.path])
            }

            let archive = try Archive(url: destinationURL, accessMode: .create)
            if try platformItemExists(at: sourcePath, isDirectory: true) {
                let baseURL = shouldKeepParent
                    ? URL(fileURLWithPath: sourcePath.parentDirectory.pathString)
                    : sourceURL
                let prefix = shouldKeepParent ? "\(sourcePath.basename)/" : ""
                for entryPath in try descendantRelativePaths(of: sourcePath) {
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

        private func extractArchive(at sourceURL: URL, to destinationURL: URL) throws {
            let sourcePath = try AbsolutePath(validating: sourceURL.path)
            guard try platformItemExists(at: sourcePath) else {
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
    #endif
}

private enum PlatformFileKind {
    case directory
    case file
    case symbolicLink
    case other
}

private struct PlatformFileInfo {
    let kind: PlatformFileKind
    let size: Int64
    let modificationDate: Date
}

extension FileSystem {
    private func platformCurrentWorkingDirectoryPath() throws -> String {
        #if os(Windows)
            var buffer = [WCHAR](repeating: 0, count: Int(MAX_PATH) + 1)
            var length = buffer.withUnsafeMutableBufferPointer {
                GetCurrentDirectoryW(DWORD($0.count), $0.baseAddress)
            }
            guard length > 0 else { throw windowsError() }
            if Int(length) >= buffer.count {
                buffer = [WCHAR](repeating: 0, count: Int(length) + 1)
                length = buffer.withUnsafeMutableBufferPointer {
                    GetCurrentDirectoryW(DWORD($0.count), $0.baseAddress)
                }
                guard length > 0, Int(length) < buffer.count else { throw windowsError() }
            }
            return buffer.withUnsafeBufferPointer {
                String(decodingCString: $0.baseAddress!, as: UTF16.self)
            }
        #else
            var buffer = [CChar](repeating: 0, count: Int(PATH_MAX))
            guard getcwd(&buffer, buffer.count) != nil else { throw posixError() }
            return String(cString: buffer)
        #endif
    }

    private func platformDirectoryContents(at path: AbsolutePath) throws -> [AbsolutePath] {
        #if os(Windows)
            guard try platformItemExists(at: path, isDirectory: true) else {
                throw windowsError(DWORD(ERROR_PATH_NOT_FOUND))
            }

            var entries: [AbsolutePath] = []
            var findData = WIN32_FIND_DATAW()
            let searchPath = "\(windowsPathString(path.pathString))\\*"
            let handle = searchPath.withCString(encodedAs: UTF16.self) { wpath in
                FindFirstFileW(wpath, &findData)
            }
            guard handle != INVALID_HANDLE_VALUE else { throw windowsError() }
            defer { FindClose(handle) }

            repeat {
                let name = windowsDirectoryEntryName(from: &findData)
                guard name != ".", name != ".." else { continue }
                entries.append(path.appending(component: name))
            } while FindNextFileW(handle, &findData) != 0

            let lastError = GetLastError()
            if lastError != DWORD(ERROR_NO_MORE_FILES) {
                throw windowsError(lastError)
            }

            return entries
        #else
            guard let directory = opendir(path.pathString) else { throw posixError() }
            defer { closedir(directory) }

            var entries: [AbsolutePath] = []
            errno = 0
            while let entryPointer = readdir(directory) {
                let entry = entryPointer.pointee
                var entryName = entry.d_name
                let capacity = MemoryLayout.size(ofValue: entryName) / MemoryLayout<CChar>.size
                let name = withUnsafePointer(to: &entryName) { pointer in
                    pointer.withMemoryRebound(
                        to: CChar.self,
                        capacity: capacity
                    ) {
                        String(cString: $0)
                    }
                }
                guard name != ".", name != ".." else { continue }
                entries.append(path.appending(component: name))
            }

            if errno != 0 {
                throw posixError()
            }

            return entries
        #endif
    }

    private func platformItemExists(at path: AbsolutePath) throws -> Bool {
        try platformItemExists(at: path, followSymlinks: true)
    }

    private func platformItemExists(at path: AbsolutePath, isDirectory: Bool) throws -> Bool {
        guard let info = try platformFileInfo(at: path, followSymlinks: true) else { return false }
        return info.kind == (isDirectory ? .directory : .file)
    }

    private func platformItemExists(at path: AbsolutePath, followSymlinks: Bool) throws -> Bool {
        try platformFileInfo(at: path, followSymlinks: followSymlinks) != nil
    }

    private func platformCreateEmptyFile(at path: AbsolutePath) throws {
        #if os(Windows)
            let handle = windowsPathString(path.pathString).withCString(encodedAs: UTF16.self) { wpath in
                CreateFileW(
                    wpath,
                    DWORD(GENERIC_WRITE),
                    DWORD(FILE_SHARE_READ | FILE_SHARE_WRITE | FILE_SHARE_DELETE),
                    nil,
                    DWORD(CREATE_NEW),
                    DWORD(FILE_ATTRIBUTE_NORMAL),
                    nil
                )
            }
            guard let handle, handle != INVALID_HANDLE_VALUE else { throw windowsError() }
            CloseHandle(handle)
        #else
            let descriptor = path.pathString.withCString { pathPointer in
                open(pathPointer, O_WRONLY | O_CREAT | O_EXCL, mode_t(0o666))
            }
            guard descriptor >= 0 else { throw posixError() }
            _ = close(descriptor)
        #endif
    }

    private func platformRemoveItem(at path: AbsolutePath) throws {
        #if os(Windows)
            let attributes = windowsAttributes(atPath: path.pathString)
            guard attributes != INVALID_FILE_ATTRIBUTES else { return }

            let isDirectory = (attributes & DWORD(FILE_ATTRIBUTE_DIRECTORY)) != 0
            let isReparsePoint = (attributes & DWORD(FILE_ATTRIBUTE_REPARSE_POINT)) != 0
            if isDirectory, !isReparsePoint {
                for child in try platformDirectoryContents(at: path) {
                    try platformRemoveItem(at: child)
                }
                let success = windowsPathString(path.pathString).withCString(encodedAs: UTF16.self) {
                    RemoveDirectoryW($0)
                }
                guard success != 0 else { throw windowsError() }
            } else if isDirectory {
                let success = windowsPathString(path.pathString).withCString(encodedAs: UTF16.self) {
                    RemoveDirectoryW($0)
                }
                guard success != 0 else { throw windowsError() }
            } else {
                let success = windowsPathString(path.pathString).withCString(encodedAs: UTF16.self) {
                    DeleteFileW($0)
                }
                guard success != 0 else { throw windowsError() }
            }
        #else
            guard let info = try platformFileInfo(at: path, followSymlinks: false) else { return }
            switch info.kind {
            case .directory:
                for child in try platformDirectoryContents(at: path) {
                    try platformRemoveItem(at: child)
                }
                let result = path.pathString.withCString { rmdir($0) }
                guard result == 0 else { throw posixError() }
            case .file, .symbolicLink, .other:
                let result = path.pathString.withCString { unlink($0) }
                guard result == 0 else { throw posixError() }
            }
        #endif
    }

    private func platformMakeTemporaryDirectory(prefix: String) throws -> AbsolutePath {
        #if os(Windows)
            var buffer = [WCHAR](repeating: 0, count: Int(MAX_PATH) + 1)
            var length = buffer.withUnsafeMutableBufferPointer {
                GetTempPathW(DWORD($0.count), $0.baseAddress)
            }
            guard length > 0 else { throw windowsError() }
            if Int(length) >= buffer.count {
                buffer = [WCHAR](repeating: 0, count: Int(length) + 1)
                length = buffer.withUnsafeMutableBufferPointer {
                    GetTempPathW(DWORD($0.count), $0.baseAddress)
                }
                guard length > 0, Int(length) < buffer.count else { throw windowsError() }
            }
            let temporaryDirectory = try AbsolutePath(
                validating: buffer.withUnsafeBufferPointer {
                    String(decodingCString: $0.baseAddress!, as: UTF16.self)
                }
            )
            let path = temporaryDirectory.appending(component: "\(prefix)-\(UUID().uuidString)")
            try platformCreateDirectory(at: path, createIntermediates: true)
            return path
        #else
            var systemTemporaryDirectory = NSTemporaryDirectory()

            #if os(macOS)
                if systemTemporaryDirectory.starts(with: "/var/") {
                    systemTemporaryDirectory = "/private\(systemTemporaryDirectory)"
                }
            #endif

            let basePath = try AbsolutePath(validating: systemTemporaryDirectory)
            var template = basePath.appending(component: "\(prefix)-XXXXXX").pathString.utf8CString
            let createdPath = template.withUnsafeMutableBufferPointer { pointer -> String? in
                guard let pathPointer = mkdtemp(pointer.baseAddress) else { return nil }
                return String(cString: pathPointer)
            }
            guard let createdPath else { throw posixError() }
            return try AbsolutePath(validating: createdPath)
        #endif
    }

    private func platformMoveItem(from: AbsolutePath, to: AbsolutePath) throws {
        if try platformItemExists(at: to, followSymlinks: false) {
            throw fileExistsError(at: to)
        }

        #if os(Windows)
            let success = windowsPathString(from.pathString).withCString(encodedAs: UTF16.self) { wsrc in
                windowsPathString(to.pathString).withCString(encodedAs: UTF16.self) { wdst in
                    MoveFileExW(wsrc, wdst, DWORD(MOVEFILE_COPY_ALLOWED))
                }
            }
            guard success != 0 else { throw windowsError() }
        #else
            let result = from.pathString.withCString { sourcePointer in
                to.pathString.withCString { destinationPointer in
                    rename(sourcePointer, destinationPointer)
                }
            }
            guard result == 0 else {
                let error = errno
                if error == EXDEV {
                    try platformCopyItem(from: from, to: to)
                    try platformRemoveItem(at: from)
                    return
                }
                throw posixError(error)
            }
        #endif
    }

    private func platformCreateDirectory(at path: AbsolutePath, createIntermediates: Bool) throws {
        #if os(Windows)
            if let existing = try platformFileInfo(at: path, followSymlinks: false) {
                guard existing.kind == .directory else { throw windowsError(DWORD(ERROR_ALREADY_EXISTS)) }
                return
            }
            if createIntermediates {
                let parent = path.parentDirectory
                if parent != path {
                    try platformCreateDirectory(at: parent, createIntermediates: true)
                }
            }
            let success = windowsPathString(path.pathString).withCString(encodedAs: UTF16.self) { wpath in
                CreateDirectoryW(wpath, nil)
            }
            guard success != 0 else {
                let error = GetLastError()
                if error == DWORD(ERROR_ALREADY_EXISTS), try platformItemExists(at: path, isDirectory: true) {
                    return
                }
                throw windowsError(error)
            }
        #else
            if let existing = try platformFileInfo(at: path, followSymlinks: false) {
                guard existing.kind == .directory else { throw posixError(EEXIST) }
                return
            }
            if createIntermediates {
                let parent = path.parentDirectory
                if parent != path {
                    try platformCreateDirectory(at: parent, createIntermediates: true)
                }
            }
            let result = path.pathString.withCString { mkdir($0, mode_t(0o755)) }
            guard result == 0 else {
                let error = errno
                if error == EEXIST, try platformItemExists(at: path, isDirectory: true) {
                    return
                }
                throw posixError(error)
            }
        #endif
    }

    private func platformCopyItem(from: AbsolutePath, to: AbsolutePath) throws {
        if try platformItemExists(at: to, followSymlinks: false) {
            throw fileExistsError(at: to)
        }

        guard let info = try platformFileInfo(at: from, followSymlinks: false) else {
            throw CocoaError(.fileReadNoSuchFile, userInfo: [NSFilePathErrorKey: from.pathString])
        }

        switch info.kind {
        case .directory:
            try platformCreateDirectory(at: to, createIntermediates: false)
            for child in try platformDirectoryContents(at: from) {
                try platformCopyItem(from: child, to: to.appending(component: child.basename))
            }
        case .symbolicLink:
            let destination = try platformReadSymbolicLink(at: from)
            try platformCreateSymbolicLink(fromPathString: to.pathString, toPathString: destination)
        case .file, .other:
            #if os(Windows)
                let success = windowsPathString(from.pathString).withCString(encodedAs: UTF16.self) { wsrc in
                    windowsPathString(to.pathString).withCString(encodedAs: UTF16.self) { wdst in
                        CopyFileW(wsrc, wdst, true)
                    }
                }
                guard success != 0 else { throw windowsError() }
            #else
                try platformCopyRegularFile(from: from, to: to)
            #endif
        }
    }

    private func platformFileMetadata(at path: AbsolutePath) throws -> FileMetadata? {
        guard let info = try platformFileInfo(at: path, followSymlinks: true) else { return nil }
        return FileMetadata(size: info.size, lastModificationDate: info.modificationDate)
    }

    private func platformSetFileTimes(
        of path: AbsolutePath,
        lastAccessDate: Date?,
        lastModificationDate: Date?
    ) throws {
        #if os(Windows)
            let handle = windowsPathString(path.pathString).withCString(encodedAs: UTF16.self) { wpath in
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
            guard let handle, handle != INVALID_HANDLE_VALUE else { throw windowsError() }
            defer { CloseHandle(handle) }

            var accessTime = lastAccessDate.map(windowsFileTime(from:))
            var modificationTime = lastModificationDate.map(windowsFileTime(from:))
            let success = SetFileTime(handle, nil, &accessTime, &modificationTime)
            guard success != 0 else { throw windowsError() }
        #else
            try Self.updateFileTimes(
                path: path.pathString,
                lastAccessDate: lastAccessDate,
                lastModificationDate: lastModificationDate
            )
        #endif
    }

    private func platformCreateSymbolicLink(fromPathString: String, toPathString: String) throws {
        #if os(Windows)
            var flags = DWORD(0x2)
            let targetAttributes = windowsAttributes(atPath: toPathString)
            if targetAttributes != INVALID_FILE_ATTRIBUTES,
                (targetAttributes & DWORD(FILE_ATTRIBUTE_DIRECTORY)) != 0
            {
                flags |= DWORD(SYMBOLIC_LINK_FLAG_DIRECTORY)
            }
            let success = windowsPathString(fromPathString).withCString(encodedAs: UTF16.self) { wlink in
                windowsPathString(toPathString).withCString(encodedAs: UTF16.self) { wtarget in
                    CreateSymbolicLinkW(wlink, wtarget, flags)
                }
            }
            guard success != 0 else { throw windowsError() }
        #else
            let result = fromPathString.withCString { linkPointer in
                toPathString.withCString { targetPointer in
                    symlink(targetPointer, linkPointer)
                }
            }
            guard result == 0 else { throw posixError() }
        #endif
    }

    private func platformReadSymbolicLink(at path: AbsolutePath) throws -> String {
        #if os(Windows)
            let handle = windowsPathString(path.pathString).withCString(encodedAs: UTF16.self) { wpath in
                CreateFileW(
                    wpath,
                    0,
                    DWORD(FILE_SHARE_READ | FILE_SHARE_WRITE | FILE_SHARE_DELETE),
                    nil,
                    DWORD(OPEN_EXISTING),
                    DWORD(FILE_FLAG_BACKUP_SEMANTICS),
                    nil
                )
            }
            guard let handle, handle != INVALID_HANDLE_VALUE else { throw windowsError() }
            defer { CloseHandle(handle) }

            var buffer = [WCHAR](repeating: 0, count: Int(MAX_PATH) + 1)
            var length = buffer.withUnsafeMutableBufferPointer {
                GetFinalPathNameByHandleW(handle, $0.baseAddress, DWORD($0.count), DWORD(FILE_NAME_NORMALIZED))
            }
            guard length > 0 else { throw windowsError() }
            if Int(length) >= buffer.count {
                buffer = [WCHAR](repeating: 0, count: Int(length) + 1)
                length = buffer.withUnsafeMutableBufferPointer {
                    GetFinalPathNameByHandleW(handle, $0.baseAddress, DWORD($0.count), DWORD(FILE_NAME_NORMALIZED))
                }
                guard length > 0, Int(length) < buffer.count else { throw windowsError() }
            }

            var resolvedPath = buffer.withUnsafeBufferPointer {
                String(decodingCString: $0.baseAddress!, as: UTF16.self)
            }
            if resolvedPath.hasPrefix("\\\\?\\UNC\\") {
                resolvedPath = "\\\(resolvedPath.dropFirst(7))"
            } else if resolvedPath.hasPrefix("\\\\?\\") {
                resolvedPath.removeFirst(4)
            }
            return resolvedPath
        #else
            var buffer = [CChar](repeating: 0, count: Int(PATH_MAX) + 1)
            let length = path.pathString.withCString { readlink($0, &buffer, buffer.count - 1) }
            guard length >= 0 else { throw posixError() }
            buffer[Int(length)] = 0
            return String(cString: buffer)
        #endif
    }

    private func descendantRelativePaths(of root: AbsolutePath) throws -> [String] {
        try descendantRelativePaths(of: root, prefix: "")
    }

    private func descendantRelativePaths(of directory: AbsolutePath, prefix: String) throws -> [String] {
        var descendants: [String] = []
        for child in try platformDirectoryContents(at: directory) {
            let relativePath = prefix.isEmpty ? child.basename : "\(prefix)/\(child.basename)"
            descendants.append(relativePath)

            if try platformFileInfo(at: child, followSymlinks: false)?.kind == .directory {
                descendants.append(contentsOf: try descendantRelativePaths(of: child, prefix: relativePath))
            }
        }
        return descendants
    }

    private func platformFileInfo(at path: AbsolutePath, followSymlinks: Bool) throws -> PlatformFileInfo? {
        #if os(Windows)
            var findData = WIN32_FIND_DATAW()
            let handle = windowsPathString(path.pathString).withCString(encodedAs: UTF16.self) { wpath in
                FindFirstFileW(wpath, &findData)
            }
            guard handle != INVALID_HANDLE_VALUE else {
                let error = GetLastError()
                if error == DWORD(ERROR_FILE_NOT_FOUND) || error == DWORD(ERROR_PATH_NOT_FOUND) {
                    return nil
                }
                throw windowsError(error)
            }
            defer { FindClose(handle) }

            let attributes = findData.dwFileAttributes
            let kind: PlatformFileKind
            if (attributes & DWORD(FILE_ATTRIBUTE_DIRECTORY)) != 0 {
                kind = .directory
            } else if (attributes & DWORD(FILE_ATTRIBUTE_REPARSE_POINT)) != 0 {
                kind = .symbolicLink
            } else {
                kind = .file
            }
            let size = (Int64(findData.nFileSizeHigh) << 32) | Int64(findData.nFileSizeLow)
            return PlatformFileInfo(
                kind: kind,
                size: size,
                modificationDate: windowsDate(from: findData.ftLastWriteTime)
            )
        #else
            var info = stat()
            let result = path.pathString.withCString { pathPointer in
                if followSymlinks {
                    stat(pathPointer, &info)
                } else {
                    lstat(pathPointer, &info)
                }
            }
            guard result == 0 else {
                let error = errno
                if error == ENOENT || error == ENOTDIR {
                    return nil
                }
                throw posixError(error)
            }

            return PlatformFileInfo(
                kind: posixFileKind(from: info),
                size: Int64(info.st_size),
                modificationDate: posixModificationDate(from: info)
            )
        #endif
    }

    #if !os(Windows)
        private func platformCopyRegularFile(from: AbsolutePath, to: AbsolutePath) throws {
            let sourceDescriptor = from.pathString.withCString { open($0, O_RDONLY) }
            guard sourceDescriptor >= 0 else { throw posixError() }
            defer { _ = close(sourceDescriptor) }

            let destinationDescriptor = to.pathString.withCString {
                open($0, O_WRONLY | O_CREAT | O_EXCL | O_TRUNC, mode_t(0o666))
            }
            guard destinationDescriptor >= 0 else { throw posixError() }
            defer { _ = close(destinationDescriptor) }

            var buffer = [UInt8](repeating: 0, count: 64 * 1024)
            while true {
                let readCount = buffer.withUnsafeMutableBytes {
                    read(sourceDescriptor, $0.baseAddress, $0.count)
                }
                guard readCount >= 0 else { throw posixError() }
                guard readCount > 0 else { return }

                var written = 0
                while written < readCount {
                    let writeCount = buffer.withUnsafeBytes { rawBuffer -> Int in
                        let baseAddress = rawBuffer.baseAddress!.advanced(by: written)
                        return write(destinationDescriptor, baseAddress, readCount - written)
                    }
                    guard writeCount >= 0 else { throw posixError() }
                    written += writeCount
                }
            }
        }

        private func posixFileKind(from info: stat) -> PlatformFileKind {
            switch info.st_mode & S_IFMT {
            case S_IFDIR:
                return .directory
            case S_IFLNK:
                return .symbolicLink
            case S_IFREG:
                return .file
            default:
                return .other
            }
        }

        private func posixModificationDate(from info: stat) -> Date {
            #if canImport(Darwin)
                let seconds = TimeInterval(info.st_mtimespec.tv_sec)
                let nanoseconds = TimeInterval(info.st_mtimespec.tv_nsec) / 1_000_000_000
            #else
                let seconds = TimeInterval(info.st_mtim.tv_sec)
                let nanoseconds = TimeInterval(info.st_mtim.tv_nsec) / 1_000_000_000
            #endif
            return Date(timeIntervalSince1970: seconds + nanoseconds)
        }

        private func posixError(_ code: Int32 = errno) -> NSError {
            NSError(domain: NSPOSIXErrorDomain, code: Int(code))
        }
    #else
        private func windowsAttributes(atPath path: String) -> DWORD {
            windowsPathString(path).withCString(encodedAs: UTF16.self) {
                GetFileAttributesW($0)
            }
        }

        private func windowsPathString(_ path: String) -> String {
            path.replacingOccurrences(of: "/", with: "\\")
        }

        private func windowsDirectoryEntryName(from findData: inout WIN32_FIND_DATAW) -> String {
            withUnsafePointer(to: &findData.cFileName) { pointer in
                pointer.withMemoryRebound(
                    to: WCHAR.self,
                    capacity: MemoryLayout.size(ofValue: findData.cFileName) / MemoryLayout<WCHAR>.size
                ) {
                    String(decodingCString: $0, as: UTF16.self)
                }
            }
        }

        private func windowsDate(from fileTime: FILETIME) -> Date {
            let intervals = (Int64(fileTime.dwHighDateTime) << 32) | Int64(fileTime.dwLowDateTime)
            let unixIntervals = intervals - 116_444_736_000_000_000
            let seconds = TimeInterval(unixIntervals / 10_000_000)
            let nanoseconds = TimeInterval(unixIntervals % 10_000_000) / 10_000_000
            return Date(timeIntervalSince1970: seconds + nanoseconds)
        }

        private func windowsFileTime(from date: Date) -> FILETIME {
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

        private func windowsError(_ code: DWORD = GetLastError()) -> NSError {
            NSError(domain: "WinSDK", code: Int(code))
        }

        private func fileExistsError(at path: AbsolutePath) -> CocoaError {
            CocoaError(.fileWriteFileExists, userInfo: [NSFilePathErrorKey: path.pathString])
        }
    #endif

    #if !os(Windows)
        private func fileExistsError(at path: AbsolutePath) -> CocoaError {
            CocoaError(.fileWriteFileExists, userInfo: [NSFilePathErrorKey: path.pathString])
        }
    #endif
}
