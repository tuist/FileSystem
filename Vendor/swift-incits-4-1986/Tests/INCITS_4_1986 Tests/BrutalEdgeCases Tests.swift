// BrutalEdgeCases Tests.swift
// swift-incits-4-1986
//
// Absolutely brutal edge case tests designed to break most ASCII libraries

import StandardsTestSupport
import Testing

@testable import INCITS_4_1986

// MARK: - Bit-Level Boundary Testing

@Suite
struct Brutal {
    @Suite
    struct `Brutal - Every Single Byte Value` {
        @Test(arguments: Array(UInt8(0)...UInt8(255)))
        func `exhaustive byte classification`(byte: UInt8) {
            // Every byte must be either ASCII or not - no exceptions
            let isASCII = byte <= 0x7F
            #expect([byte].ascii.isAllASCII == isASCII, "Byte 0x\(String(byte, radix: 16)) classification inconsistent")

            // Predicates must be consistent for all bytes
            if byte.ascii.isControl {
                // Control characters are never letters/digits
                #expect(!byte.ascii.isLetter, "Control byte 0x\(String(byte, radix: 16)) cannot be letter")
                #expect(!byte.ascii.isDigit, "Control byte 0x\(String(byte, radix: 16)) cannot be digit")
            }

            // Visible implies printable
            if byte.ascii.isVisible {
                #expect(byte.ascii.isPrintable, "Visible byte 0x\(String(byte, radix: 16)) must be printable")
            }
        }

        @Test(arguments: Array(UInt8(0)...UInt8(255)))
        func `case conversion idempotence for every byte`(byte: UInt8) {
            let upper = byte.ascii(case: .upper)
            let upperAgain = upper.ascii(case: .upper)
            #expect(upper == upperAgain, "Uppercase idempotence failed for 0x\(String(byte, radix: 16))")

            let lower = byte.ascii(case: .lower)
            let lowerAgain = lower.ascii(case: .lower)
            #expect(lower == lowerAgain, "Lowercase idempotence failed for 0x\(String(byte, radix: 16))")
        }

        @Test(arguments: Array(UInt8(0)...UInt8(255)))
        func `case conversion involution for every byte`(byte: UInt8) {
            // For letters: upper->lower->upper should return to original
            if byte.ascii.isLetter {
                let cycle = byte.ascii(case: .upper).ascii(case: .lower).ascii(case: .upper)
                #expect(
                    cycle == byte.ascii(case: .upper), "Case involution failed for 0x\(String(byte, radix: 16))"
                )
            }
        }
    }

    // MARK: - Predicate Mutual Exclusion and Coverage

    @Suite
    struct `Brutal - Predicate Consistency` {
        @Test(arguments: Array(UInt8(0)...UInt8(127)))
        func `control and printable are mutually exclusive`(byte: UInt8) {
            let isControl = byte.ascii.isControl
            let isPrintable = byte.ascii.isPrintable

            // SPACE (0x20) is the only exception: printable but not control
            // Control range is 0x00-0x1F and 0x7F (DEL)
            if byte == UInt8.ascii.sp {
                #expect(!isControl && isPrintable)
            } else if byte <= 0x1F || byte == 0x7F {
                #expect(isControl && !isPrintable, "0x\(String(byte, radix: 16)) should be control, not printable")
            } else {
                #expect(!isControl && isPrintable, "0x\(String(byte, radix: 16)) should be printable, not control")
            }
        }

        @Test(arguments: Array(UInt8(0)...UInt8(127)))
        func `every ASCII byte is either control or printable`(byte: UInt8) {
            let isControl = byte.ascii.isControl
            let isPrintable = byte.ascii.isPrintable

            // Every ASCII byte must be exactly one (XOR)
            #expect(
                isControl != isPrintable,
                "Byte 0x\(String(byte, radix: 16)) must be exactly one of control or printable"
            )
        }

        @Test(arguments: Array(UInt8(0)...UInt8(127)))
        func `letter implies alphanumeric`(byte: UInt8) {
            if byte.ascii.isLetter {
                #expect(byte.ascii.isAlphanumeric, "Letter 0x\(String(byte, radix: 16)) must be alphanumeric")
            }
        }

        @Test(arguments: Array(UInt8(0)...UInt8(127)))
        func `digit implies alphanumeric`(byte: UInt8) {
            if byte.ascii.isDigit {
                #expect(byte.ascii.isAlphanumeric, "Digit 0x\(String(byte, radix: 16)) must be alphanumeric")
            }
        }

        @Test(arguments: Array(UInt8(0)...UInt8(127)))
        func `uppercase and lowercase are mutually exclusive`(byte: UInt8) {
            let isUpper = byte.ascii.isUppercase
            let isLower = byte.ascii.isLowercase

            // Cannot be both
            #expect(!(isUpper && isLower), "Byte 0x\(String(byte, radix: 16)) cannot be both upper and lower")

            // If letter, must be exactly one
            if byte.ascii.isLetter {
                #expect(isUpper != isLower, "Letter 0x\(String(byte, radix: 16)) must be exactly one of upper or lower")
            } else {
                #expect(!isUpper && !isLower, "Non-letter 0x\(String(byte, radix: 16)) cannot be upper or lower")
            }
        }
    }

    // MARK: - Unicode Confusion Attacks

    @Suite
    struct `Brutal - Unicode Confusion` {
        @Test
        func `UTF-8 multi-byte sequences rejected`() {
            // These are valid UTF-8 but NOT ASCII
            let multiByteSequences: [[UInt8]] = [
                [0xC3, 0xA9],  // é (2-byte)
                [0xE2, 0x82, 0xAC],  // € (3-byte)
                [0xF0, 0x9F, 0x98, 0x80],  // 😀 (4-byte)
            ]

            for seq in multiByteSequences {
                #expect(!seq.ascii.isAllASCII, "Multi-byte UTF-8 \(seq.map { String($0, radix: 16) }) should fail")
            }
        }

        @Test
        func `UTF-16 surrogate range bytes rejected`() {
            // UTF-16 surrogate range is 0xD800-0xDFFF
            // In UTF-8, bytes starting with 0xED followed by 0xA0-0xBF are surrogates
            // But as individual bytes, any byte >= 0x80 is invalid ASCII
            let surrogateRangeBytes: [UInt8] = [0xD8, 0xDC, 0xDF, 0xED]

            for byte in surrogateRangeBytes {
                #expect(
                    ![byte].ascii.isAllASCII, "Surrogate-range byte 0x\(String(byte, radix: 16)) should be rejected"
                )
            }
        }

        @Test
        func `look-alike characters not confused with ASCII`() {
            // Cyrillic 'а' looks like Latin 'a' but is U+0430 (multi-byte UTF-8)
            let cyrillicA = "а"  // U+0430
            #expect(UInt8(ascii: Character(cyrillicA)) == nil, "Cyrillic 'а' should not convert to ASCII")

            // Greek 'Α' looks like Latin 'A' but is U+0391
            let greekA = "Α"  // U+0391
            #expect(UInt8(ascii: Character(greekA)) == nil, "Greek 'Α' should not convert to ASCII")
        }

        @Test
        func `zero-width characters rejected`() {
            let zeroWidth = "\u{200B}"  // Zero-width space
            #expect(UInt8(ascii: Character(zeroWidth)) == nil, "Zero-width space should be rejected")
        }

        @Test
        func `combining characters rejected`() {
            // Combining diacritical marks
            let combining = "\u{0301}"  // Combining acute accent
            #expect(UInt8(ascii: Character(combining)) == nil, "Combining character should be rejected")
        }

        @Test
        func `unicode whitespace not confused with ASCII whitespace`() {
            // U+00A0 is non-breaking space (not ASCII whitespace)
            let nbsp = "\u{00A0}"
            #expect(UInt8(ascii: Character(nbsp)) == nil, "Non-breaking space should be rejected")

            // U+2003 is em space (not ASCII)
            let emSpace = "\u{2003}"
            #expect(UInt8(ascii: Character(emSpace)) == nil, "Em space should be rejected")
        }
    }

    // MARK: - Buffer Boundary Torture

    @Suite
    struct `Brutal - Buffer Boundaries` {
        @Test(arguments: [0, 1, 2, 3, 4, 7, 8, 15, 16, 31, 32, 63, 64, 127, 128, 255, 256, 511, 512, 1023, 1024])
        func `validation at power-of-2 boundaries`(size: Int) {
            let validASCII = Array(repeating: UInt8.ascii.A, count: size)
            #expect(validASCII.ascii.isAllASCII, "Valid ASCII array of size \(size) should pass")

            var invalidASCII = validASCII
            if size > 0 {
                invalidASCII[size - 1] = 0x80
                #expect(!invalidASCII.ascii.isAllASCII, "Invalid ASCII array of size \(size) should fail")
            }
        }

        @Test
        func `massive array validation - 1 million bytes all valid`() {
            let massive = Array(repeating: UInt8.ascii.A, count: 1_000_000)
            #expect(massive.ascii.isAllASCII)
        }

        @Test
        func `massive array validation - 1 million bytes with non-ASCII at position 999999`() {
            var massive = Array(repeating: UInt8.ascii.A, count: 1_000_000)
            massive[999_999] = 0x80
            #expect(!massive.ascii.isAllASCII, "Should detect non-ASCII at end of massive array")
        }

        @Test
        func `alternating valid and invalid bytes`() {
            let size = 1000
            let alternating = (0..<size).map { $0 % 2 == 0 ? UInt8.ascii.A : UInt8(0x80) }
            #expect(!alternating.ascii.isAllASCII, "Alternating pattern should fail")
        }
    }

    // MARK: - Line Ending Hell

    @Suite
    struct `Brutal - Line Ending Pathological Cases` {
        @Test
        func `every possible line ending combination`() {
            let pathological = "\r\n\r\r\n\n\r\n\n\n\r\r\r\n\r\n"

            // Should normalize all to target
            let asLF = pathological.normalized(to: .lf)
            #expect(!asLF.contains("\r"), "All CR should be converted")

            let asCRLF = pathological.normalized(to: .crlf)
            // After normalization, should have consistent line endings
            #expect(asCRLF.contains("\r\n"), "Should contain CRLF")
        }

        @Test
        func `lone CR at every position`() {
            let positions = ["start\rmiddle", "middle\rend", "\rlone", "double\r\rCR"]
            for text in positions {
                let normalized = text.normalized(to: .lf)
                #expect(!normalized.contains("\r"), "Lone CR should be normalized in '\(text)'")
            }
        }

        @Test
        func `CRLF immediately followed by CRLF`() {
            let text = "line1\r\n\r\nline2"
            let asLF = text.normalized(to: .lf)
            #expect(asLF == "line1\n\nline2", "Consecutive CRLF should become consecutive LF")
        }

        @Test
        func `text is only line endings`() {
            let onlyEndings = "\r\n\r\n\r\n"
            let asLF = onlyEndings.normalized(to: .lf)
            #expect(asLF == "\n\n\n", "Should normalize to LF only")
        }

        @Test
        func `incomplete CRLF at end - CR without LF`() {
            let incomplete = "text\r"
            let asLF = incomplete.normalized(to: .lf)
            #expect(asLF == "text\n", "Trailing CR should normalize to LF")
        }

        @Test
        func `line endings in every ASCII position`() {
            var text = ""
            for _ in 0..<100 {
                text += "x\rx\nx\r\n"
            }
            let normalized = text.normalized(to: .lf)
            #expect(!normalized.contains("\r"), "All line endings should normalize")
        }

        @Test
        func `normalize already normalized text - idempotence stress test`() {
            var text = "line1\nline2\nline3"
            // Apply 100 times - should remain stable
            for _ in 0..<100 {
                text = text.normalized(to: .lf)
            }
            #expect(text == "line1\nline2\nline3", "Repeated normalization should be stable")
        }
    }

    // MARK: - Trimming Torture

    @Suite
    struct `Brutal - Trimming Pathological Cases` {
        @Test
        func `10000 leading spaces`() {
            let massive = String(repeating: " ", count: 10000) + "content"
            let trimmed = massive.trimming(.ascii.whitespaces)
            #expect(trimmed == "content", "Should trim 10K leading spaces")
        }

        @Test
        func `10000 trailing spaces`() {
            let massive = "content" + String(repeating: " ", count: 10000)
            let trimmed = massive.trimming(.ascii.whitespaces)
            #expect(trimmed == "content", "Should trim 10K trailing spaces")
        }

        @Test
        func `alternating whitespace and content`() {
            let alternating = " x " + String(repeating: " x ", count: 1000)
            let trimmed = alternating.trimming(.ascii.whitespaces)
            #expect(trimmed.hasPrefix("x"), "Should trim leading")
            #expect(trimmed.hasSuffix("x"), "Should trim trailing")
            #expect(trimmed.contains(" x "), "Should preserve internal")
        }

        @Test
        func `all four whitespace types mixed`() {
            let mixed = " \t\n\r content \r\n\t "
            let trimmed = mixed.trimming(.ascii.whitespaces)
            #expect(trimmed == "content", "Should trim all whitespace types")
        }

        @Test
        func `trim with empty set does nothing`() {
            let text = "   content   "
            let untrimmed = text.trimming(Set<Character>())
            #expect(untrimmed == text, "Empty set should not trim")
        }

        @Test
        func `trim when every character is in set`() {
            let text = "aaaaaaa"
            let trimmed = text.trimming(Set(["a"]))
            #expect(trimmed.isEmpty, "Should trim to empty when all match")
        }

        @Test
        func `trim single character strings`() {
            #expect(" ".trimming(.ascii.whitespaces).isEmpty)
            #expect("x".trimming(.ascii.whitespaces) == "x")
        }
    }

    // MARK: - Case Conversion Edge Cases

    @Suite
    struct `Brutal - Case Conversion Torture` {
        @Test
        func `case conversion with every non-letter byte`() {
            // All non-letters should remain unchanged
            let nonLetters = Array(UInt8(0)...UInt8(127)).filter { !$0.ascii.isLetter }
            for byte in nonLetters {
                #expect(
                    byte.ascii(case: .upper) == byte,
                    "Non-letter 0x\(String(byte, radix: 16)) should be unchanged by uppercase"
                )
                #expect(
                    byte.ascii(case: .lower) == byte,
                    "Non-letter 0x\(String(byte, radix: 16)) should be unchanged by lowercase"
                )
            }
        }

        @Test
        func `case conversion round-trip for all letters`() {
            for byte in UInt8.ascii.A...UInt8.ascii.Z {
                let lower = byte.ascii(case: .lower)
                let backToUpper = lower.ascii(case: .upper)
                #expect(backToUpper == byte, "Round-trip failed for 0x\(String(byte, radix: 16))")
            }

            for byte in UInt8.ascii.a...UInt8.ascii.z {
                let upper = byte.ascii(case: .upper)
                let backToLower = upper.ascii(case: .lower)
                #expect(backToLower == byte, "Round-trip failed for 0x\(String(byte, radix: 16))")
            }
        }

        @Test
        func `string case conversion preserves length`() {
            let test = "Hello World 123 !@#"
            #expect(test.ascii(case: .upper).count == test.count)
            #expect(test.ascii(case: .lower).count == test.count)
        }

        @Test
        func `array case conversion preserves length`() {
            let bytes: [UInt8] = [UInt8.ascii.H, .ascii.e, .ascii.l, .ascii.l, .ascii.o]
            #expect(bytes.ascii(case: .upper).count == bytes.count)
            #expect(bytes.ascii(case: .lower).count == bytes.count)
        }

        @Test
        func `case conversion applied 1000 times - stability test`() {
            var bytes: [UInt8] = [UInt8.ascii.H, .ascii.e, .ascii.l, .ascii.l, .ascii.o]

            // Apply uppercase 1000 times
            for _ in 0..<1000 {
                bytes = bytes.ascii(case: .upper)
            }
            #expect(bytes == [UInt8.ascii.H, .ascii.E, .ascii.L, .ascii.L, .ascii.O])

            // Now lowercase 1000 times
            for _ in 0..<1000 {
                bytes = bytes.ascii(case: .lower)
            }
            #expect(bytes == [UInt8.ascii.h, .ascii.e, .ascii.l, .ascii.l, .ascii.o])
        }
    }

    // MARK: - Validation Exhaustive Testing

    @Suite
    struct `Brutal - Validation Exhaustive` {
        @Test
        func `every valid ASCII byte in one array`() {
            let allValidASCII = Array(UInt8(0)...UInt8(127))
            #expect(allValidASCII.ascii.isAllASCII, "All 128 ASCII bytes should validate")
        }

        @Test
        func `every invalid byte tested individually`() {
            for byte in UInt8(128)...UInt8(255) {
                #expect(![byte].ascii.isAllASCII, "Byte 0x\(String(byte, radix: 16)) should fail")
            }
        }

        @Test
        func `non-ASCII byte at every position in array`() {
            let size = 100
            for position in 0..<size {
                var bytes = Array(repeating: UInt8.ascii.A, count: size)
                bytes[position] = 0x80
                #expect(!bytes.ascii.isAllASCII, "Should detect non-ASCII at position \(position)")
            }
        }

        @Test
        func `validation with every possible first byte`() {
            for firstByte in UInt8(0)...UInt8(255) {
                let array = [firstByte, UInt8.ascii.A, UInt8.ascii.B]
                let expected = firstByte <= 0x7F
                #expect(
                    array.ascii.isAllASCII == expected,
                    "First byte 0x\(String(firstByte, radix: 16)) validation incorrect"
                )
            }
        }

        @Test
        func `validation with every possible last byte`() {
            for lastByte in UInt8(0)...UInt8(255) {
                let array = [UInt8.ascii.A, UInt8.ascii.B, lastByte]
                let expected = lastByte <= 0x7F
                #expect(
                    array.ascii.isAllASCII == expected,
                    "Last byte 0x\(String(lastByte, radix: 16)) validation incorrect"
                )
            }
        }
    }

    // MARK: - String Conversion Torture

    @Suite
    struct `Brutal - String Conversion Edge Cases` {
        @Test
        func `round-trip every ASCII character`() {
            for byte in UInt8(0)...UInt8(127) {
                if let str = String(ascii: [byte]) {
                    if let backToBytes = [UInt8](ascii: str) {
                        #expect(backToBytes == [byte], "Round-trip failed for 0x\(String(byte, radix: 16))")
                    }
                }
            }
        }

        @Test
        func `string conversion fails for non-ASCII`() {
            for byte in UInt8(128)...UInt8(255) {
                #expect(
                    String(ascii: [byte]) == nil, "Non-ASCII byte 0x\(String(byte, radix: 16)) should fail conversion"
                )
            }
        }

        @Test
        func `empty array converts to empty string`() {
            let empty: [UInt8] = []
            #expect(String(ascii: empty)?.isEmpty == true)
        }

        @Test
        func `empty string converts to empty array`() {
            let empty = ""
            #expect([UInt8](ascii: empty) == [])
        }

        @Test
        func `NUL bytes in middle of string`() {
            let withNUL: [UInt8] = [UInt8.ascii.A, UInt8.ascii.nul, UInt8.ascii.B]
            if let str = String(ascii: withNUL) {
                // Should preserve NUL
                #expect(str.count == 3, "NUL should be preserved in string")
            }
        }

        @Test
        func `all control characters convert and round-trip`() {
            let controls = Array(UInt8.ascii.nul...UInt8.ascii.us) + [UInt8.ascii.del]

            if let str = String(ascii: controls) {
                if let backToBytes = [UInt8](ascii: str) {
                    #expect(backToBytes == controls, "Control characters should round-trip")
                } else {
                    Issue.record("Control characters failed to convert back to bytes")
                }
            } else {
                Issue.record("Control characters failed to convert to string")
            }
        }
    }
}

// MARK: - Performance Torture Tests

extension `Performance Tests` {
    @Suite
    struct `Brutal - Performance Torture` {
        @Test(.timed(threshold: .milliseconds(300)))
        func `validate 1M bytes - all valid`() {
            let massive = Array(repeating: UInt8.ascii.A, count: 1_000_000)
            _ = massive.ascii.isAllASCII
        }

        @Test(.timed(threshold: .milliseconds(50)))
        func `validate 1M bytes - fail at position 0`() {
            var massive = Array(repeating: UInt8.ascii.A, count: 1_000_000)
            massive[0] = 0x80
            _ = massive.ascii.isAllASCII
        }

        @Test(.timed(threshold: .milliseconds(300)))
        func `validate 1M bytes - fail at position 999999`() {
            var massive = Array(repeating: UInt8.ascii.A, count: 1_000_000)
            massive[999_999] = 0x80
            _ = massive.ascii.isAllASCII
        }

        @Test(.timed(threshold: .milliseconds(100)))
        func `case convert 100K byte string - all lowercase`() {
            let str = String(repeating: "abcdefghijklmnopqrstuvwxyz", count: 4000)
            _ = str.ascii(case: .upper)
        }

        @Test(.timed(threshold: .milliseconds(100)))
        func `case convert 100K byte string - all uppercase`() {
            let str = String(repeating: "ABCDEFGHIJKLMNOPQRSTUVWXYZ", count: 4000)
            _ = str.ascii(case: .lower)
        }

        @Test(.timed(threshold: .milliseconds(100)))
        func `normalize 100K byte string with 10K line endings`() {
            let line = "xxxxxxxxxx\n"  // 11 bytes
            let text = String(repeating: line, count: 10000)  // ~110KB
            _ = text.normalized(to: .crlf)
        }

        @Test(.timed(threshold: .milliseconds(50)))
        func `trim string with 10K leading and trailing spaces`() {
            let spaces = String(repeating: " ", count: 10000)
            let text = spaces + "content" + spaces
            _ = text.trimming(.ascii.whitespaces)
        }

        @Test(.timed(threshold: .milliseconds(500)))
        func `character to byte conversion - 100K ASCII characters`() {
            for _ in 0..<100_000 {
                _ = UInt8(ascii: "A" as Character)
                _ = UInt8(ascii: "z" as Character)
                _ = UInt8(ascii: "0" as Character)
            }
        }

        @Test(.timed(threshold: .milliseconds(3000)))
        func `predicate checks on every ASCII byte - 1.28M checks`() {
            // 10K iterations × 128 bytes = 1.28M operations
            // Expected ~270ms based on 4.7M ops/sec
            for _ in 0..<10000 {
                for byte in UInt8(0)...UInt8(127) {
                    _ = byte.ascii.isLetter
                }
            }
        }
    }
}
