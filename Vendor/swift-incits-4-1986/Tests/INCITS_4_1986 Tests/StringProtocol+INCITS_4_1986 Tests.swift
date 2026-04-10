// StringProtocol+INCITS_4_1986 Tests.swift
// swift-incits-4-1986
//
// Tests for StringProtocol extension methods

import StandardsTestSupport
import Testing

@testable import INCITS_4_1986

@Suite
struct `StringProtocol+INCITS_4_1986 Tests` {
    @Suite
    struct `ASCII Namespace Access` {
        @Test
        func `String has static ascii property`() {
            #expect(String.ascii.lf == "\n")
            #expect(String.ascii.cr == "\r")
            #expect(String.ascii.crlf == "\r\n")
        }

        @Test
        func `Substring has static ascii property`() {
            #expect(Substring.ascii.lf == "\n")
            #expect(Substring.ascii.cr == "\r")
            #expect(Substring.ascii.crlf == "\r\n")
        }

        @Test
        func `String instance has ascii property`() {
            let str = "Hello"
            #expect(str.ascii.isAllASCII)
        }

        @Test
        func `Substring instance has ascii property`() {
            let str = "Hello World"
            let sub = str[str.startIndex..<str.index(str.startIndex, offsetBy: 5)]
            #expect(sub.ascii.isAllASCII)
        }
    }

    @Suite
    struct `Delegation Tests` {
        @Test
        func `String delegates isAllASCII to StringClassification`() {
            #expect("Hello".ascii.isAllASCII == INCITS_4_1986.StringClassification.isAllASCII("Hello"))
            #expect("café".ascii.isAllASCII == INCITS_4_1986.StringClassification.isAllASCII("café"))
        }

        @Test
        func `Substring delegates isAllASCII to StringClassification`() {
            let str = "Hello World"
            let sub = str[str.startIndex..<str.index(str.startIndex, offsetBy: 5)]
            #expect(sub.ascii.isAllASCII == INCITS_4_1986.StringClassification.isAllASCII(sub))
        }

        @Test
        func `String delegates detectedLineEnding to LineEndingDetection`() {
            let str = "line1\r\nline2"
            #expect(str.ascii.detectedLineEnding() == INCITS_4_1986.LineEndingDetection.detect(str))
        }

        @Test
        func `Substring delegates detectedLineEnding to LineEndingDetection`() {
            let str = "line1\r\nline2"
            let sub = str[...]
            #expect(sub.ascii.detectedLineEnding() == INCITS_4_1986.LineEndingDetection.detect(sub))
        }
    }

    @Suite
    struct `Case Conversion Tests` {
        @Test
        func `ascii(case:) method works for String`() {
            #expect("Hello".ascii(case: .upper) == "HELLO")
            #expect("Hello".ascii(case: .lower) == "hello")
        }

        @Test
        func `ascii(case:) method works for Substring`() {
            let str = "Hello World"
            let sub = str[str.startIndex..<str.index(str.startIndex, offsetBy: 5)]
            #expect(sub.ascii(case: .upper) == "HELLO")
            #expect(sub.ascii(case: .lower) == "hello")
        }

        @Test
        func `uppercased() convenience method`() {
            #expect("Hello".ascii.uppercased() == "HELLO")
        }

        @Test
        func `lowercased() convenience method`() {
            #expect("Hello".ascii.lowercased() == "hello")
        }
    }

    @Suite
    struct `Line Ending Conversion Tests` {
        @Test
        func `ascii(lineEnding:) creates correct string for LF`() {
            #expect(String(ascii: .lf) == "\n")
        }

        @Test
        func `ascii(lineEnding:) creates correct string for CR`() {
            #expect(String(ascii: .cr) == "\r")
        }

        @Test
        func `ascii(lineEnding:) creates correct string for CRLF`() {
            #expect(String(ascii: .crlf) == "\r\n")
        }
    }

    @Suite
    struct `ASCII Byte Conversion Tests` {
        @Test
        func `ascii(_:) creates string from valid ASCII bytes`() {
            let bytes: [UInt8] = [72, 101, 108, 108, 111]  // "Hello"
            #expect(String(ascii: bytes) == "Hello")
        }

        @Test
        func `ascii(_:) returns nil for non-ASCII bytes`() {
            let bytes: [UInt8] = [72, 101, 255, 108, 111]
            #expect(String(ascii: bytes) == nil)
        }

        @Test
        func `ascii(unchecked:) creates string without validation`() {
            let bytes: [UInt8] = [72, 101, 108, 108, 111]
            #expect(String.ascii.unchecked(bytes) == "Hello")
        }
    }

    @Suite
    struct `Normalization Tests` {
        @Test
        func `normalized(to:) method normalizes line endings`() {
            let str = "line1\nline2\r\nline3\rline4"
            #expect(str.normalized(to: .lf) == "line1\nline2\nline3\nline4")
            #expect(str.normalized(to: .cr) == "line1\rline2\rline3\rline4")
            #expect(str.normalized(to: .crlf) == "line1\r\nline2\r\nline3\r\nline4")
        }

        @Test
        func `normalized(to:) works for Substring`() {
            let str = "line1\nline2"
            let sub = str[...]
            #expect(sub.normalized(to: .crlf) == "line1\r\nline2")
        }
    }

    @Suite
    struct `Trimming Tests` {
        @Test
        func `trimming(_:) removes characters from both ends`() {
            let str = "  hello  "
            #expect(str.trimming(Set<Character>.ascii.whitespaces) == "hello")
        }

        @Test
        func `trimming works for Substring`() {
            let str = "  hello  "
            let sub = str[...]
            #expect(String(sub.trimming(Set<Character>.ascii.whitespaces)) == "hello")
        }
    }
}
