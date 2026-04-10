//
//  RFC_4648.Base32.Hex.swift
//  swift-rfc-4648
//
//  Base32-HEX encoding per RFC 4648 Section 7

import INCITS_4_1986

// MARK: - Base32-HEX Type

extension RFC_4648.Base32 {
    /// Base32-HEX encoding (RFC 4648 Section 7) - Extended Hex Alphabet
    ///
    /// Base32-HEX uses a 32-character alphabet (0-9, A-V) that preserves
    /// lexicographic sort order when the encoded data is sorted as bytes.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// // Static methods (authoritative)
    /// RFC_4648.Base32.Hex.encode(bytes, into: &buffer)
    /// let decoded = RFC_4648.Base32.Hex.decode("91IMOR3F")
    ///
    /// // Instance methods (convenience) - via base32.hex
    /// bytes.base32.hex.encoded()
    /// "91IMOR3F".base32.hex.decoded()
    /// ```
    public enum Hex {
        /// Wrapper for instance-based convenience methods
        public struct Wrapper<Wrapped> {
            public let wrapped: Wrapped

            @inlinable
            public init(_ wrapped: Wrapped) {
                self.wrapped = wrapped
            }
        }
    }
}

// MARK: - Encoding Table

extension RFC_4648.Base32.Hex {
    /// Base32-HEX encoding table (RFC 4648 Section 7)
    public static let encodingTable = RFC_4648.EncodingTable(
        encode: Array("0123456789ABCDEFGHIJKLMNOPQRSTUV".utf8),
        caseInsensitive: true
    )
}

// MARK: - Encoder (for String.base32.hex(...) syntax)

extension RFC_4648.Base32.Hex {
    /// Encoder for `String.base32.hex(bytes)` syntax
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let encoded = String.base32.hex([72, 101, 108, 108, 111])  // "91IMOR3F"
    /// ```
    public struct Encoder: Sendable {
        @inlinable
        public init() {}

        /// Encodes bytes to Base32-HEX string
        @inlinable
        public func callAsFunction<Bytes: Collection>(
            _ bytes: Bytes,
            padding: Bool = true
        ) -> String where Bytes.Element == UInt8 {
            String(decoding: RFC_4648.Base32.Hex.encode(bytes, padding: padding), as: UTF8.self)
        }

        /// Encodes an integer to Base32-HEX string (big-endian byte order)
        @inlinable
        public func callAsFunction<T: FixedWidthInteger>(
            _ value: T,
            padding: Bool = true
        ) -> String {
            callAsFunction(value.bytes(endianness: .big), padding: padding)
        }
    }
}

// MARK: - Static Encode Methods (Authoritative)

extension RFC_4648.Base32.Hex {
    /// Encodes bytes to Base32-HEX into a buffer (streaming)
    ///
    /// Base32-HEX encodes 5 bytes into 8 characters.
    ///
    /// - Parameters:
    ///   - bytes: The bytes to encode
    ///   - buffer: The buffer to append Base32-HEX characters to
    ///   - padding: Whether to include padding characters (default: true)
    ///
    /// ## Example
    ///
    /// ```swift
    /// var buffer: [UInt8] = []
    /// RFC_4648.Base32.Hex.encode("Hello".utf8, into: &buffer)
    /// // buffer contains "91IMOR3F" as bytes
    /// ```
    @inlinable
    public static func encode<Bytes: Collection, Buffer: RangeReplaceableCollection>(
        _ bytes: Bytes,
        into buffer: inout Buffer,
        padding: Bool = true
    ) where Bytes.Element == UInt8, Buffer.Element == UInt8 {
        RFC_4648.encodeBase32(bytes, into: &buffer, table: encodingTable.encode, padding: padding)
    }

    /// Encodes bytes to Base32-HEX, returning a new array
    ///
    /// - Parameters:
    ///   - bytes: The bytes to encode
    ///   - padding: Whether to include padding characters (default: true)
    /// - Returns: Base32-HEX encoded bytes
    @inlinable
    public static func encode<Bytes: Collection>(
        _ bytes: Bytes,
        padding: Bool = true
    ) -> [UInt8] where Bytes.Element == UInt8 {
        var result: [UInt8] = []
        result.reserveCapacity(((bytes.count + 4) / 5) * 8)
        encode(bytes, into: &result, padding: padding)
        return result
    }
}

// MARK: - Static Decode Methods (Authoritative)

extension RFC_4648.Base32.Hex {
    /// Decodes a single Base32-HEX character to its 5-bit value (PRIMITIVE)
    ///
    /// - Parameter quintet: ASCII byte of Base32-HEX character (0-9, A-V, case-insensitive)
    /// - Returns: 5-bit value (0-31), or nil if invalid
    ///
    /// ## Example
    ///
    /// ```swift
    /// RFC_4648.Base32.Hex.decode(quintet: UInt8(ascii: "0"))  // 0
    /// RFC_4648.Base32.Hex.decode(quintet: UInt8(ascii: "V"))  // 31
    /// RFC_4648.Base32.Hex.decode(quintet: UInt8(ascii: "W"))  // nil (invalid)
    /// ```
    @inlinable
    public static func decode(quintet: UInt8) -> UInt8? {
        let value = encodingTable.decode[Int(quintet)]
        return value == 255 ? nil : value
    }

    /// Decodes Base32-HEX bytes into a buffer (streaming, no allocation)
    ///
    /// - Parameters:
    ///   - bytes: Base32-HEX encoded bytes
    ///   - buffer: The buffer to append decoded bytes to
    /// - Returns: `true` if decoding succeeded, `false` if invalid input
    ///
    /// ## Example
    ///
    /// ```swift
    /// var buffer: [UInt8] = []
    /// let success = RFC_4648.Base32.Hex.decode("91IMOR3F".utf8, into: &buffer)
    /// // buffer == [72, 101, 108, 108, 111] ("Hello")
    /// ```
    @inlinable
    @discardableResult
    public static func decode<Bytes: Collection, Buffer: RangeReplaceableCollection>(
        _ bytes: Bytes,
        into buffer: inout Buffer
    ) -> Bool where Bytes.Element == UInt8, Buffer.Element == UInt8 {
        RFC_4648.decodeBase32(bytes, into: &buffer, decodeTable: encodingTable.decode)
    }

    /// Decodes Base32-HEX encoded bytes to a new array
    ///
    /// - Parameter bytes: Base32-HEX encoded bytes
    /// - Returns: Decoded bytes, or nil if invalid
    ///
    /// ## Example
    ///
    /// ```swift
    /// let decoded = RFC_4648.Base32.Hex.decode("91IMOR3F".utf8)
    /// // decoded == [72, 101, 108, 108, 111] ("Hello")
    /// ```
    @inlinable
    public static func decode<Bytes: Collection>(
        _ bytes: Bytes
    ) -> [UInt8]? where Bytes.Element == UInt8 {
        var result: [UInt8] = []
        result.reserveCapacity((bytes.count * 5) / 8)
        guard decode(bytes, into: &result) else { return nil }
        return result
    }

    /// Decodes Base32-HEX encoded string (case-insensitive)
    ///
    /// Convenience overload that delegates to the byte-based version.
    ///
    /// - Parameter string: Base32-HEX encoded string
    /// - Returns: Decoded bytes, or nil if invalid
    ///
    /// ## Example
    ///
    /// ```swift
    /// let decoded = RFC_4648.Base32.Hex.decode("91IMOR3F")
    /// // decoded == [72, 101, 108, 108, 111] ("Hello")
    /// ```
    @inlinable
    public static func decode(_ string: some StringProtocol) -> [UInt8]? {
        decode(string.utf8)
    }

    /// Decodes Base32-HEX to a FixedWidthInteger (PRIMITIVE)
    ///
    /// Decodes Base32-HEX bytes directly to an integer value without intermediate array allocation.
    ///
    /// - Parameter bytes: Base32-HEX encoded bytes
    /// - Returns: Decoded integer value, or nil if invalid or overflow
    ///
    /// ## Example
    ///
    /// ```swift
    /// let value: UInt32? = RFC_4648.Base32.Hex.decode("64P36D1L".utf8)
    /// // value == 0x31323334 ("1234" as bytes)
    /// ```
    @inlinable
    public static func decode<Bytes: Collection, T: FixedWidthInteger>(
        _ bytes: Bytes,
        as type: T.Type = T.self
    ) -> T? where Bytes.Element == UInt8 {
        RFC_4648.decodeBase32ToInteger(bytes, decodeTable: encodingTable.decode)
    }
}

// MARK: - Instance Methods (Convenience) - Bytes

extension RFC_4648.Base32.Hex.Wrapper where Wrapped: Collection, Wrapped.Element == UInt8 {
    // MARK: Encoding (bytes → Base32-HEX)

    /// Encodes wrapped bytes to Base32-HEX into a buffer
    ///
    /// Delegates to static `RFC_4648.Base32.Hex.encode(_:into:padding:)`.
    @inlinable
    public func encode<Buffer: RangeReplaceableCollection>(
        into buffer: inout Buffer,
        padding: Bool = true
    ) where Buffer.Element == UInt8 {
        RFC_4648.Base32.Hex.encode(wrapped, into: &buffer, padding: padding)
    }

    /// Encodes wrapped bytes to Base32-HEX string
    ///
    /// Delegates to static `RFC_4648.Base32.Hex.encode(_:padding:)`.
    @inlinable
    public func encoded(padding: Bool = true) -> String {
        String(decoding: RFC_4648.Base32.Hex.encode(wrapped, padding: padding), as: UTF8.self)
    }

    /// Encodes wrapped bytes to Base32-HEX string (callable syntax)
    @inlinable
    public func callAsFunction(padding: Bool = true) -> String {
        encoded(padding: padding)
    }

    // MARK: Decoding (Base32-HEX bytes → raw bytes)

    /// Decodes wrapped Base32-HEX-encoded bytes into a buffer
    ///
    /// Treats the wrapped bytes as ASCII Base32-HEX characters and decodes them.
    /// Delegates to static `RFC_4648.Base32.Hex.decode(_:into:)`.
    @inlinable
    @discardableResult
    public func decode<Buffer: RangeReplaceableCollection>(
        into buffer: inout Buffer
    ) -> Bool where Buffer.Element == UInt8 {
        RFC_4648.Base32.Hex.decode(wrapped, into: &buffer)
    }

    /// Decodes wrapped Base32-HEX-encoded bytes to raw bytes
    ///
    /// Treats the wrapped bytes as ASCII Base32-HEX characters and decodes them.
    /// Delegates to static `RFC_4648.Base32.Hex.decode(_:)`.
    @inlinable
    public func decoded() -> [UInt8]? {
        RFC_4648.Base32.Hex.decode(wrapped)
    }

    /// Decodes wrapped Base32-HEX-encoded bytes to a FixedWidthInteger
    ///
    /// Treats the wrapped bytes as ASCII Base32-HEX characters and decodes them.
    /// Delegates to static `RFC_4648.Base32.Hex.decode(_:as:)`.
    @inlinable
    public func decoded<T: FixedWidthInteger>(as type: T.Type = T.self) -> T? {
        RFC_4648.Base32.Hex.decode(wrapped, as: type)
    }
}

// MARK: - Instance Methods (Convenience) - String

extension RFC_4648.Base32.Hex.Wrapper where Wrapped: StringProtocol {
    /// Decodes wrapped Base32-HEX string into a buffer
    ///
    /// Delegates to static `RFC_4648.Base32.Hex.decode(_:into:)`.
    @inlinable
    @discardableResult
    public func decode<Buffer: RangeReplaceableCollection>(
        into buffer: inout Buffer
    ) -> Bool where Buffer.Element == UInt8 {
        RFC_4648.Base32.Hex.decode(wrapped.utf8, into: &buffer)
    }

    /// Decodes wrapped Base32-HEX string to bytes
    ///
    /// Delegates to static `RFC_4648.Base32.Hex.decode(_:)`.
    @inlinable
    public func decoded() -> [UInt8]? {
        RFC_4648.Base32.Hex.decode(wrapped)
    }

    /// Decodes wrapped Base32-HEX string to a FixedWidthInteger
    ///
    /// Delegates to static `RFC_4648.Base32.Hex.decode(_:as:)`.
    @inlinable
    public func decoded<T: FixedWidthInteger>(as type: T.Type = T.self) -> T? {
        RFC_4648.Base32.Hex.decode(wrapped.utf8, as: type)
    }
}
