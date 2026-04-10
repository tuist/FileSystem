// INCITS_4_1986.CharacterClassification Tests.swift
// swift-incits-4-1986
//
// Tests for authoritative character classification predicates

import StandardsTestSupport
import Testing

@testable import INCITS_4_1986

@Suite
struct `INCITS_4_1986.CharacterClassification Tests` {
    @Suite
    struct `Whitespace Classification` {
        @Test(arguments: [
            INCITS_4_1986.SPACE.sp,
            INCITS_4_1986.ControlCharacters.htab,
            INCITS_4_1986.ControlCharacters.lf,
            INCITS_4_1986.ControlCharacters.cr,
        ])
        func `recognizes ASCII whitespace characters`(byte: UInt8) {
            #expect(INCITS_4_1986.CharacterClassification.isWhitespace(byte))
        }

        @Test(arguments: [
            INCITS_4_1986.GraphicCharacters.A,
            INCITS_4_1986.GraphicCharacters.`0`,
            INCITS_4_1986.ControlCharacters.nul,
            INCITS_4_1986.GraphicCharacters.exclamationPoint,
        ])
        func `rejects non-whitespace characters`(byte: UInt8) {
            #expect(!INCITS_4_1986.CharacterClassification.isWhitespace(byte))
        }
    }

    @Suite
    struct `Control Character Classification` {
        @Test(arguments: Array(INCITS_4_1986.ControlCharacters.nul...INCITS_4_1986.ControlCharacters.us))
        func `recognizes control characters 0x00-0x1F`(byte: UInt8) {
            #expect(INCITS_4_1986.CharacterClassification.isControl(byte))
        }

        @Test
        func `recognizes DEL as control character`() {
            #expect(INCITS_4_1986.CharacterClassification.isControl(INCITS_4_1986.ControlCharacters.del))
        }

        @Test(arguments: Array(INCITS_4_1986.SPACE.sp...UInt8(0x7E)))
        func `rejects printable characters as control`(byte: UInt8) {
            #expect(!INCITS_4_1986.CharacterClassification.isControl(byte))
        }
    }

    @Suite
    struct `Digit Classification` {
        @Test(arguments: Array(INCITS_4_1986.GraphicCharacters.`0`...INCITS_4_1986.GraphicCharacters.`9`))
        func `recognizes ASCII digits 0-9`(byte: UInt8) {
            #expect(INCITS_4_1986.CharacterClassification.isDigit(byte))
        }

        @Test(arguments: [
            INCITS_4_1986.GraphicCharacters.A,
            INCITS_4_1986.GraphicCharacters.a,
            INCITS_4_1986.SPACE.sp,
            UInt8(0x2F),  // Before '0'
            UInt8(0x3A),  // After '9'
        ])
        func `rejects non-digit characters`(byte: UInt8) {
            #expect(!INCITS_4_1986.CharacterClassification.isDigit(byte))
        }
    }

    @Suite
    struct `Letter Classification` {
        @Test(arguments: Array(INCITS_4_1986.GraphicCharacters.A...INCITS_4_1986.GraphicCharacters.Z))
        func `recognizes uppercase letters A-Z`(byte: UInt8) {
            #expect(INCITS_4_1986.CharacterClassification.isLetter(byte))
            #expect(INCITS_4_1986.CharacterClassification.isUppercase(byte))
            #expect(!INCITS_4_1986.CharacterClassification.isLowercase(byte))
        }

        @Test(arguments: Array(INCITS_4_1986.GraphicCharacters.a...INCITS_4_1986.GraphicCharacters.z))
        func `recognizes lowercase letters a-z`(byte: UInt8) {
            #expect(INCITS_4_1986.CharacterClassification.isLetter(byte))
            #expect(INCITS_4_1986.CharacterClassification.isLowercase(byte))
            #expect(!INCITS_4_1986.CharacterClassification.isUppercase(byte))
        }

        @Test(arguments: [
            INCITS_4_1986.GraphicCharacters.`0`,
            INCITS_4_1986.SPACE.sp,
            INCITS_4_1986.GraphicCharacters.exclamationPoint,
            UInt8(0x40),  // Before 'A'
            UInt8(0x5B),  // After 'Z'
            UInt8(0x60),  // Before 'a'
            UInt8(0x7B),  // After 'z'
        ])
        func `rejects non-letter characters`(byte: UInt8) {
            #expect(!INCITS_4_1986.CharacterClassification.isLetter(byte))
        }
    }

    @Suite
    struct `Alphanumeric Classification` {
        @Test(
            arguments:
                Array(INCITS_4_1986.GraphicCharacters.`0`...INCITS_4_1986.GraphicCharacters.`9`)
                + Array(INCITS_4_1986.GraphicCharacters.A...INCITS_4_1986.GraphicCharacters.Z)
                + Array(INCITS_4_1986.GraphicCharacters.a...INCITS_4_1986.GraphicCharacters.z)
        )
        func `recognizes alphanumeric characters`(byte: UInt8) {
            #expect(INCITS_4_1986.CharacterClassification.isAlphanumeric(byte))
        }

        @Test(arguments: [
            INCITS_4_1986.SPACE.sp,
            INCITS_4_1986.GraphicCharacters.exclamationPoint,
            INCITS_4_1986.ControlCharacters.lf,
            UInt8(0x40),  // @
            UInt8(0x5B),  // [
            UInt8(0x60),  // `
        ])
        func `rejects non-alphanumeric characters`(byte: UInt8) {
            #expect(!INCITS_4_1986.CharacterClassification.isAlphanumeric(byte))
        }
    }

    @Suite
    struct `Visible Character Classification` {
        @Test(arguments: Array(INCITS_4_1986.GraphicCharacters.exclamationPoint...UInt8(0x7E)))
        func `recognizes visible characters 0x21-0x7E`(byte: UInt8) {
            #expect(INCITS_4_1986.CharacterClassification.isVisible(byte))
        }

        @Test
        func `rejects SPACE as visible`() {
            #expect(!INCITS_4_1986.CharacterClassification.isVisible(INCITS_4_1986.SPACE.sp))
        }

        @Test(
            arguments: Array(INCITS_4_1986.ControlCharacters.nul...INCITS_4_1986.ControlCharacters.us) + [
                INCITS_4_1986.ControlCharacters.del
            ])
        func `rejects control characters as visible`(byte: UInt8) {
            #expect(!INCITS_4_1986.CharacterClassification.isVisible(byte))
        }
    }

    @Suite
    struct `Printable Character Classification` {
        @Test(arguments: Array(INCITS_4_1986.SPACE.sp...UInt8(0x7E)))
        func `recognizes printable characters 0x20-0x7E`(byte: UInt8) {
            #expect(INCITS_4_1986.CharacterClassification.isPrintable(byte))
        }

        @Test
        func `includes SPACE as printable`() {
            #expect(INCITS_4_1986.CharacterClassification.isPrintable(INCITS_4_1986.SPACE.sp))
        }

        @Test(
            arguments: Array(INCITS_4_1986.ControlCharacters.nul...INCITS_4_1986.ControlCharacters.us) + [
                INCITS_4_1986.ControlCharacters.del
            ])
        func `rejects control characters as printable`(byte: UInt8) {
            #expect(!INCITS_4_1986.CharacterClassification.isPrintable(byte))
        }
    }

    @Suite
    struct `Hexadecimal Digit Classification` {
        @Test(arguments: Array(INCITS_4_1986.GraphicCharacters.`0`...INCITS_4_1986.GraphicCharacters.`9`))
        func `recognizes hex digits 0-9`(byte: UInt8) {
            #expect(INCITS_4_1986.CharacterClassification.isHexDigit(byte))
        }

        @Test(arguments: Array(INCITS_4_1986.GraphicCharacters.A...INCITS_4_1986.GraphicCharacters.F))
        func `recognizes hex digits A-F`(byte: UInt8) {
            #expect(INCITS_4_1986.CharacterClassification.isHexDigit(byte))
        }

        @Test(arguments: Array(INCITS_4_1986.GraphicCharacters.a...INCITS_4_1986.GraphicCharacters.f))
        func `recognizes hex digits a-f`(byte: UInt8) {
            #expect(INCITS_4_1986.CharacterClassification.isHexDigit(byte))
        }

        @Test(arguments: [
            INCITS_4_1986.GraphicCharacters.G,
            INCITS_4_1986.GraphicCharacters.g,
            INCITS_4_1986.GraphicCharacters.Z,
            INCITS_4_1986.GraphicCharacters.z,
            INCITS_4_1986.SPACE.sp,
        ])
        func `rejects non-hex characters`(byte: UInt8) {
            #expect(!INCITS_4_1986.CharacterClassification.isHexDigit(byte))
        }
    }

    @Suite
    struct `Mutual Exclusivity` {
        @Test
        func `control and printable are mutually exclusive`() {
            for byte in UInt8(0)...UInt8(127) {
                let isControl = INCITS_4_1986.CharacterClassification.isControl(byte)
                let isPrintable = INCITS_4_1986.CharacterClassification.isPrintable(byte)
                #expect(isControl != isPrintable, "Byte \(byte) should be either control or printable, not both")
            }
        }

        @Test
        func `every ASCII byte is either control or printable`() {
            for byte in UInt8(0)...UInt8(127) {
                let isControl = INCITS_4_1986.CharacterClassification.isControl(byte)
                let isPrintable = INCITS_4_1986.CharacterClassification.isPrintable(byte)
                #expect(isControl || isPrintable, "Byte \(byte) must be either control or printable")
            }
        }

        @Test
        func `uppercase and lowercase are mutually exclusive`() {
            for byte in UInt8(0)...UInt8(127) {
                let isUpper = INCITS_4_1986.CharacterClassification.isUppercase(byte)
                let isLower = INCITS_4_1986.CharacterClassification.isLowercase(byte)
                #expect(!(isUpper && isLower), "Byte \(byte) cannot be both uppercase and lowercase")
            }
        }

        @Test
        func `letter implies alphanumeric`() {
            for byte in UInt8(0)...UInt8(127) {
                if INCITS_4_1986.CharacterClassification.isLetter(byte) {
                    #expect(INCITS_4_1986.CharacterClassification.isAlphanumeric(byte))
                }
            }
        }

        @Test
        func `digit implies alphanumeric`() {
            for byte in UInt8(0)...UInt8(127) {
                if INCITS_4_1986.CharacterClassification.isDigit(byte) {
                    #expect(INCITS_4_1986.CharacterClassification.isAlphanumeric(byte))
                }
            }
        }
    }

    @Suite
    struct `Boundary Conditions` {
        @Test
        func `digit boundaries are precise`() {
            #expect(!INCITS_4_1986.CharacterClassification.isDigit(UInt8(0x2F)))  // Before '0'
            #expect(INCITS_4_1986.CharacterClassification.isDigit(UInt8(0x30)))  // '0'
            #expect(INCITS_4_1986.CharacterClassification.isDigit(UInt8(0x39)))  // '9'
            #expect(!INCITS_4_1986.CharacterClassification.isDigit(UInt8(0x3A)))  // After '9'
        }

        @Test
        func `letter boundaries are precise`() {
            #expect(!INCITS_4_1986.CharacterClassification.isLetter(UInt8(0x40)))  // Before 'A'
            #expect(INCITS_4_1986.CharacterClassification.isLetter(UInt8(0x41)))  // 'A'
            #expect(INCITS_4_1986.CharacterClassification.isLetter(UInt8(0x5A)))  // 'Z'
            #expect(!INCITS_4_1986.CharacterClassification.isLetter(UInt8(0x5B)))  // After 'Z'
            #expect(!INCITS_4_1986.CharacterClassification.isLetter(UInt8(0x60)))  // Before 'a'
            #expect(INCITS_4_1986.CharacterClassification.isLetter(UInt8(0x61)))  // 'a'
            #expect(INCITS_4_1986.CharacterClassification.isLetter(UInt8(0x7A)))  // 'z'
            #expect(!INCITS_4_1986.CharacterClassification.isLetter(UInt8(0x7B)))  // After 'z'
        }

        @Test
        func `visible boundaries are precise`() {
            #expect(!INCITS_4_1986.CharacterClassification.isVisible(UInt8(0x20)))  // SPACE
            #expect(INCITS_4_1986.CharacterClassification.isVisible(UInt8(0x21)))  // !
            #expect(INCITS_4_1986.CharacterClassification.isVisible(UInt8(0x7E)))  // ~
            #expect(!INCITS_4_1986.CharacterClassification.isVisible(UInt8(0x7F)))  // DEL
        }

        @Test
        func `printable boundaries are precise`() {
            #expect(!INCITS_4_1986.CharacterClassification.isPrintable(UInt8(0x1F)))  // Before SPACE
            #expect(INCITS_4_1986.CharacterClassification.isPrintable(UInt8(0x20)))  // SPACE
            #expect(INCITS_4_1986.CharacterClassification.isPrintable(UInt8(0x7E)))  // ~
            #expect(!INCITS_4_1986.CharacterClassification.isPrintable(UInt8(0x7F)))  // DEL
        }
    }
}
