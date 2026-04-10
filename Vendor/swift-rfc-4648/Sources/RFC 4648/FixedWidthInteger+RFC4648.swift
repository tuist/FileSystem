// FixedWidthInteger+RFC4648.swift
// swift-rfc-4648
//
// FixedWidthInteger decoding extensions for RFC 4648 encodings
//
// These initializers decode encoded strings directly to integers.
// They delegate to RFC_4648 primitives and use the Standards library
// for byte-to-integer conversion.

import Standards

// MARK: - FixedWidthInteger Decoding

extension FixedWidthInteger {
    /// Creates an integer from a Base64 encoded string (RFC 4648 Section 4)
    ///
    /// Decodes the Base64 string to bytes and interprets them as a big-endian integer.
    /// Returns nil if the string is invalid or if the decoded byte count doesn't match
    /// the integer's byte width.
    ///
    /// Delegates to `RFC_4648.Base64.decode(_:)`.
    ///
    /// - Parameter base64Encoded: Base64 encoded string
    ///
    /// ## Examples
    ///
    /// ```swift
    /// let value = UInt32(base64Encoded: "AAHiQA==")  // 123456
    /// let invalid = UInt32(base64Encoded: "invalid")  // nil
    /// let wrongSize = UInt8(base64Encoded: "AAHiQA==")  // nil (4 bytes != 1 byte)
    /// ```
    @inlinable
    public init?(base64Encoded string: some StringProtocol) {
        guard let bytes = RFC_4648.Base64.decode(string) else { return nil }
        self.init(bytes: bytes, endianness: .big)
    }

    /// Creates an integer from a Base64URL encoded string (RFC 4648 Section 5)
    ///
    /// Decodes the Base64URL string to bytes and interprets them as a big-endian integer.
    /// Returns nil if the string is invalid or if the decoded byte count doesn't match
    /// the integer's byte width.
    ///
    /// Delegates to `RFC_4648.Base64.URL.decode(_:)`.
    ///
    /// - Parameter base64URLEncoded: Base64URL encoded string
    ///
    /// ## Examples
    ///
    /// ```swift
    /// let value = UInt32(base64URLEncoded: "AAHiQA")  // 123456
    /// ```
    @inlinable
    public init?(base64URLEncoded string: some StringProtocol) {
        guard let bytes = RFC_4648.Base64.URL.decode(string) else { return nil }
        self.init(bytes: bytes, endianness: .big)
    }

    /// Creates an integer from a Base32 encoded string (RFC 4648 Section 6)
    ///
    /// Decodes the Base32 string to bytes and interprets them as a big-endian integer.
    /// Returns nil if the string is invalid or if the decoded byte count doesn't match
    /// the integer's byte width.
    ///
    /// Delegates to `RFC_4648.Base32.decode(_:)`.
    ///
    /// - Parameter base32Encoded: Base32 encoded string (case-insensitive)
    ///
    /// ## Examples
    ///
    /// ```swift
    /// let value = UInt32(base32Encoded: "AAA6EQA=")  // 123456
    /// ```
    @inlinable
    public init?(base32Encoded string: some StringProtocol) {
        guard let bytes = RFC_4648.Base32.decode(string) else { return nil }
        self.init(bytes: bytes, endianness: .big)
    }

    /// Creates an integer from a Base32-HEX encoded string (RFC 4648 Section 7)
    ///
    /// Decodes the Base32-HEX string to bytes and interprets them as a big-endian integer.
    /// Returns nil if the string is invalid or if the decoded byte count doesn't match
    /// the integer's byte width.
    ///
    /// Delegates to `RFC_4648.Base32.Hex.decode(_:)`.
    ///
    /// - Parameter base32HexEncoded: Base32-HEX encoded string (case-insensitive)
    ///
    /// ## Examples
    ///
    /// ```swift
    /// let value = UInt32(base32HexEncoded: "000U4G0=")  // 123456
    /// ```
    @inlinable
    public init?(base32HexEncoded string: some StringProtocol) {
        guard let bytes = RFC_4648.Base32.Hex.decode(string) else { return nil }
        self.init(bytes: bytes, endianness: .big)
    }

    /// Creates an integer from a hexadecimal encoded string (RFC 4648 Section 8)
    ///
    /// Decodes the hexadecimal string to bytes and interprets them as a big-endian integer.
    /// Returns nil if the string is invalid or if the decoded byte count doesn't match
    /// the integer's byte width. Accepts strings with or without "0x" prefix.
    ///
    /// Delegates to `RFC_4648.Base16.decode(_:skipPrefix:)`.
    ///
    /// - Parameter hexEncoded: Hexadecimal encoded string (case-insensitive)
    ///
    /// ## Examples
    ///
    /// ```swift
    /// let value1 = UInt32(hexEncoded: "deadbeef")  // 3735928559
    /// let value2 = UInt32(hexEncoded: "0xdeadbeef")  // 3735928559
    /// let value3 = UInt32(hexEncoded: "0xDEADBEEF")  // 3735928559
    /// ```
    @inlinable
    public init?(hexEncoded string: some StringProtocol) {
        guard let bytes = RFC_4648.Base16.decode(string, skipPrefix: true) else { return nil }
        self.init(bytes: bytes, endianness: .big)
    }
}
