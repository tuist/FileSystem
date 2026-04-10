// Base32Tests.swift
// swift-rfc-4648
//
// Tests for RFC 4648 Section 6: Base32 Encoding

import RFC_4648
import Testing

@Suite("Base32 Encoding Tests")
struct Base32Tests {
    // MARK: - RFC 4648 Section 10 Test Vectors

    @Test(
        "RFC 4648 test vectors",
        arguments: [
            ("", ""),
            ("f", "MY======"),
            ("fo", "MZXQ===="),
            ("foo", "MZXW6==="),
            ("foob", "MZXW6YQ="),
            ("fooba", "MZXW6YTB"),
            ("foobar", "MZXW6YTBOI======"),
        ]
    )
    func rFCVectors(input: String, expected: String) {
        let bytes = Array(input.utf8)
        let encoded = String.base32(bytes)
        #expect(encoded == expected, "Encoding '\(input)' should produce '\(expected)'")

        let decoded = [UInt8](base32Encoded: encoded)
        #expect(decoded == bytes, "Round-trip failed for '\(input)'")
    }

    // MARK: - Case Insensitivity Tests

    @Test(
        "Base32 decoding is case-insensitive",
        arguments: [
            "MZXW6===",  // uppercase
            "mzxw6===",  // lowercase
            "MzXw6===",  // mixed case
            "mZxW6===",  // random mixed case
        ]
    )
    func caseInsensitive(encoded: String) {
        let expected: [UInt8] = Array("foo".utf8)
        let decoded = [UInt8](base32Encoded: encoded)
        #expect(decoded == expected, "Case-insensitive decoding should work for '\(encoded)'")
    }

    @Test("Base32 encoding produces uppercase")
    func encodingProducesUppercase() {
        let input: [UInt8] = Array("hello".utf8)
        let encoded = String.base32(input)

        // All letters should be uppercase (A-Z)
        for char in encoded {
            if char.isLetter {
                #expect(char.isUppercase)
            }
        }
    }

    // MARK: - Padding Tests

    @Test(
        "Base32 padding variations",
        arguments: [
            (Array("f".utf8), false, "MY", false),  // no padding
            (Array("f".utf8), true, "MY======", true),  // with padding
            (Array("foo".utf8), false, "MZXW6", false),  // no padding
            (Array("foo".utf8), true, "MZXW6===", true),  // with padding
        ]
    )
    func paddingVariations(
        input: [UInt8], padding: Bool, expectedEncoded: String, shouldHavePadding: Bool
    ) {
        let encoded = String.base32(input, padding: padding)
        #expect(encoded == expectedEncoded)
        #expect(encoded.contains("=") == shouldHavePadding)

        // Decoding should work both with and without padding
        let decoded = [UInt8](base32Encoded: encoded)
        #expect(decoded == input)
    }

    // MARK: - Whitespace Handling

    @Test(
        "Base32 whitespace handling",
        arguments: [
            "MZXW6===\nYTBOI===",  // newline
            "MZXW6=== \tMZXQ====",  // space and tab
            "MZXW6===\t\tMZXQ====",  // multiple tabs
            "MZXW6=== MZXQ====",  // space only
        ]
    )
    func whitespaceHandling(input: String) {
        let decoded = [UInt8](base32Encoded: input)
        #expect(decoded != nil, "Whitespace should be ignored in '\(input)'")
    }

    // MARK: - Invalid Input Tests

    @Test(
        "Base32 decoding rejects invalid input",
        arguments: [
            "MZXW0===",  // Base32 doesn't use 0
            "MZXW1===",  // Base32 doesn't use 1
            "MZXW8===",  // Base32 doesn't use 8
            "MZXW9===",  // Base32 doesn't use 9
            "M",  // invalid length (too short)
            "MZXW!@#$",  // special characters
            "========",  // only padding
        ]
    )
    func invalidInput(input: String) {
        let decoded = [UInt8](base32Encoded: input)
        #expect(decoded == nil, "\(input) should be rejected")
    }

    // MARK: - Alphabet Tests

    @Test("Base32 uses correct alphabet (A-Z, 2-7)")
    func alphabetRange() {
        // Test that all characters in encoding are within A-Z, 2-7 range
        let input: [UInt8] = Array("The quick brown fox jumps over the lazy dog".utf8)
        let encoded = String.base32(input, padding: false)

        for char in encoded {
            let isValid = (char >= "A" && char <= "Z") || (char >= "2" && char <= "7")
            #expect(isValid)
        }
    }

    // MARK: - Binary Data Tests

    @Test(
        "Base32 binary data patterns",
        arguments: [
            ([0x00, 0xFF, 0x80, 0x7F], nil),  // mixed binary
            ([0x00, 0x00, 0x00, 0x00, 0x00], "AAAAAAAA"),  // all zeros
            ([0x00, 0x01, 0x02, 0x03, 0x04], nil),  // sequential bytes
        ]
    )
    func binaryDataPatterns(input: [UInt8], expectedEncoded: String?) {
        let encoded = String.base32(input)

        if let expected = expectedEncoded {
            #expect(encoded == expected)
        }

        let decoded = [UInt8](base32Encoded: encoded)
        #expect(decoded == input)
    }

    // MARK: - TOTP/HOTP Use Cases

    @Test("Base32 secret key (typical TOTP use)")
    func tOTPSecretKey() {
        // Typical TOTP secret: 20 random bytes
        let secret: [UInt8] = [
            0x48, 0x65, 0x6C, 0x6C, 0x6F, 0x21, 0xDE, 0xAD,
            0xBE, 0xEF, 0x48, 0x65, 0x6C, 0x6C, 0x6F, 0x21,
            0xDE, 0xAD, 0xBE, 0xEF,
        ]

        let encoded = String.base32(secret, padding: false)

        // Should be decodable case-insensitively
        let decoded = [UInt8](base32Encoded: encoded.lowercased())
        #expect(decoded == secret)
    }

    // MARK: - Edge Cases

    @Test("Base32 round-trip various sizes")
    func roundTripVariousSizes() {
        for size in [1, 2, 3, 4, 5, 10, 20, 50, 100] {
            let input: [UInt8] = (0..<size).map { UInt8($0 % 256) }
            let encoded = String.base32(input)
            let decoded = [UInt8](base32Encoded: encoded)
            #expect(decoded == input)
        }
    }

    @Test("Base32 round-trip long string")
    func testLongString() {
        let longString = String(repeating: "Hello, World! ", count: 100)
        let input = Array(longString.utf8)
        let encoded = String.base32(input)
        let decoded = [UInt8](base32Encoded: encoded)
        #expect(decoded == input)
    }
}
