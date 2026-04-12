//
//  File.Directory.swift
//  swift-file-system
//
//  Created by Coen ten Thije Boonkkamp on 17/12/2025.
//

extension File {
    /// A directory reference providing convenient access to directory operations.
    ///
    /// `File.Directory` wraps a path and provides ergonomic methods that
    /// delegate to `File.System.*` primitives. It is Hashable and Sendable.
    ///
    /// ## Example
    /// ```swift
    /// let dir: File.Directory = "/tmp/mydir"
    /// try dir.create(withIntermediates: true)
    /// let readme = dir[file: "README.md"]
    ///
    /// for entry in try dir.contents() {
    ///     print(entry.name)
    /// }
    /// ```
    public struct Directory: Hashable, Sendable, ExpressibleByStringLiteral {
        /// The underlying directory path.
        public let path: File.Path

        // MARK: - Initializers

        /// Creates a directory from a path.
        ///
        /// - Parameter path: The directory path.
        public init(_ path: File.Path) {
            self.path = path
        }

        /// Creates a directory from a string path.
        ///
        /// - Parameter string: The path string.
        /// - Throws: `File.Path.Error` if the path is invalid.
        public init(_ string: String) throws {
            self.path = try File.Path(string)
        }

        /// Creates a directory from a string literal.
        ///
        /// - Parameter value: The path string literal.
        public init(stringLiteral value: String) {
            do {
                self.path = try File.Path(value)
            } catch {
                fatalError("Invalid path literal: \(error)")
            }
        }
    }
}

// MARK: - CustomStringConvertible

extension File.Directory: CustomStringConvertible {
    public var description: String {
        path.string
    }
}

// MARK: - CustomDebugStringConvertible

extension File.Directory: CustomDebugStringConvertible {
    public var debugDescription: String {
        "File.Directory(\(path.string.debugDescription))"
    }
}
