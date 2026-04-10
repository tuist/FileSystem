// INCITS_4_1986.SPACE Tests.swift
// swift-incits-4-1986
//
// Tests for INCITS_4_1986.SPACE character

import StandardsTestSupport
import Testing

@testable import INCITS_4_1986

@Suite
struct SPACE {
    // MARK: - SPACE Character

    @Suite
    struct `Character Tests` {
        @Test
        func `SPACE constant is 0x20`() {
            #expect(INCITS_4_1986.SPACE.sp == 0x20)
            #expect(UInt8.ascii.sp == 0x20)
        }

        @Test
        func `SPACE is recognized as whitespace`() {
            let sp = UInt8.ascii.sp
            #expect(sp.ascii.isWhitespace)
        }

        @Test
        func `SPACE is printable`() {
            let sp = UInt8.ascii.sp
            #expect(sp.ascii.isPrintable)
        }

        @Test
        func `SPACE is not a control character`() {
            let sp = UInt8.ascii.sp
            #expect(!sp.ascii.isControl)
        }

        @Test
        func `SPACE is not visible (visible = graphic characters only)`() {
            let sp = UInt8.ascii.sp
            #expect(!sp.ascii.isVisible, "SPACE is printable but not visible (visible = 0x21-0x7E)")
        }

        @Test
        func `SPACE accessible directly without namespace`() {
            #expect(UInt8.ascii.sp == INCITS_4_1986.SPACE.sp)
        }
    }
}

// MARK: - Performance

extension `Performance Tests` {
    @Suite
    struct `SPACE - Performance` {
        @Test(.timed(threshold: .milliseconds(2000)))
        func `SPACE access 1M times`() {
            for _ in 0..<1_000_000 {
                _ = UInt8.ascii.sp
            }
        }

        @Test(.timed(threshold: .milliseconds(2000)))
        func `SPACE whitespace check 1M times`() {
            let sp = UInt8.ascii.sp
            for _ in 0..<1_000_000 {
                _ = sp.ascii.isWhitespace
            }
        }
    }
}
