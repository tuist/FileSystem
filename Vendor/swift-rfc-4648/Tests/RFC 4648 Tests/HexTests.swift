// HexTests.swift
// swift-rfc-4648
//
// Tests for RFC 4648 Section 8: Base16 (Hexadecimal) Encoding

import RFC_4648
import Testing

@Suite("Hex Encoding Tests")
struct HexTests {
    // MARK: - RFC 4648 Section 10 Test Vectors

    @Test(
        "RFC 4648 test vectors",
        arguments: [
            ("", ""),
            ("f", "66"),
            ("fo", "666f"),
            ("foo", "666f6f"),
            ("foob", "666f6f62"),
            ("fooba", "666f6f6261"),
            ("foobar", "666f6f626172"),
        ]
    )
    func rFCVectors(input: String, expected: String) {
        let bytes = Array(input.utf8)
        let encoded = String.hex(bytes)
        #expect(encoded == expected, "Encoding '\(input)' should produce '\(expected)'")

        let decoded = [UInt8](hexEncoded: encoded)
        #expect(decoded == bytes, "Round-trip failed for '\(input)'")
    }

    // MARK: - Case Tests

    @Test("Hex encoding lowercase by default")
    func lowercaseDefault() {
        let input: [UInt8] = [0xFF, 0xAB, 0xCD]
        let encoded = String.hex(input)
        #expect(encoded == "ffabcd")
    }

    @Test("Hex encoding uppercase when requested")
    func uppercaseOption() {
        let input: [UInt8] = [0xFF, 0xAB, 0xCD]
        let encoded = String.hex(input, uppercase: true)
        #expect(encoded == "FFABCD")
    }

    @Test(
        "Hex decoding is case-insensitive",
        arguments: [
            "ffab",  // lowercase
            "FFAB",  // uppercase
            "FfAb",  // mixed case
            "fFaB",  // random mixed case
        ]
    )
    func decodingCaseInsensitive(encoded: String) {
        let expected: [UInt8] = [0xFF, 0xAB]
        let decoded = [UInt8](hexEncoded: encoded)
        #expect(decoded == expected, "Case-insensitive decoding should work for '\(encoded)'")
    }

    // MARK: - Prefix Tests

    @Test(
        "Hex decoding with various prefix formats",
        arguments: [
            ("0xFF", [0xFF]),
            ("0XFF", [0xFF]),
            ("FF", [0xFF]),
            ("0xDEADBEEF", [0xDE, 0xAD, 0xBE, 0xEF]),
            ("0Xdeadbeef", [0xDE, 0xAD, 0xBE, 0xEF]),
        ]
    )
    func prefixHandling(input: String, expected: [UInt8]) {
        let decoded = [UInt8](hexEncoded: input)
        #expect(decoded == expected, "'\(input)' should decode to \(expected)")
    }

    // MARK: - Whitespace Handling

    @Test(
        "Hex decoding with whitespace",
        arguments: [
            "DE AD BE EF",  // spaces
            "DE\nAD\nBE\nEF",  // newlines
            "DE\tAD\tBE\tEF",  // tabs
            "DE AD\nBE\tEF",  // mixed whitespace
            "DEADBEEF",  // no whitespace
        ]
    )
    func whitespaceHandling(input: String) {
        let expected: [UInt8] = [0xDE, 0xAD, 0xBE, 0xEF]
        let decoded = [UInt8](hexEncoded: input)
        #expect(decoded == expected, "Whitespace should be ignored in '\(input)'")
    }

    // MARK: - Invalid Input Tests

    @Test(
        "Hex decoding rejects invalid input",
        arguments: [
            "GGGG",  // invalid hex characters
            "FFF",  // odd length
            "FF!!",  // special characters
            "#FF5733",  // hash prefix (not valid)
        ]
    )
    func invalidInput(input: String) {
        let decoded = [UInt8](hexEncoded: input)
        #expect(decoded == nil, "\(input) should be rejected")
    }

    // MARK: - Binary Data Tests

    @Test("Hex encoding all byte values")
    func allByteValues() {
        for byte in 0...255 {
            let input: [UInt8] = [UInt8(byte)]
            let encoded = String.hex(input)
            let decoded = [UInt8](hexEncoded: encoded)
            #expect(decoded == input)
        }
    }

    @Test("Hex encoding all zeros")
    func allZeros() {
        let input: [UInt8] = [0x00, 0x00, 0x00]
        let encoded = String.hex(input)
        #expect(encoded == "000000")

        let decoded = [UInt8](hexEncoded: encoded)
        #expect(decoded == input)
    }

    @Test("Hex encoding all ones")
    func allOnes() {
        let input: [UInt8] = [0xFF, 0xFF, 0xFF]
        let encoded = String.hex(input)
        #expect(encoded == "ffffff")

        let decoded = [UInt8](hexEncoded: encoded)
        #expect(decoded == input)
    }

    @Test("Hex encoding sequential bytes")
    func sequentialBytes() {
        let input: [UInt8] = [0x00, 0x01, 0x02, 0x03, 0x04, 0x05]
        let encoded = String.hex(input)
        #expect(encoded == "000102030405")

        let decoded = [UInt8](hexEncoded: encoded)
        #expect(decoded == input)
    }

    // MARK: - Common Use Cases

    @Test("Hex encoding SHA-256 hash")
    func sHA256Hash() {
        // Typical SHA-256 hash: 32 bytes
        let hash: [UInt8] = [
            0xE3, 0xB0, 0xC4, 0x42, 0x98, 0xFC, 0x1C, 0x14,
            0x9A, 0xFB, 0xF4, 0xC8, 0x99, 0x6F, 0xB9, 0x24,
            0x27, 0xAE, 0x41, 0xE4, 0x64, 0x9B, 0x93, 0x4C,
            0xA4, 0x95, 0x99, 0x1B, 0x78, 0x52, 0xB8, 0x55,
        ]

        let encoded = String.hex(hash)
        #expect(encoded.count == 64)  // 32 bytes * 2 chars per byte

        let decoded = [UInt8](hexEncoded: encoded)
        #expect(decoded == hash)
    }

    @Test("Hex encoding UUID bytes")
    func uUIDBytes() {
        // Typical UUID: 16 bytes
        let uuid: [UInt8] = [
            0x12, 0x34, 0x56, 0x78, 0x9A, 0xBC, 0xDE, 0xF0,
            0x12, 0x34, 0x56, 0x78, 0x9A, 0xBC, 0xDE, 0xF0,
        ]

        let encoded = String.hex(uuid)
        let decoded = [UInt8](hexEncoded: encoded)
        #expect(decoded == uuid)
    }

    @Test("Hex encoding color values")
    func colorValues() {
        // RGB color: #FF5733
        let color: [UInt8] = [0xFF, 0x57, 0x33]
        let encoded = String.hex(color, uppercase: true)
        #expect(encoded == "FF5733")

        let decoded = [UInt8](hexEncoded: "#FF5733")
        #expect(decoded == nil)  // # is not valid hex

        let decoded2 = [UInt8](hexEncoded: "FF5733")
        #expect(decoded2 == color)
    }

    // MARK: - Edge Cases

    @Test("Hex round-trip various sizes")
    func roundTripVariousSizes() {
        for size in [1, 2, 10, 100, 1000] {
            let input: [UInt8] = (0..<size).map { UInt8($0 % 256) }
            let encoded = String.hex(input)
            let decoded = [UInt8](hexEncoded: encoded)
            #expect(decoded == input)
        }
    }

    @Test("Hex round-trip long string")
    func testLongString() {
        let longString = String(repeating: "Hello, World! ", count: 100)
        let input = Array(longString.utf8)
        let encoded = String.hex(input)
        let decoded = [UInt8](hexEncoded: encoded)
        #expect(decoded == input)
    }

    // MARK: - Format Variations

    @Test(
        "Hex decoding common format variations",
        arguments: [
            "DEAD",  // standard uppercase
            "0xDEAD",  // with 0x prefix
            "DE AD",  // with spaces
            "dead",  // lowercase
            "DeAd",  // mixed case
            "0xde ad",  // prefix + lowercase + spaces
        ]
    )
    func formatVariations(input: String) {
        let expected: [UInt8] = [0xDE, 0xAD]
        let decoded = [UInt8](hexEncoded: input)
        #expect(decoded == expected, "'\(input)' should decode to \(expected)")
    }

    @Test("Hex encoding produces consistent output")
    func consistentOutput() {
        let input: [UInt8] = [0xAB, 0xCD, 0xEF]

        let encoded1 = String.hex(input)
        let encoded2 = String.hex(input)

        #expect(encoded1 == encoded2)
    }
}
