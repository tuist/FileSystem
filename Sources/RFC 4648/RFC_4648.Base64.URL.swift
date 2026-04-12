//
//  RFC_4648.Base64.URL.swift
//  swift-rfc-4648
//
//  Base64URL encoding per RFC 4648 Section 5

import INCITS_4_1986

// MARK: - Base64URL Type

extension RFC_4648.Base64 {
    /// Base64URL encoding (RFC 4648 Section 5) - URL and filename safe
    ///
    /// Base64URL uses a modified alphabet that replaces `+` with `-` and `/` with `_`,
    /// making it safe for use in URLs and filenames. Padding is optional (default: off).
    ///
    /// ## Usage
    ///
    /// ```swift
    /// // Static methods (authoritative)
    /// RFC_4648.Base64.URL.encode(bytes, into: &buffer)
    /// let decoded = RFC_4648.Base64.URL.decode("SGVsbG8")
    ///
    /// // Instance methods (convenience) - via base64.url
    /// bytes.base64.url.encoded()
    /// "SGVsbG8".base64.url.decoded()
    /// ```
    public enum URL {
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

extension RFC_4648.Base64.URL {
    /// Base64URL encoding table (RFC 4648 Section 5)
    public static let encodingTable = RFC_4648.EncodingTable(
        encode: Array("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_".utf8)
    )
}

// MARK: - Encoder (for String.base64.url(...) syntax)

extension RFC_4648.Base64.URL {
    /// Encoder for `String.base64.url(bytes)` syntax
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let encoded = String.base64.url([72, 101, 108, 108, 111])  // "SGVsbG8"
    /// ```
    public struct Encoder: Sendable {
        @inlinable
        public init() {}

        /// Encodes bytes to Base64URL string
        @inlinable
        public func callAsFunction<Bytes: Collection>(
            _ bytes: Bytes,
            padding: Bool = false
        ) -> String where Bytes.Element == UInt8 {
            String(decoding: RFC_4648.Base64.URL.encode(bytes, padding: padding), as: UTF8.self)
        }

        /// Encodes an integer to Base64URL string (big-endian byte order)
        @inlinable
        public func callAsFunction<T: FixedWidthInteger>(
            _ value: T,
            padding: Bool = false
        ) -> String {
            callAsFunction(value.bytes(endianness: .big), padding: padding)
        }
    }
}

// MARK: - Static Encode Methods (Authoritative)

extension RFC_4648.Base64.URL {
    /// Encodes bytes to Base64URL into a buffer (streaming)
    ///
    /// Base64URL encodes 3 bytes into 4 characters.
    ///
    /// - Parameters:
    ///   - bytes: The bytes to encode
    ///   - buffer: The buffer to append Base64URL characters to
    ///   - padding: Whether to include padding characters (default: false per RFC 7515)
    ///
    /// ## Example
    ///
    /// ```swift
    /// var buffer: [UInt8] = []
    /// RFC_4648.Base64.URL.encode("Hello".utf8, into: &buffer)
    /// // buffer contains "SGVsbG8" as bytes (no padding)
    /// ```
    @inlinable
    public static func encode<Bytes: Collection, Buffer: RangeReplaceableCollection>(
        _ bytes: Bytes,
        into buffer: inout Buffer,
        padding: Bool = false
    ) where Bytes.Element == UInt8, Buffer.Element == UInt8 {
        RFC_4648.encodeBase64(bytes, into: &buffer, table: encodingTable.encode, padding: padding)
    }

    /// Encodes bytes to Base64URL, returning a new array
    ///
    /// - Parameters:
    ///   - bytes: The bytes to encode
    ///   - padding: Whether to include padding characters (default: false per RFC 7515)
    /// - Returns: Base64URL encoded bytes
    @inlinable
    public static func encode<Bytes: Collection>(
        _ bytes: Bytes,
        padding: Bool = false
    ) -> [UInt8] where Bytes.Element == UInt8 {
        var result: [UInt8] = []
        result.reserveCapacity(((bytes.count + 2) / 3) * 4)
        encode(bytes, into: &result, padding: padding)
        return result
    }
}

// MARK: - Static Decode Methods (Authoritative)

extension RFC_4648.Base64.URL {
    /// Decodes a single Base64URL character to its 6-bit value (PRIMITIVE)
    ///
    /// - Parameter sextet: ASCII byte of Base64URL character
    /// - Returns: 6-bit value (0-63), or nil if invalid
    ///
    /// ## Example
    ///
    /// ```swift
    /// RFC_4648.Base64.URL.decode(sextet: UInt8(ascii: "A"))  // 0
    /// RFC_4648.Base64.URL.decode(sextet: UInt8(ascii: "_"))  // 63
    /// RFC_4648.Base64.URL.decode(sextet: UInt8(ascii: "/"))  // nil (not URL-safe)
    /// ```
    @inlinable
    public static func decode(sextet: UInt8) -> UInt8? {
        let value = encodingTable.decode[Int(sextet)]
        return value == 255 ? nil : value
    }

    /// Decodes Base64URL bytes into a buffer (streaming, no allocation)
    ///
    /// Supports both padded and unpadded input.
    ///
    /// - Parameters:
    ///   - bytes: Base64URL encoded bytes
    ///   - buffer: The buffer to append decoded bytes to
    /// - Returns: `true` if decoding succeeded, `false` if invalid input
    ///
    /// ## Example
    ///
    /// ```swift
    /// var buffer: [UInt8] = []
    /// let success = RFC_4648.Base64.URL.decode("SGVsbG8".utf8, into: &buffer)
    /// // buffer == [72, 101, 108, 108, 111] ("Hello")
    /// ```
    @inlinable
    @discardableResult
    public static func decode<Bytes: Collection, Buffer: RangeReplaceableCollection>(
        _ bytes: Bytes,
        into buffer: inout Buffer
    ) -> Bool where Bytes.Element == UInt8, Buffer.Element == UInt8 {
        RFC_4648.decodeBase64(bytes, into: &buffer, decodeTable: encodingTable.decode, requirePadding: false)
    }

    /// Decodes Base64URL encoded bytes to a new array
    ///
    /// - Parameter bytes: Base64URL encoded bytes
    /// - Returns: Decoded bytes, or nil if invalid
    ///
    /// ## Example
    ///
    /// ```swift
    /// let decoded = RFC_4648.Base64.URL.decode("SGVsbG8".utf8)
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

    /// Decodes Base64URL encoded string
    ///
    /// Convenience overload that delegates to the byte-based version.
    ///
    /// - Parameter string: Base64URL encoded string
    /// - Returns: Decoded bytes, or nil if invalid
    ///
    /// ## Example
    ///
    /// ```swift
    /// let decoded = RFC_4648.Base64.URL.decode("SGVsbG8")
    /// // decoded == [72, 101, 108, 108, 111] ("Hello")
    /// ```
    @inlinable
    public static func decode(_ string: some StringProtocol) -> [UInt8]? {
        decode(string.utf8)
    }

    /// Decodes Base64URL to a FixedWidthInteger (PRIMITIVE)
    ///
    /// Decodes Base64URL bytes directly to an integer value without intermediate array allocation.
    ///
    /// - Parameter bytes: Base64URL encoded bytes
    /// - Returns: Decoded integer value, or nil if invalid or overflow
    ///
    /// ## Example
    ///
    /// ```swift
    /// let value: UInt32? = RFC_4648.Base64.URL.decode("AQIDBA".utf8)
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

// MARK: - Instance Methods (Convenience) - Bytes

extension RFC_4648.Base64.URL.Wrapper where Wrapped: Collection, Wrapped.Element == UInt8 {
    // MARK: Encoding (bytes → Base64URL)

    /// Encodes wrapped bytes to Base64URL into a buffer
    ///
    /// Delegates to static `RFC_4648.Base64.URL.encode(_:into:padding:)`.
    @inlinable
    public func encode<Buffer: RangeReplaceableCollection>(
        into buffer: inout Buffer,
        padding: Bool = false
    ) where Buffer.Element == UInt8 {
        RFC_4648.Base64.URL.encode(wrapped, into: &buffer, padding: padding)
    }

    /// Encodes wrapped bytes to Base64URL string
    ///
    /// Delegates to static `RFC_4648.Base64.URL.encode(_:padding:)`.
    @inlinable
    public func encoded(padding: Bool = false) -> String {
        String(decoding: RFC_4648.Base64.URL.encode(wrapped, padding: padding), as: UTF8.self)
    }

    /// Encodes wrapped bytes to Base64URL string (callable syntax)
    @inlinable
    public func callAsFunction(padding: Bool = false) -> String {
        encoded(padding: padding)
    }

    // MARK: Decoding (Base64URL bytes → raw bytes)

    /// Decodes wrapped Base64URL-encoded bytes into a buffer
    ///
    /// Treats the wrapped bytes as ASCII Base64URL characters and decodes them.
    /// Delegates to static `RFC_4648.Base64.URL.decode(_:into:)`.
    @inlinable
    @discardableResult
    public func decode<Buffer: RangeReplaceableCollection>(
        into buffer: inout Buffer
    ) -> Bool where Buffer.Element == UInt8 {
        RFC_4648.Base64.URL.decode(wrapped, into: &buffer)
    }

    /// Decodes wrapped Base64URL-encoded bytes to raw bytes
    ///
    /// Treats the wrapped bytes as ASCII Base64URL characters and decodes them.
    /// Delegates to static `RFC_4648.Base64.URL.decode(_:)`.
    @inlinable
    public func decoded() -> [UInt8]? {
        RFC_4648.Base64.URL.decode(wrapped)
    }

    /// Decodes wrapped Base64URL-encoded bytes to a FixedWidthInteger
    ///
    /// Treats the wrapped bytes as ASCII Base64URL characters and decodes them.
    /// Delegates to static `RFC_4648.Base64.URL.decode(_:as:)`.
    @inlinable
    public func decoded<T: FixedWidthInteger>(as type: T.Type = T.self) -> T? {
        RFC_4648.Base64.URL.decode(wrapped, as: type)
    }
}

// MARK: - Instance Methods (Convenience) - String

extension RFC_4648.Base64.URL.Wrapper where Wrapped: StringProtocol {
    /// Decodes wrapped Base64URL string into a buffer
    ///
    /// Delegates to static `RFC_4648.Base64.URL.decode(_:into:)`.
    @inlinable
    @discardableResult
    public func decode<Buffer: RangeReplaceableCollection>(
        into buffer: inout Buffer
    ) -> Bool where Buffer.Element == UInt8 {
        RFC_4648.Base64.URL.decode(wrapped.utf8, into: &buffer)
    }

    /// Decodes wrapped Base64URL string to bytes
    ///
    /// Delegates to static `RFC_4648.Base64.URL.decode(_:)`.
    @inlinable
    public func decoded() -> [UInt8]? {
        RFC_4648.Base64.URL.decode(wrapped)
    }

    /// Decodes wrapped Base64URL string to a FixedWidthInteger
    ///
    /// Delegates to static `RFC_4648.Base64.URL.decode(_:as:)`.
    @inlinable
    public func decoded<T: FixedWidthInteger>(as type: T.Type = T.self) -> T? {
        RFC_4648.Base64.URL.decode(wrapped.utf8, as: type)
    }
}
