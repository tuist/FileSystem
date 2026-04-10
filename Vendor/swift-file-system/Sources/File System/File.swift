//
//  File+Convenience.swift
//  swift-file-system
//
//  Created by Coen ten Thije Boonkkamp on 18/12/2025.
//

// MARK: - Read Operations

extension File {
    /// Reads the entire file contents into memory.
    ///
    /// - Returns: The file contents as an array of bytes.
    /// - Throws: `File.System.Read.Full.Error` on failure.
    public func read() throws -> [UInt8] {
        try File.System.Read.Full.read(from: path)
    }

    /// Reads the entire file contents into memory.
    ///
    /// Async variant.
    public func read() async throws -> [UInt8] {
        try await File.System.Read.Full.read(from: path)
    }

    /// Reads the file contents as a UTF-8 string.
    ///
    /// - Returns: The file contents as a string.
    /// - Throws: `File.System.Read.Full.Error` on failure.
    public func readString() throws -> String {
        let bytes = try File.System.Read.Full.read(from: path)
        return String(decoding: bytes, as: UTF8.self)
    }

    /// Reads the file contents as a UTF-8 string.
    ///
    /// Async variant.
    public func readString() async throws -> String {
        let bytes = try await File.System.Read.Full.read(from: path)
        return String(decoding: bytes, as: UTF8.self)
    }
}

// MARK: - Write Operations

extension File {
    /// Writes bytes to the file atomically.
    ///
    /// - Parameter bytes: The bytes to write.
    /// - Throws: `File.System.Write.Atomic.Error` on failure.
    public func write(_ bytes: [UInt8]) throws {
        try bytes.withUnsafeBufferPointer { buffer in
            let span = Span<UInt8>(_unsafeElements: buffer)
            try File.System.Write.Atomic.write(span, to: path)
        }
    }

    /// Writes bytes to the file atomically.
    ///
    /// Async variant.
    public func write(_ bytes: [UInt8]) async throws {
        try await File.System.Write.Atomic.write(bytes, to: path)
    }

    /// Writes a string to the file atomically (UTF-8 encoded).
    ///
    /// - Parameter string: The string to write.
    /// - Throws: `File.System.Write.Atomic.Error` on failure.
    public func write(_ string: String) throws {
        try write(Array(string.utf8))
    }

    /// Writes a string to the file atomically (UTF-8 encoded).
    ///
    /// Async variant.
    public func write(_ string: String) async throws {
        try await write(Array(string.utf8))
    }

    /// Appends bytes to the file.
    ///
    /// - Parameter bytes: The bytes to append.
    /// - Throws: `File.Handle.Error` on failure.
    public func append(_ bytes: [UInt8]) throws {
        try File.Handle.open(path, options: [.create]).appending { handle in
            try bytes.withUnsafeBufferPointer { buffer in
                let span = Span<UInt8>(_unsafeElements: buffer)
                try handle.write(span)
            }
        }
    }

    /// Appends bytes to the file.
    ///
    /// Async variant.
    public func append(_ bytes: [UInt8]) async throws {
        try await File.System.Write.Append.append(bytes, to: path)
    }

    /// Appends a string to the file (UTF-8 encoded).
    ///
    /// - Parameter string: The string to append.
    /// - Throws: `File.Handle.Error` on failure.
    public func append(_ string: String) throws {
        try append(Array(string.utf8))
    }

    /// Appends a string to the file (UTF-8 encoded).
    ///
    /// Async variant.
    public func append(_ string: String) async throws {
        try await append(Array(string.utf8))
    }

    /// Creates an empty file or updates its timestamp if it exists.
    ///
    /// - Returns: Self for chaining.
    /// - Throws: `File.Handle.Error` on failure.
    @discardableResult
    public func touch() throws -> Self {
        if exists {
            // Update modification time by opening for write and closing
            try File.Handle.open(path, options: []).readWrite { _ in }
        } else {
            // Create empty file
            try write([UInt8]())
        }
        return self
    }

    /// Creates an empty file or updates its timestamp if it exists.
    ///
    /// Async variant.
    @discardableResult
    public func touch() async throws -> Self {
        if exists {
            try File.Handle.open(path, options: []).readWrite { _ in }
        } else {
            try await write([UInt8]())
        }
        return self
    }
}

// MARK: - Stat Operations

extension File {
    /// Returns `true` if the file exists.
    public var exists: Bool {
        File.System.Stat.exists(at: path)
    }

    /// Returns `true` if the path is a regular file.
    public var isFile: Bool {
        File.System.Stat.isFile(at: path)
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

extension File {
    /// Returns file metadata information.
    ///
    /// - Throws: `File.System.Stat.Error` on failure.
    public var info: File.System.Metadata.Info {
        get throws {
            try File.System.Stat.info(at: path)
        }
    }

    /// Returns the file size in bytes.
    ///
    /// - Throws: `File.System.Stat.Error` on failure.
    public var size: Int64 {
        get throws {
            try info.size
        }
    }

    /// Returns the file permissions.
    ///
    /// - Throws: `File.System.Stat.Error` on failure.
    public var permissions: File.System.Metadata.Permissions {
        get throws {
            try info.permissions
        }
    }

    /// Returns `true` if the file is empty (size is 0).
    ///
    /// - Throws: `File.System.Stat.Error` on failure.
    public var isEmpty: Bool {
        get throws {
            try size == 0
        }
    }
}

// MARK: - File Operations

extension File {
    /// Deletes the file.
    ///
    /// - Throws: `File.System.Delete.Error` on failure.
    public func delete() throws {
        try File.System.Delete.delete(at: path)
    }

    /// Deletes the file.
    ///
    /// Async variant.
    public func delete() async throws {
        try await File.System.Delete.delete(at: path)
    }

    /// Copies the file to a destination path.
    ///
    /// - Parameter destination: The destination path.
    /// - Throws: `File.System.Copy.Error` on failure.
    public func copy(to destination: File.Path) throws {
        try File.System.Copy.copy(from: path, to: destination)
    }

    /// Copies the file to a destination.
    ///
    /// - Parameter destination: The destination file.
    /// - Throws: `File.System.Copy.Error` on failure.
    public func copy(to destination: File) throws {
        try File.System.Copy.copy(from: path, to: destination.path)
    }

    /// Moves the file to a destination path.
    ///
    /// - Parameter destination: The destination path.
    /// - Throws: `File.System.Move.Error` on failure.
    public func move(to destination: File.Path) throws {
        try File.System.Move.move(from: path, to: destination)
    }

    /// Moves the file to a destination.
    ///
    /// - Parameter destination: The destination file.
    /// - Throws: `File.System.Move.Error` on failure.
    public func move(to destination: File) throws {
        try File.System.Move.move(from: path, to: destination.path)
    }
}

// MARK: - Path Navigation

extension File {
    /// The parent directory as a file, or `nil` if this is a root path.
    public var parent: File? {
        path.parent.map(File.init)
    }

    /// The file name (last component of the path).
    public var name: String {
        path.lastComponent?.string ?? ""
    }

    /// The file extension, or `nil` if there is none.
    public var `extension`: String? {
        path.extension
    }

    /// The filename without extension.
    public var stem: String? {
        path.stem
    }

    /// Returns a new file with the given component appended.
    ///
    /// - Parameter component: The component to append.
    /// - Returns: A new file with the appended path.
    public func appending(_ component: String) -> File {
        File(path.appending(component))
    }

    /// Appends a component to a file.
    ///
    /// - Parameters:
    ///   - lhs: The base file.
    ///   - rhs: The component to append.
    /// - Returns: A new file with the appended path.
    public static func / (lhs: File, rhs: String) -> File {
        lhs.appending(rhs)
    }
}
