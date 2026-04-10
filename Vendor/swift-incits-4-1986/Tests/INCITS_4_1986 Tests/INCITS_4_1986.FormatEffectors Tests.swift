// INCITS_4_1986.FormatEffectors.LineEnding Tests.swift
// swift-incits-4-1986
//
// Tests for INCITS_4_1986 line ending normalization

import StandardsTestSupport
import Testing

@testable import INCITS_4_1986

@Suite
struct `FormatEffectors Tests` {
    @Suite
    struct `Line Ending Normalization - Correctness` {
        @Test(arguments: [
            ("hello\nworld", INCITS_4_1986.FormatEffectors.LineEnding.lf, "hello\nworld"),
            ("hello\nworld", .cr, "hello\rworld"),
            ("hello\nworld", .crlf, "hello\r\nworld"),
            ("hello\r\nworld", .lf, "hello\nworld"),
            ("hello\rworld", .lf, "hello\nworld"),
        ])
        func `line ending normalization`(
            input: String, to: INCITS_4_1986.FormatEffectors.LineEnding, expected: String
        ) {
            #expect(input.normalized(to: to) == expected)
        }

        @Test
        func `normalization preserves content`() {
            let text = "Line 1\nLine 2\r\nLine 3\rEnd"
            let normalized = text.normalized(to: .lf)
            let lines = normalized.split(separator: "\n").map(String.init)
            #expect(lines == ["Line 1", "Line 2", "Line 3", "End"])
        }
    }

    @Suite
    struct `Line Ending Normalization - Idempotence` {
        @Test(arguments: [INCITS_4_1986.FormatEffectors.LineEnding.lf, .cr, .crlf])
        func `normalization is idempotent`(ending: INCITS_4_1986.FormatEffectors.LineEnding) {
            let text = "hello\nworld\r\ntest\rend"
            let first = text.normalized(to: ending)
            let second = first.normalized(to: ending)
            #expect(first == second, "Normalizing twice should be idempotent")
        }

        @Test(arguments: [INCITS_4_1986.FormatEffectors.LineEnding.lf, .cr, .crlf])
        func `text without line endings unchanged`(ending: INCITS_4_1986.FormatEffectors.LineEnding) {
            let text = "no line endings here"
            #expect(text.normalized(to: ending) == text)
        }
    }
}

extension `Performance Tests` {
    @Suite
    struct `Line Ending Normalization - Performance` {
        @Test(.timed(threshold: .milliseconds(50)))
        func `normalize 100K character file with 1K line endings`() {
            let line = String(repeating: "x", count: 100)
            let text = (0..<1000).map { _ in line }.joined(separator: "\n")
            _ = text.normalized(to: .crlf)
        }

        @Test(.timed(threshold: .milliseconds(150)))
        func `normalize file with no line endings - fast path`() {
            let text = String(repeating: "x", count: 100_000)
            _ = text.normalized(to: .lf)
        }
    }
}
