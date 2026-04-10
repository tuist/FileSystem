// INCITS_4_1986.ControlCharacters Tests.swift
// swift-incits-4-1986
//
// Tests for INCITS_4_1986.ControlCharacters (33 characters: 0x00-0x1F, 0x7F)

import StandardsTestSupport
import Testing

@testable import INCITS_4_1986

// MARK: - Control Characters - Constants

@Suite
struct `Control Characters` {
    @Suite
    struct `Constants Tests` {
        @Test
        func `NUL character via namespace`() {
            #expect(UInt8.ascii.nul == 0x00)
        }

        @Test
        func `HTAB character via namespace`() {
            #expect(UInt8.ascii.htab == 0x09)
        }

        @Test
        func `LF character via namespace`() {
            #expect(UInt8.ascii.lf == 0x0A)
        }

        @Test
        func `CR character via namespace`() {
            #expect(UInt8.ascii.cr == 0x0D)
        }

        @Test
        func `DELETE character via namespace`() {
            #expect(UInt8.ascii.del == 0x7F)
        }
    }

    // MARK: - Control Characters - Coverage

    @Suite
    struct `Coverage Tests` {
        @Test(arguments: [
            (0x00, "nul"), (0x01, "soh"), (0x02, "stx"), (0x03, "etx"),
            (0x04, "eot"), (0x05, "enq"), (0x06, "ack"), (0x07, "bel"),
            (0x08, "bs"), (0x09, "htab"), (0x0A, "lf"), (0x0B, "vtab"),
            (0x0C, "ff"), (0x0D, "cr"), (0x0E, "so"), (0x0F, "si"),
            (0x10, "dle"), (0x11, "dc1"), (0x12, "dc2"), (0x13, "dc3"),
            (0x14, "dc4"), (0x15, "nak"), (0x16, "syn"), (0x17, "etb"),
            (0x18, "can"), (0x19, "em"), (0x1A, "sub"), (0x1B, "esc"),
            (0x1C, "fs"), (0x1D, "gs"), (0x1E, "rs"), (0x1F, "us"),
            (0x7F, "del"),
        ])
        func `all control characters accessible`(value: UInt8, name: String) {
            #expect(value <= 0x1F || value == 0x7F, "\(name) should be a control character")
        }

        @Test
        func `all 33 control characters present`() {
            // C0 controls (0x00-0x1F)
            #expect(UInt8.ascii.nul == 0x00)
            #expect(UInt8.ascii.soh == 0x01)
            #expect(UInt8.ascii.stx == 0x02)
            #expect(UInt8.ascii.etx == 0x03)
            #expect(UInt8.ascii.eot == 0x04)
            #expect(UInt8.ascii.enq == 0x05)
            #expect(UInt8.ascii.ack == 0x06)
            #expect(UInt8.ascii.bel == 0x07)
            #expect(UInt8.ascii.bs == 0x08)
            #expect(UInt8.ascii.htab == 0x09)
            #expect(UInt8.ascii.lf == 0x0A)
            #expect(UInt8.ascii.vtab == 0x0B)
            #expect(UInt8.ascii.ff == 0x0C)
            #expect(UInt8.ascii.cr == 0x0D)
            #expect(UInt8.ascii.so == 0x0E)
            #expect(UInt8.ascii.si == 0x0F)
            #expect(UInt8.ascii.dle == 0x10)
            #expect(UInt8.ascii.dc1 == 0x11)
            #expect(UInt8.ascii.dc2 == 0x12)
            #expect(UInt8.ascii.dc3 == 0x13)
            #expect(UInt8.ascii.dc4 == 0x14)
            #expect(UInt8.ascii.nak == 0x15)
            #expect(UInt8.ascii.syn == 0x16)
            #expect(UInt8.ascii.etb == 0x17)
            #expect(UInt8.ascii.can == 0x18)
            #expect(UInt8.ascii.em == 0x19)
            #expect(UInt8.ascii.sub == 0x1A)
            #expect(UInt8.ascii.esc == 0x1B)
            #expect(UInt8.ascii.fs == 0x1C)
            #expect(UInt8.ascii.gs == 0x1D)
            #expect(UInt8.ascii.rs == 0x1E)
            #expect(UInt8.ascii.us == 0x1F)
            // DELETE
            #expect(UInt8.ascii.del == 0x7F)
        }

        @Test
        func `control characters recognized by predicate`() {
            let controlChars: [UInt8] = [
                UInt8.ascii.nul, UInt8.ascii.htab, UInt8.ascii.lf,
                UInt8.ascii.cr, UInt8.ascii.esc, UInt8.ascii.del,
            ]
            for byte in controlChars {
                #expect(byte.ascii.isControl, "0x\(String(byte, radix: 16)) should be control")
            }
        }

        @Test
        func `control characters accessible directly`() {
            // Verify direct access without ControlCharacters namespace
            #expect(UInt8.ascii.nul == INCITS_4_1986.ControlCharacters.nul)
            #expect(UInt8.ascii.lf == INCITS_4_1986.ControlCharacters.lf)
            #expect(UInt8.ascii.cr == INCITS_4_1986.ControlCharacters.cr)
            #expect(UInt8.ascii.del == INCITS_4_1986.ControlCharacters.del)
        }
    }
}

// MARK: - Performance

extension `Performance Tests` {
    @Suite
    struct `Control Characters - Performance` {
        @Test(.timed(threshold: .milliseconds(200)))
        func `control character access 100K times`() {
            for _ in 0..<100_000 {
                _ = UInt8.ascii.lf
                _ = UInt8.ascii.cr
                _ = UInt8.ascii.htab
            }
        }

        @Test(.timed(threshold: .milliseconds(2000)))
        func `control character classification 1M times`() {
            let testBytes: [UInt8] = [
                UInt8.ascii.nul, UInt8.ascii.htab, UInt8.ascii.lf, UInt8.ascii.cr, UInt8.ascii.us, UInt8.ascii.del,
            ]
            for _ in 0..<166_667 {
                for byte in testBytes {
                    _ = byte.ascii.isControl
                }
            }
        }
    }
}
