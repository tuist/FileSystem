// INCITS_4_1986.FormatEffectors.LineEnding+INCITS_4_1986 Tests.swift
// swift-incits-4-1986
//
// Tests for INCITS_4_1986.FormatEffectors.LineEnding support

import StandardsTestSupport
import Testing

@testable import INCITS_4_1986

// MARK: - Line Ending Constants

@Suite
struct `INCITS_4_1986.FormatEffectors.LineEnding` {
    @Suite
    struct `INCITS_4_1986.FormatEffectors.LineEnding - Constants` {
        @Test(arguments: [
            (INCITS_4_1986.FormatEffectors.LineEnding.lf, "LF", [UInt8.ascii.lf]),
            (INCITS_4_1986.FormatEffectors.LineEnding.cr, "CR", [UInt8.ascii.cr]),
            (INCITS_4_1986.FormatEffectors.LineEnding.crlf, "CRLF", [UInt8.ascii.cr, UInt8.ascii.lf]),
        ])
        func `line ending conversions to bytes`(
            ending: INCITS_4_1986.FormatEffectors.LineEnding, name: String, expected: [UInt8]
        ) {
            #expect([UInt8](ascii: ending) == expected, "\(name) should produce correct bytes")
        }

        @Test(arguments: [
            (INCITS_4_1986.FormatEffectors.LineEnding.lf, "\n"),
            (INCITS_4_1986.FormatEffectors.LineEnding.cr, "\r"),
            (INCITS_4_1986.FormatEffectors.LineEnding.crlf, "\r\n"),
        ])
        func `line ending conversions to string`(ending: INCITS_4_1986.FormatEffectors.LineEnding, expected: String) {
            #expect(String(ascii: ending) == expected)
        }

        @Test
        func `line ending round-trip through bytes`() {
            for ending in [INCITS_4_1986.FormatEffectors.LineEnding.lf, .cr, .crlf] {
                let bytes = [UInt8](ascii: ending)
                let string = String(ascii: bytes)!
                let expectedString = String(ascii: ending)
                #expect(string == expectedString)
            }
        }
    }
}

// MARK: - Performance

extension `Performance Tests` {
    @Suite
    struct `INCITS_4_1986.FormatEffectors.LineEnding - Performance` {
        @Test(.timed(threshold: .milliseconds(200)))
        func `line ending to bytes conversion 10K times`() {
            for _ in 0..<10000 {
                _ = [UInt8](ascii: .lf)
                _ = [UInt8](ascii: .cr)
                _ = [UInt8](ascii: .crlf)
            }
        }
    }
}
