// Base64URLTests.swift
// swift-rfc-4648
//
// Tests for RFC 4648 Section 5: Base64URL Encoding (URL and filename safe)

import RFC_4648
import Testing

@Suite("Base64URL Encoding Tests")
struct Base64URLTests {
    // MARK: - Basic Encoding/Decoding

    @Test(
        "Base64URL basic patterns",
        arguments: [
            ([], ""),  // empty string
            (Array("hello".utf8), nil),  // simple string - verify round-trip only
        ]
    )
    func basicPatterns(input: [UInt8], expectedEncoded: String?) {
        let encoded = String.base64.url(input)

        if let expected = expectedEncoded {
            #expect(encoded == expected)
        }

        let decoded = [UInt8](base64URLEncoded: encoded)
        #expect(decoded == input)
    }

    // MARK: - URL Safety Tests

    @Test("Base64URL uses URL-safe characters")
    func uRLSafeCharacters() {
        // This input would produce '+' and '/' in standard Base64
        let input: [UInt8] = [0xFB, 0xFF, 0xFF]
        let encoded = String.base64.url(input)

        // Base64URL should use '-' and '_' instead of '+' and '/'
        #expect(encoded.contains("-") || encoded.contains("_"))
        #expect(!encoded.contains("+"))
        #expect(!encoded.contains("/"))

        let decoded = [UInt8](base64URLEncoded: encoded)
        #expect(decoded == input)
    }

    @Test("Base64URL with special chars")
    func specialCharacterSubstitution() {
        // Input that produces all special chars in Base64URL
        let input: [UInt8] = [0xFF, 0xFF]
        let encoded = String.base64.url(input)

        // Should contain '_' (not '/')
        #expect(encoded.contains("_"))
        #expect(!encoded.contains("/"))
    }

    // MARK: - Padding Tests (RFC 7515 recommends no padding)

    @Test(
        "Base64URL padding variations",
        arguments: [
            (Array("f".utf8), false, "Zg", false),  // default: no padding
            (Array("f".utf8), true, "Zg==", true),  // explicit padding
            (Array("fo".utf8), false, "Zm8", false),  // no padding
            (Array("fo".utf8), true, "Zm8=", true),  // with padding
            (Array("foo".utf8), false, "Zm9v", false),  // no padding needed
        ]
    )
    func paddingVariations(
        input: [UInt8], padding: Bool, expectedEncoded: String, shouldHavePadding: Bool
    ) {
        let encoded = String.base64.url(input, padding: padding)
        #expect(encoded == expectedEncoded)
        #expect(encoded.contains("=") == shouldHavePadding)

        // Decoding should work both with and without padding
        let decoded = [UInt8](base64URLEncoded: encoded)
        #expect(decoded == input)
    }

    // MARK: - Whitespace Handling

    @Test("Base64URL decoding with whitespace")
    func whitespaceHandling() {
        let input = "Zm9v\nYmFy"
        let decoded = [UInt8](base64URLEncoded: input)
        #expect(decoded == Array("foobar".utf8))
    }

    // MARK: - Invalid Input Tests

    @Test(
        "Base64URL decoding rejects invalid input",
        arguments: [
            "Zg+A",  // '+' not valid in Base64URL
            "Zg/A",  // '/' not valid in Base64URL
            "Zm9v!!!!",  // special characters
            "Z",  // too short
        ]
    )
    func invalidInput(input: String) {
        let decoded = [UInt8](base64URLEncoded: input)
        #expect(decoded == nil, "\(input) should be rejected")
    }

    // MARK: - JWT Use Case

    @Test("Base64URL JWT header example")
    func jWTHeader() {
        // Typical JWT header: {"alg":"HS256","typ":"JWT"}
        let headerJSON = Array("{\"alg\":\"HS256\",\"typ\":\"JWT\"}".utf8)
        let encoded = String.base64.url(headerJSON, padding: false)

        // Should not contain URL-unsafe characters
        #expect(!encoded.contains("+"))
        #expect(!encoded.contains("/"))
        #expect(!encoded.contains("="))

        let decoded = [UInt8](base64URLEncoded: encoded)
        #expect(decoded == headerJSON)
    }

    // MARK: - Binary Data Tests

    @Test("Base64URL binary data")
    func binaryData() {
        let input: [UInt8] = [0x00, 0xFF, 0x80, 0x7F, 0x3E, 0x3F]
        let encoded = String.base64.url(input)
        let decoded = [UInt8](base64URLEncoded: encoded)
        #expect(decoded == input)
    }

    @Test("Base64URL all special characters")
    func allSpecialCharacters() {
        // Input that generates maximum special chars
        let input: [UInt8] = [0xFF, 0xEF, 0xFF, 0xEF]
        let encoded = String.base64.url(input)

        // Should use '_' and '-' not '/' and '+'
        if encoded.contains("_") {
            #expect(!encoded.contains("/"))
        }
        if encoded.contains("-") {
            #expect(!encoded.contains("+"))
        }

        let decoded = [UInt8](base64URLEncoded: encoded)
        #expect(decoded == input)
    }

    // MARK: - Edge Cases

    @Test("Base64URL round-trip long string")
    func testLongString() {
        let longString = String(repeating: "Hello, World! ", count: 100)
        let input = Array(longString.utf8)
        let encoded = String.base64.url(input, padding: false)
        let decoded = [UInt8](base64URLEncoded: encoded)
        #expect(decoded == input)
    }

    // MARK: - Comparison with Standard Base64

    @Test("Base64URL produces different output than Base64 for special chars")
    func differentFromBase64() {
        let input: [UInt8] = [0xFF, 0xFF]

        // Use padding for Base64 (standard Base64 requires it for decoding)
        let base64 = String.base64(input, padding: true)
        let base64url = String.base64.url(input, padding: false)

        // They should differ when special chars are present
        #expect(base64 != base64url)

        // Both should decode correctly with their respective decoders
        #expect([UInt8](base64Encoded: base64) == input)
        #expect([UInt8](base64URLEncoded: base64url) == input)
    }
}
