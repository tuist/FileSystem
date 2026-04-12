//
//  RFC_4648.Base32.swift
//  swift-rfc-4648
//
//  Base32 encoding per RFC 4648 Section 6

import INCITS_4_1986

// MARK: - Base32 Type

extension RFC_4648 {
    /// Base32 encoding (RFC 4648 Section 6) - Case-insensitive, human-friendly
    ///
    /// Base32 uses a 32-character alphabet (A-Z, 2-7) designed to be:
    /// - Case-insensitive (avoids confusion between similar letters)
    /// - Human-friendly (excludes 0, 1, 8, 9 which resemble letters)
    ///
    /// ## Usage
    ///
    /// ```swift
    /// // Static methods (authoritative)
    /// RFC_4648.Base32.encode(bytes, into: &buffer)
    /// let decoded = RFC_4648.Base32.decode("JBSWY3DPEHPK3PXP")
    ///
    /// // Instance methods (convenience)
    /// bytes.base32.encoded()
    /// "JBSWY3DPEHPK3PXP".base32.decoded()
    /// ```
    public enum Base32 {
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

extension RFC_4648.Base32 {
    /// Base32 encoding table (RFC 4648 Section 6)
    public static let encodingTable = RFC_4648.EncodingTable(
        encode: Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ234567".utf8),
        caseInsensitive: true
    )
}

// MARK: - Encoder (for String.base32(...) syntax)

extension RFC_4648.Base32 {
    /// Encoder for `String.base32(bytes)` syntax
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let encoded = String.base32([72, 101, 108, 108, 111])  // "JBSWY3DP"
    /// let encoded = String.base32.hex([72, 101, 108, 108, 111])  // "91IMOR3F"
    /// ```
    public struct Encoder: Sendable {
        @inlinable
        public init() {}

        /// Encodes bytes to Base32 string
        @inlinable
        public func callAsFunction<Bytes: Collection>(
            _ bytes: Bytes,
            padding: Bool = true
        ) -> String where Bytes.Element == UInt8 {
            String(decoding: RFC_4648.Base32.encode(bytes, padding: padding), as: UTF8.self)
        }

        /// Encodes an integer to Base32 string (big-endian byte order)
        @inlinable
        public func callAsFunction<T: FixedWidthInteger>(
            _ value: T,
            padding: Bool = true
        ) -> String {
            callAsFunction(value.bytes(endianness: .big), padding: padding)
        }

        /// Access to Base32-HEX encoder
        @inlinable
        public var hex: RFC_4648.Base32.Hex.Encoder {
            RFC_4648.Base32.Hex.Encoder()
        }
    }
}

// MARK: - Static Encode Methods (Authoritative)

extension RFC_4648.Base32 {
    /// Encodes bytes to Base32 into a buffer (streaming)
    ///
    /// Base32 encodes 5 bytes into 8 characters.
    ///
    /// - Parameters:
    ///   - bytes: The bytes to encode
    ///   - buffer: The buffer to append Base32 characters to
    ///   - padding: Whether to include padding characters (default: true)
    ///
    /// ## Example
    ///
    /// ```swift
    /// var buffer: [UInt8] = []
    /// RFC_4648.Base32.encode("Hello".utf8, into: &buffer)
    /// // buffer contains "JBSWY3DP" as bytes
    /// ```
    @inlinable
    public static func encode<Bytes: Collection, Buffer: RangeReplaceableCollection>(
        _ bytes: Bytes,
        into buffer: inout Buffer,
        padding: Bool = true
    ) where Bytes.Element == UInt8, Buffer.Element == UInt8 {
        RFC_4648.encodeBase32(bytes, into: &buffer, table: encodingTable.encode, padding: padding)
    }

    /// Encodes bytes to Base32, returning a new array
    ///
    /// - Parameters:
    ///   - bytes: The bytes to encode
    ///   - padding: Whether to include padding characters (default: true)
    /// - Returns: Base32 encoded bytes
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

extension RFC_4648.Base32 {
    /// Decodes a single Base32 character to its 5-bit value (PRIMITIVE)
    ///
    /// - Parameter quintet: ASCII byte of Base32 character (A-Z, 2-7, case-insensitive)
    /// - Returns: 5-bit value (0-31), or nil if invalid
    ///
    /// ## Example
    ///
    /// ```swift
    /// RFC_4648.Base32.decode(quintet: UInt8(ascii: "A"))  // 0
    /// RFC_4648.Base32.decode(quintet: UInt8(ascii: "7"))  // 31
    /// RFC_4648.Base32.decode(quintet: UInt8(ascii: "0"))  // nil (invalid)
    /// ```
    @inlinable
    public static func decode(quintet: UInt8) -> UInt8? {
        let value = encodingTable.decode[Int(quintet)]
        return value == 255 ? nil : value
    }

    /// Decodes Base32 bytes into a buffer (streaming, no allocation)
    ///
    /// - Parameters:
    ///   - bytes: Base32 encoded bytes
    ///   - buffer: The buffer to append decoded bytes to
    /// - Returns: `true` if decoding succeeded, `false` if invalid input
    ///
    /// ## Example
    ///
    /// ```swift
    /// var buffer: [UInt8] = []
    /// let success = RFC_4648.Base32.decode("JBSWY3DP".utf8, into: &buffer)
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

    /// Decodes Base32 encoded bytes to a new array
    ///
    /// - Parameter bytes: Base32 encoded bytes
    /// - Returns: Decoded bytes, or nil if invalid
    ///
    /// ## Example
    ///
    /// ```swift
    /// let decoded = RFC_4648.Base32.decode("JBSWY3DP".utf8)
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

    /// Decodes Base32 encoded string (case-insensitive)
    ///
    /// Convenience overload that delegates to the byte-based version.
    ///
    /// - Parameter string: Base32 encoded string
    /// - Returns: Decoded bytes, or nil if invalid
    ///
    /// ## Example
    ///
    /// ```swift
    /// let decoded = RFC_4648.Base32.decode("JBSWY3DP")
    /// // decoded == [72, 101, 108, 108, 111] ("Hello")
    /// ```
    @inlinable
    public static func decode(_ string: some StringProtocol) -> [UInt8]? {
        decode(string.utf8)
    }

    /// Decodes Base32 to a FixedWidthInteger (PRIMITIVE)
    ///
    /// Decodes Base32 bytes directly to an integer value without intermediate array allocation.
    ///
    /// - Parameter bytes: Base32 encoded bytes
    /// - Returns: Decoded integer value, or nil if invalid or overflow
    ///
    /// ## Example
    ///
    /// ```swift
    /// let value: UInt32? = RFC_4648.Base32.decode("GEZDGNBV".utf8)
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

// MARK: - Hex Accessor

extension RFC_4648.Base32.Wrapper {
    /// Access to Base32-HEX instance operations
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let bytes: [UInt8] = [72, 101, 108, 108, 111]
    /// bytes.base32.hex.encoded()  // "91IMOR3F"
    ///
    /// let encoded = "91IMOR3F"
    /// encoded.base32.hex.decoded()  // [72, 101, 108, 108, 111]
    /// ```
    @inlinable
    public var hex: RFC_4648.Base32.Hex.Wrapper<Wrapped> {
        RFC_4648.Base32.Hex.Wrapper(wrapped)
    }
}

// MARK: - Instance Methods (Convenience) - Bytes

extension RFC_4648.Base32.Wrapper where Wrapped: Collection, Wrapped.Element == UInt8 {
    // MARK: Encoding (bytes → Base32)

    /// Encodes wrapped bytes to Base32 into a buffer
    ///
    /// Delegates to static `RFC_4648.Base32.encode(_:into:padding:)`.
    @inlinable
    public func encode<Buffer: RangeReplaceableCollection>(
        into buffer: inout Buffer,
        padding: Bool = true
    ) where Buffer.Element == UInt8 {
        RFC_4648.Base32.encode(wrapped, into: &buffer, padding: padding)
    }

    /// Encodes wrapped bytes to Base32 string
    ///
    /// Delegates to static `RFC_4648.Base32.encode(_:padding:)`.
    @inlinable
    public func encoded(padding: Bool = true) -> String {
        String(decoding: RFC_4648.Base32.encode(wrapped, padding: padding), as: UTF8.self)
    }

    /// Encodes wrapped bytes to Base32 string (callable syntax)
    @inlinable
    public func callAsFunction(padding: Bool = true) -> String {
        encoded(padding: padding)
    }

    // MARK: Decoding (Base32 bytes → raw bytes)

    /// Decodes wrapped Base32-encoded bytes into a buffer
    ///
    /// Treats the wrapped bytes as ASCII Base32 characters and decodes them.
    /// Delegates to static `RFC_4648.Base32.decode(_:into:)`.
    @inlinable
    @discardableResult
    public func decode<Buffer: RangeReplaceableCollection>(
        into buffer: inout Buffer
    ) -> Bool where Buffer.Element == UInt8 {
        RFC_4648.Base32.decode(wrapped, into: &buffer)
    }

    /// Decodes wrapped Base32-encoded bytes to raw bytes
    ///
    /// Treats the wrapped bytes as ASCII Base32 characters and decodes them.
    /// Delegates to static `RFC_4648.Base32.decode(_:)`.
    @inlinable
    public func decoded() -> [UInt8]? {
        RFC_4648.Base32.decode(wrapped)
    }

    /// Decodes wrapped Base32-encoded bytes to a FixedWidthInteger
    ///
    /// Treats the wrapped bytes as ASCII Base32 characters and decodes them.
    /// Delegates to static `RFC_4648.Base32.decode(_:as:)`.
    @inlinable
    public func decoded<T: FixedWidthInteger>(as type: T.Type = T.self) -> T? {
        RFC_4648.Base32.decode(wrapped, as: type)
    }
}

// MARK: - Instance Methods (Convenience) - String

extension RFC_4648.Base32.Wrapper where Wrapped: StringProtocol {
    /// Decodes wrapped Base32 string into a buffer
    ///
    /// Delegates to static `RFC_4648.Base32.decode(_:into:)`.
    @inlinable
    @discardableResult
    public func decode<Buffer: RangeReplaceableCollection>(
        into buffer: inout Buffer
    ) -> Bool where Buffer.Element == UInt8 {
        RFC_4648.Base32.decode(wrapped.utf8, into: &buffer)
    }

    /// Decodes wrapped Base32 string to bytes
    ///
    /// Delegates to static `RFC_4648.Base32.decode(_:)`.
    @inlinable
    public func decoded() -> [UInt8]? {
        RFC_4648.Base32.decode(wrapped)
    }

    /// Decodes wrapped Base32 string to a FixedWidthInteger
    ///
    /// Delegates to static `RFC_4648.Base32.decode(_:as:)`.
    @inlinable
    public func decoded<T: FixedWidthInteger>(as type: T.Type = T.self) -> T? {
        RFC_4648.Base32.decode(wrapped.utf8, as: type)
    }
}
