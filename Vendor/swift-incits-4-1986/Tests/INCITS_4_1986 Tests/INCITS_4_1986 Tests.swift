// INCITS_4_1986 Tests.swift
// swift-incits-4-1986
//
// Tests for module-level INCITS_4_1986 namespace

import StandardsTestSupport
import Testing

@testable import INCITS_4_1986

// MARK: - Module Constants

@Suite
struct `INCITS_4_1986 - Constants Tests` {
    @Test
    func `whitespaces set contains exactly 4 characters`() {
        #expect(INCITS_4_1986.whitespaces.count == 4)
    }

    @Test
    func `whitespaces contains SPACE, TAB, LF, CR`() {
        #expect(INCITS_4_1986.whitespaces.contains(UInt8.ascii.sp))  // SPACE
        #expect(INCITS_4_1986.whitespaces.contains(UInt8.ascii.htab))  // HT
        #expect(INCITS_4_1986.whitespaces.contains(UInt8.ascii.lf))  // LF
        #expect(INCITS_4_1986.whitespaces.contains(UInt8.ascii.cr))  // CR
    }

    @Test
    func `CRLF sequence is correct`() {
        #expect(INCITS_4_1986.ControlCharacters.crlf == [UInt8.ascii.cr, UInt8.ascii.lf])
    }

    @Test
    func `case conversion offset is 0x20`() {
        #expect(INCITS_4_1986.CaseConversion.offset == UInt8.ascii.sp)
        #expect(INCITS_4_1986.CaseConversion.offset == 32)
    }

    @Test
    func `case conversion offset matches letter distance`() {
        let a = UInt8.ascii.a
        let A = UInt8.ascii.A
        #expect(a - A == INCITS_4_1986.CaseConversion.offset)
    }
}

// MARK: - Performance

extension `Performance Tests` {
    @Suite
    struct `INCITS_4_1986 - Performance` {
        @Test(.timed(threshold: .milliseconds(2000)))
        func `whitespaces set lookup 1M times`() {
            let testBytes: [UInt8] = [UInt8.ascii.sp, UInt8.ascii.A, UInt8.ascii.htab, UInt8.ascii.a]
            for _ in 0..<250_000 {
                for byte in testBytes {
                    _ = INCITS_4_1986.whitespaces.contains(byte)
                }
            }
        }
    }
}
