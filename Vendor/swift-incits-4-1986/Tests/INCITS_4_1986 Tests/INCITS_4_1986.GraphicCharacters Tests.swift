// INCITS_4_1986.GraphicCharacters Tests.swift
// swift-incits-4-1986
//
// Tests for INCITS_4_1986.GraphicCharacters (94 characters: 0x21-0x7E)

import StandardsTestSupport
import Testing

@testable import INCITS_4_1986

@Suite
struct `Graphic Characters` {
    @Suite
    struct `Digits Tests` {
        @Test
        func `all digits 0-9 accessible`() {
            #expect(UInt8.ascii.0 == 0x30)
            #expect(UInt8.ascii.1 == 0x31)
            #expect(UInt8.ascii.9 == 0x39)
        }

        @Test(arguments: Array(0...9))
        func `digit constants correct`(digit: Int) {
            let char = Character("\(digit)")
            let byte = UInt8(ascii: char)!
            #expect(byte == 0x30 + UInt8(digit))
        }
    }

    @Suite
    struct `Letters Tests` {
        @Test
        func `uppercase letters accessible`() {
            #expect(UInt8.ascii.A == 0x41)
            #expect(UInt8.ascii.Z == 0x5A)
        }

        @Test
        func `lowercase letters accessible`() {
            #expect(UInt8.ascii.a == 0x61)
            #expect(UInt8.ascii.z == 0x7A)
        }

        @Test(arguments: Array(zip("ABCDEFGHIJKLMNOPQRSTUVWXYZ", UInt8.ascii.A...UInt8.ascii.Z)))
        func `uppercase letters present`(char: Character, expected: UInt8) {
            let byte = UInt8(ascii: char)!
            #expect(byte == expected, "Character '\(char)' should have value 0x\(String(expected, radix: 16))")
        }

        @Test(arguments: Array(zip("abcdefghijklmnopqrstuvwxyz", UInt8.ascii.a...UInt8.ascii.z)))
        func `lowercase letters present`(char: Character, expected: UInt8) {
            let byte = UInt8(ascii: char)!
            #expect(byte == expected, "Character '\(char)' should have value 0x\(String(expected, radix: 16))")
        }
    }

    @Suite
    struct `Punctuation Tests` {
        @Test
        func `common punctuation accessible`() {
            #expect(UInt8.ascii.exclamationPoint == 0x21)
            #expect(UInt8.ascii.period == 0x2E)
            #expect(UInt8.ascii.comma == 0x2C)
            #expect(UInt8.ascii.questionMark == 0x3F)
        }

        @Test
        func `brackets and parentheses accessible`() {
            #expect(UInt8.ascii.leftParenthesis == 0x28)
            #expect(UInt8.ascii.rightParenthesis == 0x29)
            #expect(UInt8.ascii.leftBracket == 0x5B)
            #expect(UInt8.ascii.rightBracket == 0x5D)
        }
    }
}

extension `Performance Tests` {
    @Suite
    struct `Graphic Characters - Performance` {
        @Test(.timed(threshold: .milliseconds(200)))
        func `graphic character access 100K times`() {
            for _ in 0..<100_000 {
                _ = UInt8.ascii.A
                _ = UInt8.ascii.0
                _ = UInt8.ascii.period
            }
        }
    }
}
