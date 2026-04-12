// INCITS_4_1986.StringClassification.swift
// swift-incits-4-1986
//
// INCITS 4-1986: String Classification Operations
// Authoritative predicates for testing properties of strings

import Standards

extension INCITS_4_1986 {
    /// String Classification Operations
    ///
    /// Authoritative implementations of string-level classification tests per INCITS 4-1986.
    /// All string predicates are defined here as the single source of truth.
    ///
    /// These operations test properties of entire strings, delegating to the byte-level
    /// character classification operations for individual character tests.
    public enum StringClassification {}
}

extension INCITS_4_1986.StringClassification {
    // MARK: - ASCII Validation

    /// Tests if all bytes in the UTF-8 representation are valid ASCII (0x00-0x7F)
    ///
    /// Returns `true` if every byte in the string's UTF-8 encoding has the high bit clear,
    /// indicating valid 7-bit US-ASCII encoding.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// INCITS_4_1986.StringClassification.isAllASCII("Hello")     // true
    /// INCITS_4_1986.StringClassification.isAllASCII("café")      // false (é is U+00E9)
    /// INCITS_4_1986.StringClassification.isAllASCII("Hello🌍")   // false (emoji)
    /// ```
    ///
    /// - Parameter string: The string to test
    /// - Returns: `true` if all bytes are in the ASCII range (0x00-0x7F)
    @inlinable
    public static func isAllASCII<S: StringProtocol>(_ string: S) -> Bool {
        string.utf8.allSatisfy { $0 <= 0x7F }
    }

    /// Tests if the string contains any non-ASCII characters
    ///
    /// Returns `true` if any byte in the string's UTF-8 encoding has the high bit set,
    /// indicating the presence of characters outside the 7-bit US-ASCII range.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// INCITS_4_1986.StringClassification.containsNonASCII("Hello")     // false
    /// INCITS_4_1986.StringClassification.containsNonASCII("café")      // true
    /// INCITS_4_1986.StringClassification.containsNonASCII("Hello🌍")   // true
    /// ```
    ///
    /// - Parameter string: The string to test
    /// - Returns: `true` if any byte is outside the ASCII range (>= 0x80)
    @inlinable
    public static func containsNonASCII<S: StringProtocol>(_ string: S) -> Bool {
        string.utf8.contains { $0 > 0x7F }
    }

    // MARK: - Character Class Tests

    /// Tests if all characters in the string are ASCII whitespace
    ///
    /// Returns `true` if every character is one of the four ASCII whitespace characters:
    /// SPACE, TAB, LF, or CR.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// INCITS_4_1986.StringClassification.isAllWhitespace("   ")      // true
    /// INCITS_4_1986.StringClassification.isAllWhitespace("\t\n")     // true
    /// INCITS_4_1986.StringClassification.isAllWhitespace("")         // true (vacuous truth)
    /// INCITS_4_1986.StringClassification.isAllWhitespace(" a ")      // false
    /// ```
    ///
    /// - Parameter string: The string to test
    /// - Returns: `true` if all characters are ASCII whitespace (vacuous truth for empty strings)
    @inlinable
    public static func isAllWhitespace<S: StringProtocol>(_ string: S) -> Bool {
        string.allSatisfy { char in
            guard let byte = UInt8(ascii: char) else { return false }
            return INCITS_4_1986.CharacterClassification.isWhitespace(byte)
        }
    }

    /// Tests if all characters in the string are ASCII digits (0-9)
    ///
    /// Returns `true` if every character is an ASCII digit.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// INCITS_4_1986.StringClassification.isAllDigits("12345")    // true
    /// INCITS_4_1986.StringClassification.isAllDigits("123a45")   // false
    /// INCITS_4_1986.StringClassification.isAllDigits("")         // true (vacuous truth)
    /// ```
    ///
    /// - Parameter string: The string to test
    /// - Returns: `true` if all characters are ASCII digits (vacuous truth for empty strings)
    @inlinable
    public static func isAllDigits<S: StringProtocol>(_ string: S) -> Bool {
        string.allSatisfy { char in
            guard let byte = UInt8(ascii: char) else { return false }
            return INCITS_4_1986.CharacterClassification.isDigit(byte)
        }
    }

    /// Tests if all characters in the string are ASCII letters (A-Z, a-z)
    ///
    /// Returns `true` if every character is an ASCII letter.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// INCITS_4_1986.StringClassification.isAllLetters("Hello")    // true
    /// INCITS_4_1986.StringClassification.isAllLetters("Hello123") // false
    /// INCITS_4_1986.StringClassification.isAllLetters("")         // true (vacuous truth)
    /// ```
    ///
    /// - Parameter string: The string to test
    /// - Returns: `true` if all characters are ASCII letters (vacuous truth for empty strings)
    @inlinable
    public static func isAllLetters<S: StringProtocol>(_ string: S) -> Bool {
        string.allSatisfy { char in
            guard let byte = UInt8(ascii: char) else { return false }
            return INCITS_4_1986.CharacterClassification.isLetter(byte)
        }
    }

    /// Tests if all characters in the string are ASCII alphanumeric (0-9, A-Z, a-z)
    ///
    /// Returns `true` if every character is either an ASCII digit or letter.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// INCITS_4_1986.StringClassification.isAllAlphanumeric("Hello123")  // true
    /// INCITS_4_1986.StringClassification.isAllAlphanumeric("Hello-123") // false
    /// INCITS_4_1986.StringClassification.isAllAlphanumeric("")          // true (vacuous truth)
    /// ```
    ///
    /// - Parameter string: The string to test
    /// - Returns: `true` if all characters are ASCII alphanumeric (vacuous truth for empty strings)
    @inlinable
    public static func isAllAlphanumeric<S: StringProtocol>(_ string: S) -> Bool {
        string.allSatisfy { char in
            guard let byte = UInt8(ascii: char) else { return false }
            return INCITS_4_1986.CharacterClassification.isAlphanumeric(byte)
        }
    }

    /// Tests if all characters in the string are ASCII control characters
    ///
    /// Returns `true` if every character is an ASCII control character (0x00-0x1F or 0x7F).
    ///
    /// ## Usage
    ///
    /// ```swift
    /// INCITS_4_1986.StringClassification.isAllControl("\t\n")    // true
    /// INCITS_4_1986.StringClassification.isAllControl("\tA")     // false
    /// INCITS_4_1986.StringClassification.isAllControl("")        // true (vacuous truth)
    /// ```
    ///
    /// - Parameter string: The string to test
    /// - Returns: `true` if all characters are ASCII control characters (vacuous truth for empty strings)
    @inlinable
    public static func isAllControl<S: StringProtocol>(_ string: S) -> Bool {
        string.allSatisfy { char in
            guard let byte = UInt8(ascii: char) else { return false }
            return INCITS_4_1986.CharacterClassification.isControl(byte)
        }
    }

    /// Tests if all characters in the string are ASCII visible characters (excludes SPACE)
    ///
    /// Returns `true` if every character is a visible ASCII graphic character (0x21-0x7E).
    ///
    /// ## Usage
    ///
    /// ```swift
    /// INCITS_4_1986.StringClassification.isAllVisible("Hello!")   // true
    /// INCITS_4_1986.StringClassification.isAllVisible("Hello ")   // false (contains SPACE)
    /// INCITS_4_1986.StringClassification.isAllVisible("")         // true (vacuous truth)
    /// ```
    ///
    /// - Parameter string: The string to test
    /// - Returns: `true` if all characters are ASCII visible characters (vacuous truth for empty strings)
    @inlinable
    public static func isAllVisible<S: StringProtocol>(_ string: S) -> Bool {
        string.allSatisfy { char in
            guard let byte = UInt8(ascii: char) else { return false }
            return INCITS_4_1986.CharacterClassification.isVisible(byte)
        }
    }

    /// Tests if all characters in the string are ASCII printable characters (includes SPACE)
    ///
    /// Returns `true` if every character is a printable ASCII graphic character (0x20-0x7E).
    ///
    /// ## Usage
    ///
    /// ```swift
    /// INCITS_4_1986.StringClassification.isAllPrintable("Hello World")  // true
    /// INCITS_4_1986.StringClassification.isAllPrintable("Hello\n")      // false (contains LF)
    /// INCITS_4_1986.StringClassification.isAllPrintable("")             // true (vacuous truth)
    /// ```
    ///
    /// - Parameter string: The string to test
    /// - Returns: `true` if all characters are ASCII printable characters (vacuous truth for empty strings)
    @inlinable
    public static func isAllPrintable<S: StringProtocol>(_ string: S) -> Bool {
        string.allSatisfy { char in
            guard let byte = UInt8(ascii: char) else { return false }
            return INCITS_4_1986.CharacterClassification.isPrintable(byte)
        }
    }

    /// Tests if the string contains any ASCII hexadecimal digit (0-9, A-F, a-f)
    ///
    /// Returns `true` if at least one character is a valid hexadecimal digit.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// INCITS_4_1986.StringClassification.containsHexDigit("0x1A")     // true
    /// INCITS_4_1986.StringClassification.containsHexDigit("Hello")    // false
    /// INCITS_4_1986.StringClassification.containsHexDigit("")         // false
    /// ```
    ///
    /// - Parameter string: The string to test
    /// - Returns: `true` if the string contains at least one hex digit
    @inlinable
    public static func containsHexDigit<S: StringProtocol>(_ string: S) -> Bool {
        string.contains { char in
            guard let byte = UInt8(ascii: char) else { return false }
            return INCITS_4_1986.CharacterClassification.isHexDigit(byte)
        }
    }

    // MARK: - Case Tests

    /// Tests if all ASCII letters in the string are lowercase
    ///
    /// Non-letter characters are ignored in the check. Returns `true` if there are no
    /// uppercase ASCII letters.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// INCITS_4_1986.StringClassification.isAllLowercase("hello")      // true
    /// INCITS_4_1986.StringClassification.isAllLowercase("hello123")   // true (digits ignored)
    /// INCITS_4_1986.StringClassification.isAllLowercase("Hello")      // false
    /// INCITS_4_1986.StringClassification.isAllLowercase("123")        // true (no letters)
    /// ```
    ///
    /// - Parameter string: The string to test
    /// - Returns: `true` if all ASCII letters are lowercase (non-letters ignored)
    @inlinable
    public static func isAllLowercase<S: StringProtocol>(_ string: S) -> Bool {
        string.allSatisfy { char in
            guard let byte = UInt8(ascii: char) else { return true }
            return INCITS_4_1986.CharacterClassification.isLetter(byte)
                ? INCITS_4_1986.CharacterClassification.isLowercase(byte)
                : true
        }
    }

    /// Tests if all ASCII letters in the string are uppercase
    ///
    /// Non-letter characters are ignored in the check. Returns `true` if there are no
    /// lowercase ASCII letters.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// INCITS_4_1986.StringClassification.isAllUppercase("HELLO")      // true
    /// INCITS_4_1986.StringClassification.isAllUppercase("HELLO123")   // true (digits ignored)
    /// INCITS_4_1986.StringClassification.isAllUppercase("Hello")      // false
    /// INCITS_4_1986.StringClassification.isAllUppercase("123")        // true (no letters)
    /// ```
    ///
    /// - Parameter string: The string to test
    /// - Returns: `true` if all ASCII letters are uppercase (non-letters ignored)
    @inlinable
    public static func isAllUppercase<S: StringProtocol>(_ string: S) -> Bool {
        string.allSatisfy { char in
            guard let byte = UInt8(ascii: char) else { return true }
            return INCITS_4_1986.CharacterClassification.isLetter(byte)
                ? INCITS_4_1986.CharacterClassification.isUppercase(byte)
                : true
        }
    }
}
