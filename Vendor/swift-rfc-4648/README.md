# swift-rfc-4648

[![CI](https://github.com/swift-standards/swift-rfc-4648/workflows/CI/badge.svg)](https://github.com/swift-standards/swift-rfc-4648/actions/workflows/ci.yml)
![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

**Pure Swift implementation of RFC 4648: The Base16, Base32, and Base64 Data Encodings**

A comprehensive, standards-compliant library providing all RFC 4648 encoding variants with zero dependencies, Swift Embedded compatibility, and a clean API.

## Standard Reference

- **RFC**: 4648
- **Title**: The Base16, Base32, and Base64 Data Encodings
- **Status**: Standards Track
- **Published**: October 2006

## Features

- **RFC 4648 Compliant** - Full implementation of all encoding variants specified in RFC 4648
- **Base64 Encoding** - Standard Base64 with padding (Section 4)
- **Base64URL Encoding** - URL and filename safe variant, padding optional (Section 5)
- **Base32 Encoding** - Case-insensitive encoding suitable for human entry (Section 6)
- **Base32-HEX Encoding** - Extended Hex Alphabet variant (Section 7)
- **Base16/Hex Encoding** - Hexadecimal encoding (Section 8)
- **Zero Dependencies** - Pure Swift using only standard library (no Foundation)
- **Swift Embedded Compatible** - No existentials, no runtime features, suitable for embedded systems
- **Type-Safe API** - Clean Swift API with clear encoding/decoding methods
- **Cross-Platform** - Works on macOS, Linux, iOS, watchOS, tvOS, and embedded platforms

## Encodings Provided

### Base64 (Section 4)
Standard Base64 encoding with padding.

### Base64URL (Section 5)
URL and filename safe variant of Base64 (no padding by default).

### Base32 (Section 6)
Case-insensitive encoding suitable for human entry.

### Base32-HEX (Section 7)
Extended Hex Alphabet variant of Base32.

### Base16/Hex (Section 8)
Hexadecimal encoding (base 16).

## Quick Start

### Basic Base64 Encoding

```swift
import RFC4648

// Encode bytes to Base64
let bytes: [UInt8] = [72, 101, 108, 108, 111]
let encoded = String(base64Encoding: bytes)
print(encoded)  // "SGVsbG8="

// Decode Base64 back to bytes
if let decoded = [UInt8](base64Encoded: "SGVsbG8=") {
    print(decoded)  // [72, 101, 108, 108, 111]
}
```

### URL-Safe Base64URL

```swift
// Base64URL is URL-safe and has no padding by default
let urlSafe = String(base64URLEncoding: bytes)
print(urlSafe)  // "SGVsbG8" (no padding)

let decoded = [UInt8](base64URLEncoded: urlSafe)
```

### Base32 for Human Entry

```swift
// Base32 is case-insensitive, suitable for user input
let base32 = String(base32Encoding: bytes)
print(base32)  // "JBSWY3DP"

// Decoding is case-insensitive
let decoded1 = [UInt8](base32Encoded: "JBSWY3DP")
let decoded2 = [UInt8](base32Encoded: "jbswy3dp")
// Both produce the same result
```

### Hexadecimal Encoding

```swift
// Hex encoding for debugging and data inspection
let hex = String(hexEncoding: bytes)
print(hex)  // "48656c6c6f"

let decoded = [UInt8](hexEncoded: "48656c6c6f")
```

## API Overview

The library provides convenient initializers and methods on `String` and `[UInt8]` for all encoding variants.

### Base64 Encoding

```swift
// Encoding
extension String {
    public init(base64Encoding bytes: [UInt8])
}

// Decoding (returns nil if invalid)
extension Array where Element == UInt8 {
    public init?(base64Encoded string: String)
}
```

**Example:**
```swift
let encoded = String(base64Encoding: [72, 101, 108, 108, 111])  // "SGVsbG8="
let decoded = [UInt8](base64Encoded: "SGVsbG8=")  // [72, 101, 108, 108, 111]
```

### Base64URL Encoding

```swift
// Encoding (no padding by default)
extension String {
    public init(base64URLEncoding bytes: [UInt8])
}

// Decoding (accepts with or without padding)
extension Array where Element == UInt8 {
    public init?(base64URLEncoded string: String)
}
```

**Example:**
```swift
let encoded = String(base64URLEncoding: [72, 101, 108, 108, 111])  // "SGVsbG8"
let decoded = [UInt8](base64URLEncoded: "SGVsbG8")  // [72, 101, 108, 108, 111]
```

### Base32 Encoding

```swift
// Encoding
extension String {
    public init(base32Encoding bytes: [UInt8])
}

// Decoding (case-insensitive)
extension Array where Element == UInt8 {
    public init?(base32Encoded string: String)
}
```

**Example:**
```swift
let encoded = String(base32Encoding: [72, 101, 108, 108, 111])  // "JBSWY3DP"
let decoded = [UInt8](base32Encoded: "JBSWY3DP")  // [72, 101, 108, 108, 111]
```

### Base32-HEX Encoding

```swift
// Encoding (extended hex alphabet variant)
extension String {
    public init(base32HexEncoding bytes: [UInt8])
}

// Decoding
extension Array where Element == UInt8 {
    public init?(base32HexEncoded string: String)
}
```

### Base16/Hex Encoding

```swift
// Encoding
extension String {
    public init(hexEncoding bytes: [UInt8])
}

// Decoding (case-insensitive)
extension Array where Element == UInt8 {
    public init?(hexEncoded string: String)
}
```

**Example:**
```swift
let encoded = String(hexEncoding: [72, 101, 108, 108, 111])  // "48656c6c6f"
let decoded = [UInt8](hexEncoded: "48656c6c6f")  // [72, 101, 108, 108, 111]
```

## Architecture

This package is part of the swift-standards ecosystem:

**Tier 0: swift-standards** (Foundation)
- Truly generic, standard-agnostic utilities
- Collection safety, clamping, byte serialization, etc.

**Tier 1: swift-rfc-4648** (This package - Standard implementation)
- Implements RFC 4648 data encodings
- Depends only on swift-standards

**Tier 2+: Other RFC packages**
- Use RFC 4648 encodings as needed
- Examples: JWT (RFC 7519) uses Base64URL, TOTP (RFC 6238) uses Base32

## Installation

Add `swift-rfc-4648` to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/swift-standards/swift-rfc-4648.git", from: "0.1.0")
]
```

Then add it to your target:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "RFC4648", package: "swift-rfc-4648")
    ]
)
```

## Use Cases

### 1. JWT Token Encoding

JSON Web Tokens (RFC 7519) use Base64URL encoding for token components:

```swift
import RFC4648

// Encode JWT header and payload
let header = String(base64URLEncoding: headerBytes)
let payload = String(base64URLEncoding: payloadBytes)
let token = "\(header).\(payload).\(signature)"
```

### 2. TOTP/2FA Secrets

Time-based One-Time Passwords (RFC 6238) typically use Base32 for shared secrets:

```swift
// Decode user's TOTP secret (case-insensitive)
if let secret = [UInt8](base32Encoded: userInput) {
    generateTOTP(secret: secret)
}
```

### 3. Data URLs and Embedded Resources

Base64 encoding for embedding binary data in text formats:

```swift
// Create data URL
let imageData: [UInt8] = loadImage()
let base64 = String(base64Encoding: imageData)
let dataURL = "data:image/png;base64,\(base64)"
```

### 4. Cryptographic Key Exchange

Encoding cryptographic keys for transmission or storage:

```swift
// Export public key as Base64
let publicKeyBase64 = String(base64Encoding: publicKeyBytes)

// Import received key
if let keyBytes = [UInt8](base64Encoded: receivedKey) {
    importPublicKey(keyBytes)
}
```

### 5. Hexadecimal Debugging

Hex encoding for debugging and inspecting binary data:

```swift
// Debug network packet
let packet: [UInt8] = receivePacket()
print("Packet hex: \(String(hexEncoding: packet))")
```

### 6. URL-Safe Identifiers

Base64URL for generating URL-safe unique identifiers:

```swift
// Generate URL-safe ID
let randomBytes = generateRandomBytes(count: 16)
let urlSafeID = String(base64URLEncoding: randomBytes)
// Use in URLs without escaping
let url = "https://api.example.com/resource/\(urlSafeID)"
```

## Requirements

- Swift 6.0+
- Platform: macOS, Linux, iOS, watchOS, tvOS, or Swift Embedded

## License

This library is released under the Apache License 2.0. See [LICENSE.md](LICENSE.md) for details.

## Related Packages

- [swift-standards](../swift-standards) - Foundation utilities
- [swift-incits-4-1986](../swift-incits-4-1986) - ASCII standard
- [swift-rfc-3986](../swift-rfc-3986) - URI parsing
