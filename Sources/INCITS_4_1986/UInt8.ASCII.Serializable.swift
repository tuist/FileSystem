//
//  Binary.ASCII.Serializable.swift
//  swift-incits-4-1986
//
//  ASCII Serialization Protocol
//
//  This protocol captures the canonical transformation pattern for types
//  that work at the ASCII byte level (INCITS 4-1986 / ASCII standard).
//
//  ## Philosophy
//
//  Types conforming to Serializable treat [UInt8] as the canonical form.
//  String operations are derived through composition:
//
//  ```
//  String → [UInt8] (UTF-8) → Type  (parsing)
//  Type → [UInt8] (ASCII) → String  (serialization)
//  ```
//
//  ## Usage
//
//  Conforming types must provide:
//  1. `init(ascii:in:)` - byte-level parsing with context
//  2. `static func serialize(ascii:into:)` - byte-level buffer serialization
//
//  For context-free types, use `Context = Void` (the default) and
//  implement `init(ascii bytes: Bytes, in context: Void)`.
//
//  The protocol automatically provides:
//  - `init(_: some StringProtocol)` - string parsing
//  - `String.init(_:)` - string conversion
//  - `var description: String` - (if type conforms to CustomStringConvertible)
//
//  ## Example
//
//  ```swift
//  struct EmailAddress: Binary.ASCII.Serializable {
//      init<Bytes: Collection>(ascii bytes: Bytes, in context: Void) throws(Error) {
//          // Parse bytes...
//      }
//
//      static func serialize<Buffer: RangeReplaceableCollection>(
//          ascii address: Self,
//          into buffer: inout Buffer
//      ) where Buffer.Element == UInt8 {
//          buffer.append(contentsOf: address.localPart.utf8)
//          buffer.append(UInt8(ascii: "@"))
//          buffer.append(contentsOf: address.domain.utf8)
//      }
//  }
//
//  // Now you get for free:
//  let addr = try EmailAddress("user@example.com")  // String parsing
//  let str = String(addr)                           // String conversion
//  ```
//
//  Created by Coen ten Thije Boonkkamp on 24/11/2025.
//

public import Binary

extension Binary.ASCII {
    /// Protocol for types with canonical ASCII byte-level transformations
    ///
    /// Types conforming to this protocol work at the byte level as the primitive form,
    /// with string operations derived through composition.
    ///
    /// ## Category Theory
    ///
    /// This protocol models the relationship between structured types and byte sequences:
    /// - **Serialize**: `(T, Buffer) → Buffer` (buffer mutation, context-free)
    /// - **Parse**: `(Context, [UInt8]) → T` (may require context to interpret bytes)
    ///
    /// The asymmetry is natural: structured values contain complete information,
    /// while raw bytes may need external context to interpret.
    ///
    /// ## Requirements
    ///
    /// Conforming types must provide:
    /// - `init(ascii:in:)` - Parse from bytes with context
    /// - `static func serialize(ascii:into:)` - Serialize to buffer
    ///
    /// ## Context-Free Types (Context == Void)
    ///
    /// Most types are context-free and use `Context = Void` (the default):
    ///
    /// ```swift
    /// struct Token: Binary.ASCII.Serializable {
    ///     init<Bytes>(ascii bytes: Bytes, in context: Void) throws(Error) { ... }
    ///     static func serialize<Buffer>(ascii token: Self, into buffer: inout Buffer) { ... }
    /// }
    ///
    /// let token = try Token(ascii: bytes)  // Context-free
    /// let token = try Token("example")     // String convenience
    /// ```
    ///
    /// ## Context-Dependent Types (Context != Void)
    ///
    /// Types that require external information to parse define a custom `Context`:
    ///
    /// ```swift
    /// struct Multipart: Binary.ASCII.Serializable {
    ///     struct Context: Sendable {
    ///         let boundary: Boundary
    ///     }
    ///
    ///     init<Bytes>(ascii bytes: Bytes, in context: Context) throws(Error) { ... }
    /// }
    ///
    /// let multipart = try Multipart(ascii: bytes, in: .init(boundary: boundary))
    /// ```
    ///
    /// ## Automatic Implementations
    ///
    /// The protocol provides:
    /// - `init(ascii:)` convenience when `Context == Void`
    /// - String parsing via `init(_: some StringProtocol)` when `Context == Void`
    /// - String conversion via `String.init(_:)`
    /// - CustomStringConvertible (if type conforms)
    /// - `Binary.Serializable` conformance (buffer-based serialization)
    public protocol Serializable: Binary.Serializable {
        /// Serialize this value into an ASCII byte buffer
        ///
        /// Writes the ASCII byte representation of this value into the buffer.
        /// Implementations should append bytes without clearing existing content.
        ///
        /// ## Implementation Requirements
        ///
        /// - MUST append bytes to buffer (not replace)
        /// - MUST produce valid ASCII (bytes 0x00-0x7F)
        /// - MUST NOT throw (serialization is infallible for valid values)
        /// - SHOULD be deterministic (same value produces same bytes)
        ///
        /// - Parameters:
        ///   - serializable: The value to serialize
        ///   - buffer: The buffer to append bytes to
        static func serialize<Buffer: RangeReplaceableCollection>(
            ascii serializable: Self,
            into buffer: inout Buffer
        ) where Buffer.Element == UInt8

        /// The error type for parsing failures
        associatedtype Error: Swift.Error

        /// The context type required for parsing
        ///
        /// Use `Void` (the default) for context-free types.
        /// Define a custom type for context-dependent parsing.
        associatedtype Context: Sendable = Void

        /// Parse from canonical ASCII byte representation with context
        ///
        /// This is the primary parsing requirement. Implement this method
        /// for all conforming types.
        ///
        /// - For context-free types: use `in context: Void` (or just `in _: Void`)
        /// - For context-dependent types: use your custom context type
        ///
        /// - Parameters:
        ///   - bytes: The ASCII byte representation
        ///   - context: Parsing context (use `()` for context-free types)
        /// - Throws: Self.Error if the bytes are malformed
        init<Bytes: Collection>(
            ascii bytes: Bytes,
            in context: Context
        ) throws(Error) where Bytes.Element == UInt8
    }
}

// MARK: - Binary.Serializable Conformance

extension Binary.ASCII.Serializable {
    /// Default `Binary.Serializable` implementation via ASCII serialization
    ///
    /// Bridges ASCII serialization to the base `Binary.Serializable` protocol.
    /// This enables ASCII types to be used anywhere `Binary.Serializable` is expected.
    @inlinable
    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ serializable: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == UInt8 {
        Self.serialize(ascii: serializable, into: &buffer)
    }
}

// MARK: - Static Returning Convenience

extension Binary.ASCII.Serializable {
    /// Serialize to a new collection (static method)
    ///
    /// Creates a new buffer of the inferred type and serializes into it.
    ///
    /// - Parameter serializable: The value to serialize
    /// - Returns: A new collection containing the serialized ASCII bytes
    @inlinable
    public static func serialize<Bytes: RangeReplaceableCollection>(
        ascii serializable: Self
    ) -> Bytes where Bytes.Element == UInt8 {
        var buffer = Bytes()
        Self.serialize(ascii: serializable, into: &buffer)
        return buffer
    }
}

// MARK: - Collection Initializers

extension Array where Element == UInt8 {
    /// Create an ASCII byte array from a serializable value
    ///
    /// - Parameter serializable: The ASCII serializable value
    @inlinable
    public init<S: Binary.ASCII.Serializable>(ascii serializable: S) {
        self = []
        S.serialize(ascii: serializable, into: &self)
    }
}

extension Binary.ASCII.Serializable where Self: Swift.RawRepresentable, Self.RawValue == [UInt8] {
    /// Default implementation for byte-array-backed types
    ///
    /// Appends the raw value directly (identity transformation).
    @inlinable
    public static func serialize<Buffer: RangeReplaceableCollection>(
        ascii serializable: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == UInt8 {
        buffer.append(contentsOf: serializable.rawValue)
    }
}

// MARK: - Context-Free Convenience

extension Binary.ASCII.Serializable where Context == Void {
    /// Parse from canonical ASCII byte representation (context-free convenience)
    ///
    /// This convenience initializer is available for context-free types
    /// where `Context == Void`. It simply calls `init(ascii:in:)` with `()`.
    ///
    /// - Parameter bytes: The ASCII byte representation
    /// - Throws: Self.Error if the bytes are malformed
    @inlinable
    public init<Bytes: Collection>(ascii bytes: Bytes) throws(Error) where Bytes.Element == UInt8 {
        try self.init(ascii: bytes, in: ())
    }
}

extension Binary.ASCII.Serializable where Context == Void {
    /// Parse from string representation
    ///
    /// Automatically provided for context-free types (`Context == Void`).
    /// Composes through canonical byte representation.
    ///
    /// - Parameter string: The string representation to parse
    /// - Throws: Self.Error if the string is malformed
    @inlinable
    public init(_ string: some StringProtocol) throws(Error) {
        try self.init(ascii: Array(string.utf8))
    }
}

// MARK: - String Conversion

extension StringProtocol {
    /// Create a string from an ASCII serializable value
    ///
    /// Serializes the value and interprets the bytes as UTF-8.
    ///
    /// - Parameter value: The ASCII serializable value to convert
    @inlinable
    public init<T: Binary.ASCII.Serializable>(ascii value: T) {
        let bytes: [UInt8] = T.serialize(ascii: value)
        self = .init(decoding: bytes, as: UTF8.self)
    }
}

// MARK: - CustomStringConvertible

extension Binary.ASCII.Serializable where Self: CustomStringConvertible {
    /// Default CustomStringConvertible implementation via byte serialization
    ///
    /// Marked as disfavored to avoid ambiguity with types that already have
    /// CustomStringConvertible conformance from the standard library (e.g., Int, Double).
    @_disfavoredOverload
    @inlinable
    public var description: String {
        String(ascii: self)
    }
}

extension Binary.ASCII.Serializable
where Self: RawRepresentable, Self: CustomStringConvertible, Self.RawValue: CustomStringConvertible {
    /// Optimized description for RawRepresentable types with CustomStringConvertible raw values
    @inlinable
    public var description: String {
        rawValue.description
    }
}

extension Binary.ASCII.Serializable
where Self: RawRepresentable, Self: CustomStringConvertible, Self.RawValue == [UInt8] {
    /// UTF-8 decoded description for byte-array backed types
    @inlinable
    public var description: String {
        String(decoding: rawValue, as: UTF8.self)
    }
}

// MARK: - ExpressibleBy*Literal Support

extension Binary.ASCII.Serializable
where Self: ExpressibleByStringLiteral, Context == Void {
    /// Default ExpressibleByStringLiteral implementation
    ///
    /// **Warning**: Uses force-try. Will crash at runtime if the literal is invalid.
    @inlinable
    public init(stringLiteral value: String) {
        // swiftlint:disable:next force_try
        try! self.init(value)
    }
}

extension Binary.ASCII.Serializable where Self: ExpressibleByIntegerLiteral, Context == Void {
    /// Default ExpressibleByIntegerLiteral implementation
    ///
    /// **Warning**: Uses force-try. Will crash at runtime if the integer
    /// string representation is invalid for this type.
    @inlinable
    public init(integerLiteral value: Int) {
        // swiftlint:disable:next force_try
        try! self.init(String(value))
    }
}

extension Binary.ASCII.Serializable where Self: ExpressibleByFloatLiteral, Context == Void {
    /// Default ExpressibleByFloatLiteral implementation
    ///
    /// **Warning**: Uses force-try. Will crash at runtime if the float
    /// string representation is invalid for this type.
    @inlinable
    public init(floatLiteral value: Double) {
        // swiftlint:disable:next force_try
        try! self.init(String(value))
    }
}

extension RangeReplaceableCollection where Element == UInt8 {
    @inlinable
    public mutating func append<Serializable: Binary.ASCII.Serializable>(
        ascii serializable: Serializable
    ) {
        Serializable.serialize(ascii: serializable, into: &self)
    }
}

// MARK: - ASCII Serialization Wrapper

extension Binary.ASCII {
    /// Wrapper for ASCII serializable types
    ///
    /// Provides instance-level access to ASCII serialization methods.
    /// This wrapper enables the syntax `value.ascii.serialize(into:)` for types
    /// that have both binary and ASCII serializations.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// // For types with both binary and ASCII serialization:
    /// let address = try RFC_791.IPv4.Address("192.168.1.1")
    ///
    /// var binaryBuffer: [UInt8] = []
    /// address.serialize(into: &binaryBuffer)  // Binary: [192, 168, 1, 1]
    ///
    /// var asciiBuffer: [UInt8] = []
    /// address.ascii.serialize(into: &asciiBuffer)  // ASCII: "192.168.1.1"
    /// ```
    ///
    /// ## Category Theory
    ///
    /// This wrapper enables explicit selection of the ASCII serialization functor
    /// when multiple serialization morphisms are available:
    /// - `serialize(into:)` → binary bytes (for types with binary representation)
    /// - `ascii.serialize(into:)` → ASCII text representation
    public struct Wrapper<Wrapped: Binary.ASCII.Serializable>: Sendable where Wrapped: Sendable {
        /// The wrapped value
        public let wrapped: Wrapped

        /// Creates a wrapper around the given value
        @inlinable
        init(_ wrapped: Wrapped) {
            self.wrapped = wrapped
        }
    }
}

// MARK: - Wrapper Serialization Methods

extension Binary.ASCII.Wrapper {
    /// Serialize the wrapped value into an ASCII byte buffer
    ///
    /// - Parameter buffer: The buffer to append ASCII bytes to
    @inlinable
    public func serialize<Buffer: RangeReplaceableCollection>(
        into buffer: inout Buffer
    ) where Buffer.Element == UInt8 {
        Wrapped.serialize(ascii: wrapped, into: &buffer)
    }

    /// Serialize to a new ASCII byte array
    ///
    /// - Returns: A new `[UInt8]` containing the ASCII representation
    @inlinable
    public var bytes: [UInt8] {
        var buffer: [UInt8] = []
        serialize(into: &buffer)
        return buffer
    }
}

extension Binary.ASCII.Wrapper: CustomStringConvertible {
    /// The ASCII string representation
    @inlinable
    public var description: String {
        String(decoding: bytes, as: UTF8.self)
    }
}

// MARK: - Serializable Extension

extension Binary.ASCII.Serializable where Self: Sendable {
    /// Access ASCII serialization wrapper
    ///
    /// Returns a wrapper that provides instance-level access to ASCII serialization.
    /// Use this when the type has both binary and ASCII serializations, and you need
    /// to explicitly select ASCII serialization.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let address = try RFC_791.IPv4.Address("192.168.1.1")
    ///
    /// // Binary serialization (4 bytes)
    /// var binary: [UInt8] = []
    /// address.serialize(into: &binary)
    ///
    /// // ASCII serialization (dotted-decimal string)
    /// var ascii: [UInt8] = []
    /// address.ascii.serialize(into: &ascii)
    /// ```
    @inlinable
    public var ascii: Binary.ASCII.Wrapper<Self> {
        Binary.ASCII.Wrapper(self)
    }
}
