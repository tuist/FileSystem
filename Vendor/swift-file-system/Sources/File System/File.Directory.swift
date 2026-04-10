//
//  File.Directory+Convenience.swift
//  swift-file-system
//
//  Created by Coen ten Thije Boonkkamp on 18/12/2025.
//

// MARK: - Directory Operations

extension File.Directory {
    /// Creates the directory.
    ///
    /// - Parameter withIntermediates: Whether to create intermediate directories.
    /// - Throws: `File.System.Create.Directory.Error` on failure.
    public func create(withIntermediates: Bool = false) throws {
        let options = File.System.Create.Directory.Options(createIntermediates: withIntermediates)
        try File.System.Create.Directory.create(at: path, options: options)
    }

    /// Creates the directory.
    ///
    /// Async variant.
    public func create(withIntermediates: Bool = false) async throws {
        let options = File.System.Create.Directory.Options(createIntermediates: withIntermediates)
        try await File.System.Create.Directory.create(at: path, options: options)
    }

    /// Deletes the directory.
    ///
    /// - Parameter recursive: Whether to delete contents recursively.
    /// - Throws: `File.System.Delete.Error` on failure.
    public func delete(recursive: Bool = false) throws {
        let options = File.System.Delete.Options(recursive: recursive)
        try File.System.Delete.delete(at: path, options: options)
    }

    /// Deletes the directory.
    ///
    /// Async variant.
    public func delete(recursive: Bool = false) async throws {
        let options = File.System.Delete.Options(recursive: recursive)
        try await File.System.Delete.delete(at: path, options: options)
    }

    /// Copies the directory to a destination path.
    ///
    /// - Parameter destination: The destination path.
    /// - Throws: `File.System.Copy.Error` on failure.
    public func copy(to destination: File.Path) throws {
        try File.System.Copy.copy(from: path, to: destination)
    }

    /// Copies the directory to a destination.
    ///
    /// - Parameter destination: The destination directory.
    /// - Throws: `File.System.Copy.Error` on failure.
    public func copy(to destination: File.Directory) throws {
        try File.System.Copy.copy(from: path, to: destination.path)
    }

    /// Copies the directory to a destination path.
    ///
    /// Async variant.
    public func copy(to destination: File.Path) async throws {
        try await File.System.Copy.copy(from: path, to: destination)
    }

    /// Copies the directory to a destination.
    ///
    /// Async variant.
    public func copy(to destination: File.Directory) async throws {
        try await File.System.Copy.copy(from: path, to: destination.path)
    }

    /// Moves the directory to a destination path.
    ///
    /// - Parameter destination: The destination path.
    /// - Throws: `File.System.Move.Error` on failure.
    public func move(to destination: File.Path) throws {
        try File.System.Move.move(from: path, to: destination)
    }

    /// Moves the directory to a destination.
    ///
    /// - Parameter destination: The destination directory.
    /// - Throws: `File.System.Move.Error` on failure.
    public func move(to destination: File.Directory) throws {
        try File.System.Move.move(from: path, to: destination.path)
    }

    /// Moves the directory to a destination path.
    ///
    /// Async variant.
    public func move(to destination: File.Path) async throws {
        try await File.System.Move.move(from: path, to: destination)
    }

    /// Moves the directory to a destination.
    ///
    /// Async variant.
    public func move(to destination: File.Directory) async throws {
        try await File.System.Move.move(from: path, to: destination.path)
    }
}

// MARK: - Stat Operations

extension File.Directory {
    /// Returns `true` if the directory exists.
    public var exists: Bool {
        File.System.Stat.exists(at: path)
    }

    /// Returns `true` if the path is a directory.
    public var isDirectory: Bool {
        File.System.Stat.isDirectory(at: path)
    }

    /// Returns `true` if the path is a symbolic link.
    public var isSymlink: Bool {
        File.System.Stat.isSymlink(at: path)
    }
}

// MARK: - Metadata

extension File.Directory {
    /// Returns directory metadata information.
    ///
    /// - Throws: `File.System.Stat.Error` on failure.
    public var info: File.System.Metadata.Info {
        get throws {
            try File.System.Stat.info(at: path)
        }
    }

    /// Returns the directory permissions.
    ///
    /// - Throws: `File.System.Stat.Error` on failure.
    public var permissions: File.System.Metadata.Permissions {
        get throws {
            try info.permissions
        }
    }
}

// MARK: - Contents

extension File.Directory {
    /// Returns the contents of the directory.
    ///
    /// - Returns: An array of directory entries.
    /// - Throws: `File.Directory.Contents.Error` on failure.
    public func contents() throws -> [File.Directory.Entry] {
        try File.Directory.Contents.list(at: path)
    }

    /// Returns the contents of the directory.
    ///
    /// Async variant. Use `entries()` for true streaming iteration.
    public func contents() async throws -> [File.Directory.Entry] {
        try await File.Directory.Contents.list(at: path)
    }

    /// Returns all files in the directory.
    ///
    /// - Returns: An array of files.
    /// - Throws: `File.Directory.Contents.Error` on failure.
    public func files() throws -> [File] {
        try contents()
            .filter { $0.type == .file }
            .map { File($0.path) }
    }

    /// Returns all subdirectories in the directory.
    ///
    /// - Returns: An array of directories.
    /// - Throws: `File.Directory.Contents.Error` on failure.
    public func subdirectories() throws -> [File.Directory] {
        try contents()
            .filter { $0.type == .directory }
            .map { File.Directory($0.path) }
    }

    /// Returns whether the directory is empty.
    ///
    /// - Returns: `true` if the directory contains no entries.
    /// - Throws: `File.Directory.Contents.Error` on failure.
    public var isEmpty: Bool {
        get throws {
            try contents().isEmpty
        }
    }

    // Note: Async directory streaming (entries()) is available in the File System Async layer
    // via File.Async.Directory.Entries
}

// MARK: - Subscript Access

extension File.Directory {
    /// Access a file in this directory.
    ///
    /// - Parameter name: The file name.
    /// - Returns: A file for the named file.
    public subscript(_ name: String) -> File {
        File(path.appending(name))
    }

    /// Access a file in this directory (labeled).
    ///
    /// ## Example
    /// ```swift
    /// let readme = dir[file: "README.md"]
    /// ```
    ///
    /// - Parameter name: The file name.
    /// - Returns: A file for the named file.
    public subscript(file name: String) -> File {
        File(path.appending(name))
    }

    /// Access a subdirectory (labeled).
    ///
    /// ## Example
    /// ```swift
    /// let src = dir[directory: "src"]
    /// let nested = dir[directory: "src"][file: "main.swift"]
    /// ```
    ///
    /// - Parameter name: The subdirectory name.
    /// - Returns: A directory for the named subdirectory.
    public subscript(directory name: String) -> File.Directory {
        File.Directory(path.appending(name))
    }

    /// Access a subdirectory.
    ///
    /// - Parameter name: The subdirectory name.
    /// - Returns: A directory for the named subdirectory.
    public func subdirectory(_ name: String) -> File.Directory {
        File.Directory(path.appending(name))
    }
}

// MARK: - Path Navigation

extension File.Directory {
    /// The parent directory, or `nil` if this is a root path.
    public var parent: File.Directory? {
        path.parent.map(File.Directory.init)
    }

    /// The directory name (last component of the path).
    public var name: String {
        path.lastComponent?.string ?? ""
    }

    /// Returns a new directory with the given component appended.
    ///
    /// - Parameter component: The component to append.
    /// - Returns: A new directory with the appended path.
    public func appending(_ component: String) -> File.Directory {
        File.Directory(path.appending(component))
    }

    /// Appends a component to a directory.
    ///
    /// - Parameters:
    ///   - lhs: The base directory.
    ///   - rhs: The component to append.
    /// - Returns: A new directory with the appended path.
    public static func / (lhs: File.Directory, rhs: String) -> File.Directory {
        lhs.appending(rhs)
    }
}
