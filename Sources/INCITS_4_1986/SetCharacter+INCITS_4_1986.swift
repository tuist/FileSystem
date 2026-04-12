// Set<Character>+INCITS_4_1986.swift
// swift-incits-4-1986
//
// INCITS 4-1986: US-ASCII character sets

import Standards

extension Set {
    /// Convenient access to INCITS 4-1986 (US-ASCII) character constants
    ///
    /// Returns the INCITS_4_1986 namespace for accessing ASCII constants without conflicts.
    ///
    /// Example:
    /// ```swift
    /// let whitespaces: Set<Character> = .ascii.whitespaceCharacters
    /// let trimmed = " hello ".trimming(.ascii.whitespaceCharacters)
    /// ```
    public static var ascii: ASCII.Type {
        ASCII.self
    }

    public enum ASCII {}
}

extension Set<Character>.ASCII {
    /// ASCII whitespace characters as Set<Character>
    ///
    /// Derived from the canonical byte-level definition in `INCITS_4_1986.whitespaces`.
    /// Per INCITS 4-1986, these are the only four whitespace characters in US-ASCII:
    /// - U+0020 (SPACE)
    /// - U+0009 (HORIZONTAL TAB)
    /// - U+000A (LINE FEED)
    /// - U+000D (CARRIAGE RETURN)
    ///
    /// This is explicitly ASCII-only and does not include Unicode whitespace
    /// characters (e.g., U+00A0 NO-BREAK SPACE, U+2003 EM SPACE).
    ///
    /// - Note: For trimming operations that must handle CRLF sequences (which Swift
    ///   treats as a single grapheme cluster), use ``isWhitespace(_:)`` predicate instead.
    ///
    /// ## See Also
    ///
    /// - ``isWhitespace(_:)``
    public static let whitespaces: Set<Character> = {
        var set = Set(
            INCITS_4_1986.whitespaces.map {
                Character(UnicodeScalar($0))
            })
        set.insert(Character(.init([UInt8].ascii.crlf)))
        return set
    }()

    /// Tests if a Character is ASCII whitespace (handles grapheme clusters)
    ///
    /// Returns `true` if ALL Unicode scalars in the Character are ASCII whitespace bytes.
    /// This correctly handles Swift's grapheme clustering where `\r\n` (CRLF) is a single Character.
    ///
    /// Per INCITS 4-1986, ASCII whitespace bytes are: SP (0x20), HT (0x09), LF (0x0A), CR (0x0D).
    ///
    /// ## Why use this instead of Set membership?
    ///
    /// Swift treats `\r\n` as a single grapheme cluster (Character). The `whitespaces` set
    /// contains `\r` and `\n` as separate Characters, so `whitespaces.contains("\r\n")` returns
    /// `false`. This predicate correctly identifies CRLF as whitespace because both of its
    /// constituent scalars are whitespace bytes.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// // For trimming with grapheme-aware whitespace handling:
    /// "\t\nhello\r\n".trimming(.ascii.whitespaces)  // "hello"
    ///
    /// // Individual character checks:
    /// Set<Character>.ascii.isWhitespace(" ")     // true
    /// Set<Character>.ascii.isWhitespace("\r\n")  // true (CRLF grapheme)
    /// Set<Character>.ascii.isWhitespace("a")     // false
    /// ```
    ///
    /// - Parameter char: The Character to test
    /// - Returns: `true` if all Unicode scalars in the Character are ASCII whitespace
    public static func isWhitespace(_ char: Character) -> Bool {
        char.unicodeScalars.allSatisfy { scalar in
            scalar.value < 128 && INCITS_4_1986.whitespaces.contains(UInt8(scalar.value))
        }
    }
}
