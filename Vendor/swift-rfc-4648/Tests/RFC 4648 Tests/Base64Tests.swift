// Base64Tests.swift
// swift-rfc-4648
//
// Tests for RFC 4648 Section 4: Base64 Encoding

import RFC_4648
import Testing

@Suite("Base64 Encoding Tests")
struct Base64Tests {
    // MARK: - RFC 4648 Section 10 Test Vectors

    @Test(
        "RFC 4648 test vectors",
        arguments: [
            ("", ""),
            ("f", "Zg=="),
            ("fo", "Zm8="),
            ("foo", "Zm9v"),
            ("foob", "Zm9vYg=="),
            ("fooba", "Zm9vYmE="),
            ("foobar", "Zm9vYmFy"),
        ]
    )
    func rFCVectors(input: String, expected: String) {
        let bytes = Array(input.utf8)
        let encoded = String.base64(bytes)
        #expect(encoded == expected, "Encoding '\(input)' should produce '\(expected)'")

        let decoded = [UInt8](base64Encoded: encoded)
        #expect(decoded == bytes, "Round-trip failed for '\(input)'")
    }

    // MARK: - Padding Tests

    @Test(
        "Base64 padding variations",
        arguments: [
            (Array("f".utf8), false, "Zg", [UInt8]?.none),  // no padding - decoding fails
            (Array("f".utf8), true, "Zg==", Array("f".utf8)),  // with padding - succeeds
            (Array("fo".utf8), false, "Zm8", [UInt8]?.none),  // no padding - fails
            (Array("fo".utf8), true, "Zm8=", Array("fo".utf8)),  // with padding - succeeds
            (Array("foo".utf8), false, "Zm9v", Array("foo".utf8)),  // no padding needed
            //            (Array("foo".utf8), true, "Zm9v", Array("foo".utf8)),  // padding doesn't hurt
        ]
    )
    func paddingVariations(
        input: [UInt8],
        padding: Bool,
        expectedEncoded: String,
        expectedDecoded: [UInt8]?
    ) {
        let encoded = String.base64(input, padding: padding)
        #expect(encoded == expectedEncoded)

        let decoded = [UInt8](base64Encoded: encoded)
        #expect(decoded == expectedDecoded)
    }

    // MARK: - Whitespace Handling

    @Test(
        "Base64 decoding with whitespace",
        arguments: [
            "Zm9v\nYmFy",  // newline
            "Zm9v\tYmFy",  // tab
            "Zm9v YmFy",  // space
            "Zm9v\n\t YmFy",  // mixed whitespace
        ]
    )
    func whitespaceHandling(input: String) {
        let decoded = [UInt8](base64Encoded: input)
        #expect(decoded == Array("foobar".utf8), "Whitespace should be ignored")
    }

    // MARK: - Invalid Input Tests

    @Test(
        "Base64 decoding rejects invalid input",
        arguments: [
            "Zm9v!!!!",  // invalid characters
            "Zm9",  // invalid length (not multiple of 4)
            "====",  // only padding
            "Z",  // too short
        ]
    )
    func invalidInput(input: String) {
        let decoded = [UInt8](base64Encoded: input)
        #expect(decoded == nil, "\(input) should be rejected")
    }

    // MARK: - Binary Data Tests

    @Test(
        "Base64 binary data patterns",
        arguments: [
            ([0x00, 0xFF, 0x80, 0x7F], nil),  // mixed binary data
            ([0x00, 0x00, 0x00], "AAAA"),  // all zeros
            ([0xFF, 0xFF, 0xFF], "////"),  // all ones
        ]
    )
    func binaryDataPatterns(input: [UInt8], expectedEncoded: String?) {
        let encoded = String.base64(input)

        if let expected = expectedEncoded {
            #expect(encoded == expected)
        }

        let decoded = [UInt8](base64Encoded: encoded)
        #expect(decoded == input)
    }

    // MARK: - Edge Cases

    @Test("Base64 round-trip long string")
    func testLongString() {
        let longString = String(repeating: "Hello, World! ", count: 100)
        let input = Array(longString.utf8)
        let encoded = String.base64(input)
        let decoded = [UInt8](base64Encoded: encoded)
        #expect(decoded == input)
    }
}
