// BinaryIntegerDecodingTests.swift
// swift-rfc-4648
//
// Tests for BinaryInteger decoding and round-trip encoding

import Testing

@testable import RFC_4648

@Suite("BinaryInteger Decoding Tests")
struct BinaryIntegerDecodingTests {
    // MARK: - Base64 Decoding

    @Test("UInt32 Base64 decoding")
    func uInt32Base64Decoding() {
        let value = UInt32(123_456)
        let encoded = String.base64(value)

        let decoded = UInt32(base64Encoded: encoded)
        #expect(decoded == value)
    }

    @Test(
        "UInt32 Base64 round-trip",
        arguments: [
            UInt32(0),
            UInt32(1),
            UInt32(255),
            UInt32(256),
            UInt32(65535),
            UInt32(123_456),
            UInt32(0xDEAD_BEEF),
            UInt32.max,
        ]
    )
    func uInt32Base64RoundTrip(value: UInt32) {
        let encoded = String.base64(value)
        let decoded = UInt32(base64Encoded: encoded)

        #expect(decoded == value, "Failed for \(value)")
    }

    @Test(
        "UInt8 Base64 round-trip",
        arguments: [
            UInt8(0), UInt8(1), UInt8(127), UInt8(128), UInt8(255),
        ]
    )
    func uInt8Base64RoundTrip(value: UInt8) {
        let encoded = String.base64(value)
        let decoded = UInt8(base64Encoded: encoded)

        #expect(decoded == value)
    }

    @Test(
        "UInt16 Base64 round-trip",
        arguments: [
            UInt16(0), UInt16(255), UInt16(256), UInt16(0xABCD), UInt16.max,
        ]
    )
    func uInt16Base64RoundTrip(value: UInt16) {
        let encoded = String.base64(value)
        let decoded = UInt16(base64Encoded: encoded)

        #expect(decoded == value)
    }

    @Test(
        "UInt64 Base64 round-trip",
        arguments: [
            UInt64(0),
            UInt64(UInt32.max),
            UInt64(0x1234_5678_9ABC_DEF0),
            UInt64.max,
        ]
    )
    func uInt64Base64RoundTrip(value: UInt64) {
        let encoded = String.base64(value)
        let decoded = UInt64(base64Encoded: encoded)

        #expect(decoded == value)
    }

    @Test("Signed integer Base64 round-trip")
    func signedIntegerBase64RoundTrip() {
        let values: [Int32] = [-1, -128, 0, 127, Int32.max, Int32.min]

        for value in values {
            let encoded = String.base64(value)
            let decoded = Int32(base64Encoded: encoded)

            #expect(decoded == value, "Failed for \(value)")
        }
    }

    @Test("Wrong size Base64 decoding fails")
    func wrongSizeBase64Decoding() {
        let uint32Value = UInt32(123_456)
        let encoded = String.base64(uint32Value)

        // Try to decode 4 bytes as UInt8 (should fail)
        #expect(UInt8(base64Encoded: encoded) == nil)

        // Try to decode 4 bytes as UInt64 (should fail)
        #expect(UInt64(base64Encoded: encoded) == nil)
    }

    // MARK: - Base64URL Decoding

    @Test(
        "UInt32 Base64URL round-trip",
        arguments: [
            UInt32(0), UInt32(123_456), UInt32(0xDEAD_BEEF), UInt32.max,
        ]
    )
    func uInt32Base64URLRoundTrip(value: UInt32) {
        let encoded = String.base64.url(value)
        let decoded = UInt32(base64URLEncoded: encoded)

        #expect(decoded == value)
    }

    // MARK: - Base32 Decoding

    @Test(
        "UInt32 Base32 round-trip",
        arguments: [
            UInt32(0), UInt32(123_456), UInt32.max,
        ]
    )
    func uInt32Base32RoundTrip(value: UInt32) {
        let encoded = String.base32(value)
        let decoded = UInt32(base32Encoded: encoded)

        #expect(decoded == value)
    }

    @Test("Base32 case insensitive decoding")
    func base32CaseInsensitive() {
        let value = UInt32(123_456)
        let upper = String.base32(value)  // Default uppercase
        let lower = upper.lowercased()

        #expect(UInt32(base32Encoded: upper) == value)
        #expect(UInt32(base32Encoded: lower) == value)
    }

    // MARK: - Base32-HEX Decoding

    @Test(
        "UInt32 Base32-HEX round-trip",
        arguments: [
            UInt32(0), UInt32(123_456), UInt32.max,
        ]
    )
    func uInt32Base32HexRoundTrip(value: UInt32) {
        let encoded = String.base32.hex(value)
        let decoded = UInt32(base32HexEncoded: encoded)

        #expect(decoded == value)
    }

    // MARK: - Hexadecimal Decoding

    @Test("UInt32 hexadecimal decoding")
    func uInt32HexDecoding() {
        #expect(UInt32(hexEncoded: "deadbeef") == 0xDEAD_BEEF)
        #expect(UInt32(hexEncoded: "0xdeadbeef") == 0xDEAD_BEEF)
        #expect(UInt32(hexEncoded: "0xDEADBEEF") == 0xDEAD_BEEF)
        #expect(UInt32(hexEncoded: "DEADBEEF") == 0xDEAD_BEEF)
    }

    @Test(
        "UInt8 hexadecimal round-trip",
        arguments: [
            UInt8(0x00), UInt8(0x0F), UInt8(0xFF), UInt8(0xAB),
        ]
    )
    func uInt8HexRoundTrip(value: UInt8) {
        let encoded = String.hex(value, prefix: "")
        let decoded = UInt8(hexEncoded: encoded)

        #expect(decoded == value)
    }

    @Test(
        "UInt16 hexadecimal round-trip",
        arguments: [
            UInt16(0x0000), UInt16(0xABCD), UInt16(0xFFFF),
        ]
    )
    func uInt16HexRoundTrip(value: UInt16) {
        let encoded = String.hex(value, prefix: "")
        let decoded = UInt16(hexEncoded: encoded)

        #expect(decoded == value)
    }

    @Test(
        "UInt64 hexadecimal round-trip",
        arguments: [
            UInt64(0),
            UInt64(0x1234_5678_9ABC_DEF0),
            UInt64.max,
        ]
    )
    func uInt64HexRoundTrip(value: UInt64) {
        let encoded = String.hex(value, prefix: "")
        let decoded = UInt64(hexEncoded: encoded)

        #expect(decoded == value)
    }

    @Test("Hexadecimal decoding with prefix")
    func hexDecodingWithPrefix() {
        #expect(UInt32(hexEncoded: "0xDEADBEEF") == 0xDEAD_BEEF)
        #expect(UInt32(hexEncoded: "0XDEADBEEF") == 0xDEAD_BEEF)
        #expect(UInt32(hexEncoded: "deadbeef") == 0xDEAD_BEEF)
    }

    // MARK: - Invalid Input

    @Test("Invalid Base64 returns nil")
    func invalidBase64() {
        #expect(UInt32(base64Encoded: "invalid!@#$") == nil)
        #expect(UInt32(base64Encoded: "") == nil)
    }

    @Test("Invalid Base32 returns nil")
    func invalidBase32() {
        #expect(UInt32(base32Encoded: "189") == nil)
    }

    @Test("Invalid hexadecimal returns nil")
    func invalidHex() {
        #expect(UInt32(hexEncoded: "GHIJK") == nil)
        #expect(UInt32(hexEncoded: "xyz") == nil)
    }

    // MARK: - Edge Cases

    @Test("Zero value across all encodings")
    func zeroValue() {
        let zero = UInt32(0)

        #expect(UInt32(base64Encoded: String.base64(zero)) == zero)
        #expect(UInt32(base64URLEncoded: String.base64.url(zero)) == zero)
        #expect(UInt32(base32Encoded: String.base32(zero)) == zero)
        #expect(UInt32(base32HexEncoded: String.base32.hex(zero)) == zero)
        #expect(UInt32(hexEncoded: String.hex(zero, prefix: "")) == zero)
    }

    @Test("Maximum value across all encodings")
    func maxValue() {
        let max = UInt32.max

        #expect(UInt32(base64Encoded: String.base64(max)) == max)
        #expect(UInt32(base64URLEncoded: String.base64.url(max)) == max)
        #expect(UInt32(base32Encoded: String.base32(max)) == max)
        #expect(UInt32(base32HexEncoded: String.base32.hex(max)) == max)
        #expect(UInt32(hexEncoded: String.hex(max, prefix: "")) == max)
    }

    // MARK: - All Integer Types

    @Test("All unsigned integer types supported")
    func allUnsignedTypes() {
        _ = UInt8(base64Encoded: String.base64(UInt8(42)))
        _ = UInt16(base64Encoded: String.base64(UInt16(42)))
        _ = UInt32(base64Encoded: String.base64(UInt32(42)))
        _ = UInt64(base64Encoded: String.base64(UInt64(42)))
        _ = UInt(base64Encoded: String.base64(UInt(42)))
    }

    @Test("All signed integer types supported")
    func allSignedTypes() {
        _ = Int8(base64Encoded: String.base64(Int8(42)))
        _ = Int16(base64Encoded: String.base64(Int16(42)))
        _ = Int32(base64Encoded: String.base64(Int32(42)))
        _ = Int64(base64Encoded: String.base64(Int64(42)))
        _ = Int(base64Encoded: String.base64(Int(42)))
    }
}
