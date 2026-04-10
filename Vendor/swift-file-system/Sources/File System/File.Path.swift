//
//  File.Path+Convenience.swift
//  swift-file-system
//
//  Created by Coen ten Thije Boonkkamp on 18/12/2025.
//

import SystemPackage

extension File.Path {
    /// A property that can be modified on a path.
    ///
    /// This struct enables extensible path manipulation. Users can define
    /// custom properties beyond the built-in `.extension` and `.lastComponent`.
    ///
    /// ## Example
    /// ```swift
    /// // Built-in properties
    /// path.with(.extension, "txt")
    /// path.removing(.extension)
    ///
    /// // Custom property
    /// extension File.Path.Property {
    ///     static let stem = Property(
    ///         set: { path, value in
    ///             let ext = path.extension
    ///             return path.removing(.extension).parent?.appending(value + (ext.map { ".\($0)" } ?? "")) ?? path
    ///         },
    ///         remove: { $0 }  // Can't remove stem
    ///     )
    /// }
    /// ```
    public struct Property: Sendable {
        /// Sets the property to a new value.
        public let set: @Sendable (File.Path, String) -> File.Path

        /// Removes the property from the path.
        public let remove: @Sendable (File.Path) -> File.Path

        /// Creates a new property.
        public init(
            set: @escaping @Sendable (File.Path, String) -> File.Path,
            remove: @escaping @Sendable (File.Path) -> File.Path
        ) {
            self.set = set
            self.remove = remove
        }
    }

    // MARK: - Modification

    /// Returns path with property set to value.
    ///
    /// ## Example
    /// ```swift
    /// let path: File.Path = "/tmp/data.json"
    /// let txt = path.with(.extension, "txt")  // /tmp/data.txt
    /// let renamed = path.with(.lastComponent, "config.json")  // /tmp/config.json
    /// ```
    @inlinable
    public func with(_ property: Property, _ value: String) -> Self {
        property.set(self, value)
    }

    /// Returns path with property removed.
    ///
    /// ## Example
    /// ```swift
    /// let path: File.Path = "/tmp/data.json"
    /// let noExt = path.removing(.extension)  // /tmp/data
    /// ```
    @inlinable
    public func removing(_ property: Property) -> Self {
        property.remove(self)
    }
}

// MARK: - Built-in Properties

extension File.Path.Property {
    /// The file extension.
    public static let `extension` = Self(
        set: { path, value in
            var copy = path._path
            copy.extension = value
            return File.Path(__unchecked: (), copy)
        },
        remove: { path in
            var copy = path._path
            copy.extension = nil
            return File.Path(__unchecked: (), copy)
        }
    )

    /// The last path component (filename or directory name).
    public static let lastComponent = Self(
        set: { path, value in
            guard let parent = path.parent else {
                return File.Path(__unchecked: (), value)
            }
            return parent.appending(value)
        },
        remove: { path in
            path.parent ?? path
        }
    )
}

extension File.Path {
    // MARK: - Components

    /// All path components as an array.
    @inlinable
    public var components: [Component] {
        _path.components.map { Component(__unchecked: $0) }
    }

    /// Number of path components.
    @inlinable
    public var count: Int {
        _path.components.count
    }

    // MARK: - Prefix/Relative

    /// Returns true if this path starts with the given prefix.
    ///
    /// ## Example
    /// ```swift
    /// let path: File.Path = "/usr/local/bin/swift"
    /// path.hasPrefix("/usr/local")  // true
    /// path.hasPrefix("/var")        // false
    /// ```
    @inlinable
    public func hasPrefix(_ other: File.Path) -> Bool {
        let selfComponents = Array(_path.components)
        let otherComponents = Array(other._path.components)

        guard otherComponents.count <= selfComponents.count else {
            return false
        }

        return zip(selfComponents, otherComponents).allSatisfy { $0 == $1 }
    }

    /// Returns the relative path from a base path, or nil if base is not a prefix.
    ///
    /// ## Example
    /// ```swift
    /// let path: File.Path = "/usr/local/bin/swift"
    /// let rel = path.relative(to: "/usr/local")  // "bin/swift"
    /// ```
    @inlinable
    public func relative(to base: File.Path) -> File.Path? {
        guard hasPrefix(base) else { return nil }

        let selfComponents = Array(_path.components)
        let baseCount = base._path.components.count

        guard baseCount < selfComponents.count else {
            // Same path
            return nil
        }

        var result = SystemPackage.FilePath()
        for component in selfComponents.dropFirst(baseCount) {
            result.append(component)
        }

        guard !result.isEmpty else { return nil }
        return File.Path(__unchecked: (), result)
    }
}
