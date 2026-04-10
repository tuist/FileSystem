// ValidationTests.swift
// swift-rfc-4648
//
// Tests for RFC 4648 validation methods

import Testing

@testable import RFC_4648

@Suite("RFC 4648 Validation Tests")
struct ValidationTests {
    // MARK: - Base64 Validation

    @Test(
        "Valid Base64 strings",
        arguments: [
            "",
            "Zg==",
            "Zm8=",
            "Zm9v",
            "Zm9vYg==",
            "Zm9vYmE=",
            "Zm9vYmFy",
            "VGhlIHF1aWNrIGJyb3duIGZveCBqdW1wcyBvdmVyIHRoZSBsYXp5IGRvZw==",
        ]
    )
    func validBase64(input: String) {
        #expect(RFC_4648.Base64.isValid(input), "\(input) should be valid Base64")
    }

    @Test(
        "Invalid Base64 strings",
        arguments: [
            "!@#$",
            "Zm9",  // Invalid length
            "====",  // Only padding
            "Z!9v",  // Invalid character
            "Zm9v===",  // Too much padding
        ]
    )
    func invalidBase64(input: String) {
        #expect(!RFC_4648.Base64.isValid(input), "\(input) should be invalid Base64")
    }

    @Test("Base64 validation with whitespace")
    func base64ValidationWithWhitespace() {
        // Our implementation allows whitespace
        #expect(RFC_4648.Base64.isValid("Zm9v\nYmFy"))
        #expect(RFC_4648.Base64.isValid("Zm9v YmFy"))
        #expect(RFC_4648.Base64.isValid("Zm9v\tYmFy"))
    }

    // MARK: - Base64URL Validation

    @Test(
        "Valid Base64URL strings",
        arguments: [
            "",
            "Zg",
            "Zm8",
            "Zm9v",
            "Zm9vYg",
            "Zm9vYmE",
            "Zm9vYmFy",
            "A-B_",  // Base64URL uses - and _ (length 4 is valid)
        ]
    )
    func validBase64URL(input: String) {
        #expect(RFC_4648.Base64.URL.isValid(input), "\(input) should be valid Base64URL")
    }

    @Test(
        "Invalid Base64URL strings",
        arguments: [
            "!@#$",
            "A+B/C",  // Base64URL doesn't use + and /
        ]
    )
    func invalidBase64URL(input: String) {
        #expect(!RFC_4648.Base64.URL.isValid(input), "\(input) should be invalid Base64URL")
    }

    // MARK: - Base32 Validation

    @Test(
        "Valid Base32 strings",
        arguments: [
            "",
            "MZXW6===",
            "MZXW6YTBOI======",
            "JBSWY3DPEBLW64TMMQ======",
        ]
    )
    func validBase32(input: String) {
        #expect(RFC_4648.Base32.isValid(input), "\(input) should be valid Base32")
    }

    @Test("Base32 case insensitive validation")
    func base32CaseInsensitive() {
        #expect(RFC_4648.Base32.isValid("MZXW6==="))
        #expect(RFC_4648.Base32.isValid("mzxw6==="))
        #expect(RFC_4648.Base32.isValid("MzXw6==="))
    }

    @Test(
        "Invalid Base32 strings",
        arguments: [
            "189",  // Base32 doesn't use 0, 1, 8, 9
            "ABC!@#",  // Invalid characters
            "====",  // Only padding
        ]
    )
    func invalidBase32(input: String) {
        #expect(!RFC_4648.Base32.isValid(input), "\(input) should be invalid Base32")
    }

    // MARK: - Base32-HEX Validation

    @Test(
        "Valid Base32-HEX strings",
        arguments: [
            "",
            "CPNMU===",
            "CPNMUOJ1",
            "91IMOR3F41BMUSJCCG======",
        ]
    )
    func validBase32Hex(input: String) {
        #expect(RFC_4648.Base32.Hex.isValid(input), "\(input) should be valid Base32-HEX")
    }

    @Test("Base32-HEX case insensitive validation")
    func base32HexCaseInsensitive() {
        #expect(RFC_4648.Base32.Hex.isValid("CPNMU==="))
        #expect(RFC_4648.Base32.Hex.isValid("cpnmu==="))
        #expect(RFC_4648.Base32.Hex.isValid("CpNmU==="))
    }

    @Test(
        "Invalid Base32-HEX strings",
        arguments: [
            "XYZ",  // Base32-HEX doesn't use W-Z
            "ABC!@#",  // Invalid characters
            "====",  // Only padding
        ]
    )
    func invalidBase32Hex(input: String) {
        #expect(!RFC_4648.Base32.Hex.isValid(input), "\(input) should be invalid Base32-HEX")
    }

    // MARK: - Hexadecimal Validation

    @Test(
        "Valid hexadecimal strings",
        arguments: [
            "",
            "00",
            "ff",
            "FF",
            "deadbeef",
            "DEADBEEF",
            "0xdeadbeef",
            "0xDEADBEEF",
            "0XDEADBEEF",
            "0123456789abcdef",
            "0123456789ABCDEF",
        ]
    )
    func validHex(input: String) {
        #expect(RFC_4648.Base16.isValid(input), "\(input) should be valid hexadecimal")
    }

    @Test(
        "Invalid hexadecimal strings",
        arguments: [
            "ghijk",  // Invalid characters
            "xyz",  // Invalid characters
            "fff",  // Odd length
            "!@#$",  // Invalid characters
        ]
    )
    func invalidHex(input: String) {
        #expect(!RFC_4648.Base16.isValid(input), "\(input) should be invalid hexadecimal")
        #expect(!input.hex.isValid, "\(input) should be invalid hexadecimal")
    }

    @Test("Hexadecimal validation with prefix")
    func hexValidationWithPrefix() {
        #expect(RFC_4648.Base16.isValid("0xdeadbeef"))
        #expect(RFC_4648.Base16.isValid("0xDEADBEEF"))
        #expect(RFC_4648.Base16.isValid("0XDEADBEEF"))
        #expect(RFC_4648.Base16.isValid("deadbeef"))
    }

    // MARK: - Performance

    @Test("Validation is efficient for large strings")
    func validationPerformance() {
        let largeValid = String(repeating: "Zm9vYmFy", count: 1000)
        let largeInvalid = String(repeating: "!!!!", count: 1000)

        #expect(RFC_4648.Base64.isValid(largeValid))
        #expect(!RFC_4648.Base64.isValid(largeInvalid))
    }

    // MARK: - Validation vs Decoding

    @Test("Validation matches decoding for Base64")
    func base64ValidationMatchesDecoding() {
        let testCases = [
            "Zm9vYmFy",  // valid
            "!@#$",  // invalid
            "Zm9",  // invalid length
            "",  // empty
        ]

        for test in testCases {
            let isValid = RFC_4648.Base64.isValid(test)
            let canDecode = [UInt8](base64Encoded: test) != nil

            #expect(
                isValid == canDecode,
                "Validation and decoding disagree for '\(test)'"
            )
        }
    }

    @Test("Validation matches decoding for Base32")
    func base32ValidationMatchesDecoding() {
        let testCases = [
            "MZXW6===",  // valid
            "189",  // invalid
            "",  // empty
        ]

        for test in testCases {
            let isValid = RFC_4648.Base32.isValid(test)
            let canDecode = [UInt8](base32Encoded: test) != nil

            #expect(
                isValid == canDecode,
                "Validation and decoding disagree for '\(test)'"
            )
        }
    }

    @Test("Validation matches decoding for hexadecimal")
    func hexValidationMatchesDecoding() {
        let testCases = [
            "deadbeef",  // valid
            "0xdeadbeef",  // valid with prefix
            "ghijk",  // invalid
            "fff",  // odd length
            "",  // empty
        ]

        for test in testCases {
            let isValid = RFC_4648.Base16.isValid(test)
            let canDecode = [UInt8](hexEncoded: test) != nil

            #expect(
                isValid == canDecode,
                "Validation and decoding disagree for '\(test)'"
            )
        }
    }

    // MARK: - Edge Cases

    @Test("Empty string validation across all encodings")
    func emptyStringValidation() {
        let empty = ""

        #expect(RFC_4648.Base64.isValid(empty))
        #expect(RFC_4648.Base64.URL.isValid(empty))
        #expect(RFC_4648.Base32.isValid(empty))
        #expect(RFC_4648.Base32.Hex.isValid(empty))
        #expect(RFC_4648.Base16.isValid(empty))
    }

    @Test("Unicode characters in validation")
    func unicodeInValidation() {
        // Non-ASCII characters should fail validation
        #expect(!RFC_4648.Base64.isValid("Zm9v🚀"))
        #expect(!RFC_4648.Base32.isValid("MZXW6😀"))
        #expect(!RFC_4648.Base16.isValid("dead你好"))
    }
}
