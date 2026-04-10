// INCITS_4_1986.Validation Tests.swift
// swift-incits-4-1986
//
// Tests for INCITS_4_1986.isAllASCII validation

import StandardsTestSupport
import Testing

@testable import INCITS_4_1986

@Suite
struct `ASCII Validation Tests` {
    // MARK: - ASCII Validation

    @Suite
    struct `Correctness Tests` {
        @Test
        func `Valid ASCII bytes`() {
            let ascii: [UInt8] = [0, 65, 127]  // All valid ASCII
            #expect(ascii.ascii.isAllASCII)
        }

        @Test
        func `Invalid ASCII bytes`() {
            let nonAscii: [UInt8] = [65, 128, 255]  // Contains non-ASCII
            #expect(!nonAscii.ascii.isAllASCII)
        }

        @Test
        func `Empty array is valid ASCII`() {
            let empty: [UInt8] = []
            #expect(empty.ascii.isAllASCII)
        }

        @Test
        func `Boundary values`() {
            #expect([0].ascii.isAllASCII)  // Minimum ASCII
            #expect([127].ascii.isAllASCII)  // Maximum ASCII
            #expect(![128].ascii.isAllASCII)  // Just above ASCII range
        }
    }

    @Suite
    struct `Boundary Values Tests` {
        @Test(arguments: [UInt8.ascii.nul, 0x01, UInt8.ascii.tilde, UInt8.ascii.del])
        func `valid ASCII bytes`(byte: UInt8) {
            #expect([byte].ascii.isAllASCII, "Byte 0x\(String(byte, radix: 16)) should be valid ASCII")
        }

        @Test(arguments: [0x80, 0x81, 0xFE, 0xFF])
        func `invalid ASCII bytes`(byte: UInt8) {
            #expect(![byte].ascii.isAllASCII, "Byte 0x\(String(byte, radix: 16)) should be invalid ASCII")
        }

        @Test
        func `all valid ASCII bytes pass validation`() {
            let allASCII = Array(UInt8(0)...UInt8(127))
            #expect(allASCII.ascii.isAllASCII)
        }

        @Test
        func `any non-ASCII byte fails validation`() {
            for byte in UInt8(128)...UInt8(255) {
                let mixed = [UInt8.ascii.A, byte, UInt8.ascii.B]
                #expect(!mixed.ascii.isAllASCII, "Array containing 0x\(String(byte, radix: 16)) should fail")
            }
        }
    }
}

// MARK: - Performance

extension `Performance Tests` {
    @Suite
    struct `ASCII Validation - Performance` {
        @Test(.timed(threshold: .milliseconds(2000)))
        func `validate 1M ASCII bytes`() {
            let ascii = Array(repeating: UInt8(65), count: 1_000_000)
            _ = ascii.ascii.isAllASCII
        }

        @Test(.timed(threshold: .milliseconds(150)))
        func `validate 1M mixed bytes - early exit`() {
            var bytes = Array(repeating: UInt8(65), count: 1_000_000)
            bytes[100] = 128  // Non-ASCII early in array
            _ = bytes.ascii.isAllASCII
        }

        @Test(.timed(threshold: .milliseconds(2000)))
        func `validate 1M mixed bytes - late exit`() {
            var bytes = Array(repeating: UInt8(65), count: 1_000_000)
            bytes[999_999] = 128  // Non-ASCII at end
            _ = bytes.ascii.isAllASCII
        }
    }
}
