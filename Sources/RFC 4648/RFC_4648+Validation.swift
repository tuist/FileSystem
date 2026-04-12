// RFC_4648+Validation.swift
// swift-rfc-4648
//
// Validation extensions for RFC 4648 encodings

extension RFC_4648.Base64 {
    /// Checks if the string is valid Base64 encoding (RFC 4648 Section 4)
    ///
    /// - Parameter string: The string to validate
    /// - Returns: true if the string is valid Base64, false otherwise
    ///
    /// ## Examples
    ///
    /// ```swift
    /// RFC_4648.Base64.isValid("Zm9vYmFy")  // true
    /// RFC_4648.Base64.isValid("!!!invalid")  // false
    /// ```
    @inlinable
    public static func isValid(_ string: some StringProtocol) -> Bool {
        decode(string) != nil
    }
}

extension RFC_4648.Base64.URL {
    /// Checks if the string is valid Base64URL encoding (RFC 4648 Section 5)
    ///
    /// - Parameter string: The string to validate
    /// - Returns: true if the string is valid Base64URL, false otherwise
    ///
    /// ## Examples
    ///
    /// ```swift
    /// RFC_4648.Base64.URL.isValid("Zm9vYmFy")  // true
    /// RFC_4648.Base64.URL.isValid("A-B_")  // true (Base64URL uses - and _)
    /// ```
    @inlinable
    public static func isValid(_ string: some StringProtocol) -> Bool {
        decode(string) != nil
    }
}

extension RFC_4648.Base32 {
    /// Checks if the string is valid Base32 encoding (RFC 4648 Section 6)
    ///
    /// Base32 uses A-Z and 2-7, case-insensitive.
    ///
    /// - Parameter string: The string to validate
    /// - Returns: true if the string is valid Base32, false otherwise
    ///
    /// ## Examples
    ///
    /// ```swift
    /// RFC_4648.Base32.isValid("MZXW6YTBOI======")  // true
    /// RFC_4648.Base32.isValid("123@#$")  // false
    /// ```
    @inlinable
    public static func isValid(_ string: some StringProtocol) -> Bool {
        decode(string) != nil
    }
}

extension RFC_4648.Base32.Hex {
    /// Checks if the string is valid Base32-HEX encoding (RFC 4648 Section 7)
    ///
    /// Base32-HEX uses 0-9 and A-V, case-insensitive.
    ///
    /// - Parameter string: The string to validate
    /// - Returns: true if the string is valid Base32-HEX, false otherwise
    ///
    /// ## Examples
    ///
    /// ```swift
    /// RFC_4648.Base32.Hex.isValid("CPNMUOJ1")  // true
    /// RFC_4648.Base32.Hex.isValid("XYZ123")  // false (X, Y, Z not in alphabet)
    /// ```
    @inlinable
    public static func isValid(_ string: some StringProtocol) -> Bool {
        decode(string) != nil
    }
}

extension RFC_4648.Base16 {
    /// Checks if the string is valid Base16 (hexadecimal) encoding (RFC 4648 Section 8)
    ///
    /// Accepts both lowercase and uppercase hex digits. Accepts strings with
    /// or without "0x" prefix.
    ///
    /// - Parameter string: The string to validate
    /// - Returns: true if the string is valid hexadecimal, false otherwise
    ///
    /// ## Examples
    ///
    /// ```swift
    /// RFC_4648.Base16.isValid("deadbeef")  // true
    /// RFC_4648.Base16.isValid("0xDEADBEEF")  // true
    /// RFC_4648.Base16.isValid("ghijk")  // false
    /// ```
    @inlinable
    public static func isValid(_ string: some StringProtocol) -> Bool {
        decode(string, skipPrefix: true) != nil
    }
}

// MARK: - Instance Validation (Convenience)

extension RFC_4648.Base64.Wrapper where Wrapped: StringProtocol {
    /// Checks if the wrapped string is valid Base64 encoding
    ///
    /// Delegates to the static `RFC_4648.Base64.isValid(_:)` method.
    ///
    /// ## Examples
    ///
    /// ```swift
    /// "Zm9vYmFy".base64.isValid  // true
    /// "!!!invalid".base64.isValid  // false
    /// ```
    @inlinable
    public var isValid: Bool {
        RFC_4648.Base64.isValid(wrapped)
    }
}

extension RFC_4648.Base64.URL.Wrapper where Wrapped: StringProtocol {
    /// Checks if the wrapped string is valid Base64URL encoding
    ///
    /// Delegates to the static `RFC_4648.Base64.URL.isValid(_:)` method.
    ///
    /// ## Examples
    ///
    /// ```swift
    /// "Zm9vYmFy".base64.url.isValid  // true
    /// "A-B_".base64.url.isValid  // true
    /// ```
    @inlinable
    public var isValid: Bool {
        RFC_4648.Base64.URL.isValid(wrapped)
    }
}

extension RFC_4648.Base32.Wrapper where Wrapped: StringProtocol {
    /// Checks if the wrapped string is valid Base32 encoding
    ///
    /// Delegates to the static `RFC_4648.Base32.isValid(_:)` method.
    ///
    /// ## Examples
    ///
    /// ```swift
    /// "MZXW6YTBOI======".base32.isValid  // true
    /// "123@#$".base32.isValid  // false
    /// ```
    @inlinable
    public var isValid: Bool {
        RFC_4648.Base32.isValid(wrapped)
    }
}

extension RFC_4648.Base32.Hex.Wrapper where Wrapped: StringProtocol {
    /// Checks if the wrapped string is valid Base32-HEX encoding
    ///
    /// Delegates to the static `RFC_4648.Base32.Hex.isValid(_:)` method.
    ///
    /// ## Examples
    ///
    /// ```swift
    /// "CPNMUOJ1".base32.hex.isValid  // true
    /// "XYZ123".base32.hex.isValid  // false
    /// ```
    @inlinable
    public var isValid: Bool {
        RFC_4648.Base32.Hex.isValid(wrapped)
    }
}

extension RFC_4648.Base16.Wrapper where Wrapped: StringProtocol {
    /// Checks if the wrapped string is valid Base16 (hexadecimal) encoding
    ///
    /// Delegates to the static `RFC_4648.Base16.isValid(_:)` method.
    ///
    /// ## Examples
    ///
    /// ```swift
    /// "deadbeef".hex.isValid  // true
    /// "0xDEADBEEF".hex.isValid  // true
    /// "ghijk".hex.isValid  // false
    /// ```
    @inlinable
    public var isValid: Bool {
        RFC_4648.Base16.isValid(wrapped)
    }
}
