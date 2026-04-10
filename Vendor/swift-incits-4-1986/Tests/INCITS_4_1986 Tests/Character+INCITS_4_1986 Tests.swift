// Character+INCITS_4_1986 Tests.swift
// swift-incits-4-1986
//
// Tests for Character extension predicates

import StandardsTestSupport
import Testing

@testable import INCITS_4_1986

@Suite
struct `Character Tests` {
    @Suite
    struct `Character - ASCII Whitespace` {
        @Test(arguments: [" ", "\t", "\n", "\r"])
        func `whitespace characters are recognized`(char: Character) {
            #expect(char.ascii.isWhitespace)
        }

        @Test(arguments: ["a", "Z", "0", "!"])
        func `non-whitespace characters are not recognized`(char: Character) {
            #expect(!char.ascii.isWhitespace)
        }
    }

    @Suite
    struct `Character - ASCII Digits` {
        @Test(arguments: Array("0123456789"))
        func `digit characters are recognized`(char: Character) {
            #expect(char.ascii.isDigit)
        }

        @Test(arguments: ["a", "Z", " ", "!"])
        func `non-digit characters are not recognized`(char: Character) {
            #expect(!char.ascii.isDigit)
        }
    }

    @Suite
    struct `Character - ASCII Letters` {
        @Test(arguments: Array(UInt8.ascii.A...UInt8.ascii.Z))
        func `uppercase letters A-Z are recognized`(ascii: UInt8) {
            let char = Character(UnicodeScalar(ascii))
            #expect(char.ascii.isLetter, "Character '\(char)' should be a letter")
            #expect(char.ascii.isUppercase, "Character '\(char)' should be uppercase")
        }

        @Test(arguments: Array(UInt8.ascii.a...UInt8.ascii.z))
        func `lowercase letters a-z are recognized`(ascii: UInt8) {
            let char = Character(UnicodeScalar(ascii))
            #expect(char.ascii.isLetter, "Character '\(char)' should be a letter")
            #expect(char.ascii.isLowercase, "Character '\(char)' should be lowercase")
        }

        @Test(arguments: ["0", "9", " ", "!", "@"])
        func `non-letter characters are not recognized`(char: Character) {
            #expect(!char.ascii.isLetter)
        }
    }

    @Suite
    struct `Character - ASCII Alphanumeric` {
        @Test(arguments: Array("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"))
        func `letters and digits are alphanumeric`(char: Character) {
            #expect(char.ascii.isAlphanumeric, "Character '\(char)' should be alphanumeric")
        }

        @Test(arguments: [" ", "!", "@", "#", "$", "%", "^", "&", "*", "(", ")", "-", "_", "+", "="])
        func `special characters are not alphanumeric`(char: Character) {
            #expect(!char.ascii.isAlphanumeric)
        }
    }

    @Suite
    struct `Character - ASCII Hex Digits` {
        @Test(arguments: Array("0123456789ABCDEFabcdef"))
        func `all valid hex characters`(char: Character) {
            #expect(char.ascii.isHexDigit, "Character '\(char)' should be a hex digit")
        }

        @Test(arguments: ["G", "g", "Z", "z", " ", "!", "@"])
        func `non-hex characters are not recognized`(char: Character) {
            #expect(!char.ascii.isHexDigit)
        }
    }

    @Suite
    struct `Character - ASCII Case` {
        @Test(arguments: Array(UInt8.ascii.A...UInt8.ascii.Z))
        func `uppercase letters A-Z are recognized`(ascii: UInt8) {
            let char = Character(UnicodeScalar(ascii))
            #expect(char.ascii.isUppercase, "Character '\(char)' should be uppercase")
            #expect(!char.ascii.isLowercase, "Character '\(char)' should not be lowercase")
        }

        @Test(arguments: Array(UInt8.ascii.a...UInt8.ascii.z))
        func `lowercase letters a-z are recognized`(ascii: UInt8) {
            let char = Character(UnicodeScalar(ascii))
            #expect(char.ascii.isLowercase, "Character '\(char)' should be lowercase")
            #expect(!char.ascii.isUppercase, "Character '\(char)' should not be uppercase")
        }

        @Test(arguments: ["0", "9", " ", "!", "@", "#"])
        func `non-letter characters are neither uppercase nor lowercase`(char: Character) {
            #expect(!char.ascii.isUppercase)
            #expect(!char.ascii.isLowercase)
        }
    }

    @Suite
    struct `Character - ASCII Validation` {
        @Test
        func `ascii() returns character if valid ASCII`() {
            let char: Character = "A"
            #expect(char.ascii() == "A")
        }

        @Test
        func `ascii() returns nil for non-ASCII`() {
            let char: Character = "🌍"
            #expect(char.ascii() == nil)
        }

        @Test(arguments: Array(0x00...0x7F))
        func `all ASCII bytes validate`(byte: UInt8) {
            let char = Character(UnicodeScalar(byte))
            #expect(char.ascii() != nil)
        }
    }

    @Suite
    struct `Character - ASCII Case Conversion` {
        @Test
        func `ascii(case:) converts to uppercase`() {
            #expect("a".ascii(case: .upper) == "A")
            #expect("z".ascii(case: .upper) == "Z")
        }

        @Test
        func `ascii(case:) converts to lowercase`() {
            #expect("A".ascii(case: .lower) == "a")
            #expect("Z".ascii(case: .lower) == "z")
        }

        @Test
        func `ascii(case:) preserves non-letters`() {
            #expect("5".ascii(case: .upper) == "5")
            #expect(" ".ascii(case: .lower) == " ")
        }

        @Test
        func `ascii(case:) preserves non-ASCII`() {
            #expect("🌍".ascii(case: .upper) == "🌍")
            #expect("é".ascii(case: .lower) == "é")
        }
    }

    @Suite
    struct `Character - ASCII Construction` {
        @Test
        func `init(ascii:) creates character from valid byte`() {
            #expect(Character(ascii: 0x41) == "A")
            #expect(Character(ascii: 0x61) == "a")
            #expect(Character(ascii: 0x30) == "0")
        }

        @Test
        func `init(ascii:) returns nil for non-ASCII byte`() {
            #expect(Character(ascii: 0xFF) == nil)
            #expect(Character(ascii: 0x80) == nil)
        }

        @Test(arguments: Array(0x00...0x7F))
        func `init(ascii:) works for all ASCII bytes`(byte: UInt8) {
            #expect(Character(ascii: byte) != nil)
        }

        @Test
        func `unchecked creates character without validation`() {
            #expect(Character.ascii.unchecked(0x41) == "A")
            #expect(Character.ascii.unchecked(0x61) == "a")
        }

        @Test
        func `round-trip Character to UInt8 and back`() {
            let original: Character = "X"
            let byte = UInt8(ascii: original)!
            let restored = Character(ascii: byte)!
            #expect(restored == original)
        }
    }
}

extension `Performance Tests` {
    @Suite
    struct `Character - Performance` {
        @Test(.timed(threshold: .milliseconds(2000)))
        func `character whitespace check 1M times`() {
            let char: Character = " "
            for _ in 0..<1_000_000 {
                _ = char.ascii.isWhitespace
            }
        }

        @Test(.timed(threshold: .milliseconds(2000)))
        func `character digit check 1M times`() {
            let char: Character = "5"
            for _ in 0..<1_000_000 {
                _ = char.ascii.isDigit
            }
        }

        @Test(.timed(threshold: .milliseconds(2000)))
        func `character letter check 1M times`() {
            let char: Character = "A"
            for _ in 0..<1_000_000 {
                _ = char.ascii.isLetter
            }
        }
    }
}
