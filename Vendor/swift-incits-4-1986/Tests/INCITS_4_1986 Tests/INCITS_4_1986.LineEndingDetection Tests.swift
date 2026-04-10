// INCITS_4_1986.LineEndingDetection Tests.swift
// swift-incits-4-1986
//
// Tests for authoritative line ending detection operations

import StandardsTestSupport
import Testing

@testable import INCITS_4_1986

@Suite
struct `INCITS_4_1986.LineEndingDetection Tests` {
    // MARK: - Line Ending Detection Tests

    @Suite
    struct `detect() Method Tests` {
        @Test(arguments: [
            ("line1\nline2", INCITS_4_1986.FormatEffectors.LineEnding.lf),
            ("line1\n", INCITS_4_1986.FormatEffectors.LineEnding.lf),
            ("\n", INCITS_4_1986.FormatEffectors.LineEnding.lf),
            ("test\nmore\nlines", INCITS_4_1986.FormatEffectors.LineEnding.lf),
        ])
        func `detects LF line endings`(input: (String, INCITS_4_1986.FormatEffectors.LineEnding)) {
            let (str, expected) = input
            #expect(INCITS_4_1986.LineEndingDetection.detect(str) == expected)
        }

        @Test(arguments: [
            ("line1\rline2", INCITS_4_1986.FormatEffectors.LineEnding.cr),
            ("line1\r", INCITS_4_1986.FormatEffectors.LineEnding.cr),
            ("\r", INCITS_4_1986.FormatEffectors.LineEnding.cr),
            ("test\rmore\rlines", INCITS_4_1986.FormatEffectors.LineEnding.cr),
        ])
        func `detects CR line endings`(input: (String, INCITS_4_1986.FormatEffectors.LineEnding)) {
            let (str, expected) = input
            #expect(INCITS_4_1986.LineEndingDetection.detect(str) == expected)
        }

        @Test(arguments: [
            ("line1\r\nline2", INCITS_4_1986.FormatEffectors.LineEnding.crlf),
            ("line1\r\n", INCITS_4_1986.FormatEffectors.LineEnding.crlf),
            ("\r\n", INCITS_4_1986.FormatEffectors.LineEnding.crlf),
            ("test\r\nmore\r\nlines", INCITS_4_1986.FormatEffectors.LineEnding.crlf),
        ])
        func `detects CRLF line endings`(input: (String, INCITS_4_1986.FormatEffectors.LineEnding)) {
            let (str, expected) = input
            #expect(INCITS_4_1986.LineEndingDetection.detect(str) == expected)
        }

        @Test(arguments: [
            "no line endings",
            "test",
            "",
            "hello world",
        ])
        func `returns nil when no line endings present`(str: String) {
            #expect(INCITS_4_1986.LineEndingDetection.detect(str) == nil)
        }

        @Test
        func `prioritizes CRLF over individual CR or LF`() {
            // String with CRLF should return .crlf, not .cr or .lf
            #expect(INCITS_4_1986.LineEndingDetection.detect("test\r\nmore") == .crlf)
        }
    }

    // MARK: - Mixed Line Ending Tests

    @Suite
    struct `hasMixedLineEndings() Method Tests` {
        @Test(arguments: [
            "line1\nline2\nline3",  // Consistent LF
            "line1\rline2\rline3",  // Consistent CR
            "line1\r\nline2\r\nline3",  // Consistent CRLF
            "no line endings",  // No line endings
            "",  // Empty string
        ])
        func `returns false for consistent or no line endings`(str: String) {
            #expect(!INCITS_4_1986.LineEndingDetection.hasMixedLineEndings(str))
        }

        @Test(arguments: [
            "line1\nline2\r\nline3",  // LF and CRLF
            "line1\rline2\nline3",  // CR and LF
            "line1\rline2\r\nline3",  // CR and CRLF
            "line1\nline2\rline3\r\n",  // All three types
        ])
        func `returns true for mixed line endings`(str: String) {
            #expect(INCITS_4_1986.LineEndingDetection.hasMixedLineEndings(str))
        }

        @Test
        func `CRLF is distinct from standalone CR and LF`() {
            // CRLF followed by LF should be mixed
            #expect(INCITS_4_1986.LineEndingDetection.hasMixedLineEndings("line1\r\nline2\nline3"))

            // CRLF followed by CR should be mixed
            #expect(INCITS_4_1986.LineEndingDetection.hasMixedLineEndings("line1\r\nline2\rline3"))
        }

        @Test
        func `consecutive CRLF is not mixed`() {
            #expect(!INCITS_4_1986.LineEndingDetection.hasMixedLineEndings("line1\r\nline2\r\n"))
            #expect(!INCITS_4_1986.LineEndingDetection.hasMixedLineEndings("\r\n\r\n"))
        }

        @Test
        func `CR not followed by LF is standalone`() {
            // CR at end of string (not followed by LF) is standalone CR
            #expect(!INCITS_4_1986.LineEndingDetection.hasMixedLineEndings("line1\rline2\r"))
        }
    }

    // MARK: - Edge Cases

    @Suite
    struct `Edge Cases` {
        @Test
        func `empty string has no line endings`() {
            #expect(INCITS_4_1986.LineEndingDetection.detect("") == nil)
            #expect(!INCITS_4_1986.LineEndingDetection.hasMixedLineEndings(""))
        }

        @Test
        func `single LF`() {
            #expect(INCITS_4_1986.LineEndingDetection.detect("\n") == .lf)
        }

        @Test
        func `single CR`() {
            #expect(INCITS_4_1986.LineEndingDetection.detect("\r") == .cr)
        }

        @Test
        func `single CRLF`() {
            #expect(INCITS_4_1986.LineEndingDetection.detect("\r\n") == .crlf)
        }

        @Test
        func `line ending at start`() {
            #expect(INCITS_4_1986.LineEndingDetection.detect("\ntest") == .lf)
            #expect(INCITS_4_1986.LineEndingDetection.detect("\rtest") == .cr)
            #expect(INCITS_4_1986.LineEndingDetection.detect("\r\ntest") == .crlf)
        }

        @Test
        func `line ending at end`() {
            #expect(INCITS_4_1986.LineEndingDetection.detect("test\n") == .lf)
            #expect(INCITS_4_1986.LineEndingDetection.detect("test\r") == .cr)
            #expect(INCITS_4_1986.LineEndingDetection.detect("test\r\n") == .crlf)
        }

        @Test
        func `consecutive line endings`() {
            #expect(INCITS_4_1986.LineEndingDetection.detect("\n\n") == .lf)
            #expect(INCITS_4_1986.LineEndingDetection.detect("\r\r") == .cr)
            #expect(INCITS_4_1986.LineEndingDetection.detect("\r\n\r\n") == .crlf)
        }

        @Test
        func `CR followed by non-LF is standalone CR`() {
            #expect(INCITS_4_1986.LineEndingDetection.detect("\ra") == .cr)
            #expect(INCITS_4_1986.LineEndingDetection.detect("test\r1") == .cr)
        }
    }

    // MARK: - Priority Tests

    @Suite
    struct `Detection Priority Tests` {
        @Test
        func `CRLF takes precedence in detection`() {
            // When CRLF is present, it should be detected first
            #expect(INCITS_4_1986.LineEndingDetection.detect("test\r\n") == .crlf)
            #expect(INCITS_4_1986.LineEndingDetection.detect("a\r\nb") == .crlf)
        }

        @Test
        func `standalone CR without LF following`() {
            // CR not followed by LF should detect as CR
            #expect(INCITS_4_1986.LineEndingDetection.detect("test\rmore") == .cr)
            #expect(INCITS_4_1986.LineEndingDetection.detect("\r") == .cr)
        }

        @Test
        func `standalone LF without CR preceding`() {
            // LF not preceded by CR should detect as LF
            #expect(INCITS_4_1986.LineEndingDetection.detect("test\nmore") == .lf)
            #expect(INCITS_4_1986.LineEndingDetection.detect("\n") == .lf)
        }
    }

    // MARK: - Real World Examples

    @Suite
    struct `Real World Examples` {
        @Test
        func `Unix-style multi-line text`() {
            let text = "#!/bin/bash\necho 'Hello'\necho 'World'\n"
            #expect(INCITS_4_1986.LineEndingDetection.detect(text) == .lf)
            #expect(!INCITS_4_1986.LineEndingDetection.hasMixedLineEndings(text))
        }

        @Test
        func `Windows-style multi-line text`() {
            let text = "Line 1\r\nLine 2\r\nLine 3\r\n"
            #expect(INCITS_4_1986.LineEndingDetection.detect(text) == .crlf)
            #expect(!INCITS_4_1986.LineEndingDetection.hasMixedLineEndings(text))
        }

        @Test
        func `Classic Mac-style multi-line text`() {
            let text = "Line 1\rLine 2\rLine 3\r"
            #expect(INCITS_4_1986.LineEndingDetection.detect(text) == .cr)
            #expect(!INCITS_4_1986.LineEndingDetection.hasMixedLineEndings(text))
        }

        @Test
        func `mixed platform text file`() {
            let text = "Unix line\nWindows line\r\nMac line\r"
            #expect(INCITS_4_1986.LineEndingDetection.hasMixedLineEndings(text))
        }
    }
}
