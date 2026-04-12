// Collection+RFC4648.swift
// swift-rfc-4648
//
// Collection extensions using RFC_4648 primitives
//
// Array initializers for decoding encoded strings to bytes.
// Byte collection accessors for encoding bytes to strings.

// MARK: - Array Initializers (Decoding)

extension [UInt8] {
    /// Creates an array from a Base64 encoded string (RFC 4648 Section 4)
    ///
    /// Delegates to `RFC_4648.Base64.decode(_:)`.
    ///
    /// - Parameter base64Encoded: Base64 encoded string
    /// - Returns: Decoded bytes, or nil if invalid Base64
    @inlinable
    public init?(base64Encoded string: some StringProtocol) {
        guard let decoded = RFC_4648.Base64.decode(string) else { return nil }
        self = decoded
    }

    /// Creates an array from a Base64URL encoded string (RFC 4648 Section 5)
    ///
    /// Delegates to `RFC_4648.Base64.URL.decode(_:)`.
    ///
    /// - Parameter base64URLEncoded: Base64URL encoded string
    /// - Returns: Decoded bytes, or nil if invalid Base64URL
    @inlinable
    public init?(base64URLEncoded string: some StringProtocol) {
        guard let decoded = RFC_4648.Base64.URL.decode(string) else { return nil }
        self = decoded
    }

    /// Creates an array from a Base32 encoded string (RFC 4648 Section 6)
    ///
    /// Delegates to `RFC_4648.Base32.decode(_:)`.
    ///
    /// - Parameter base32Encoded: Base32 encoded string (case-insensitive)
    /// - Returns: Decoded bytes, or nil if invalid Base32
    @inlinable
    public init?(base32Encoded string: some StringProtocol) {
        guard let decoded = RFC_4648.Base32.decode(string) else { return nil }
        self = decoded
    }

    /// Creates an array from a Base32-HEX encoded string (RFC 4648 Section 7)
    ///
    /// Delegates to `RFC_4648.Base32.Hex.decode(_:)`.
    ///
    /// - Parameter base32HexEncoded: Base32-HEX encoded string (case-insensitive)
    /// - Returns: Decoded bytes, or nil if invalid Base32-HEX
    @inlinable
    public init?(base32HexEncoded string: some StringProtocol) {
        guard let decoded = RFC_4648.Base32.Hex.decode(string) else { return nil }
        self = decoded
    }

    /// Creates an array from a Base16 (hexadecimal) encoded string (RFC 4648 Section 8)
    ///
    /// Delegates to `RFC_4648.Base16.decode(_:skipPrefix:)`.
    ///
    /// - Parameter hexEncoded: Base16/hexadecimal encoded string (case-insensitive)
    /// - Returns: Decoded bytes, or nil if invalid Base16
    @inlinable
    public init?(hexEncoded string: some StringProtocol) {
        guard let decoded = RFC_4648.Base16.decode(string, skipPrefix: true) else { return nil }
        self = decoded
    }
}

// MARK: - Byte Collection Encoding Accessors

extension Collection where Element == UInt8 {
    /// Access to Base64 instance operations for encoding
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let bytes: [UInt8] = [72, 101, 108, 108, 111]
    /// bytes.base64.encoded()       // "SGVsbG8=" (standard Base64)
    /// bytes.base64.url.encoded()   // "SGVsbG8" (URL-safe, no padding)
    /// ```
    @inlinable
    public var base64: RFC_4648.Base64.Wrapper<Self> {
        RFC_4648.Base64.Wrapper(self)
    }

    /// Access to Base32 instance operations for encoding
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let bytes: [UInt8] = [72, 101, 108, 108, 111]
    /// bytes.base32.encoded()      // "JBSWY3DP" (standard Base32)
    /// bytes.base32.hex.encoded()  // "91IMOR3F" (Base32-HEX)
    /// ```
    @inlinable
    public var base32: RFC_4648.Base32.Wrapper<Self> {
        RFC_4648.Base32.Wrapper(self)
    }

    /// Access to Base16/Hex instance operations for encoding
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let bytes: [UInt8] = [0xde, 0xad, 0xbe, 0xef]
    /// bytes.hex.encoded()  // "deadbeef"
    /// bytes.hex.encoded(uppercase: true)  // "DEADBEEF"
    /// bytes.hex()  // "deadbeef" (callAsFunction)
    /// ```
    @inlinable
    public var hex: RFC_4648.Base16.Wrapper<Self> {
        RFC_4648.Base16.Wrapper(self)
    }
}
