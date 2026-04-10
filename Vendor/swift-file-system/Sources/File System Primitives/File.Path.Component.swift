//
//  File.Path.Component.swift
//  swift-file-system
//
//  Created by Coen ten Thije Boonkkamp on 17/12/2025.
//

import SystemPackage

extension File.Path {
    /// A single component of a file path.
    ///
    /// A component represents a single directory or file name within a path.
    /// For example, in `/usr/local/bin`, the components are `usr`, `local`, and `bin`.
    public struct Component: Hashable, Sendable {
        @usableFromInline
        package var _component: FilePath.Component

        /// Creates a component from a SystemPackage FilePath.Component.
        @usableFromInline
        package init(__unchecked component: FilePath.Component) {
            self._component = component
        }

        /// Creates a validated component from a string.
        ///
        /// - Parameter string: The component string.
        /// - Throws: `File.Path.Component.Error` if the string is invalid.
        @inlinable
        public init(_ string: String) throws(Error) {
            guard !string.isEmpty else {
                throw .empty
            }
            guard !string.contains("/") else {
                throw .containsPathSeparator
            }
            guard let component = FilePath.Component(string) else {
                throw .invalid
            }
            self._component = component
        }
    }
}

// MARK: - Error

extension File.Path.Component {
    /// Errors that can occur during component construction.
    public enum Error: Swift.Error, Equatable, Sendable {
        /// The component string is empty.
        case empty
        /// The component contains a path separator.
        case containsPathSeparator
        /// The component is invalid.
        case invalid
    }
}

// MARK: - Properties

extension File.Path.Component {
    /// The string representation of this component.
    @inlinable
    public var string: String {
        _component.string
    }

    /// The file extension, or `nil` if there is none.
    @inlinable
    public var `extension`: String? {
        _component.extension
    }

    /// The filename without extension.
    @inlinable
    public var stem: String? {
        _component.stem
    }

    /// The underlying SystemPackage FilePath.Component.
    @inlinable
    public var filePathComponent: FilePath.Component {
        _component
    }
}

// MARK: - CustomStringConvertible

extension File.Path.Component: CustomStringConvertible {
    @inlinable
    public var description: String {
        string
    }
}

// MARK: - CustomDebugStringConvertible

extension File.Path.Component: CustomDebugStringConvertible {
    public var debugDescription: String {
        "File.Path.Component(\(string.debugDescription))"
    }
}

// MARK: - ExpressibleByStringLiteral

extension File.Path.Component: ExpressibleByStringLiteral {
    /// Creates a component from a string literal.
    ///
    /// String literals are compile-time constants, so validation failures
    /// are programmer errors and will trigger a fatal error.
    @inlinable
    public init(stringLiteral value: String) {
        do {
            try self.init(value)
        } catch {
            fatalError("Invalid component literal: \(error)")
        }
    }
}

// MARK: - CustomStringConvertible for Error

extension File.Path.Component.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .empty:
            return "Component is empty"
        case .containsPathSeparator:
            return "Component contains path separator"
        case .invalid:
            return "Component is invalid"
        }
    }
}
