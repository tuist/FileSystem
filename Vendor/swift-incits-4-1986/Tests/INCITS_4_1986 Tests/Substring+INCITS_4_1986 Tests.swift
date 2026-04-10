// Substring+INCITS_4_1986 Tests.swift
// swift-incits-4-1986
//
// Tests for Substring extension methods

import StandardsTestSupport
import Testing

@testable import INCITS_4_1986

@Suite
struct `Substring Tests` {
    @Suite
    struct `Substring - API Surface` {
        @Test
        func `substring has trimming method`() {
            let str = "  hello  "
            let sub = str[...]
            #expect(sub.trimming(.ascii.whitespaces) == "hello")
        }

        @Test
        func `substring trimming preserves content`() {
            let str = "  test content  "
            let sub = str[...]
            let trimmed = sub.trimming(.ascii.whitespaces)
            #expect(trimmed == "test content")
        }

        @Test
        func `substring trimming with custom character set`() {
            let str = "***hello***"
            let sub = str[...]
            let trimmed = sub.trimming(Set<Character>(["*"]))
            #expect(trimmed == "hello")
        }

        @Test
        func `substring trimming empty string`() {
            let str = ""
            let sub = str[...]
            #expect(sub.trimming(.ascii.whitespaces).isEmpty)
        }

        @Test
        func `substring has case conversion method`() {
            let sub = "Hello"[...]
            #expect(sub.ascii(case: .upper) == "HELLO")
            #expect(sub.ascii(case: .lower) == "hello")
        }
    }

    // MARK: - Character Classification Tests

    @Suite
    struct `Substring.ASCII - isAllASCII` {
        @Test(arguments: [
            "Hello",
            "test123",
            "ABCDEFGHIJKLMNOPQRSTUVWXYZ",
            "abcdefghijklmnopqrstuvwxyz",
            "0123456789",
            "!@#$%^&*()",
            "",  // Empty substring
            " \t\n\r",  // Whitespace
        ])
        func `valid ASCII substrings`(str: String) {
            let sub = str[...]
            #expect(sub.ascii.isAllASCII, "Substring '\(sub)' should be all ASCII")
        }

        @Test(arguments: [
            "Hello🌍",
            "café",
            "日本語",
            "Ñoño",
            "test\u{80}",
            "test\u{FF}",
        ])
        func `substrings with non-ASCII characters`(str: String) {
            let sub = str[...]
            #expect(!sub.ascii.isAllASCII, "Substring '\(sub)' should contain non-ASCII")
        }
    }

    @Suite
    struct `Substring.ASCII - isAllWhitespace` {
        @Test(arguments: [
            " ",
            "  ",
            "\t",
            "\n",
            "\r",
            " \t\n\r",
            "    \t\t\n\n",
        ])
        func `all whitespace substrings`(str: String) {
            let sub = str[...]
            #expect(sub.ascii.isAllWhitespace, "Substring should be all whitespace")
        }

        @Test(arguments: [
            "a",
            " a ",
            "  test  ",
            "\thello\t",
        ])
        func `substrings with non-whitespace`(str: String) {
            let sub = str[...]
            #expect(!sub.ascii.isAllWhitespace, "Substring should not be all whitespace")
        }
    }

    @Suite
    struct `Substring.ASCII - isAllDigits` {
        @Test(arguments: [
            "0",
            "123",
            "0123456789",
            "999",
        ])
        func `all digit substrings`(str: String) {
            let sub = str[...]
            #expect(sub.ascii.isAllDigits, "Substring '\(sub)' should be all digits")
        }

        @Test(arguments: [
            "12a34",
            "test",
            "123 456",
            "1.23",
        ])
        func `substrings with non-digits`(str: String) {
            let sub = str[...]
            #expect(!sub.ascii.isAllDigits, "Substring '\(sub)' should not be all digits")
        }
    }

    @Suite
    struct `Substring.ASCII - isAllLetters` {
        @Test(arguments: [
            "a",
            "ABC",
            "hello",
            "WORLD",
            "AbCdEfG",
        ])
        func `all letter substrings`(str: String) {
            let sub = str[...]
            #expect(sub.ascii.isAllLetters, "Substring '\(sub)' should be all letters")
        }

        @Test(arguments: [
            "hello123",
            "test ",
            "A-B",
            "hello_world",
        ])
        func `substrings with non-letters`(str: String) {
            let sub = str[...]
            #expect(!sub.ascii.isAllLetters, "Substring '\(sub)' should not be all letters")
        }
    }

    @Suite
    struct `Substring.ASCII - isAllAlphanumeric` {
        @Test(arguments: [
            "abc123",
            "ABC",
            "123",
            "Test123",
            "a1b2c3",
        ])
        func `all alphanumeric substrings`(str: String) {
            let sub = str[...]
            #expect(sub.ascii.isAllAlphanumeric, "Substring '\(sub)' should be all alphanumeric")
        }

        @Test(arguments: [
            "hello world",
            "test-123",
            "A_B",
            "test!",
        ])
        func `substrings with non-alphanumeric`(str: String) {
            let sub = str[...]
            #expect(!sub.ascii.isAllAlphanumeric, "Substring '\(sub)' should not be all alphanumeric")
        }
    }

    @Suite
    struct `Substring.ASCII - isAllControl` {
        @Test(arguments: [
            "\0",
            "\0\0",
            "\t",
            "\n",
            "\r",
            "\t\n\r",
            "\u{7F}",
        ])
        func `all control character substrings`(str: String) {
            let sub = str[...]
            #expect(sub.ascii.isAllControl, "Substring should be all control characters")
        }

        @Test(arguments: [
            "a",
            " ",
            "\ta\n",
            "hello",
        ])
        func `substrings with non-control`(str: String) {
            let sub = str[...]
            #expect(!sub.ascii.isAllControl, "Substring should not be all control characters")
        }
    }

    @Suite
    struct `Substring.ASCII - isAllVisible` {
        @Test(arguments: [
            "!",
            "~",
            "ABC",
            "abc123!@#",
        ])
        func `all visible character substrings`(str: String) {
            let sub = str[...]
            #expect(sub.ascii.isAllVisible, "Substring '\(sub)' should be all visible")
        }

        @Test(arguments: [
            " ",
            "hello world",
            "\t",
            "test ",
        ])
        func `substrings with non-visible`(str: String) {
            let sub = str[...]
            #expect(!sub.ascii.isAllVisible, "Substring '\(sub)' should not be all visible")
        }
    }

    @Suite
    struct `Substring.ASCII - isAllPrintable` {
        @Test(arguments: [
            " ",
            "hello world",
            "!@#$%",
            "ABC 123",
        ])
        func `all printable character substrings`(str: String) {
            let sub = str[...]
            #expect(sub.ascii.isAllPrintable, "Substring '\(sub)' should be all printable")
        }

        @Test(arguments: [
            "\t",
            "\n",
            "hello\nworld",
            "\0",
        ])
        func `substrings with non-printable`(str: String) {
            let sub = str[...]
            #expect(!sub.ascii.isAllPrintable, "Substring '\(sub)' should not be all printable")
        }
    }

    @Suite
    struct `Substring.ASCII - containsNonASCII` {
        @Test(arguments: [
            "Hello🌍",
            "café",
            "日本語",
            "test\u{80}",
        ])
        func `substrings containing non-ASCII`(str: String) {
            let sub = str[...]
            #expect(sub.ascii.containsNonASCII, "Substring '\(sub)' should contain non-ASCII")
        }

        @Test(arguments: [
            "",
            "Hello",
            "test123",
            "!@#$%",
        ])
        func `pure ASCII substrings`(str: String) {
            let sub = str[...]
            #expect(!sub.ascii.containsNonASCII, "Substring '\(sub)' should not contain non-ASCII")
        }
    }

    @Suite
    struct `Substring.ASCII - containsHexDigit` {
        @Test(arguments: [
            "0",
            "9",
            "A",
            "F",
            "a",
            "f",
            "hello",
            "FACE",
            "test0",
        ])
        func `substrings containing hex digits`(str: String) {
            let sub = str[...]
            #expect(sub.ascii.containsHexDigit, "Substring '\(sub)' should contain hex digit")
        }

        @Test(arguments: [
            "",
            "xyz",
            "!!!",
            "   ",
        ])
        func `substrings without hex digits`(str: String) {
            let sub = str[...]
            #expect(!sub.ascii.containsHexDigit, "Substring '\(sub)' should not contain hex digit")
        }
    }

    // MARK: - Case Validation Tests

    @Suite
    struct `Substring.ASCII - isAllLowercase` {
        @Test(arguments: [
            "abc",
            "hello",
            "test123",
            "hello world",
            "a-b-c",
        ])
        func `all lowercase substrings`(str: String) {
            let sub = str[...]
            #expect(sub.ascii.isAllLowercase, "Substring '\(sub)' should be all lowercase")
        }

        @Test(arguments: [
            "ABC",
            "Hello",
            "tEst",
            "WORLD",
        ])
        func `substrings with uppercase letters`(str: String) {
            let sub = str[...]
            #expect(!sub.ascii.isAllLowercase, "Substring '\(sub)' should not be all lowercase")
        }

        @Test
        func `empty substring is all lowercase`() {
            #expect(""[...].ascii.isAllLowercase)
        }

        @Test
        func `non-letter substring is all lowercase`() {
            #expect("123!@#"[...].ascii.isAllLowercase)
        }
    }

    @Suite
    struct `Substring.ASCII - isAllUppercase` {
        @Test(arguments: [
            "ABC",
            "HELLO",
            "TEST123",
            "HELLO WORLD",
            "A-B-C",
        ])
        func `all uppercase substrings`(str: String) {
            let sub = str[...]
            #expect(sub.ascii.isAllUppercase, "Substring '\(sub)' should be all uppercase")
        }

        @Test(arguments: [
            "abc",
            "Hello",
            "TeSt",
            "world",
        ])
        func `substrings with lowercase letters`(str: String) {
            let sub = str[...]
            #expect(!sub.ascii.isAllUppercase, "Substring '\(sub)' should not be all uppercase")
        }

        @Test
        func `empty substring is all uppercase`() {
            #expect(""[...].ascii.isAllUppercase)
        }

        @Test
        func `non-letter substring is all uppercase`() {
            #expect("123!@#"[...].ascii.isAllUppercase)
        }
    }

    // MARK: - Case Conversion Tests

    @Suite
    struct `Substring - ASCII Case Conversion` {
        @Test(arguments: [
            ("hello", "HELLO"),
            ("world", "WORLD"),
            ("TeSt", "TEST"),
            ("abc123", "ABC123"),
            ("", ""),
        ])
        func `case conversion to upper`(input: String, expected: String) {
            let sub = input[...]
            #expect(sub.ascii(case: .upper) == expected)
        }

        @Test(arguments: [
            ("HELLO", "hello"),
            ("WORLD", "world"),
            ("TeSt", "test"),
            ("ABC123", "abc123"),
            ("", ""),
        ])
        func `case conversion to lower`(input: String, expected: String) {
            let sub = input[...]
            #expect(sub.ascii(case: .lower) == expected)
        }

        @Test
        func `non-ASCII preserved in case conversion`() {
            let sub = "Hello🌍"[...]
            #expect(sub.ascii(case: .upper) == "HELLO🌍")
            #expect(sub.ascii(case: .lower) == "hello🌍")
        }
    }

    // MARK: - Case Convenience Method Tests

    @Suite
    struct `Substring.ASCII - uppercased and lowercased` {
        @Test(arguments: [
            ("hello", "HELLO"),
            ("world", "WORLD"),
            ("TeSt", "TEST"),
            ("abc123", "ABC123"),
            ("", ""),
        ])
        func `uppercased converts correctly`(input: String, expected: String) {
            let sub = input[...]
            #expect(sub.ascii.uppercased() == expected)
        }

        @Test(arguments: [
            ("HELLO", "hello"),
            ("WORLD", "world"),
            ("TeSt", "test"),
            ("ABC123", "abc123"),
            ("", ""),
        ])
        func `lowercased converts correctly`(input: String, expected: String) {
            let sub = input[...]
            #expect(sub.ascii.lowercased() == expected)
        }

        @Test
        func `convenience methods match ascii(case:)`() {
            let sub = "Hello World"[...]
            #expect(sub.ascii.uppercased() == sub.ascii(case: .upper))
            #expect(sub.ascii.lowercased() == sub.ascii(case: .lower))
        }

        @Test
        func `non-ASCII preserved in case methods`() {
            let sub = "Hello🌍"[...]
            #expect(sub.ascii.uppercased() == "HELLO🌍")
            #expect(sub.ascii.lowercased() == "hello🌍")
        }
    }

    // MARK: - Line Ending Constants Tests

    @Suite
    struct `Substring.ASCII - Line Ending Constants` {
        @Test
        func `lf constant is correct`() {
            #expect(.ascii.lf == "\n")
            #expect(String.ascii.lf.count == 1)
        }

        @Test
        func `cr constant is correct`() {
            #expect(.ascii.cr == "\r")
            #expect(String.ascii.cr.count == 1)
        }

        @Test
        func `crlf constant is correct`() {
            #expect(.ascii.crlf == "\r\n")
            #expect(Substring.ascii.crlf.utf8.count == 2)
        }
    }

    // MARK: - Line Ending Detection Tests

    @Suite
    struct `Substring.ASCII - containsMixedLineEndings` {
        @Test(arguments: [
            "line1\nline2\r\nline3",
            "line1\rline2\nline3",
            "line1\nline2\rline3\r\nline4",
        ])
        func `substrings with mixed line endings`(str: String) {
            let sub = str[...]
            #expect(sub.ascii.containsMixedLineEndings, "Substring should have mixed line endings")
        }

        @Test(arguments: [
            "",
            "hello",
            "line1\nline2\nline3",
            "line1\rline2\rline3",
            "line1\r\nline2\r\nline3",
        ])
        func `substrings with consistent or no line endings`(str: String) {
            let sub = str[...]
            #expect(!sub.ascii.containsMixedLineEndings, "Substring should not have mixed line endings")
        }
    }

    @Suite
    struct `Substring.ASCII - detectedLineEnding` {
        @Test(arguments: [
            ("line1\nline2", INCITS_4_1986.FormatEffectors.LineEnding.lf),
            ("line1\n", INCITS_4_1986.FormatEffectors.LineEnding.lf),
            ("\n", INCITS_4_1986.FormatEffectors.LineEnding.lf),
        ])
        func `detects LF`(str: String, expected: INCITS_4_1986.FormatEffectors.LineEnding) {
            let sub = str[...]
            #expect(sub.ascii.detectedLineEnding() == expected)
        }

        @Test(arguments: [
            ("line1\rline2", INCITS_4_1986.FormatEffectors.LineEnding.cr),
            ("line1\r", INCITS_4_1986.FormatEffectors.LineEnding.cr),
            ("\r", INCITS_4_1986.FormatEffectors.LineEnding.cr),
        ])
        func `detects CR`(str: String, expected: INCITS_4_1986.FormatEffectors.LineEnding) {
            let sub = str[...]
            #expect(sub.ascii.detectedLineEnding() == expected)
        }

        @Test(arguments: [
            ("line1\r\nline2", INCITS_4_1986.FormatEffectors.LineEnding.crlf),
            ("line1\r\n", INCITS_4_1986.FormatEffectors.LineEnding.crlf),
            ("\r\n", INCITS_4_1986.FormatEffectors.LineEnding.crlf),
        ])
        func `detects CRLF`(str: String, expected: INCITS_4_1986.FormatEffectors.LineEnding) {
            let sub = str[...]
            #expect(sub.ascii.detectedLineEnding() == expected)
        }

        @Test
        func `returns nil when no line endings`() {
            #expect("hello world"[...].ascii.detectedLineEnding() == nil)
            #expect(""[...].ascii.detectedLineEnding() == nil)
        }

        @Test
        func `prioritizes CRLF over individual CR or LF`() {
            let sub = "line1\r\nline2\nline3"[...]
            #expect(sub.ascii.detectedLineEnding() == .crlf)
        }
    }
}

extension `Performance Tests` {
    @Suite
    struct `Substring - Performance` {
        @Test(.timed(threshold: .milliseconds(2000)))
        func `substring trimming 10K times`() {
            let str = "  hello world  "
            let sub = str[...]
            for _ in 0..<10000 {
                _ = sub.trimming(.ascii.whitespaces)
            }
        }
    }
}
