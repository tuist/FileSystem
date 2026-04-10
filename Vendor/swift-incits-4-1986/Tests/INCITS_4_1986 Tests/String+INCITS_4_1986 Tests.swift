// String+INCITS_4_1986 Tests.swift
// swift-incits-4-1986
//
// Tests for String extension methods

import StandardsTestSupport
import Testing

@testable import INCITS_4_1986

// Note: String conversion tests are in INCITS_4_1986 Tests.swift
// Note: String case conversion tests are in INCITS_4_1986.CaseConversion Tests.swift
// Note: String trimming tests are in INCITS_4_1986.StringOperations Tests.swift
// Note: String normalization tests are in INCITS_4_1986.FormatEffectors.LineEnding Tests.swift

@Suite
struct `String Tests` {
    @Suite
    struct `String - API Surface` {
        @Test
        func `string has ascii conversion method`() {
            let bytes: [UInt8] = [UInt8.ascii.H, .ascii.e, .ascii.l, .ascii.l, .ascii.o]
            let string = String(ascii: bytes)
            #expect(string == "Hello")
        }

        @Test
        func `string has case conversion method`() {
            let str = "Hello"
            #expect(str.ascii(case: .upper) == "HELLO")
            #expect(str.ascii(case: .lower) == "hello")
        }

        @Test
        func `string has trimming method`() {
            let str = "  hello  "
            #expect(str.trimming(Set<Character>.ascii.whitespaces) == "hello")
        }

        @Test
        func `string has normalization method`() {
            let str = "hello\r\nworld"
            #expect(str.normalized(to: .lf) == "hello\nworld")
        }
    }

    // MARK: - Character Classification Tests

    @Suite
    struct `INCITS_4_1986.ASCII - isAllASCII` {
        @Test(arguments: [
            "Hello",
            "test123",
            "ABCDEFGHIJKLMNOPQRSTUVWXYZ",
            "abcdefghijklmnopqrstuvwxyz",
            "0123456789",
            "!@#$%^&*()",
            "",  // Empty string is all ASCII
            " \t\n\r",  // Whitespace
        ])
        func `valid ASCII strings`(str: String) {
            #expect(str.ascii.isAllASCII, "String '\(str)' should be all ASCII")
        }

        @Test(arguments: [
            "Hello🌍",
            "café",
            "日本語",
            "Ñoño",
            "test\u{80}",  // First non-ASCII byte
            "test\u{FF}",  // High byte
        ])
        func `strings with non-ASCII characters`(str: String) {
            #expect(!str.ascii.isAllASCII, "String '\(str)' should contain non-ASCII")
        }
    }

    @Suite
    struct `INCITS_4_1986.ASCII - isAllWhitespace` {
        @Test(arguments: [
            " ",
            "  ",
            "\t",
            "\n",
            "\r",
            " \t\n\r",
            "    \t\t\n\n",
        ])
        func `all whitespace strings`(str: String) {
            #expect(str.ascii.isAllWhitespace, "String '\(str)' should be all whitespace")
        }

        @Test(arguments: [
            "a",
            " a ",
            "  test  ",
            "\thello\t",
        ])
        func `strings with non-whitespace`(str: String) {
            #expect(!str.ascii.isAllWhitespace, "String '\(str)' should not be all whitespace")
        }
    }

    @Suite
    struct `INCITS_4_1986.ASCII - isAllDigits` {
        @Test(arguments: [
            "0",
            "123",
            "0123456789",
            "999",
        ])
        func `all digit strings`(str: String) {
            #expect(str.ascii.isAllDigits, "String '\(str)' should be all digits")
        }

        @Test(arguments: [
            "12a34",
            "test",
            "123 456",
            "1.23",
        ])
        func `strings with non-digits`(str: String) {
            #expect(!str.ascii.isAllDigits, "String '\(str)' should not be all digits")
        }
    }

    @Suite
    struct `INCITS_4_1986.ASCII - isAllLetters` {
        @Test(arguments: [
            "a",
            "ABC",
            "hello",
            "WORLD",
            "AbCdEfG",
        ])
        func `all letter strings`(str: String) {
            #expect(str.ascii.isAllLetters, "String '\(str)' should be all letters")
        }

        @Test(arguments: [
            "hello123",
            "test ",
            "A-B",
            "hello_world",
        ])
        func `strings with non-letters`(str: String) {
            #expect(!str.ascii.isAllLetters, "String '\(str)' should not be all letters")
        }
    }

    @Suite
    struct `INCITS_4_1986.ASCII - isAllAlphanumeric` {
        @Test(arguments: [
            "abc123",
            "ABC",
            "123",
            "Test123",
            "a1b2c3",
        ])
        func `all alphanumeric strings`(str: String) {
            #expect(str.ascii.isAllAlphanumeric, "String '\(str)' should be all alphanumeric")
        }

        @Test(arguments: [
            "hello world",
            "test-123",
            "A_B",
            "test!",
        ])
        func `strings with non-alphanumeric`(str: String) {
            #expect(!str.ascii.isAllAlphanumeric, "String '\(str)' should not be all alphanumeric")
        }
    }

    @Suite
    struct `INCITS_4_1986.ASCII - isAllControl` {
        @Test(arguments: [
            "\0",
            "\0\0",
            "\t",
            "\n",
            "\r",
            "\t\n\r",
            "\u{7F}",  // DEL
        ])
        func `all control character strings`(str: String) {
            #expect(str.ascii.isAllControl, "String should be all control characters")
        }

        @Test(arguments: [
            "a",
            " ",  // SPACE is not control
            "\ta\n",
            "hello",
        ])
        func `strings with non-control`(str: String) {
            #expect(!str.ascii.isAllControl, "String should not be all control characters")
        }
    }

    @Suite
    struct `INCITS_4_1986.ASCII - isAllVisible` {
        @Test(arguments: [
            "!",
            "~",
            "ABC",
            "abc123!@#",
        ])
        func `all visible character strings`(str: String) {
            #expect(str.ascii.isAllVisible, "String '\(str)' should be all visible")
        }

        @Test(arguments: [
            " ",  // SPACE is not visible
            "hello world",
            "\t",
            "test ",
        ])
        func `strings with non-visible`(str: String) {
            #expect(!str.ascii.isAllVisible, "String '\(str)' should not be all visible")
        }
    }

    @Suite
    struct `INCITS_4_1986.ASCII - isAllPrintable` {
        @Test(arguments: [
            " ",
            "hello world",
            "!@#$%",
            "ABC 123",
        ])
        func `all printable character strings`(str: String) {
            #expect(str.ascii.isAllPrintable, "String '\(str)' should be all printable")
        }

        @Test(arguments: [
            "\t",
            "\n",
            "hello\nworld",
            "\0",
        ])
        func `strings with non-printable`(str: String) {
            #expect(!str.ascii.isAllPrintable, "String '\(str)' should not be all printable")
        }
    }

    @Suite
    struct `INCITS_4_1986.ASCII - containsNonASCII` {
        @Test(arguments: [
            "Hello🌍",
            "café",
            "日本語",
            "test\u{80}",
        ])
        func `strings containing non-ASCII`(str: String) {
            #expect(str.ascii.containsNonASCII, "String '\(str)' should contain non-ASCII")
        }

        @Test(arguments: [
            "",
            "Hello",
            "test123",
            "!@#$%",
        ])
        func `pure ASCII strings`(str: String) {
            #expect(!str.ascii.containsNonASCII, "String '\(str)' should not contain non-ASCII")
        }
    }

    @Suite
    struct `INCITS_4_1986.ASCII - containsHexDigit` {
        @Test(arguments: [
            "0",
            "9",
            "A",
            "F",
            "a",
            "f",
            "hello",  // contains 'e'
            "FACE",
            "test0",
        ])
        func `strings containing hex digits`(str: String) {
            #expect(str.ascii.containsHexDigit, "String '\(str)' should contain hex digit")
        }

        @Test(arguments: [
            "",
            "xyz",
            "!!!",
            "   ",
        ])
        func `strings without hex digits`(str: String) {
            #expect(!str.ascii.containsHexDigit, "String '\(str)' should not contain hex digit")
        }
    }

    // MARK: - Case Validation Tests

    @Suite
    struct `INCITS_4_1986.ASCII - isAllLowercase` {
        @Test(arguments: [
            "abc",
            "hello",
            "test123",  // Non-letters don't affect the check
            "hello world",
            "a-b-c",
        ])
        func `all lowercase strings`(str: String) {
            #expect(str.ascii.isAllLowercase, "String '\(str)' should be all lowercase")
        }

        @Test(arguments: [
            "ABC",
            "Hello",
            "tEst",
            "WORLD",
        ])
        func `strings with uppercase letters`(str: String) {
            #expect(!str.ascii.isAllLowercase, "String '\(str)' should not be all lowercase")
        }

        @Test
        func `empty string is all lowercase`() {
            #expect("".ascii.isAllLowercase)
        }

        @Test
        func `non-letter string is all lowercase`() {
            #expect("123!@#".ascii.isAllLowercase)
        }
    }

    @Suite
    struct `INCITS_4_1986.ASCII - isAllUppercase` {
        @Test(arguments: [
            "ABC",
            "HELLO",
            "TEST123",
            "HELLO WORLD",
            "A-B-C",
        ])
        func `all uppercase strings`(str: String) {
            #expect(str.ascii.isAllUppercase, "String '\(str)' should be all uppercase")
        }

        @Test(arguments: [
            "abc",
            "Hello",
            "TeSt",
            "world",
        ])
        func `strings with lowercase letters`(str: String) {
            #expect(!str.ascii.isAllUppercase, "String '\(str)' should not be all uppercase")
        }

        @Test
        func `empty string is all uppercase`() {
            #expect("".ascii.isAllUppercase)
        }

        @Test
        func `non-letter string is all uppercase`() {
            #expect("123!@#".ascii.isAllUppercase)
        }
    }

    // MARK: - Case Convenience Method Tests

    @Suite
    struct `INCITS_4_1986.ASCII - uppercased and lowercased` {
        @Test(arguments: [
            ("hello", "HELLO"),
            ("world", "WORLD"),
            ("TeSt", "TEST"),
            ("abc123", "ABC123"),
            ("", ""),
        ])
        func `uppercased converts correctly`(input: String, expected: String) {
            #expect(input.ascii.uppercased() == expected)
        }

        @Test(arguments: [
            ("HELLO", "hello"),
            ("WORLD", "world"),
            ("TeSt", "test"),
            ("ABC123", "abc123"),
            ("", ""),
        ])
        func `lowercased converts correctly`(input: String, expected: String) {
            #expect(input.ascii.lowercased() == expected)
        }

        @Test
        func `convenience methods match ascii(case:)`() {
            let test = "Hello World"
            #expect(test.ascii.uppercased() == test.ascii(case: .upper))
            #expect(test.ascii.lowercased() == test.ascii(case: .lower))
        }

        @Test
        func `non-ASCII preserved in case methods`() {
            let test = "Hello🌍"
            #expect(test.ascii.uppercased() == "HELLO🌍")
            #expect(test.ascii.lowercased() == "hello🌍")
        }
    }

    // MARK: - Line Ending Constants Tests

    @Suite
    struct `INCITS_4_1986.ASCII - Line Ending Constants` {
        @Test
        func `lf constant is correct`() {
            let lf: String = .ascii.lf
            #expect(lf == "\n")
            #expect(lf.count == 1)
        }

        @Test
        func `cr constant is correct`() {
            let cr: String = .ascii.cr
            #expect(cr == "\r")
            #expect(cr.count == 1)
        }

        @Test
        func `crlf constant is correct`() {
            let crlf: String = .ascii.crlf
            #expect(crlf == "\r\n")
            #expect(crlf.utf8.count == 2)
        }

        @Test
        func `constants match byte values`() {
            #expect(.ascii.lf == String(decoding: [UInt8.ascii.lf], as: UTF8.self))
            #expect(.ascii.cr == String(decoding: [UInt8.ascii.cr], as: UTF8.self))
            #expect(.ascii.crlf == String(decoding: INCITS_4_1986.ControlCharacters.crlf, as: UTF8.self))
        }
    }

    // MARK: - Line Ending Detection Tests

    @Suite
    struct `INCITS_4_1986.ASCII - containsMixedLineEndings` {
        @Test(arguments: [
            "line1\nline2\r\nline3",  // LF and CRLF
            "line1\rline2\nline3",  // CR and LF
            "line1\nline2\rline3\r\nline4",  // All three
        ])
        func `strings with mixed line endings`(str: String) {
            #expect(str.ascii.containsMixedLineEndings, "String should have mixed line endings")
        }

        @Test(arguments: [
            "",
            "hello",
            "line1\nline2\nline3",  // Only LF
            "line1\rline2\rline3",  // Only CR
            "line1\r\nline2\r\nline3",  // Only CRLF
        ])
        func `strings with consistent or no line endings`(str: String) {
            #expect(!str.ascii.containsMixedLineEndings, "String should not have mixed line endings")
        }
    }

    @Suite
    struct `INCITS_4_1986.ASCII - detectedLineEnding` {
        @Test(arguments: [
            ("line1\nline2", INCITS_4_1986.FormatEffectors.LineEnding.lf),
            ("line1\n", .lf),
            ("\n", .lf),
        ])
        func `detects LF`(str: String, expected: INCITS_4_1986.FormatEffectors.LineEnding) {
            #expect(str.ascii.detectedLineEnding() == expected)
        }

        @Test(arguments: [
            ("line1\rline2", INCITS_4_1986.FormatEffectors.LineEnding.cr),
            ("line1\r", .cr),
            ("\r", .cr),
        ])
        func `detects CR`(str: String, expected: INCITS_4_1986.FormatEffectors.LineEnding) {
            #expect(str.ascii.detectedLineEnding() == expected)
        }

        @Test(arguments: [
            ("line1\r\nline2", INCITS_4_1986.FormatEffectors.LineEnding.crlf),
            ("line1\r\n", .crlf),
            ("\r\n", .crlf),
        ])
        func `detects CRLF`(str: String, expected: INCITS_4_1986.FormatEffectors.LineEnding) {
            #expect(str.ascii.detectedLineEnding() == expected)
        }

        @Test
        func `returns nil when no line endings`() {
            #expect("hello world".ascii.detectedLineEnding() == nil)
            #expect("".ascii.detectedLineEnding() == nil)
        }

        @Test
        func `prioritizes CRLF over individual CR or LF`() {
            // When CRLF is present, it should be detected first
            let str = "line1\r\nline2\nline3"
            #expect(str.ascii.detectedLineEnding() == .crlf)
        }
    }
}

extension `Performance Tests` {
    @Suite
    struct `String - Performance` {
        @Test(.timed(threshold: .milliseconds(150)))
        func `string to bytes conversion 10K times`() {
            let str = "Hello World!"
            for _ in 0..<10000 {
                _ = [UInt8](ascii: str)
            }
        }

        @Test(.timed(threshold: .milliseconds(150)))
        func `bytes to string conversion 10K times`() {
            let bytes: [UInt8] = [UInt8.ascii.H, .ascii.e, .ascii.l, .ascii.l, .ascii.o]
            for _ in 0..<10000 {
                _ = String(ascii: bytes)
            }
        }
    }
}
