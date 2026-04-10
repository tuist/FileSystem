// FoundationComparisonTests.swift
// swift-rfc-4648
//
// Tests comparing RFC_4648 implementations against Foundation's implementations

import RFC_4648
import Testing

#if canImport(Foundation)
    import Foundation

    @Suite("Foundation Comparison Tests")
    struct FoundationComparisonTests {
        // MARK: - Base64 Comparison

        @Test("Base64 encoding matches Foundation")
        func base64EncodingMatchesFoundation() {
            let testCases: [[UInt8]] = [
                [],
                Array("f".utf8),
                Array("fo".utf8),
                Array("foo".utf8),
                Array("foob".utf8),
                Array("fooba".utf8),
                Array("foobar".utf8),
                [0x00, 0xFF, 0x80, 0x7F],
                Array("The quick brown fox jumps over the lazy dog".utf8),
                (0..<100).map { UInt8($0 % 256) },
            ]

            for bytes in testCases {
                let ourEncoding = String.base64(bytes, padding: true)
                let foundationEncoding = Data(bytes).base64EncodedString()

                #expect(
                    ourEncoding == foundationEncoding,
                    "Our encoding: \(ourEncoding), Foundation: \(foundationEncoding)"
                )
            }
        }

        @Test("Base64 decoding matches Foundation")
        func base64DecodingMatchesFoundation() {
            let testCases = [
                "",
                "Zg==",
                "Zm8=",
                "Zm9v",
                "Zm9vYg==",
                "Zm9vYmE=",
                "Zm9vYmFy",
                "VGhlIHF1aWNrIGJyb3duIGZveCBqdW1wcyBvdmVyIHRoZSBsYXp5IGRvZw==",
            ]

            for encoded in testCases {
                let ourDecoding = [UInt8](base64Encoded: encoded)
                let foundationDecoding = Data(base64Encoded: encoded).map { Array($0) }

                #expect(
                    ourDecoding == foundationDecoding,
                    "Our decoding: \(String(describing: ourDecoding)), Foundation: \(String(describing: foundationDecoding))"
                )
            }
        }

        @Test("Base64 round-trip matches Foundation")
        func base64RoundTripMatchesFoundation() {
            let testBytes: [[UInt8]] = [
                Array("Hello, World!".utf8),
                (0..<255).map { UInt8($0) },
                Array(repeating: 0xFF, count: 100),
                Array(repeating: 0x00, count: 100),
            ]

            for bytes in testBytes {
                // Our implementation
                let ourEncoded = String.base64(bytes)
                let ourDecoded = [UInt8](base64Encoded: ourEncoded)

                // Foundation implementation
                let foundationEncoded = Data(bytes).base64EncodedString()
                let foundationDecoded = Data(base64Encoded: foundationEncoded).map { Array($0) }

                #expect(ourEncoded == foundationEncoded)
                #expect(ourDecoded == foundationDecoded)
                #expect(ourDecoded == bytes)
            }
        }

        // MARK: - Base64 with Options

        @Test("Base64 encoding with line length matches Foundation")
        func base64WithLineLength() {
            let longBytes = (0..<200).map { UInt8($0 % 256) }

            // Our implementation (single line, no line breaks)
            let ourEncoded = String.base64(longBytes)

            // Foundation implementation without line length
            let foundationEncoded = Data(longBytes).base64EncodedString()

            #expect(ourEncoded == foundationEncoded)
            #expect(!ourEncoded.contains("\n"))
            #expect(!ourEncoded.contains("\r"))
        }

        // MARK: - Invalid Base64

        @Test("Base64 invalid characters rejected by both")
        func invalidCharactersRejected() {
            let invalidChars = "!!!!"  // Invalid characters

            let ourResult = [UInt8](base64Encoded: invalidChars)
            let foundationResult = Data(base64Encoded: invalidChars)

            // Both should reject invalid characters
            #expect(ourResult == nil)
            #expect(foundationResult == nil)
        }

        @Test("Base64 invalid length rejected by both")
        func invalidLengthRejected() {
            let invalidLength = "Zm9"  // Not multiple of 4

            let ourResult = [UInt8](base64Encoded: invalidLength)
            let foundationResult = Data(base64Encoded: invalidLength)

            // Both should reject invalid length
            #expect(ourResult == nil)
            #expect(foundationResult == nil)
        }

        @Test("Base64 edge case padding differences")
        func paddingEdgeCases() {
            // Note: Foundation is more lenient with some padding edge cases
            // Our implementation strictly follows RFC 4648

            // Case 1: Only padding - Foundation accepts, we reject (strict RFC compliance)
            let onlyPadding = "===="
            let ourResult1 = [UInt8](base64Encoded: onlyPadding)
            #expect(ourResult1 == nil, "RFC 4648: Only padding is invalid")

            // Case 2: Too much padding - Foundation may accept, we reject
            let tooMuchPadding = "Zm9v==="
            let ourResult2 = [UInt8](base64Encoded: tooMuchPadding)
            #expect(ourResult2 == nil, "RFC 4648: Too much padding is invalid")
        }

        // MARK: - Edge Cases

        @Test("Base64 whitespace handling - RFC 4648 compliance")
        func whitespaceHandling() {
            // RFC 4648 Section 3.3: "Implementations MUST reject the encoded data if it
            // contains characters outside the base alphabet when interpreting base-encoded
            // data, unless the specification referring to this document explicitly states
            // otherwise."
            //
            // However, Section 3.3 also states: "Implementations MAY choose to ignore
            // white space (SP, HTAB, CR, LF)."
            //
            // Our implementation chooses to ignore whitespace (common practice).
            // Foundation does NOT ignore whitespace in base64 (stricter interpretation).

            let withWhitespace = "Zm9v\nYmFy"
            let withoutWhitespace = "Zm9vYmFy"

            // Our implementation: whitespace is ignored (permitted by RFC 4648)
            let ourDecoded = [UInt8](base64Encoded: withWhitespace)
            #expect(ourDecoded == [UInt8](base64Encoded: withoutWhitespace))
            #expect(ourDecoded == Array("foobar".utf8))

            // Foundation: whitespace causes failure
            let foundationDecoded = Data(base64Encoded: withWhitespace)
            #expect(foundationDecoded == nil, "Foundation rejects whitespace in base64")

            // Both succeed without whitespace
            let ourClean = [UInt8](base64Encoded: withoutWhitespace)
            let foundationClean = Data(base64Encoded: withoutWhitespace).map { Array($0) }
            #expect(ourClean == foundationClean)
        }

        @Test("Base64 empty string handling")
        func emptyStringHandling() {
            let emptyBytes: [UInt8] = []

            let ourEncoded = String.base64(emptyBytes)
            let foundationEncoded = Data(emptyBytes).base64EncodedString()

            #expect(ourEncoded == foundationEncoded)
            #expect(ourEncoded.isEmpty)

            let ourDecoded = [UInt8](base64Encoded: "")
            let foundationDecoded = Data(base64Encoded: "").map { Array($0) }

            #expect(ourDecoded == foundationDecoded)
            #expect(ourDecoded == [])
        }

        // MARK: - Performance Parity

        @Test("Base64 large data matches Foundation")
        func largeDataMatchesFoundation() {
            // Test with 1MB of data
            let largeBytes = (0..<(1024 * 1024)).map { UInt8($0 % 256) }

            let ourEncoded = String.base64(largeBytes)
            let foundationEncoded = Data(largeBytes).base64EncodedString()

            #expect(ourEncoded == foundationEncoded)

            let ourDecoded = [UInt8](base64Encoded: ourEncoded)
            let foundationDecoded = Data(base64Encoded: foundationEncoded).map { Array($0) }

            #expect(ourDecoded == foundationDecoded)
            #expect(ourDecoded == largeBytes)
        }

        // MARK: - Binary Data

        @Test("Base64 all byte values match Foundation")
        func allByteValuesMatchFoundation() {
            let allBytes = (0...255).map { UInt8($0) }

            let ourEncoded = String.base64(allBytes)
            let foundationEncoded = Data(allBytes).base64EncodedString()

            #expect(ourEncoded == foundationEncoded)

            let ourDecoded = [UInt8](base64Encoded: ourEncoded)
            let foundationDecoded = Data(base64Encoded: foundationEncoded).map { Array($0) }

            #expect(ourDecoded == foundationDecoded)
            #expect(ourDecoded == allBytes)
        }

        // MARK: - Hex Comparison (if Foundation provides hex encoding)

        @Test("Hex encoding produces valid output")
        func hexEncodingFormat() {
            let testBytes: [UInt8] = [0x00, 0x0F, 0xFF, 0xAB, 0xCD, 0xEF]

            let ourHex = String.hex(testBytes)

            // Verify format is correct (lowercase hex by default)
            #expect(ourHex == "000fffabcdef")

            // Verify round-trip
            let decoded = [UInt8](hexEncoded: ourHex)
            #expect(decoded == testBytes)
        }

        @Test("Hex uppercase encoding produces valid output")
        func hexUppercaseEncoding() {
            let testBytes: [UInt8] = [0x00, 0x0F, 0xFF, 0xAB, 0xCD, 0xEF]

            let ourHexUpper = String.hex(testBytes, uppercase: true)

            // Verify format is correct (uppercase hex)
            #expect(ourHexUpper == "000FFFABCDEF")

            // Verify round-trip (decoding is case-insensitive)
            let decoded = [UInt8](hexEncoded: ourHexUpper)
            #expect(decoded == testBytes)
        }

        // MARK: - Exhaustive Byte Pattern Tests

        @Test("Base64 all single-byte values match Foundation")
        func allSingleByteValues() {
            for byte in 0...255 {
                let bytes: [UInt8] = [UInt8(byte)]

                let ourEncoded = String.base64(bytes)
                let foundationEncoded = Data(bytes).base64EncodedString()

                #expect(
                    ourEncoded == foundationEncoded,
                    "Mismatch for byte \(byte): our=\(ourEncoded), foundation=\(foundationEncoded)"
                )

                let ourDecoded = [UInt8](base64Encoded: ourEncoded)
                #expect(ourDecoded == bytes)
            }
        }

        @Test("Base64 all two-byte combinations (sampled)")
        func twoBytePatterns() {
            // Test representative two-byte patterns (every 17th to keep test fast)
            for i in stride(from: 0, through: 255, by: 17) {
                for j in stride(from: 0, through: 255, by: 17) {
                    let bytes: [UInt8] = [UInt8(i), UInt8(j)]

                    let ourEncoded = String.base64(bytes)
                    let foundationEncoded = Data(bytes).base64EncodedString()

                    #expect(
                        ourEncoded == foundationEncoded,
                        "Mismatch for [\(i), \(j)]"
                    )
                }
            }
        }

        @Test("Base64 all three-byte combinations (sampled)")
        func threeBytePatterns() {
            // Test representative three-byte patterns
            for i in stride(from: 0, through: 255, by: 51) {
                for j in stride(from: 0, through: 255, by: 51) {
                    for k in stride(from: 0, through: 255, by: 51) {
                        let bytes: [UInt8] = [UInt8(i), UInt8(j), UInt8(k)]

                        let ourEncoded = String.base64(bytes)
                        let foundationEncoded = Data(bytes).base64EncodedString()

                        #expect(ourEncoded == foundationEncoded)
                    }
                }
            }
        }

        // MARK: - Specific Length Tests

        @Test(
            "Base64 specific lengths match Foundation",
            arguments: [
                1, 2, 3, 4, 5, 6, 7, 8, 9, 10,
                15, 16, 17, 31, 32, 33, 63, 64, 65,
                100, 127, 128, 129, 255, 256, 257,
                511, 512, 513, 1000, 1023, 1024, 1025,
            ]
        )
        func specificLengths(length: Int) {
            let bytes = (0..<length).map { UInt8($0 % 256) }

            let ourEncoded = String.base64(bytes)
            let foundationEncoded = Data(bytes).base64EncodedString()

            #expect(
                ourEncoded == foundationEncoded,
                "Length \(length): our=\(ourEncoded.prefix(50))..., foundation=\(foundationEncoded.prefix(50))..."
            )

            let ourDecoded = [UInt8](base64Encoded: ourEncoded)
            let foundationDecoded = Data(base64Encoded: foundationEncoded).map { Array($0) }

            #expect(ourDecoded == foundationDecoded)
            #expect(ourDecoded == bytes)
        }

        // MARK: - Random Data Tests

        @Test("Base64 random data patterns match Foundation")
        func randomDataPatterns() {
            // Use seeded random for reproducibility
            var generator = SeededRandomNumberGenerator(seed: 42)

            for _ in 0..<100 {
                let length = Int.random(in: 1...500, using: &generator)
                let bytes = (0..<length).map { _ in UInt8.random(in: 0...255, using: &generator) }

                let ourEncoded = String.base64(bytes)
                let foundationEncoded = Data(bytes).base64EncodedString()

                #expect(ourEncoded == foundationEncoded)

                let ourDecoded = [UInt8](base64Encoded: ourEncoded)
                #expect(ourDecoded == bytes)
            }
        }

        // MARK: - UTF-8 String Tests

        @Test(
            "Base64 UTF-8 strings match Foundation",
            arguments: [
                "Hello, World!",
                "The quick brown fox jumps over the lazy dog",
                "1234567890",
                "!@#$%^&*()_+-=[]{}|;':\",./<>?",
                "αβγδεζηθικλμνξοπρστυφχψω",  // Greek
                "你好世界",  // Chinese
                "こんにちは世界",  // Japanese
                "🚀🌟💻🎉🔥",  // Emojis
                "Iñtërnâtiônàlizætiøn",  // Accented characters
                "",  // Empty
                " ",  // Single space
                "\n\r\t",  // Whitespace characters
                String(repeating: "A", count: 1000),  // Long repetitive
                String(repeating: "😀", count: 100),  // Emoji repetition
            ]
        )
        func uTF8Strings(input: String) {
            let bytes = Array(input.utf8)

            let ourEncoded = String.base64(bytes)
            let foundationEncoded = Data(bytes).base64EncodedString()

            #expect(
                ourEncoded == foundationEncoded,
                "Input: \(input.prefix(50))"
            )

            let ourDecoded = [UInt8](base64Encoded: ourEncoded)
            let foundationDecoded = Data(base64Encoded: foundationEncoded).map { Array($0) }

            #expect(ourDecoded == foundationDecoded)
            #expect(ourDecoded == bytes)
        }

        // MARK: - Padding Variation Tests

        @Test(
            "Base64 padding scenarios match Foundation",
            arguments: [
                (1, "AA=="),  // 2 padding chars
                (2, "AAA="),  // 1 padding char
                (3, "AAAA"),  // 0 padding chars
                (4, "AAAAAA=="),  // 2 padding chars
                (5, "AAAAAAA="),  // 1 padding char
                (6, "AAAAAAAA"),  // 0 padding chars
            ]
        )
        func paddingScenarios(length: Int, expectedPattern: String) {
            let bytes = Array(repeating: UInt8(0), count: length)

            let ourEncoded = String.base64(bytes)
            let foundationEncoded = Data(bytes).base64EncodedString()

            #expect(ourEncoded == foundationEncoded)
            #expect(ourEncoded == expectedPattern)
        }

        // MARK: - BinaryInteger Encoding Tests

        @Test("Base64 BinaryInteger UInt8 values match Foundation")
        func binaryIntegerUInt8() {
            for value in [UInt8.min, 1, 127, 128, 255, UInt8.max] {
                let bytes = withUnsafeBytes(of: value.bigEndian) { Array($0) }

                let ourEncoded = String.base64(value)
                let foundationEncoded = Data(bytes).base64EncodedString()

                #expect(
                    ourEncoded == foundationEncoded,
                    "UInt8(\(value)): our=\(ourEncoded), foundation=\(foundationEncoded)"
                )
            }
        }

        @Test("Base64 BinaryInteger UInt16 values match Foundation")
        func binaryIntegerUInt16() {
            let values: [UInt16] = [0, 1, 255, 256, 32767, 32768, 65535, UInt16.max]

            for value in values {
                let bytes = withUnsafeBytes(of: value.bigEndian) { Array($0) }

                let ourEncoded = String.base64(value)
                let foundationEncoded = Data(bytes).base64EncodedString()

                #expect(
                    ourEncoded == foundationEncoded,
                    "UInt16(\(value)): our=\(ourEncoded), foundation=\(foundationEncoded)"
                )
            }
        }

        @Test("Base64 BinaryInteger UInt32 values match Foundation")
        func binaryIntegerUInt32() {
            let values: [UInt32] = [
                0, 1, 255, 256, 65535, 65536,
                123_456, 0xDEAD_BEEF, 0x1234_5678,
                UInt32.max,
            ]

            for value in values {
                let bytes = withUnsafeBytes(of: value.bigEndian) { Array($0) }

                let ourEncoded = String.base64(value)
                let foundationEncoded = Data(bytes).base64EncodedString()

                #expect(
                    ourEncoded == foundationEncoded,
                    "UInt32(\(value)): our=\(ourEncoded), foundation=\(foundationEncoded)"
                )
            }
        }

        @Test("Base64 BinaryInteger UInt64 values match Foundation")
        func binaryIntegerUInt64() {
            let values: [UInt64] = [
                0, 1, 255, 256, 65535, 65536,
                UInt64(UInt32.max),
                0x1234_5678_9ABC_DEF0,
                UInt64.max,
            ]

            for value in values {
                let bytes = withUnsafeBytes(of: value.bigEndian) { Array($0) }

                let ourEncoded = String.base64(value)
                let foundationEncoded = Data(bytes).base64EncodedString()

                #expect(
                    ourEncoded == foundationEncoded,
                    "UInt64(\(value)): our=\(ourEncoded), foundation=\(foundationEncoded)"
                )
            }
        }

        // MARK: - Boundary and Edge Cases

        @Test("Base64 consecutive byte values match Foundation")
        func consecutiveByteValues() {
            for start in stride(from: 0, through: 200, by: 50) {
                let length = 55
                let bytes = (start..<min(start + length, 256)).map { UInt8($0) }

                let ourEncoded = String.base64(bytes)
                let foundationEncoded = Data(bytes).base64EncodedString()

                #expect(ourEncoded == foundationEncoded)
            }
        }

        @Test("Base64 alternating patterns match Foundation")
        func alternatingPatterns() {
            let patterns: [[UInt8]] = [
                Array(repeating: [0x00, 0xFF], count: 50).flatMap { $0 },
                Array(repeating: [0xAA, 0x55], count: 50).flatMap { $0 },
                Array(repeating: [0x00, 0x80, 0xFF], count: 50).flatMap { $0 },
                (0..<100).map { UInt8($0 % 2 == 0 ? 0xFF : 0x00) },
            ]

            for pattern in patterns {
                let ourEncoded = String.base64(pattern)
                let foundationEncoded = Data(pattern).base64EncodedString()

                #expect(ourEncoded == foundationEncoded)
            }
        }

        @Test("Base64 powers of two lengths match Foundation")
        func powersOfTwoLengths() {
            for power in 0...10 {
                let length = 1 << power  // 1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024
                let bytes = (0..<length).map { UInt8($0 % 256) }

                let ourEncoded = String.base64(bytes)
                let foundationEncoded = Data(bytes).base64EncodedString()

                #expect(
                    ourEncoded == foundationEncoded,
                    "Length 2^\(power) = \(length)"
                )
            }
        }

        // MARK: - Decoding Edge Cases

        @Test("Base64 decode various valid inputs match Foundation")
        func decodeVariousValidInputs() {
            let validInputs = [
                "YQ==",  // "a"
                "YWI=",  // "ab"
                "YWJj",  // "abc"
                "YWJjZA==",  // "abcd"
                "dGVzdA==",  // "test"
                "SGVsbG8gV29ybGQh",  // "Hello World!"
                "AAAA",  // zeros
                "////",  // all 1s in certain bits
                "++++",  // plus signs
                "MDEyMzQ1Njc4OQ==",  // "0123456789"
            ]

            for encoded in validInputs {
                let ourDecoded = [UInt8](base64Encoded: encoded)
                let foundationDecoded = Data(base64Encoded: encoded).map { Array($0) }

                #expect(
                    ourDecoded == foundationDecoded,
                    "Decoding '\(encoded)'"
                )
            }
        }

        @Test("Base64 decode with padding matches Foundation")
        func decodeWithPadding() {
            // Both our implementation and Foundation require proper 4-byte alignment
            // (padding to make the input length a multiple of 4)

            let testCases: [(padded: String, expected: [UInt8])] = [
                ("YQ==", Array("a".utf8)),  // 1 byte
                ("YWI=", Array("ab".utf8)),  // 2 bytes
                ("YWJj", Array("abc".utf8)),  // 3 bytes (no padding needed)
                ("YWJjZA==", Array("abcd".utf8)),  // 4 bytes
            ]

            for (padded, expectedBytes) in testCases {
                // Our implementation
                let ourDecoded = [UInt8](base64Encoded: padded)

                // Foundation implementation
                let foundationDecoded = Data(base64Encoded: padded).map { Array($0) }

                // Both should succeed with properly padded input
                #expect(ourDecoded != nil, "Our implementation should decode '\(padded)'")
                #expect(foundationDecoded != nil, "Foundation should decode '\(padded)'")

                // Both should produce the same result
                #expect(
                    ourDecoded == foundationDecoded,
                    "Results should match for '\(padded)'"
                )

                // Both should match expected output
                #expect(
                    ourDecoded == expectedBytes,
                    "Should decode to expected bytes"
                )
            }
        }

        // MARK: - Stress Tests

        @Test("Base64 very large data matches Foundation")
        func veryLargeData() {
            // Test with 10MB of data
            let largeSize = 10 * 1024 * 1024
            let largeBytes = (0..<largeSize).map { UInt8($0 % 256) }

            let ourEncoded = String.base64(largeBytes)
            let foundationEncoded = Data(largeBytes).base64EncodedString()

            #expect(
                ourEncoded == foundationEncoded,
                "10MB encoding should match"
            )

            // Verify length is correct
            let expectedLength = ((largeSize + 2) / 3) * 4
            #expect(ourEncoded.count == expectedLength)
            #expect(foundationEncoded.count == expectedLength)
        }

        @Test("Base64 repetitive patterns at scale match Foundation")
        func repetitivePatternsAtScale() {
            let patterns: [[UInt8]] = [
                Array(repeating: 0x00, count: 10000),
                Array(repeating: 0xFF, count: 10000),
                Array(repeating: 0xAA, count: 10000),
                Array(repeating: 0x55, count: 10000),
            ]

            for pattern in patterns {
                let ourEncoded = String.base64(pattern)
                let foundationEncoded = Data(pattern).base64EncodedString()

                #expect(ourEncoded == foundationEncoded)
            }
        }
    }

    // MARK: - Helper Types

    /// Seeded random number generator for reproducible tests
    struct SeededRandomNumberGenerator: RandomNumberGenerator {
        private var state: UInt64

        init(seed: UInt64) {
            state = seed
        }

        mutating func next() -> UInt64 {
            // Simple LCG (Linear Congruential Generator)
            state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
            return state
        }
    }

#endif
