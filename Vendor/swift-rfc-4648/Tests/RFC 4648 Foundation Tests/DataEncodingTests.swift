// DataEncodingTests.swift
// swift-rfc-4648
//
// Tests for Data encoding/decoding extensions

import Foundation
import Testing

@testable import RFC_4648_Foundation

@Suite("Data Encoding Tests")
struct DataEncodingTests {
    // Note: Base64 tests omitted - Foundation already provides excellent Base64 support
    // We only test encodings that Foundation doesn't provide

    // MARK: - Base64URL

    @Test("Data Base64URL encoding")
    func dataBase64URLEncoding() {
        let data = Data("foobar".utf8)

        // Base64URL defaults to no padding per RFC 7515
        #expect(data.base64URLEncodedString() == "Zm9vYmFy")
        #expect(data.base64URLEncodedString(padding: false) == "Zm9vYmFy")
        #expect(data.base64URLEncodedString(padding: true) == "Zm9vYmFy")
    }

    @Test("Data Base64URL decoding")
    func dataBase64URLDecoding() {
        let encoded = "Zm9vYmFy"
        let data = Data(base64URLEncoded: encoded)

        #expect(data != nil)
        #expect(String(data: data!, encoding: .utf8) == "foobar")
    }

    @Test("Data Base64URL handles URL-safe characters")
    func dataBase64URLSafeCharacters() {
        // Value that would produce '+' or '/' in standard Base64
        let data = Data([0xFF, 0xFF, 0xFF])

        let base64URL = data.base64URLEncodedString()

        // Base64URL should use '-' and '_' instead of '+' and '/'
        #expect(!base64URL.contains("+"))
        #expect(!base64URL.contains("/"))

        // Should round-trip correctly
        let decoded = Data(base64URLEncoded: base64URL)
        #expect(decoded == data)
    }

    // MARK: - Base32

    @Test("Data Base32 encoding")
    func dataBase32Encoding() {
        let data = Data("foo".utf8)

        #expect(data.base32EncodedString() == "MZXW6===")
        #expect(data.base32EncodedString(padding: false) == "MZXW6")
    }

    @Test("Data Base32 decoding")
    func dataBase32Decoding() {
        let encoded = "MZXW6==="
        let data = Data(base32Encoded: encoded)

        #expect(data != nil)
        #expect(String(data: data!, encoding: .utf8) == "foo")
    }

    @Test("Data Base32 case insensitive decoding")
    func dataBase32CaseInsensitive() {
        let upper = Data(base32Encoded: "MZXW6===")
        let lower = Data(base32Encoded: "mzxw6===")
        let mixed = Data(base32Encoded: "MzXw6===")

        #expect(upper == lower)
        #expect(lower == mixed)
        #expect(String(data: upper!, encoding: .utf8) == "foo")
    }

    // MARK: - Base32-HEX

    @Test("Data Base32-HEX encoding")
    func dataBase32HexEncoding() {
        let data = Data("foo".utf8)

        #expect(data.base32HexEncodedString() == "CPNMU===")
        #expect(data.base32HexEncodedString(padding: false) == "CPNMU")
    }

    @Test("Data Base32-HEX decoding")
    func dataBase32HexDecoding() {
        let encoded = "CPNMU==="
        let data = Data(base32HexEncoded: encoded)

        #expect(data != nil)
        #expect(String(data: data!, encoding: .utf8) == "foo")
    }

    @Test("Data Base32-HEX differs from Base32")
    func dataBase32HexDifference() {
        let data = Data("foo".utf8)

        let base32 = data.base32EncodedString()
        let base32Hex = data.base32HexEncodedString()

        #expect(base32 != base32Hex)

        // But both decode correctly
        #expect(Data(base32Encoded: base32) == data)
        #expect(Data(base32HexEncoded: base32Hex) == data)
    }

    // MARK: - Hexadecimal

    @Test("Data hexadecimal encoding")
    func dataHexEncoding() {
        let data = Data([0xDE, 0xAD, 0xBE, 0xEF])

        #expect(data.hexEncodedString() == "deadbeef")
        #expect(data.hexEncodedString(uppercase: false) == "deadbeef")
        #expect(data.hexEncodedString(uppercase: true) == "DEADBEEF")
    }

    @Test("Data hexadecimal decoding")
    func dataHexDecoding() {
        let lower = Data(hexEncoded: "deadbeef")
        let upper = Data(hexEncoded: "DEADBEEF")
        let mixed = Data(hexEncoded: "DeAdBeEf")

        #expect(lower == upper)
        #expect(upper == mixed)
        #expect(lower == Data([0xDE, 0xAD, 0xBE, 0xEF]))
    }

    @Test(
        "Data hexadecimal round-trip",
        arguments: [
            Data([0x00]),
            Data([0xFF]),
            Data([0x00, 0x0F, 0xFF]),
            Data([0xDE, 0xAD, 0xBE, 0xEF]),
            Data((0...255).map { UInt8($0) }),
        ]
    )
    func dataHexRoundTrip(input: Data) {
        let encoded = input.hexEncodedString()
        let decoded = Data(hexEncoded: encoded)

        #expect(decoded == input)
    }

    // MARK: - Empty Data

    @Test(
        "Empty data encoding",
        arguments: [
            "base64URL", "base32", "base32Hex", "hex",
        ]
    )
    func emptyDataEncoding(encoding: String) {
        let empty = Data()

        switch encoding {
        case "base64URL":
            #expect(empty.base64URLEncodedString().isEmpty)
        case "base32":
            #expect(empty.base32EncodedString().isEmpty)
        case "base32Hex":
            #expect(empty.base32HexEncodedString().isEmpty)
        case "hex":
            #expect(empty.hexEncodedString().isEmpty)
        default:
            break
        }
    }

    @Test(
        "Empty string decoding",
        arguments: [
            "base64URL", "base32", "base32Hex", "hex",
        ]
    )
    func emptyStringDecoding(encoding: String) {
        let empty = ""

        switch encoding {
        case "base64URL":
            #expect(Data(base64URLEncoded: empty) == Data())
        case "base32":
            #expect(Data(base32Encoded: empty) == Data())
        case "base32Hex":
            #expect(Data(base32HexEncoded: empty) == Data())
        case "hex":
            #expect(Data(hexEncoded: empty) == Data())
        default:
            break
        }
    }

    // MARK: - Invalid Input

    @Test("Invalid Base32 decoding")
    func invalidBase32() {
        #expect(Data(base32Encoded: "189") == nil)  // Base32 doesn't use 1, 8, 9
    }

    @Test("Invalid hexadecimal decoding")
    func invalidHex() {
        #expect(Data(hexEncoded: "GHIJK") == nil)
        #expect(Data(hexEncoded: "fff") == nil)  // Odd length
    }

    // MARK: - Large Data

    @Test("Large data encoding and decoding")
    func testLargeData() {
        let largeData = Data((0..<10000).map { UInt8($0 % 256) })

        // Base64URL
        let base64url = largeData.base64URLEncodedString()
        #expect(Data(base64URLEncoded: base64url) == largeData)

        // Hex
        let hex = largeData.hexEncodedString()
        #expect(Data(hexEncoded: hex) == largeData)
    }
}
