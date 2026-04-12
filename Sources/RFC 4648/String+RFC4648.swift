// String+RFC4648.swift
// swift-rfc-4648
//
// String extensions using RFC_4648 primitives
//
// Encoding: String.base64(bytes), String.base64.url(bytes), etc.
// Decoding: "encoded".base64.decoded(), "encoded".base64.url.decoded(), etc.

// MARK: - Static Encoder Properties (for String.base64(...) syntax)

extension String {
    /// Base64 encoder for `String.base64(bytes)` syntax
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let encoded = String.base64([72, 101, 108, 108, 111])  // "SGVsbG8="
    /// let encoded = String.base64.url([72, 101, 108, 108, 111])  // "SGVsbG8"
    /// ```
    public static let base64 = RFC_4648.Base64.Encoder()

    /// Base64URL encoder for `String.base64URL(bytes)` syntax
    ///
    /// RFC 4648 Section 5 defines this URL and filename safe alphabet.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let encoded = String.base64URL([72, 101, 108, 108, 111])  // "SGVsbG8"
    /// ```
    public static let base64URL = RFC_4648.Base64.URL.Encoder()

    /// Base32 encoder for `String.base32(bytes)` syntax
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let encoded = String.base32([72, 101, 108, 108, 111])  // "JBSWY3DP"
    /// let encoded = String.base32.hex([72, 101, 108, 108, 111])  // "91IMOR3F"
    /// ```
    public static let base32 = RFC_4648.Base32.Encoder()

    /// Base32-HEX encoder for `String.base32Hex(bytes)` syntax
    ///
    /// RFC 4648 Section 7 defines this extended hex alphabet.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let encoded = String.base32Hex([72, 101, 108, 108, 111])  // "91IMOR3F"
    /// ```
    public static let base32Hex = RFC_4648.Base32.Hex.Encoder()

    /// Hex encoder for `String.hex(bytes)` syntax
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let encoded = String.hex([0xde, 0xad, 0xbe, 0xef])  // "deadbeef"
    /// let encoded = String.hex([0xde, 0xad], uppercase: true)  // "DEAD"
    /// ```
    public static let hex = RFC_4648.Base16.Encoder()

    /// Base16 encoder (alias for `hex`) for `String.base16(bytes)` syntax
    ///
    /// RFC 4648 Section 8 calls this encoding "Base16" (also known as hex).
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let encoded = String.base16([0xde, 0xad, 0xbe, 0xef])  // "deadbeef"
    /// ```
    public static let base16 = RFC_4648.Base16.Encoder()
}

// MARK: - StringProtocol Decoding Accessors

extension StringProtocol {
    /// Access to Base64 instance operations for decoding
    ///
    /// ## Usage
    ///
    /// ```swift
    /// "SGVsbG8=".base64.decoded()  // [72, 101, 108, 108, 111] ("Hello")
    /// "SGVsbG8=".base64.isValid    // true
    /// "SGVsbG8".base64.url.decoded()  // [72, 101, 108, 108, 111] (URL variant)
    /// ```
    @inlinable
    public var base64: RFC_4648.Base64.Wrapper<Self> {
        RFC_4648.Base64.Wrapper(self)
    }

    /// Access to Base64URL instance operations for decoding
    ///
    /// RFC 4648 Section 5 defines this URL and filename safe alphabet.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// "SGVsbG8".base64URL.decoded()  // [72, 101, 108, 108, 111] ("Hello")
    /// ```
    @inlinable
    public var base64URL: RFC_4648.Base64.URL.Wrapper<Self> {
        RFC_4648.Base64.URL.Wrapper(self)
    }

    /// Access to Base32 instance operations for decoding
    ///
    /// ## Usage
    ///
    /// ```swift
    /// "JBSWY3DP".base32.decoded()  // [72, 101, 108, 108, 111] ("Hello")
    /// "JBSWY3DP".base32.isValid    // true
    /// "91IMOR3F".base32.hex.decoded()  // [72, 101, 108, 108, 111] (HEX variant)
    /// ```
    @inlinable
    public var base32: RFC_4648.Base32.Wrapper<Self> {
        RFC_4648.Base32.Wrapper(self)
    }

    /// Access to Base32-HEX instance operations for decoding
    ///
    /// RFC 4648 Section 7 defines this extended hex alphabet.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// "91IMOR3F".base32Hex.decoded()  // [72, 101, 108, 108, 111] ("Hello")
    /// ```
    @inlinable
    public var base32Hex: RFC_4648.Base32.Hex.Wrapper<Self> {
        RFC_4648.Base32.Hex.Wrapper(self)
    }

    /// Access to Base16/Hex instance operations for decoding
    ///
    /// ## Usage
    ///
    /// ```swift
    /// "deadbeef".hex.decoded()  // [0xde, 0xad, 0xbe, 0xef]
    /// "48656c6c6f".hex.decoded()  // [72, 101, 108, 108, 111] ("Hello")
    /// "deadbeef".hex.isValid  // true
    /// ```
    @inlinable
    public var hex: RFC_4648.Base16.Wrapper<Self> {
        RFC_4648.Base16.Wrapper(self)
    }

    /// Access to Base16 instance operations for decoding (alias for `hex`)
    ///
    /// RFC 4648 Section 8 calls this encoding "Base16" (also known as hex).
    ///
    /// ## Usage
    ///
    /// ```swift
    /// "deadbeef".base16.decoded()  // [0xde, 0xad, 0xbe, 0xef]
    /// ```
    @inlinable
    public var base16: RFC_4648.Base16.Wrapper<Self> {
        RFC_4648.Base16.Wrapper(self)
    }
}
