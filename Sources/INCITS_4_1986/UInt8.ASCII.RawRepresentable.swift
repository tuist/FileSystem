//
//  Binary.ASCII.RawRepresentable.swift
//  swift-incits-4-1986
//
//  Protocol for ASCII serializable types that synthesize RawRepresentable
//
//  Created by Coen ten Thije Boonkkamp on 28/11/2025.
//

public import Binary

extension Binary.ASCII {
    /// Protocol for ASCII types that need synthesized RawRepresentable conformance
    ///
    /// Use this protocol for struct types that need `rawValue` synthesized from
    /// their ASCII serialization. Enums with native `rawValue` should NOT use this -
    /// they should conform directly to `Binary.ASCII.Serializable` which will use
    /// their native `rawValue`.
    ///
    /// ## When to Use
    ///
    /// - **Structs**: Use `Binary.ASCII.RawRepresentable` to get synthesized `rawValue`
    /// - **Enums**: Use `Binary.ASCII.Serializable` directly (uses native `rawValue`)
    ///
    /// ## Example
    ///
    /// ```swift
    /// struct Token: Binary.ASCII.RawRepresentable {
    ///     let value: String
    ///
    ///     init<Bytes: Collection>(ascii bytes: Bytes, in context: Void) throws(Error) {
    ///         self.value = String(decoding: bytes, as: UTF8.self)
    ///     }
    ///
    ///     static func serialize<Buffer: RangeReplaceableCollection>(
    ///         ascii token: Self,
    ///         into buffer: inout Buffer
    ///     ) where Buffer.Element == UInt8 {
    ///         buffer.append(contentsOf: token.value.utf8)
    ///     }
    /// }
    ///
    /// // Now you get:
    /// let token = Token(rawValue: "abc")  // Synthesized
    /// token.rawValue                       // "abc" (synthesized)
    /// ```
    public protocol RawRepresentable: Binary.ASCII.Serializable, Swift.RawRepresentable {}
}

// MARK: - String RawValue

extension Binary.ASCII.RawRepresentable where Self.RawValue == String, Context == Void {
    /// Synthesized init(rawValue:) for String-based raw values
    ///
    /// Parses the raw string value through the canonical byte transformation.
    @_disfavoredOverload
    @inlinable
    public init?(rawValue: String) {
        try? self.init(ascii: Array(rawValue.utf8))
    }

    /// Synthesized rawValue for String-based raw values
    ///
    /// Serializes to bytes and interprets as UTF-8 string.
    @_disfavoredOverload
    @inlinable
    public var rawValue: String {
        String(ascii: self)
    }
}

// MARK: - [UInt8] RawValue

extension Binary.ASCII.RawRepresentable where Self.RawValue == [UInt8], Context == Void {
    /// Synthesized init(rawValue:) for byte array raw values
    ///
    /// Parses the raw bytes directly through `init(ascii:)`.
    @_disfavoredOverload
    @inlinable
    public init?(rawValue: [UInt8]) {
        try? self.init(ascii: rawValue)
    }

    /// Synthesized rawValue for byte array raw values
    ///
    /// Returns the serialized bytes directly.
    @_disfavoredOverload
    @inlinable
    public var rawValue: [UInt8] {
        self.bytes
    }
}

// MARK: - LosslessStringConvertible RawValue

extension Binary.ASCII.RawRepresentable where Self.RawValue: LosslessStringConvertible, Context == Void {
    /// Synthesized init(rawValue:) for LosslessStringConvertible raw values
    ///
    /// Converts the raw value to string, then parses through bytes.
    /// Supports Int, Double, UInt, etc.
    @_disfavoredOverload
    @inlinable
    public init?(rawValue: RawValue) {
        try? self.init(ascii: Array(String(rawValue).utf8))
    }

    /// Synthesized rawValue for LosslessStringConvertible raw values
    ///
    /// Serializes to string, then converts to RawValue.
    @_disfavoredOverload
    @inlinable
    public var rawValue: RawValue {
        let string = String(ascii: self)
        // Safe to force unwrap: LosslessStringConvertible guarantees round-trip
        return RawValue(string)!
    }
}
