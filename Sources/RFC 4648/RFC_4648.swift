// RFC_4648.swift
// swift-rfc-4648
//
// Core implementations for RFC 4648: The Base16, Base32, and Base64 Data Encodings

import Standards

/// RFC 4648: The Base16, Base32, and Base64 Data Encodings
public enum RFC_4648 {
    /// Padding character used in Base64 and Base32 encodings (RFC 4648)
    /// Not used by hexadecimal encoding (Section 8)
    public static let padding: UInt8 = .init(ascii: "=")
}
