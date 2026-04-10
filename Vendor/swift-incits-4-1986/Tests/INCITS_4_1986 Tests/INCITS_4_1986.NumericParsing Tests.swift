// INCITS_4_1986.NumericParsing Tests.swift
// swift-incits-4-1986
//
// Tests for authoritative numeric parsing operations

import StandardsTestSupport
import Testing

@testable import INCITS_4_1986

@Suite
struct `INCITS_4_1986.NumericParsing Tests` {
    @Suite
    struct `Decimal Digit Parsing` {
        @Test
        func `parses digit '0' as 0`() {
            #expect(INCITS_4_1986.NumericParsing.digit(INCITS_4_1986.GraphicCharacters.`0`) == 0)
        }

        @Test
        func `parses digit '1' as 1`() {
            #expect(INCITS_4_1986.NumericParsing.digit(INCITS_4_1986.GraphicCharacters.`1`) == 1)
        }

        @Test
        func `parses digit '9' as 9`() {
            #expect(INCITS_4_1986.NumericParsing.digit(INCITS_4_1986.GraphicCharacters.`9`) == 9)
        }

        @Test
        func `parses all digits 0-9 correctly`() {
            let digits: [(UInt8, UInt8)] = [
                (INCITS_4_1986.GraphicCharacters.`0`, 0),
                (INCITS_4_1986.GraphicCharacters.`1`, 1),
                (INCITS_4_1986.GraphicCharacters.`2`, 2),
                (INCITS_4_1986.GraphicCharacters.`3`, 3),
                (INCITS_4_1986.GraphicCharacters.`4`, 4),
                (INCITS_4_1986.GraphicCharacters.`5`, 5),
                (INCITS_4_1986.GraphicCharacters.`6`, 6),
                (INCITS_4_1986.GraphicCharacters.`7`, 7),
                (INCITS_4_1986.GraphicCharacters.`8`, 8),
                (INCITS_4_1986.GraphicCharacters.`9`, 9),
            ]

            for (digitByte, expectedValue) in digits {
                #expect(INCITS_4_1986.NumericParsing.digit(digitByte) == expectedValue)
            }
        }

        @Test(arguments: [
            INCITS_4_1986.GraphicCharacters.A,
            INCITS_4_1986.GraphicCharacters.a,
            INCITS_4_1986.SPACE.sp,
            UInt8(0x2F),  // Before '0'
            UInt8(0x3A),  // After '9'
        ])
        func `returns nil for non-digit bytes`(byte: UInt8) {
            #expect(INCITS_4_1986.NumericParsing.digit(byte) == nil)
        }
    }

    @Suite
    struct `Hexadecimal Digit Parsing` {
        @Test
        func `parses hex digit '0' as 0`() {
            #expect(INCITS_4_1986.NumericParsing.hexDigit(INCITS_4_1986.GraphicCharacters.`0`) == 0)
        }

        @Test
        func `parses hex digit '9' as 9`() {
            #expect(INCITS_4_1986.NumericParsing.hexDigit(INCITS_4_1986.GraphicCharacters.`9`) == 9)
        }

        @Test
        func `parses hex digit 'A' as 10`() {
            #expect(INCITS_4_1986.NumericParsing.hexDigit(INCITS_4_1986.GraphicCharacters.A) == 10)
        }

        @Test
        func `parses hex digit 'F' as 15`() {
            #expect(INCITS_4_1986.NumericParsing.hexDigit(INCITS_4_1986.GraphicCharacters.F) == 15)
        }

        @Test
        func `parses hex digit 'a' as 10`() {
            #expect(INCITS_4_1986.NumericParsing.hexDigit(INCITS_4_1986.GraphicCharacters.a) == 10)
        }

        @Test
        func `parses hex digit 'f' as 15`() {
            #expect(INCITS_4_1986.NumericParsing.hexDigit(INCITS_4_1986.GraphicCharacters.f) == 15)
        }

        @Test
        func `parses all decimal digits 0-9`() {
            for i in UInt8(0)...UInt8(9) {
                let digitByte = INCITS_4_1986.GraphicCharacters.`0` + i
                #expect(INCITS_4_1986.NumericParsing.hexDigit(digitByte) == i)
            }
        }

        @Test
        func `parses all uppercase hex letters A-F`() {
            for i in UInt8(0)...UInt8(5) {
                let letterByte = INCITS_4_1986.GraphicCharacters.A + i
                #expect(INCITS_4_1986.NumericParsing.hexDigit(letterByte) == 10 + i)
            }
        }

        @Test
        func `parses all lowercase hex letters a-f`() {
            for i in UInt8(0)...UInt8(5) {
                let letterByte = INCITS_4_1986.GraphicCharacters.a + i
                #expect(INCITS_4_1986.NumericParsing.hexDigit(letterByte) == 10 + i)
            }
        }

        @Test(arguments: [
            INCITS_4_1986.GraphicCharacters.G,
            INCITS_4_1986.GraphicCharacters.g,
            INCITS_4_1986.GraphicCharacters.Z,
            INCITS_4_1986.GraphicCharacters.z,
            INCITS_4_1986.SPACE.sp,
            INCITS_4_1986.ControlCharacters.lf,
        ])
        func `returns nil for non-hex bytes`(byte: UInt8) {
            #expect(INCITS_4_1986.NumericParsing.hexDigit(byte) == nil)
        }
    }

    @Suite
    struct `Round Trip Properties` {
        @Test
        func `digit round-trip for 0-9`() {
            for value in UInt8(0)...UInt8(9) {
                let digitByte = INCITS_4_1986.GraphicCharacters.`0` + value
                let parsed = INCITS_4_1986.NumericParsing.digit(digitByte)
                #expect(parsed == value)
            }
        }

        @Test
        func `hexDigit round-trip for 0-15 via uppercase`() {
            let hexChars: [UInt8] = [
                INCITS_4_1986.GraphicCharacters.`0`,
                INCITS_4_1986.GraphicCharacters.`1`,
                INCITS_4_1986.GraphicCharacters.`2`,
                INCITS_4_1986.GraphicCharacters.`3`,
                INCITS_4_1986.GraphicCharacters.`4`,
                INCITS_4_1986.GraphicCharacters.`5`,
                INCITS_4_1986.GraphicCharacters.`6`,
                INCITS_4_1986.GraphicCharacters.`7`,
                INCITS_4_1986.GraphicCharacters.`8`,
                INCITS_4_1986.GraphicCharacters.`9`,
                INCITS_4_1986.GraphicCharacters.A,
                INCITS_4_1986.GraphicCharacters.B,
                INCITS_4_1986.GraphicCharacters.C,
                INCITS_4_1986.GraphicCharacters.D,
                INCITS_4_1986.GraphicCharacters.E,
                INCITS_4_1986.GraphicCharacters.F,
            ]

            for (index, hexChar) in hexChars.enumerated() {
                let parsed = INCITS_4_1986.NumericParsing.hexDigit(hexChar)
                #expect(parsed == UInt8(index))
            }
        }

        @Test
        func `hexDigit round-trip for 0-15 via lowercase`() {
            let hexChars: [UInt8] = [
                INCITS_4_1986.GraphicCharacters.`0`,
                INCITS_4_1986.GraphicCharacters.`1`,
                INCITS_4_1986.GraphicCharacters.`2`,
                INCITS_4_1986.GraphicCharacters.`3`,
                INCITS_4_1986.GraphicCharacters.`4`,
                INCITS_4_1986.GraphicCharacters.`5`,
                INCITS_4_1986.GraphicCharacters.`6`,
                INCITS_4_1986.GraphicCharacters.`7`,
                INCITS_4_1986.GraphicCharacters.`8`,
                INCITS_4_1986.GraphicCharacters.`9`,
                INCITS_4_1986.GraphicCharacters.a,
                INCITS_4_1986.GraphicCharacters.b,
                INCITS_4_1986.GraphicCharacters.c,
                INCITS_4_1986.GraphicCharacters.d,
                INCITS_4_1986.GraphicCharacters.e,
                INCITS_4_1986.GraphicCharacters.f,
            ]

            for (index, hexChar) in hexChars.enumerated() {
                let parsed = INCITS_4_1986.NumericParsing.hexDigit(hexChar)
                #expect(parsed == UInt8(index))
            }
        }
    }

    @Suite
    struct `Case Insensitivity` {
        @Test
        func `uppercase and lowercase hex letters parse to same value`() {
            for i in UInt8(0)...UInt8(5) {
                let upperByte = INCITS_4_1986.GraphicCharacters.A + i
                let lowerByte = INCITS_4_1986.GraphicCharacters.a + i

                let upperValue = INCITS_4_1986.NumericParsing.hexDigit(upperByte)
                let lowerValue = INCITS_4_1986.NumericParsing.hexDigit(lowerByte)

                #expect(upperValue == lowerValue)
                #expect(upperValue == 10 + i)
            }
        }
    }
}
