//
//  File.System+Async.swift
//  swift-file-system
//
//  Async overloads for sync operations.
//  Swift disambiguates by context - use `await` for async version.
//

// MARK: - Read

extension File.System.Read.Full {
    /// Reads entire file contents asynchronously.
    ///
    /// ```swift
    /// let data = try await File.System.Read.Full.read(from: path)
    /// ```
    public static func read(
        from path: File.Path,
        io: File.IO.Executor = .default
    ) async throws -> [UInt8] {
        try await io.run { try read(from: path) }
    }
}

// MARK: - Write

extension File.System.Write.Atomic {
    /// Writes data atomically to a file asynchronously.
    ///
    /// ```swift
    /// try await File.System.Write.Atomic.write(data, to: path)
    /// ```
    public static func write(
        _ bytes: [UInt8],
        to path: File.Path,
        options: Options = .init(),
        io: File.IO.Executor = .default
    ) async throws {
        try await io.run {
            try bytes.withUnsafeBufferPointer { buffer in
                let span = Span<UInt8>(_unsafeElements: buffer)
                try write(span, to: path, options: options)
            }
        }
    }
}

extension File.System.Write.Append {
    /// Appends data to a file asynchronously.
    ///
    /// ```swift
    /// try await File.System.Write.Append.append(data, to: path)
    /// ```
    public static func append(
        _ bytes: [UInt8],
        to path: File.Path,
        io: File.IO.Executor = .default
    ) async throws {
        try await io.run {
            try bytes.withUnsafeBufferPointer { buffer in
                let span = Span<UInt8>(_unsafeElements: buffer)
                try append(span, to: path)
            }
        }
    }
}

// MARK: - Copy

extension File.System.Copy {
    /// Copies a file asynchronously.
    ///
    /// ```swift
    /// try await File.System.Copy.copy(from: source, to: destination)
    /// ```
    public static func copy(
        from source: File.Path,
        to destination: File.Path,
        options: Options = .init(),
        io: File.IO.Executor = .default
    ) async throws {
        try await io.run { try copy(from: source, to: destination, options: options) }
    }
}

// MARK: - Move

extension File.System.Move {
    /// Moves or renames a file asynchronously.
    ///
    /// ```swift
    /// try await File.System.Move.move(from: source, to: destination)
    /// ```
    public static func move(
        from source: File.Path,
        to destination: File.Path,
        options: Options = .init(),
        io: File.IO.Executor = .default
    ) async throws {
        try await io.run { try move(from: source, to: destination, options: options) }
    }
}

// MARK: - Delete

extension File.System.Delete {
    /// Deletes a file or directory asynchronously.
    ///
    /// ```swift
    /// try await File.System.Delete.delete(at: path)
    /// ```
    public static func delete(
        at path: File.Path,
        options: Options = .init(),
        io: File.IO.Executor = .default
    ) async throws {
        try await io.run { try delete(at: path, options: options) }
    }
}

// MARK: - Create Directory

extension File.System.Create.Directory {
    /// Creates a directory asynchronously.
    ///
    /// ```swift
    /// try await File.System.Create.Directory.create(at: path)
    /// ```
    public static func create(
        at path: File.Path,
        options: Options = .init(),
        io: File.IO.Executor = .default
    ) async throws {
        try await io.run { try create(at: path, options: options) }
    }
}

// MARK: - Stat

extension File.System.Stat {
    /// Gets file metadata asynchronously.
    ///
    /// ```swift
    /// let info = try await File.System.Stat.info(at: path)
    /// ```
    public static func info(
        at path: File.Path,
        io: File.IO.Executor = .default
    ) async throws -> File.System.Metadata.Info {
        try await io.run { try info(at: path) }
    }

    /// Checks if a path exists asynchronously.
    ///
    /// ```swift
    /// let exists = await File.System.Stat.exists(at: path)
    /// ```
    public static func exists(
        at path: File.Path,
        io: File.IO.Executor = .default
    ) async -> Bool {
        do {
            return try await io.run { exists(at: path) }
        } catch {
            return false
        }
    }

    /// Checks if path is a file asynchronously.
    public static func isFile(
        at path: File.Path,
        io: File.IO.Executor = .default
    ) async -> Bool {
        do {
            let metadata = try await io.run { try File.System.Stat.info(at: path) }
            return metadata.type == .regular
        } catch {
            return false
        }
    }

    /// Checks if path is a directory asynchronously.
    public static func isDirectory(
        at path: File.Path,
        io: File.IO.Executor = .default
    ) async -> Bool {
        do {
            let metadata = try await io.run { try File.System.Stat.info(at: path) }
            return metadata.type == .directory
        } catch {
            return false
        }
    }

    /// Checks if path is a symlink asynchronously.
    public static func isSymlink(
        at path: File.Path,
        io: File.IO.Executor = .default
    ) async -> Bool {
        do {
            let metadata = try await io.run { try File.System.Stat.lstatInfo(at: path) }
            return metadata.type == .symbolicLink
        } catch {
            return false
        }
    }
}

// MARK: - Directory Contents

extension File.Directory.Contents {
    /// Lists directory contents asynchronously.
    ///
    /// ```swift
    /// let entries = try await File.Directory.Contents.list(at: path)
    /// ```
    public static func list(
        at path: File.Path,
        io: File.IO.Executor = .default
    ) async throws -> [File.Directory.Entry] {
        try await io.run { try list(at: path) }
    }
}

// MARK: - Links

extension File.System.Link.Symbolic {
    /// Creates a symbolic link asynchronously.
    ///
    /// ```swift
    /// try await File.System.Link.Symbolic.create(at: link, pointingTo: target)
    /// ```
    public static func create(
        at path: File.Path,
        pointingTo target: File.Path,
        io: File.IO.Executor = .default
    ) async throws {
        try await io.run { try create(at: path, pointingTo: target) }
    }
}

extension File.System.Link.Hard {
    /// Creates a hard link asynchronously.
    ///
    /// ```swift
    /// try await File.System.Link.Hard.create(at: link, to: target)
    /// ```
    public static func create(
        at path: File.Path,
        to existing: File.Path,
        io: File.IO.Executor = .default
    ) async throws {
        try await io.run { try create(at: path, to: existing) }
    }
}

extension File.System.Link.ReadTarget {
    /// Reads symlink target asynchronously.
    ///
    /// ```swift
    /// let target = try await File.System.Link.ReadTarget.target(of: link)
    /// ```
    public static func target(
        of path: File.Path,
        io: File.IO.Executor = .default
    ) async throws -> File.Path {
        try await io.run { try target(of: path) }
    }
}
