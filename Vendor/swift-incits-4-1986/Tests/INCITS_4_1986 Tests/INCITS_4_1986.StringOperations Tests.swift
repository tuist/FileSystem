// INCITS_4_1986.StringOperations Tests.swift
// swift-incits-4-1986
//
// Tests for INCITS_4_1986 string trimming operations

import StandardsTestSupport
import Testing

@testable import INCITS_4_1986

@Suite
struct `StringOperator Tests` {
    @Suite
    struct `String Trimming - Correctness` {
        @Test
        func `trim leading whitespace`() {
            #expect("  hello".trimming(Set<Character>.ascii.whitespaces) == "hello")
            #expect("\t\nhello".trimming(Set<Character>.ascii.whitespaces) == "hello")
        }

        @Test
        func `trim trailing whitespace`() {
            #expect("hello  ".trimming(Set<Character>.ascii.whitespaces) == "hello")
            #expect("hello\t\n".trimming(Set<Character>.ascii.whitespaces) == "hello")
        }

        @Test
        func `trim both ends`() {
            #expect("  hello  ".trimming(.ascii.whitespaces) == "hello")
            // CRLF is a single grapheme in Swift - use predicate for grapheme-aware trimming
            #expect("\t\nhello\r\n".trimming(where: Set<Character>.ascii.isWhitespace) == "hello")
        }

        @Test
        func `preserve internal whitespace`() {
            #expect("  hello world  ".trimming(Set<Character>.ascii.whitespaces) == "hello world")
        }

        @Test
        func `empty string unchanged`() {
            #expect("".trimming(Set<Character>.ascii.whitespaces).isEmpty)
        }

        @Test
        func `all whitespace becomes empty`() {
            #expect("   \t\n\r   ".trimming(Set<Character>.ascii.whitespaces).isEmpty)
        }

        @Test
        func `trim custom character set`() {
            #expect("***text***".trimming(["*"]) == "text")
            #expect("abcHELLOcba".trimming(["a", "b", "c"]) == "HELLO")
        }
    }

    @Suite
    struct `Substring Trimming - Correctness` {
        @Test
        func `trim substring`() {
            let str = "  hello  "
            let sub = str[...]
            #expect(sub.trimming(Set<Character>.ascii.whitespaces) == "hello")
        }
    }
}

extension `Performance Tests` {
    @Suite
    struct `String Trimming - Performance` {
        @Test(.timed(threshold: .milliseconds(2000)))
        func `trim 10K strings with ASCII whitespace`() {
            for _ in 0..<10000 {
                _ = "  hello world  ".trimming(Set<Character>.ascii.whitespaces)
            }
        }

        @Test(.timed(threshold: .milliseconds(50)))
        func `trim large string with many leading spaces`() {
            let spaces = String(repeating: " ", count: 10000)
            let text = spaces + "content" + spaces
            _ = text.trimming(Set<Character>.ascii.whitespaces)
        }
    }
}
