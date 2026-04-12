//
//  RFC_4648.Base64.swift
//  swift-rfc-4648
//
//  Base64 encoding per RFC 4648 Section 4

import INCITS_4_1986

// MARK: - Base64 Type

extension RFC_4648 {
    /// Base64 encoding (RFC 4648 Section 4)
    ///
    /// Base64 encodes binary data using a 64-character alphabet (A-Z, a-z, 0-9, +, /).
    /// Each 3 bytes of input produce 4 characters of output.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// // Static methods (authoritative)
    /// RFC_4648.Base64.encode(bytes, into: &buffer)
    /// let decoded = RFC_4648.Base64.decode("SGVsbG8=")
    ///
    /// // Instance methods (convenience)
    /// bytes.base64.encoded()
    /// "SGVsbG8=".base64.decoded()
    ///
    /// // URL-safe variant via .url accessor
    /// bytes.base64.url.encoded()
    /// ```
    public enum Base64 {
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

extension RFC_4648.Base64 {
    /// Base64 encoding table (RFC 4648 Section 4)
    public static let encodingTable = RFC_4648.EncodingTable(
        encode: Array("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/".utf8)
    )
}

// MARK: - Static Encode Methods (Authoritative)

extension RFC_4648.Base64 {
    /// Encodes bytes to Base64 into a buffer (streaming)
    ///
    /// Base64 encodes 3 bytes into 4 characters.
    ///
    /// - Parameters:
    ///   - bytes: The bytes to encode
    ///   - buffer: The buffer to append Base64 characters to
    ///   - padding: Whether to include padding characters (default: true)
    ///
    /// ## Example
    ///
    /// ```swift
    /// var buffer: [UInt8] = []
    /// RFC_4648.Base64.encode("Hello".utf8, into: &buffer)
    /// // buffer contains "SGVsbG8=" as bytes
    /// ```
    @inlinable
    public static func encode<Bytes: Collection, Buffer: RangeReplaceableCollection>(
        _ bytes: Bytes,
        into buffer: inout Buffer,
        padding: Bool = true
    ) where Bytes.Element == UInt8, Buffer.Element == UInt8 {
        RFC_4648.encodeBase64(bytes, into: &buffer, table: encodingTable.encode, padding: padding)
    }

    /// Encodes bytes to Base64, returning a new array
    ///
    /// - Parameters:
    ///   - bytes: The bytes to encode
    ///   - padding: Whether to include padding characters (default: true)
    /// - Returns: Base64 encoded bytes
    @inlinable
    public static func encode<Bytes: Collection>(
        _ bytes: Bytes,
        padding: Bool = true
    ) -> [UInt8] where Bytes.Element == UInt8 {
        var result: [UInt8] = []
        result.reserveCapacity(((bytes.count + 2) / 3) * 4)
        encode(bytes, into: &result, padding: padding)
        return result
    }
}

// MARK: - Static Decode Methods (Authoritative)

extension RFC_4648.Base64 {
    /// Decodes a single Base64 character to its 6-bit value (PRIMITIVE)
    ///
    /// - Parameter sextet: ASCII byte of Base64 character
    /// - Returns: 6-bit value (0-63), or nil if invalid
    ///
    /// ## Example
    ///
    /// ```swift
    /// RFC_4648.Base64.decode(sextet: UInt8(ascii: "A"))  // 0
    /// RFC_4648.Base64.decode(sextet: UInt8(ascii: "/"))  // 63
    /// RFC_4648.Base64.decode(sextet: UInt8(ascii: "@"))  // nil (invalid)
    /// ```
    @inlinable
    public static func decode(sextet: UInt8) -> UInt8? {
        let value = encodingTable.decode[Int(sextet)]
        return value == 255 ? nil : value
    }

    /// Decodes Base64 bytes into a buffer (streaming, no allocation)
    ///
    /// Standard Base64 requires proper padding (groups of 4 characters).
    ///
    /// - Parameters:
    ///   - bytes: Base64 encoded bytes
    ///   - buffer: The buffer to append decoded bytes to
    /// - Returns: `true` if decoding succeeded, `false` if invalid input
    ///
    /// ## Example
    ///
    /// ```swift
    /// var buffer: [UInt8] = []
    /// let success = RFC_4648.Base64.decode("SGVsbG8=".utf8, into: &buffer)
    /// // buffer == [72, 101, 108, 108, 111] ("Hello")
    /// ```
    @inlinable
    @discardableResult
    public static func decode<Bytes: Collection, Buffer: RangeReplaceableCollection>(
        _ bytes: Bytes,
        into buffer: inout Buffer
    ) -> Bool where Bytes.Element == UInt8, Buffer.Element == UInt8 {
        RFC_4648.decodeBase64(bytes, into: &buffer, decodeTable: encodingTable.decode, requirePadding: true)
    }

    /// Decodes Base64 encoded bytes to a new array
    ///
    /// - Parameter bytes: Base64 encoded bytes
    /// - Returns: Decoded bytes, or nil if invalid
    ///
    /// ## Example
    ///
    /// ```swift
    /// let decoded = RFC_4648.Base64.decode("SGVsbG8=".utf8)
    /// // decoded == [72, 101, 108, 108, 111] ("Hello")
    /// ```
    @inlinable
    public static func decode<Bytes: Collection>(
        _ bytes: Bytes
    ) -> [UInt8]? where Bytes.Element == UInt8 {
        var result: [UInt8] = []
        result.reserveCapacity((bytes.count * 3) / 4)
        guard decode(bytes, into: &result) else { return nil }
        return result
    }

    /// Decodes Base64 encoded string
    ///
    /// Convenience overload that delegates to the byte-based version.
    ///
    /// - Parameter string: Base64 encoded string
    /// - Returns: Decoded bytes, or nil if invalid
    ///
    /// ## Example
    ///
    /// ```swift
    /// let decoded = RFC_4648.Base64.decode("SGVsbG8=")
    /// // decoded == [72, 101, 108, 108, 111] ("Hello")
    /// ```
    @inlinable
    public static func decode(_ string: some StringProtocol) -> [UInt8]? {
        decode(string.utf8)
    }

    /// Decodes Base64 to a FixedWidthInteger (PRIMITIVE)
    ///
    /// Decodes Base64 bytes directly to an integer value without intermediate array allocation.
    ///
    /// - Parameter bytes: Base64 encoded bytes
    /// - Returns: Decoded integer value, or nil if invalid or overflow
    ///
    /// ## Example
    ///
    /// ```swift
    /// let value: UInt32? = RFC_4648.Base64.decode("AQIDBA==".utf8)
    /// // value == 0x01020304
    /// ```
    @inlinable
    public static func decode<Bytes: Collection, T: FixedWidthInteger>(
        _ bytes: Bytes,
        as type: T.Type = T.self
    ) -> T? where Bytes.Element == UInt8 {
        RFC_4648.decodeBase64ToInteger(bytes, decodeTable: encodingTable.decode)
    }
}

// MARK: - Encoder (for String.base64(...) syntax)

extension RFC_4648.Base64 {
    /// Encoder for `String.base64(bytes)` syntax
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let encoded = String.base64([72, 101, 108, 108, 111])  // "SGVsbG8="
    /// let encoded = String.base64.url([72, 101, 108, 108, 111])  // "SGVsbG8"
    /// ```
    public struct Encoder: Sendable {
        @inlinable
        public init() {}

        /// Encodes bytes to Base64 string
        @inlinable
        public func callAsFunction<Bytes: Collection>(
            _ bytes: Bytes,
            padding: Bool = true
        ) -> String where Bytes.Element == UInt8 {
            String(decoding: RFC_4648.Base64.encode(bytes, padding: padding), as: UTF8.self)
        }

        /// Encodes an integer to Base64 string (big-endian byte order)
        @inlinable
        public func callAsFunction<T: FixedWidthInteger>(
            _ value: T,
            padding: Bool = true
        ) -> String {
            callAsFunction(value.bytes(endianness: .big), padding: padding)
        }

        /// Access to Base64URL encoder
        @inlinable
        public var url: RFC_4648.Base64.URL.Encoder {
            RFC_4648.Base64.URL.Encoder()
        }
    }
}

// MARK: - URL Accessor

extension RFC_4648.Base64.Wrapper {
    /// Access to Base64URL instance operations
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let bytes: [UInt8] = [72, 101, 108, 108, 111]
    /// bytes.base64.url.encoded()  // "SGVsbG8" (no padding by default)
    ///
    /// let encoded = "SGVsbG8"
    /// encoded.base64.url.decoded()  // [72, 101, 108, 108, 111]
    /// ```
    @inlinable
    public var url: RFC_4648.Base64.URL.Wrapper<Wrapped> {
        RFC_4648.Base64.URL.Wrapper(wrapped)
    }
}

// MARK: - Instance Methods (Convenience) - Bytes

extension RFC_4648.Base64.Wrapper where Wrapped: Collection, Wrapped.Element == UInt8 {
    // MARK: Encoding (bytes → Base64)

    /// Encodes wrapped bytes to Base64 into a buffer
    ///
    /// Delegates to static `RFC_4648.Base64.encode(_:into:padding:)`.
    @inlinable
    public func encode<Buffer: RangeReplaceableCollection>(
        into buffer: inout Buffer,
        padding: Bool = true
    ) where Buffer.Element == UInt8 {
        RFC_4648.Base64.encode(wrapped, into: &buffer, padding: padding)
    }

    /// Encodes wrapped bytes to Base64 string
    ///
    /// Delegates to static `RFC_4648.Base64.encode(_:padding:)`.
    @inlinable
    public func encoded(padding: Bool = true) -> String {
        String(decoding: RFC_4648.Base64.encode(wrapped, padding: padding), as: UTF8.self)
    }

    /// Encodes wrapped bytes to Base64 string (callable syntax)
    @inlinable
    public func callAsFunction(padding: Bool = true) -> String {
        encoded(padding: padding)
    }

    // MARK: Decoding (Base64 bytes → raw bytes)

    /// Decodes wrapped Base64-encoded bytes into a buffer
    ///
    /// Treats the wrapped bytes as ASCII Base64 characters and decodes them.
    /// Delegates to static `RFC_4648.Base64.decode(_:into:)`.
    @inlinable
    @discardableResult
    public func decode<Buffer: RangeReplaceableCollection>(
        into buffer: inout Buffer
    ) -> Bool where Buffer.Element == UInt8 {
        RFC_4648.Base64.decode(wrapped, into: &buffer)
    }

    /// Decodes wrapped Base64-encoded bytes to raw bytes
    ///
    /// Treats the wrapped bytes as ASCII Base64 characters and decodes them.
    /// Delegates to static `RFC_4648.Base64.decode(_:)`.
    @inlinable
    public func decoded() -> [UInt8]? {
        RFC_4648.Base64.decode(wrapped)
    }

    /// Decodes wrapped Base64-encoded bytes to a FixedWidthInteger
    ///
    /// Treats the wrapped bytes as ASCII Base64 characters and decodes them.
    /// Delegates to static `RFC_4648.Base64.decode(_:as:)`.
    @inlinable
    public func decoded<T: FixedWidthInteger>(as type: T.Type = T.self) -> T? {
        RFC_4648.Base64.decode(wrapped, as: type)
    }
}

// MARK: - Instance Methods (Convenience) - String

extension RFC_4648.Base64.Wrapper where Wrapped: StringProtocol {
    /// Decodes wrapped Base64 string into a buffer
    ///
    /// Delegates to static `RFC_4648.Base64.decode(_:into:)`.
    @inlinable
    @discardableResult
    public func decode<Buffer: RangeReplaceableCollection>(
        into buffer: inout Buffer
    ) -> Bool where Buffer.Element == UInt8 {
        RFC_4648.Base64.decode(wrapped.utf8, into: &buffer)
    }

    /// Decodes wrapped Base64 string to bytes
    ///
    /// Delegates to static `RFC_4648.Base64.decode(_:)`.
    @inlinable
    public func decoded() -> [UInt8]? {
        RFC_4648.Base64.decode(wrapped)
    }

    /// Decodes wrapped Base64 string to a FixedWidthInteger
    ///
    /// Delegates to static `RFC_4648.Base64.decode(_:as:)`.
    @inlinable
    public func decoded<T: FixedWidthInteger>(as type: T.Type = T.self) -> T? {
        RFC_4648.Base64.decode(wrapped.utf8, as: type)
    }
}
