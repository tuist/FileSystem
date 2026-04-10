// [UInt8]+INCITS_4_1986 Tests.swift
// swift-incits-4-1986
//
// Tests for [UInt8] array extension methods

import StandardsTestSupport
import Testing

@testable import INCITS_4_1986

@Suite
struct `[UInt8] Tests` {
    @Suite
    struct `[UInt8] - API Surface` {
        @Test
        func `byte array has validation method`() {
            let ascii: [UInt8] = [0x48, 0x65, 0x6C, 0x6C, 0x6F]
            #expect(ascii.ascii.isAllASCII)

            let nonAscii: [UInt8] = [0x48, 0xFF]
            #expect(!nonAscii.ascii.isAllASCII)
        }

        @Test
        func `byte array has case conversion method`() {
            let bytes: [UInt8] = [UInt8.ascii.H, .ascii.e, .ascii.l, .ascii.l, .ascii.o]  // "Hello"
            let upper = bytes.ascii(case: .upper)
            #expect(upper == [UInt8.ascii.H, .ascii.E, .ascii.L, .ascii.L, .ascii.O])  // "HELLO"
        }

        @Test
        func `byte array has line ending conversion`() {
            let lf = [UInt8](ascii: .lf)
            #expect(lf == [UInt8.ascii.lf])

            let crlf = [UInt8](ascii: .crlf)
            #expect(crlf == [UInt8.ascii.cr, UInt8.ascii.lf])
        }

        @Test
        func `byte array has string conversion`() {
            let bytes: [UInt8] = [UInt8.ascii.H, .ascii.e, .ascii.l, .ascii.l, .ascii.o]
            #expect([UInt8](ascii: "Hello") == bytes)
        }

        @Test
        func `byte array has whitespaces constant`() {
            let ws = [UInt8].ascii.whitespaces
            #expect(ws.contains(UInt8.ascii.sp))  // Space
            #expect(ws.contains(UInt8.ascii.htab))  // Tab
            #expect(ws.contains(UInt8.ascii.lf))  // LF
            #expect(ws.contains(UInt8.ascii.cr))  // CR
        }
    }
}

extension `Performance Tests` {
    @Suite
    struct `[UInt8] - Performance` {
        @Test(.timed(threshold: .milliseconds(150)))
        func `byte array string conversion 10K times`() {
            for _ in 0..<10000 {
                _ = [UInt8](ascii: "Hello World!")
            }
        }

        @Test(.timed(threshold: .milliseconds(2000)))
        func `byte array case conversion 10K arrays`() {
            let bytes: [UInt8] = Array(repeating: 0x41, count: 100)  // "AAA..."
            for _ in 0..<10000 {
                _ = bytes.ascii(case: Character.Case.lower)
            }
        }

        @Test(
            .timed(threshold: .milliseconds(10000))
        )
        func `byte array validation 10K arrays`() {
            let bytes: [UInt8] = Array(repeating: 0x41, count: 1000)
            for _ in 0..<10000 {
                _ = bytes.ascii.isAllASCII
            }
        }
    }
}
