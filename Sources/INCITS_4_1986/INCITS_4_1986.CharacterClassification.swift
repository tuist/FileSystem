// INCITS_4_1986.CharacterClassification.swift
// swift-incits-4-1986
//
// INCITS 4-1986 Section 4: Character Classification
// Authoritative predicates for testing ASCII byte properties

import Standards

extension INCITS_4_1986 {
    /// Character Classification Operations
    ///
    /// Authoritative implementations of character class tests per INCITS 4-1986.
    /// All classification predicates are defined here as the single source of truth.
    ///
    /// Per the standard:
    /// - Control Characters: 0x00-0x1F, 0x7F (33 total)
    /// - Graphic Characters: 0x20-0x7E (95 total)
    /// - Whitespace: 0x20, 0x09, 0x0A, 0x0D (4 total)
    /// - Digits: 0x30-0x39 ('0'-'9')
    /// - Letters: 0x41-0x5A ('A'-'Z') and 0x61-0x7A ('a'-'z')
    ///
    /// ## Performance
    ///
    /// All predicates use `@_transparent` for zero-overhead inlining.
    /// Range checks use branchless subtraction tricks for optimal codegen.
    public enum CharacterClassification {}
}

// MARK: - Lookup Table

extension INCITS_4_1986.CharacterClassification {
    /// Character classification bit flags
    @usableFromInline
    internal static let _digit: UInt8 = 0x01
    @usableFromInline
    internal static let _upper: UInt8 = 0x02
    @usableFromInline
    internal static let _lower: UInt8 = 0x04
    @usableFromInline
    internal static let _hexUpper: UInt8 = 0x08
    @usableFromInline
    internal static let _hexLower: UInt8 = 0x10
    @usableFromInline
    internal static let _whitespace: UInt8 = 0x20
    @usableFromInline
    internal static let _control: UInt8 = 0x40
    @usableFromInline
    internal static let _printable: UInt8 = 0x80

    /// Pre-computed 128-byte lookup table for O(1) character classification
    ///
    /// Each byte encodes multiple class memberships via bit flags:
    /// - Bit 0: Digit (0-9)
    /// - Bit 1: Uppercase letter (A-Z)
    /// - Bit 2: Lowercase letter (a-z)
    /// - Bit 3: Hex digit uppercase (A-F)
    /// - Bit 4: Hex digit lowercase (a-f)
    /// - Bit 5: Whitespace (SP, HT, LF, CR)
    /// - Bit 6: Control character
    /// - Bit 7: Printable (graphic + space)
    @usableFromInline
    internal static let _classTable: [UInt8] = {
        var table = [UInt8](repeating: 0, count: 128)

        // Control characters (0x00-0x1F)
        for i in 0x00...0x1F {
            table[i] = _control
        }
        // DEL (0x7F)
        table[0x7F] = _control

        // Whitespace (overwrites some control flags, adds whitespace)
        table[0x09] |= _whitespace  // HT
        table[0x0A] |= _whitespace  // LF
        table[0x0D] |= _whitespace  // CR
        table[0x20] = _whitespace | _printable  // SP

        // Printable characters (0x21-0x7E)
        for i in 0x21...0x7E {
            table[i] |= _printable
        }

        // Digits (0x30-0x39)
        for i in 0x30...0x39 {
            table[i] |= _digit
        }

        // Uppercase letters (0x41-0x5A)
        for i in 0x41...0x5A {
            table[i] |= _upper
        }

        // Lowercase letters (0x61-0x7A)
        for i in 0x61...0x7A {
            table[i] |= _lower
        }

        // Hex digits uppercase (A-F: 0x41-0x46)
        for i in 0x41...0x46 {
            table[i] |= _hexUpper
        }

        // Hex digits lowercase (a-f: 0x61-0x66)
        for i in 0x61...0x66 {
            table[i] |= _hexLower
        }

        return table
    }()

    /// Fast lookup for ASCII bytes (< 128)
    @_transparent
    @usableFromInline
    internal static func _lookup(_ byte: UInt8) -> UInt8 {
        byte < 128 ? _classTable[Int(byte)] : 0
    }
}

// MARK: - Whitespace Classification

extension INCITS_4_1986.CharacterClassification {
    /// Tests if byte is ASCII whitespace
    ///
    /// Returns `true` for the four ASCII whitespace characters defined in INCITS 4-1986:
    /// - **SPACE** (0x20): Word separator
    /// - **HORIZONTAL TAB** (0x09): Tabulation
    /// - **LINE FEED** (0x0A): End of line (Unix/macOS)
    /// - **CARRIAGE RETURN** (0x0D): End of line (classic Mac, Internet protocols)
    ///
    /// ## Performance
    ///
    /// Uses lookup table for O(1) classification.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// INCITS_4_1986.CharacterClassification.isWhitespace(0x20)    // true (SPACE)
    /// INCITS_4_1986.CharacterClassification.isWhitespace(0x09)    // true (TAB)
    /// INCITS_4_1986.CharacterClassification.isWhitespace(0x41)    // false ('A')
    /// ```
    @_transparent
    public static func isWhitespace(_ byte: UInt8) -> Bool {
        _lookup(byte) & _whitespace != 0
    }

    // MARK: - Control Character Classification

    /// Tests if byte is ASCII control character
    ///
    /// Returns `true` for all 33 control characters defined in INCITS 4-1986:
    /// - **C0 controls**: 0x00-0x1F (NULL, SOH, STX, ..., US)
    /// - **DELETE**: 0x7F
    ///
    /// ## Control Character Ranges
    ///
    /// - **0x00 (NUL)** through **0x1F (US)**: 32 control characters
    /// - **0x7F (DEL)**: The DELETE character
    ///
    /// ## Usage
    ///
    /// ```swift
    /// INCITS_4_1986.CharacterClassification.isControl(0x00)    // true (NUL)
    /// INCITS_4_1986.CharacterClassification.isControl(0x0A)    // true (LF)
    /// INCITS_4_1986.CharacterClassification.isControl(0x7F)    // true (DEL)
    /// INCITS_4_1986.CharacterClassification.isControl(0x41)    // false ('A')
    /// ```
    @_transparent
    public static func isControl(_ byte: UInt8) -> Bool {
        byte <= 0x1F || byte == 0x7F
    }

    // MARK: - Graphic Character Classification

    /// Tests if byte is ASCII visible (non-whitespace printable) character
    ///
    /// Returns `true` for visible graphic characters (0x21-0x7E), which are printable characters
    /// **excluding SPACE**. These are characters with distinct visual glyphs.
    ///
    /// ## Character Range
    ///
    /// - **0x21 ('!')** through **0x7E ('~')**: 94 visible characters
    /// - Includes: digits, letters, punctuation, and symbols
    /// - Excludes: SPACE (0x20), all control characters, and DELETE (0x7F)
    ///
    /// ## Usage
    ///
    /// ```swift
    /// INCITS_4_1986.CharacterClassification.isVisible(0x41)    // true ('A')
    /// INCITS_4_1986.CharacterClassification.isVisible(0x30)    // true ('0')
    /// INCITS_4_1986.CharacterClassification.isVisible(0x20)    // false (SPACE)
    /// ```
    @_transparent
    public static func isVisible(_ byte: UInt8) -> Bool {
        byte >= 0x21 && byte <= 0x7E
    }

    /// Tests if byte is ASCII printable (graphic) character
    ///
    /// Returns `true` for all printable graphic characters (0x20-0x7E), which includes both
    /// visible characters and SPACE. These are the 95 characters that can appear in displayed text.
    ///
    /// ## Character Range
    ///
    /// - **0x20 (SPACE)** through **0x7E ('~')**: 95 printable characters
    /// - Includes: SPACE, digits, letters, punctuation, and symbols
    /// - Excludes: Control characters (0x00-0x1F) and DELETE (0x7F)
    ///
    /// ## Usage
    ///
    /// ```swift
    /// INCITS_4_1986.CharacterClassification.isPrintable(0x41)    // true ('A')
    /// INCITS_4_1986.CharacterClassification.isPrintable(0x20)    // true (SPACE)
    /// INCITS_4_1986.CharacterClassification.isPrintable(0x0A)    // false (LF)
    /// ```
    @_transparent
    public static func isPrintable(_ byte: UInt8) -> Bool {
        byte >= 0x20 && byte <= 0x7E
    }

    // MARK: - Digit Classification

    /// Tests if byte is ASCII digit ('0'...'9')
    ///
    /// Returns `true` for bytes in the range 0x30-0x39.
    ///
    /// ## Performance
    ///
    /// Uses branchless subtraction: `(byte - 0x30) < 10`
    ///
    /// ## Usage
    ///
    /// ```swift
    /// INCITS_4_1986.CharacterClassification.isDigit(0x30)    // true ('0')
    /// INCITS_4_1986.CharacterClassification.isDigit(0x39)    // true ('9')
    /// INCITS_4_1986.CharacterClassification.isDigit(0x41)    // false ('A')
    /// ```
    @_transparent
    public static func isDigit(_ byte: UInt8) -> Bool {
        (byte &- 0x30) < 10
    }

    /// Tests if byte is ASCII hexadecimal digit ('0'...'9', 'A'...'F', 'a'...'f')
    ///
    /// Returns `true` for bytes that represent valid hexadecimal digits in either case.
    ///
    /// ## Performance
    ///
    /// Uses lookup table for single memory access.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// INCITS_4_1986.CharacterClassification.isHexDigit(0x30)    // true ('0')
    /// INCITS_4_1986.CharacterClassification.isHexDigit(0x41)    // true ('A')
    /// INCITS_4_1986.CharacterClassification.isHexDigit(0x61)    // true ('a')
    /// INCITS_4_1986.CharacterClassification.isHexDigit(0x47)    // false ('G')
    /// ```
    @_transparent
    public static func isHexDigit(_ byte: UInt8) -> Bool {
        let flags = _lookup(byte)
        return flags & (_digit | _hexUpper | _hexLower) != 0
    }

    // MARK: - Letter Classification

    /// Tests if byte is ASCII letter ('A'...'Z' or 'a'...'z')
    ///
    /// Returns `true` for uppercase letters (0x41-0x5A) or lowercase letters (0x61-0x7A).
    ///
    /// ## Performance
    ///
    /// Uses OR of two branchless range checks.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// INCITS_4_1986.CharacterClassification.isLetter(0x41)    // true ('A')
    /// INCITS_4_1986.CharacterClassification.isLetter(0x61)    // true ('a')
    /// INCITS_4_1986.CharacterClassification.isLetter(0x30)    // false ('0')
    /// ```
    @_transparent
    public static func isLetter(_ byte: UInt8) -> Bool {
        (byte &- 0x41) < 26 || (byte &- 0x61) < 26
    }

    /// Tests if byte is ASCII uppercase letter ('A'...'Z')
    ///
    /// Returns `true` for bytes in the range 0x41-0x5A.
    ///
    /// ## Performance
    ///
    /// Uses branchless subtraction: `(byte - 0x41) < 26`
    ///
    /// ## Usage
    ///
    /// ```swift
    /// INCITS_4_1986.CharacterClassification.isUppercase(0x41)    // true ('A')
    /// INCITS_4_1986.CharacterClassification.isUppercase(0x5A)    // true ('Z')
    /// INCITS_4_1986.CharacterClassification.isUppercase(0x61)    // false ('a')
    /// ```
    @_transparent
    public static func isUppercase(_ byte: UInt8) -> Bool {
        (byte &- 0x41) < 26
    }

    /// Tests if byte is ASCII lowercase letter ('a'...'z')
    ///
    /// Returns `true` for bytes in the range 0x61-0x7A.
    ///
    /// ## Performance
    ///
    /// Uses branchless subtraction: `(byte - 0x61) < 26`
    ///
    /// ## Usage
    ///
    /// ```swift
    /// INCITS_4_1986.CharacterClassification.isLowercase(0x61)    // true ('a')
    /// INCITS_4_1986.CharacterClassification.isLowercase(0x7A)    // true ('z')
    /// INCITS_4_1986.CharacterClassification.isLowercase(0x41)    // false ('A')
    /// ```
    @_transparent
    public static func isLowercase(_ byte: UInt8) -> Bool {
        (byte &- 0x61) < 26
    }

    /// Tests if byte is ASCII alphanumeric (digit or letter)
    ///
    /// Returns `true` if the byte is either a digit or a letter (uppercase or lowercase).
    ///
    /// ## Performance
    ///
    /// Uses lookup table for single memory access.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// INCITS_4_1986.CharacterClassification.isAlphanumeric(0x41)    // true ('A')
    /// INCITS_4_1986.CharacterClassification.isAlphanumeric(0x30)    // true ('0')
    /// INCITS_4_1986.CharacterClassification.isAlphanumeric(0x21)    // false ('!')
    /// ```
    @_transparent
    public static func isAlphanumeric(_ byte: UInt8) -> Bool {
        let flags = _lookup(byte)
        return flags & (_digit | _upper | _lower) != 0
    }
}
