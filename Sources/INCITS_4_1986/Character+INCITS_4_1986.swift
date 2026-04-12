// Character+INCITS_4_1986.swift
// swift-incits-4-1986
//
// INCITS 4-1986: US-ASCII character classification

import Standards

extension Character {
    /// Character case style for ASCII case conversion
    ///
    /// Enum for ASCII case transformations per INCITS 4-1986.
    /// Only affects ASCII letters ('A'...'Z', 'a'...'z').
    public enum Case: Sendable {
        /// Convert to uppercase (A-Z)
        case upper
        /// Convert to lowercase (a-z)
        case lower
    }
}

extension Character {
    /// Access to ASCII type-level constants and methods
    public static var ascii: ASCII.Type {
        ASCII.self
    }

    /// Access to ASCII instance methods for this character
    public var ascii: ASCII {
        ASCII(character: self)
    }

    public struct ASCII {
        public let character: Character
    }
}

extension Character {
    /// Creates a Character from an ASCII byte with validation
    ///
    /// Converts a UInt8 byte to a Character, returning `nil` if the byte is outside
    /// the valid US-ASCII range (0x00-0x7F).
    ///
    /// ## Usage
    ///
    /// ```swift
    /// // Valid ASCII bytes
    /// Character(ascii: 0x41)  // "A"
    /// Character(ascii: 0x61)  // "a"
    /// Character(ascii: 0x30)  // "0"
    ///
    /// // Non-ASCII bytes
    /// Character(ascii: 0xFF)  // nil
    /// Character(ascii: 0x80)  // nil
    /// ```
    ///
    /// - Parameter ascii: Byte value to convert to Character
    /// - Returns: Character if byte is valid ASCII (0x00-0x7F), `nil` otherwise
    @inlinable
    public init?(ascii byte: UInt8) {
        guard byte <= 0x7F else { return nil }
        self.init(UnicodeScalar(byte))
    }
}

extension Character.ASCII {
    /// Creates a Character from an ASCII byte without validation
    ///
    /// Converts a UInt8 byte to a Character, assuming the byte is valid ASCII without validation.
    /// This method provides optimal performance when the caller can guarantee ASCII validity.
    ///
    /// ## Safety
    ///
    /// **Important**: This method does not validate the input. Passing non-ASCII bytes (>= 0x80)
    /// will create a Character with that Unicode scalar, which may not be what you expect.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// // When you know the byte is ASCII
    /// let char = Character.ascii.unchecked(0x41)  // "A"
    /// let digit = Character.ascii.unchecked(0x35) // "5"
    /// ```
    ///
    /// - Parameter byte: Byte value to convert to Character (assumed ASCII, no checking performed)
    /// - Returns: Character created from the byte
    ///
    /// ## See Also
    ///
    /// - ``Character/init(ascii:)``
    @inlinable
    public static func unchecked(_ byte: UInt8) -> Character {
        Character(UnicodeScalar(byte))
    }

    /// Returns the character if it's valid ASCII, nil otherwise
    ///
    /// Validates that the character is in the ASCII range (U+0000 to U+007F).
    ///
    /// ```swift
    /// let valid = "A"
    /// valid.ascii()  // Optional("A")
    ///
    /// let invalid = "🌍"
    /// invalid.ascii()  // nil
    /// ```
    @inlinable
    public func callAsFunction() -> Character? {
        character.isASCII ? character : nil
    }

    /// Converts ASCII letters to specified case
    ///
    /// Transforms the character to the specified case if it's an ASCII letter,
    /// leaving all other characters unchanged.
    ///
    /// ```swift
    /// "a".ascii(case: .upper)  // "A"
    /// "Z".ascii(case: .lower)  // "z"
    /// "5".ascii(case: .upper)  // "5"
    /// "🌍".ascii(case: .upper) // "🌍"
    /// ```
    @inlinable
    public func callAsFunction(case: Character.Case) -> Character {
        guard let byte = UInt8(ascii: character) else { return character }
        let converted = byte.ascii(case: `case`)
        return Character(UnicodeScalar(converted))
    }

    /// Tests if character is ASCII whitespace (space, tab, LF, CR)
    @_transparent
    public var isWhitespace: Bool {
        guard let value = UInt8(ascii: character) else { return false }
        return value.ascii.isWhitespace
    }

    /// Tests if character is ASCII digit ('0'...'9')
    @_transparent
    public var isDigit: Bool {
        guard let value = UInt8(ascii: character) else { return false }
        return value.ascii.isDigit
    }

    /// Tests if character is ASCII letter ('A'...'Z' or 'a'...'z')
    @_transparent
    public var isLetter: Bool {
        guard let value = UInt8(ascii: character) else { return false }
        return value.ascii.isLetter
    }

    /// Tests if character is ASCII alphanumeric (digit or letter)
    @inlinable
    public var isAlphanumeric: Bool {
        guard let value = UInt8(ascii: character) else { return false }
        return value.ascii.isAlphanumeric
    }

    /// Tests if character is ASCII hexadecimal digit
    @inlinable
    public var isHexDigit: Bool {
        guard let value = UInt8(ascii: character) else { return false }
        return value.ascii.isHexDigit
    }

    /// Tests if character is ASCII uppercase letter ('A'...'Z')
    @_transparent
    public var isUppercase: Bool {
        guard let value = UInt8(ascii: character) else { return false }
        return value.ascii.isUppercase
    }

    /// Tests if character is ASCII lowercase letter ('a'...'z')
    @_transparent
    public var isLowercase: Bool {
        guard let value = UInt8(ascii: character) else { return false }
        return value.ascii.isLowercase
    }
}
