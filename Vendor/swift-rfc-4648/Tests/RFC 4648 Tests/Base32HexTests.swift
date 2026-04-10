// Base32HexTests.swift
// swift-rfc-4648
//
// Tests for RFC 4648 Section 7: Base32-HEX Encoding (Extended Hex Alphabet)

import RFC_4648
import Testing

@Suite("Base32-HEX Encoding Tests")
struct Base32HexTests {
    // MARK: - RFC 4648 Section 10 Test Vectors

    @Test(
        "RFC 4648 test vectors",
        arguments: [
            ("", ""),
            ("f", "CO======"),
            ("fo", "CPNG===="),
            ("foo", "CPNMU==="),
            ("foob", "CPNMUOG="),
            ("fooba", "CPNMUOJ1"),
            ("foobar", "CPNMUOJ1E8======"),
        ]
    )
    func rFCVectors(input: String, expected: String) {
        let bytes = Array(input.utf8)
        let encoded = String.base32.hex(bytes)
        #expect(encoded == expected, "Encoding '\(input)' should produce '\(expected)'")

        let decoded = [UInt8](base32HexEncoded: encoded)
        #expect(decoded == bytes, "Round-trip failed for '\(input)'")
    }

    // MARK: - Alphabet Tests

    @Test("Base32-HEX uses correct alphabet (0-9, A-V)")
    func alphabetRange() {
        let input: [UInt8] = Array("The quick brown fox jumps over the lazy dog".utf8)
        let encoded = String.base32.hex(input, padding: false)

        for char in encoded {
            let isValid = (char >= "0" && char <= "9") || (char >= "A" && char <= "V")
            #expect(isValid)
        }
    }

    @Test("Base32-HEX differs from Base32")
    func differentFromBase32() {
        let input: [UInt8] = Array("foo".utf8)

        let base32 = String.base32(input, padding: false)
        let base32hex = String.base32.hex(input, padding: false)

        // Different encodings
        #expect(base32 != base32hex)

        // But both decode correctly
        #expect([UInt8](base32Encoded: base32) == input)
        #expect([UInt8](base32HexEncoded: base32hex) == input)
    }

    // MARK: - Case Insensitivity Tests

    @Test(
        "Base32-HEX decoding is case-insensitive",
        arguments: [
            "CPNMU===",  // uppercase
            "cpnmu===",  // lowercase
            "CpNmU===",  // mixed case
            "cPnMu===",  // random mixed case
        ]
    )
    func caseInsensitive(encoded: String) {
        let expected: [UInt8] = Array("foo".utf8)
        let decoded = [UInt8](base32HexEncoded: encoded)
        #expect(decoded == expected, "Case-insensitive decoding should work for '\(encoded)'")
    }

    @Test("Base32-HEX encoding produces uppercase")
    func encodingProducesUppercase() {
        let input: [UInt8] = Array("hello".utf8)
        let encoded = String.base32.hex(input)

        // All letters should be uppercase (A-V)
        for char in encoded {
            if char.isLetter {
                #expect(char.isUppercase)
            }
        }
    }

    // MARK: - Padding Tests

    @Test(
        "Base32-HEX padding variations",
        arguments: [
            (Array("f".utf8), false, "CO", false),  // no padding
            (Array("f".utf8), true, "CO======", true),  // with padding
            (Array("foo".utf8), false, "CPNMU", false),  // no padding
            (Array("foo".utf8), true, "CPNMU===", true),  // with padding
        ]
    )
    func paddingVariations(
        input: [UInt8], padding: Bool, expectedEncoded: String, shouldHavePadding: Bool
    ) {
        let encoded = String.base32.hex(input, padding: padding)
        #expect(encoded == expectedEncoded)
        #expect(encoded.contains("=") == shouldHavePadding)

        // Decoding should work both with and without padding
        let decoded = [UInt8](base32HexEncoded: encoded)
        #expect(decoded == input)
    }

    // MARK: - Whitespace Handling

    @Test(
        "Base32-HEX whitespace handling",
        arguments: [
            "CPNMU===\nCPNG====",  // newline
            "CPNMU===\t\tCPNG====",  // tabs
            "CPNMU=== CPNG====",  // space
            "CPNMU=== \t CPNG====",  // mixed
        ]
    )
    func whitespaceHandling(input: String) {
        let decoded = [UInt8](base32HexEncoded: input)
        #expect(decoded != nil, "Whitespace should be ignored in '\(input)'")
    }

    // MARK: - Invalid Input Tests

    @Test(
        "Base32-HEX decoding rejects invalid input",
        arguments: [
            "CPNMW===",  // Base32-HEX doesn't use W
            "CPNMZ===",  // Base32-HEX doesn't use Z
            "C",  // invalid length (too short)
            "CPNM!@#$",  // special characters
            "========",  // only padding
        ]
    )
    func invalidInput(input: String) {
        let decoded = [UInt8](base32HexEncoded: input)
        #expect(decoded == nil, "\(input) should be rejected")
    }

    // MARK: - Binary Data Tests

    @Test(
        "Base32-HEX binary data patterns",
        arguments: [
            ([0x00, 0xFF, 0x80, 0x7F], nil),  // mixed binary
            ([0x00, 0x00, 0x00, 0x00, 0x00], "00000000"),  // all zeros
            ([0x00, 0x01, 0x02, 0x03, 0x04], nil),  // sequential
            ([0xFF, 0xFF, 0xFF, 0xFF, 0xFF], nil),  // all ones
        ]
    )
    func binaryDataPatterns(input: [UInt8], expectedEncoded: String?) {
        let encoded = String.base32.hex(input)

        if let expected = expectedEncoded {
            #expect(encoded == expected)
        }

        let decoded = [UInt8](base32HexEncoded: encoded)
        #expect(decoded == input)
    }

    // MARK: - Edge Cases

    @Test("Base32-HEX round-trip various sizes")
    func roundTripVariousSizes() {
        for size in [1, 2, 3, 4, 5, 10, 20, 50, 100] {
            let input: [UInt8] = (0..<size).map { UInt8($0 % 256) }
            let encoded = String.base32.hex(input)
            let decoded = [UInt8](base32HexEncoded: encoded)
            #expect(decoded == input)
        }
    }

    @Test("Base32-HEX round-trip long string")
    func testLongString() {
        let longString = String(repeating: "Hello, World! ", count: 100)
        let input = Array(longString.utf8)
        let encoded = String.base32.hex(input)
        let decoded = [UInt8](base32HexEncoded: encoded)
        #expect(decoded == input)
    }

    // MARK: - Lexicographic Ordering

    @Test("Base32-HEX maintains lexicographic order")
    func lexicographicOrder() {
        // Base32-HEX is designed so encoded values maintain the same order as input
        let input1: [UInt8] = [0x00]
        let input2: [UInt8] = [0x01]
        let input3: [UInt8] = [0xFF]

        let encoded1 = String.base32.hex(input1, padding: false)
        let encoded2 = String.base32.hex(input2, padding: false)
        let encoded3 = String.base32.hex(input3, padding: false)

        // Lexicographic order should be preserved
        #expect(encoded1 < encoded2)
        #expect(encoded2 < encoded3)
    }
}
