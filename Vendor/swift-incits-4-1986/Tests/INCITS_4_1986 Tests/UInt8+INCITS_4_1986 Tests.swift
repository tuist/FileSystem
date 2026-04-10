// UInt8+INCITS_4_1986 Tests.swift
// swift-incits-4-1986
//
// Tests for UInt8 ASCII namespace and predicates

import StandardsTestSupport
import Testing

@testable import INCITS_4_1986

// Note: UInt8 constant tests are in INCITS_4_1986.GraphicCharacters Tests, INCITS_4_1986.ControlCharacters Tests, etc.
// Note: UInt8 case conversion tests are in INCITS_4_1986.CaseConversion Tests.swift

@Suite
struct `UInt8 Tests` {
    @Suite
    struct `UInt8 - ASCII Predicates` {
        @Test(arguments: [UInt8.ascii.htab, UInt8.ascii.lf, UInt8.ascii.cr, UInt8.ascii.sp])
        func `whitespace bytes recognized`(byte: UInt8) {
            #expect(byte.ascii.isWhitespace)
        }

        @Test(arguments: Array(UInt8.ascii.0...UInt8.ascii.9))
        func `digit bytes recognized`(byte: UInt8) {
            #expect(byte.ascii.isDigit)
        }

        @Test(arguments: Array(UInt8.ascii.A...UInt8.ascii.Z))
        func `uppercase letters recognized`(byte: UInt8) {
            #expect(byte.ascii.isUppercase)
            #expect(byte.ascii.isLetter)
        }

        @Test(arguments: Array(UInt8.ascii.a...UInt8.ascii.z))
        func `lowercase letters recognized`(byte: UInt8) {
            #expect(byte.ascii.isLowercase)
            #expect(byte.ascii.isLetter)
        }

        @Test(arguments: Array(UInt8.ascii.nul...UInt8.ascii.us) + [UInt8.ascii.del])
        func `control characters recognized`(byte: UInt8) {
            #expect(byte.ascii.isControl)
        }

        @Test(arguments: Array(UInt8.ascii.sp...UInt8.ascii.tilde))
        func `printable characters recognized`(byte: UInt8) {
            #expect(byte.ascii.isPrintable)
        }

        @Test(arguments: Array(UInt8.ascii.exclamationPoint...UInt8.ascii.tilde))
        func `visible characters recognized`(byte: UInt8) {
            #expect(byte.ascii.isVisible)
        }
    }

    @Suite
    struct `UInt8 - Character Conversion` {
        @Test
        func `convert ASCII character to byte`() {
            #expect(UInt8(ascii: "A") == UInt8.ascii.A)
            #expect(UInt8(ascii: "0") == UInt8.ascii.0)
            #expect(UInt8(ascii: " ") == UInt8.ascii.sp)
        }

        @Test
        func `non-ASCII character returns nil`() {
            #expect(UInt8(ascii: "é") == nil)
            #expect(UInt8(ascii: "中") == nil)
        }
    }
}

extension `Performance Tests` {
    @Suite
    struct `UInt8 - Performance` {
        @Test(.timed(threshold: .milliseconds(2000)))
        func `byte predicate checks 1M times`() {
            let byte: UInt8 = 65
            for _ in 0..<1_000_000 {
                _ = byte.ascii.isLetter
                _ = byte.ascii.isUppercase
                _ = byte.ascii.isPrintable
            }
        }

        @Test(.timed(threshold: .milliseconds(300)))
        func `character to byte conversion 100K times`() {
            for _ in 0..<100_000 {
                _ = UInt8(ascii: "A" as Character)
                _ = UInt8(ascii: "0" as Character)
                _ = UInt8(ascii: " " as Character)
            }
        }
    }
}
