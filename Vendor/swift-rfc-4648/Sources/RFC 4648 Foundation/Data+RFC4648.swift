// Data+RFC4648.swift
// swift-rfc-4648
//
// Foundation Data extensions for RFC 4648 encodings
// Note: Foundation already provides Base64 encoding, so we only add the encodings it doesn't have

import Foundation
import RFC_4648

// MARK: - Base64URL (RFC 4648 Section 5)

extension Data {
    /// Creates a Base64URL encoded string from data (RFC 4648 Section 5)
    /// Base64URL uses '-' and '_' instead of '+' and '/', making it URL and filename safe.
    /// - Parameter padding: Whether to include padding characters (default: false per RFC 7515)
    /// - Returns: Base64URL encoded string
    public func base64URLEncodedString(padding: Bool = false) -> String {
        String.base64.url(Array(self), padding: padding)
    }

    /// Creates data from a Base64URL encoded string (RFC 4648 Section 5)
    /// - Parameter base64URLEncoded: Base64URL encoded string
    /// - Returns: Decoded data, or nil if invalid Base64URL
    public init?(base64URLEncoded string: String) {
        guard let bytes = [UInt8](base64URLEncoded: string) else { return nil }
        self.init(bytes)
    }
}

// MARK: - Base32 (RFC 4648 Section 6)

extension Data {
    /// Creates a Base32 encoded string from data (RFC 4648 Section 6)
    /// Base32 uses 32-character alphabet (A-Z, 2-7), case-insensitive for decoding
    /// - Parameter padding: Whether to include padding characters (default: true)
    /// - Returns: Base32 encoded string
    public func base32EncodedString(padding: Bool = true) -> String {
        String.base32(Array(self), padding: padding)
    }

    /// Creates data from a Base32 encoded string (RFC 4648 Section 6)
    /// - Parameter base32Encoded: Base32 encoded string (case-insensitive)
    /// - Returns: Decoded data, or nil if invalid Base32
    public init?(base32Encoded string: String) {
        guard let bytes = [UInt8](base32Encoded: string) else { return nil }
        self.init(bytes)
    }
}

// MARK: - Base32-HEX (RFC 4648 Section 7)

extension Data {
    /// Creates a Base32-HEX encoded string from data (RFC 4648 Section 7)
    /// Base32-HEX uses 0-9,A-V alphabet, case-insensitive for decoding
    /// - Parameter padding: Whether to include padding characters (default: true)
    /// - Returns: Base32-HEX encoded string
    public func base32HexEncodedString(padding: Bool = true) -> String {
        String.base32.hex(Array(self), padding: padding)
    }

    /// Creates data from a Base32-HEX encoded string (RFC 4648 Section 7)
    /// - Parameter base32HexEncoded: Base32-HEX encoded string (case-insensitive)
    /// - Returns: Decoded data, or nil if invalid Base32-HEX
    public init?(base32HexEncoded string: String) {
        guard let bytes = [UInt8](base32HexEncoded: string) else { return nil }
        self.init(bytes)
    }
}

// MARK: - Base16/Hex (RFC 4648 Section 8)

extension Data {
    /// Creates a Base16 (hexadecimal) encoded string from data (RFC 4648 Section 8)
    /// - Parameter uppercase: Whether to use uppercase hex digits (default: false)
    /// - Returns: Hexadecimal encoded string
    public func hexEncodedString(uppercase: Bool = false) -> String {
        String.hex(Array(self), uppercase: uppercase)
    }

    /// Creates data from a Base16 (hexadecimal) encoded string (RFC 4648 Section 8)
    /// - Parameter hexEncoded: Hexadecimal encoded string (case-insensitive)
    /// - Returns: Decoded data, or nil if invalid hexadecimal
    public init?(hexEncoded string: String) {
        guard let bytes = [UInt8](hexEncoded: string) else { return nil }
        self.init(bytes)
    }
}
