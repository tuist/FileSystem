//
//  RFC_4648.Base16.swift
//  swift-rfc-4648
//
//  Base16 (Hexadecimal) encoding per RFC 4648 Section 8

import INCITS_4_1986

// MARK: - Base16 Type

extension RFC_4648 {
    /// Base16 (hexadecimal) encoding (RFC 4648 Section 8)
    ///
    /// RFC 4648 Section 8 defines "Base 16 Encoding" as the canonical name.
    /// Commonly known as hexadecimal or hex encoding.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// // Static methods (authoritative)
    /// RFC_4648.Base16.encode(segment, into: &buffer, suppressLeadingZeros: true)
    /// let decoded = RFC_4648.Base16.decode("deadbeef")
    ///
    /// // Instance methods (convenience)
    /// bytes.hex.encoded()
    /// "deadbeef".hex.decoded()
    /// ```
    public enum Base16 {
        /// Wrapper for instance-based convenience methods
        public struct Wrapper<Wrapped> {
            public let wrapped: Wrapped

            @inlinable
            public init(_ wrapped: Wrapped) {
                self.wrapped = wrapped
            }
        }
    }
}

// MARK: - Encoding Tables

extension RFC_4648.Base16 {
    /// Shared decode table for hex (case-insensitive)
    private static let hexDecodeTable: [UInt8] = {
        var table = [UInt8](repeating: 255, count: 256)

        // 0-9
        for char in UInt8(ascii: "0")...UInt8(ascii: "9") {
            table[Int(char)] = char - UInt8(ascii: "0")
        }

        // a-f
        for char in UInt8(ascii: "a")...UInt8(ascii: "f") {
            table[Int(char)] = 10 + (char - UInt8(ascii: "a"))
        }

        // A-F
        for char in UInt8(ascii: "A")...UInt8(ascii: "F") {
            table[Int(char)] = 10 + (char - UInt8(ascii: "A"))
        }

        return table
    }()

    /// Base16 encoding table - lowercase (RFC 4648 Section 8)
    public static let encodingTable = RFC_4648.EncodingTable(
        encode: Array("0123456789abcdef".utf8),
        decode: hexDecodeTable
    )

    /// Base16 encoding table - uppercase (RFC 4648 Section 8)
    public static let encodingTableUppercase = RFC_4648.EncodingTable(
        encode: Array("0123456789ABCDEF".utf8),
        decode: hexDecodeTable
    )
}

// MARK: - Encoder (for String.hex(...) syntax)

extension RFC_4648.Base16 {
    /// Encoder for `String.hex(bytes)` syntax
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let encoded = String.hex([0xde, 0xad, 0xbe, 0xef])  // "deadbeef"
    /// let encoded = String.hex([0xde, 0xad], uppercase: true)  // "DEAD"
    /// ```
    public struct Encoder: Sendable {
        @inlinable
        public init() {}

        /// Encodes bytes to hexadecimal string
        @inlinable
        public func callAsFunction<Bytes: Collection>(
            _ bytes: Bytes,
            uppercase: Bool = false
        ) -> String where Bytes.Element == UInt8 {
            let encoded: [UInt8] = RFC_4648.Base16.encode(bytes, uppercase: uppercase)
            return String(decoding: encoded, as: UTF8.self)
        }

        /// Encodes an integer to hexadecimal string (big-endian byte order)
        ///
        /// - Parameters:
        ///   - value: The integer to encode
        ///   - prefix: Optional prefix (default: "0x")
        ///   - uppercase: Whether to use uppercase hex digits (default: false)
        /// - Returns: Prefixed hexadecimal string
        @inlinable
        public func callAsFunction<T: FixedWidthInteger>(
            _ value: T,
            prefix: String = "0x",
            uppercase: Bool = false
        ) -> String {
            prefix + callAsFunction(value.bytes(endianness: .big), uppercase: uppercase)
        }
    }
}

// MARK: - Static Encode Methods (Authoritative)

extension RFC_4648.Base16 {
    /// Encodes an integer value to Base16 (hexadecimal) into a buffer (PRIMITIVE)
    ///
    /// This is the fundamental encoding operation. All other encode methods
    /// delegate to this implementation.
    ///
    /// - Parameters:
    ///   - value: The integer value to encode
    ///   - buffer: The buffer to append hex characters to
    ///   - uppercase: Whether to use uppercase hex digits (default: false)
    ///   - suppressLeadingZeros: Whether to suppress leading zeros (default: false)
    ///
    /// ## Examples
    ///
    /// ```swift
    /// var buffer: [UInt8] = []
    ///
    /// // Full width (no suppression): UInt8 → 2 chars, UInt16 → 4 chars
    /// RFC_4648.Base16.encode(UInt8(0x0F), into: &buffer)  // "0f"
    /// RFC_4648.Base16.encode(UInt16(0x00FF), into: &buffer)  // "00ff"
    ///
    /// // With suppression: minimum chars needed (at least 1)
    /// RFC_4648.Base16.encode(UInt16(0x00FF), into: &buffer, suppressLeadingZeros: true)  // "ff"
    /// RFC_4648.Base16.encode(UInt16(0x0000), into: &buffer, suppressLeadingZeros: true)  // "0"
    /// ```
    @inlinable
    public static func encode<Buffer: RangeReplaceableCollection, T: FixedWidthInteger>(
        _ value: T,
        into buffer: inout Buffer,
        uppercase: Bool = false,
        suppressLeadingZeros: Bool = false
    ) where Buffer.Element == UInt8 {
        let table = uppercase ? encodingTableUppercase.encode : encodingTable.encode
        let nibbleCount = T.bitWidth / 4

        var foundNonZero = false

        for i in (0..<nibbleCount).reversed() {
            let nibble = Int((value >> (i * 4)) & 0x0F)

            if suppressLeadingZeros {
                if nibble != 0 {
                    foundNonZero = true
                }
                // Always output if: non-zero found, or last nibble (ensure at least "0")
                if foundNonZero || i == 0 {
                    buffer.append(table[nibble])
                }
            } else {
                buffer.append(table[nibble])
            }
        }
    }

    /// Encodes bytes to Base16 into a buffer
    ///
    /// Each byte is encoded as exactly 2 hex characters.
    ///
    /// - Parameters:
    ///   - bytes: The bytes to encode
    ///   - buffer: The buffer to append hex characters to
    ///   - uppercase: Whether to use uppercase hex digits (default: false)
    @inlinable
    public static func encode<Bytes: Collection, Buffer: RangeReplaceableCollection>(
        _ bytes: Bytes,
        into buffer: inout Buffer,
        uppercase: Bool = false
    ) where Bytes.Element == UInt8, Buffer.Element == UInt8 {
        for byte in bytes {
            encode(byte, into: &buffer, uppercase: uppercase, suppressLeadingZeros: false)
        }
    }

    /// Encodes bytes to Base16, returning a new collection
    ///
    /// Convenience method that creates a buffer and returns it.
    @inlinable
    public static func encode<Bytes: Collection, Result: RangeReplaceableCollection>(
        _ bytes: Bytes,
        uppercase: Bool = false
    ) -> Result where Bytes.Element == UInt8, Result.Element == UInt8 {
        var result = Result()
        encode(bytes, into: &result, uppercase: uppercase)
        return result
    }
}

// MARK: - Static Decode Methods (Authoritative)

extension RFC_4648.Base16 {
    /// Decodes a single hex character to its nibble value (PRIMITIVE)
    ///
    /// This is the fundamental decoding operation for a single hex digit.
    ///
    /// - Parameter nibble: ASCII byte of hex character ('0'-'9', 'a'-'f', 'A'-'F')
    /// - Returns: Nibble value (0-15), or nil if invalid
    ///
    /// ## Example
    ///
    /// ```swift
    /// RFC_4648.Base16.decode(nibble: UInt8(ascii: "a"))  // 10
    /// RFC_4648.Base16.decode(nibble: UInt8(ascii: "F"))  // 15
    /// RFC_4648.Base16.decode(nibble: UInt8(ascii: "g"))  // nil
    /// ```
    @inlinable
    public static func decode(nibble: UInt8) -> UInt8? {
        let value = encodingTable.decode[Int(nibble)]
        return value == 255 ? nil : value
    }

    /// Decodes a hex pair to a single byte (PRIMITIVE)
    ///
    /// - Parameters:
    ///   - high: ASCII byte of high nibble hex character
    ///   - low: ASCII byte of low nibble hex character
    /// - Returns: Decoded byte, or nil if either character is invalid
    ///
    /// ## Example
    ///
    /// ```swift
    /// RFC_4648.Base16.decode(high: UInt8(ascii: "f"), low: UInt8(ascii: "f"))  // 255
    /// RFC_4648.Base16.decode(high: UInt8(ascii: "0"), low: UInt8(ascii: "a"))  // 10
    /// ```
    @inlinable
    public static func decode(high: UInt8, low: UInt8) -> UInt8? {
        let decodeTable = encodingTable.decode
        let highNibble = decodeTable[Int(high)]
        let lowNibble = decodeTable[Int(low)]
        guard highNibble != 255, lowNibble != 255 else { return nil }
        return (highNibble << 4) | lowNibble
    }

    /// Decodes Base16 bytes into a buffer (streaming, no allocation)
    ///
    /// - Parameters:
    ///   - bytes: Base16 encoded bytes (must have even count after whitespace removal)
    ///   - buffer: The buffer to append decoded bytes to
    ///   - skipPrefix: Whether to skip "0x" or "0X" prefix (default: true)
    /// - Returns: `true` if decoding succeeded, `false` if invalid input
    ///
    /// ## Example
    ///
    /// ```swift
    /// var buffer: [UInt8] = []
    /// let success = RFC_4648.Base16.decode("deadbeef".utf8, into: &buffer)
    /// // buffer == [0xde, 0xad, 0xbe, 0xef]
    /// ```
    @inlinable
    @discardableResult
    public static func decode<Bytes: Collection, Buffer: RangeReplaceableCollection>(
        _ bytes: Bytes,
        into buffer: inout Buffer,
        skipPrefix: Bool = true
    ) -> Bool where Bytes.Element == UInt8, Buffer.Element == UInt8 {
        guard !bytes.isEmpty else { return true }

        let decodeTable = encodingTable.decode
        var iterator = bytes.makeIterator()

        // Check for "0x" or "0X" prefix
        if skipPrefix {
            // Peek at first two bytes
            guard let first = iterator.next() else { return true }

            if first == 0x30 {  // '0'
                guard let second = iterator.next() else {
                    // Just "0" - decode as single zero nibble? No, need pairs.
                    // Single '0' is invalid for byte decoding
                    return false
                }
                if second != 0x78 && second != 0x58 {  // 'x' or 'X'
                    // Not a prefix, these are actual hex digits
                    // Decode this pair
                    let highNibble = decodeTable[Int(first)]
                    let lowNibble = decodeTable[Int(second)]
                    guard highNibble != 255, lowNibble != 255 else { return false }
                    buffer.append((highNibble << 4) | lowNibble)
                }
                // If it was "0x"/"0X", we consumed it and continue
            } else {
                // First byte is not '0', need to pair it with next
                guard let second = iterator.next() else { return false }
                // Skip whitespace for first byte
                var high = first
                while high.ascii.isWhitespace {
                    guard let next = iterator.next() else { return false }
                    high = next
                }
                var low = second
                while low.ascii.isWhitespace {
                    guard let next = iterator.next() else { return false }
                    low = next
                }
                let highNibble = decodeTable[Int(high)]
                let lowNibble = decodeTable[Int(low)]
                guard highNibble != 255, lowNibble != 255 else { return false }
                buffer.append((highNibble << 4) | lowNibble)
            }
        }

        // Process remaining pairs
        while let high = iterator.next() {
            // Skip whitespace
            var highByte = high
            while highByte.ascii.isWhitespace {
                guard let next = iterator.next() else { return true }  // trailing whitespace ok
                highByte = next
            }

            guard let low = iterator.next() else { return false }  // odd number of hex chars

            var lowByte = low
            while lowByte.ascii.isWhitespace {
                guard let next = iterator.next() else { return false }
                lowByte = next
            }

            let highNibble = decodeTable[Int(highByte)]
            let lowNibble = decodeTable[Int(lowByte)]
            guard highNibble != 255, lowNibble != 255 else { return false }
            buffer.append((highNibble << 4) | lowNibble)
        }

        return true
    }

    /// Decodes Base16 encoded bytes to a new array
    ///
    /// - Parameters:
    ///   - bytes: Base16 encoded bytes
    ///   - skipPrefix: Whether to skip "0x" or "0X" prefix (default: true)
    /// - Returns: Decoded bytes, or nil if invalid
    ///
    /// ## Example
    ///
    /// ```swift
    /// let decoded = RFC_4648.Base16.decode("0xDEADBEEF".utf8)
    /// // decoded == [0xde, 0xad, 0xbe, 0xef]
    /// ```
    @inlinable
    public static func decode<Bytes: Collection>(
        _ bytes: Bytes,
        skipPrefix: Bool = true
    ) -> [UInt8]? where Bytes.Element == UInt8 {
        var result: [UInt8] = []
        result.reserveCapacity(bytes.count / 2)
        guard decode(bytes, into: &result, skipPrefix: skipPrefix) else { return nil }
        return result
    }

    /// Decodes Base16 encoded string (case-insensitive)
    ///
    /// Convenience overload that delegates to the byte-based version.
    ///
    /// - Parameters:
    ///   - string: Base16 encoded string
    ///   - skipPrefix: Whether to skip "0x" or "0X" prefix (default: true)
    /// - Returns: Decoded bytes, or nil if invalid
    ///
    /// ## Example
    ///
    /// ```swift
    /// let decoded = RFC_4648.Base16.decode("deadbeef")
    /// // decoded == [0xde, 0xad, 0xbe, 0xef]
    /// ```
    @inlinable
    public static func decode(
        _ string: some StringProtocol,
        skipPrefix: Bool = true
    ) -> [UInt8]? {
        decode(string.utf8, skipPrefix: skipPrefix)
    }

    /// Decodes Base16 to a FixedWidthInteger (PRIMITIVE)
    ///
    /// Decodes hex bytes directly to an integer value without intermediate array allocation.
    ///
    /// - Parameters:
    ///   - bytes: Base16 encoded bytes (must decode to at most T.bitWidth/8 bytes)
    ///   - skipPrefix: Whether to skip "0x" or "0X" prefix (default: true)
    /// - Returns: Decoded integer value, or nil if invalid
    ///
    /// ## Example
    ///
    /// ```swift
    /// let value: UInt32? = RFC_4648.Base16.decode("deadbeef".utf8)
    /// // value == 0xDEADBEEF
    ///
    /// let byte: UInt8? = RFC_4648.Base16.decode("ff".utf8)
    /// // byte == 255
    /// ```
    @inlinable
    public static func decode<Bytes: Collection, T: FixedWidthInteger>(
        _ bytes: Bytes,
        as type: T.Type = T.self,
        skipPrefix: Bool = true
    ) -> T? where Bytes.Element == UInt8 {
        guard !bytes.isEmpty else { return 0 }

        let decodeTable = encodingTable.decode
        var iterator = bytes.makeIterator()
        var result: T = 0
        var nibbleCount = 0
        let maxNibbles = T.bitWidth / 4

        // Check for "0x" or "0X" prefix
        if skipPrefix {
            guard let first = iterator.next() else { return 0 }

            if first == 0x30 {  // '0'
                if let second = iterator.next() {
                    if second == 0x78 || second == 0x58 {  // 'x' or 'X'
                        // Prefix consumed, continue
                    } else if !second.ascii.isWhitespace {
                        // Not a prefix, these are hex digits
                        let highNibble = decodeTable[Int(first)]
                        let lowNibble = decodeTable[Int(second)]
                        guard highNibble != 255, lowNibble != 255 else { return nil }
                        result = T(highNibble) << 4 | T(lowNibble)
                        nibbleCount = 2
                    } else {
                        // '0' followed by whitespace - just '0'
                        let nibble = decodeTable[Int(first)]
                        guard nibble != 255 else { return nil }
                        result = T(nibble)
                        nibbleCount = 1
                    }
                } else {
                    // Just "0"
                    return 0
                }
            } else if !first.ascii.isWhitespace {
                let nibble = decodeTable[Int(first)]
                guard nibble != 255 else { return nil }
                result = T(nibble)
                nibbleCount = 1
            }
        }

        // Process remaining nibbles
        while let byte = iterator.next() {
            guard !byte.ascii.isWhitespace else { continue }

            let nibble = decodeTable[Int(byte)]
            guard nibble != 255 else { return nil }

            nibbleCount += 1
            guard nibbleCount <= maxNibbles else { return nil }  // overflow

            result = result << 4 | T(nibble)
        }

        return result
    }
}

// MARK: - Instance Methods (Convenience) - Bytes

extension RFC_4648.Base16.Wrapper where Wrapped: Collection, Wrapped.Element == UInt8 {
    // MARK: Encoding (bytes → hex)

    /// Encodes wrapped bytes to Base16 into a buffer
    ///
    /// Delegates to static `RFC_4648.Base16.encode(_:into:uppercase:)`.
    @inlinable
    public func encode<Buffer: RangeReplaceableCollection>(
        into buffer: inout Buffer,
        uppercase: Bool = false
    ) where Buffer.Element == UInt8 {
        RFC_4648.Base16.encode(wrapped, into: &buffer, uppercase: uppercase)
    }

    /// Encodes wrapped bytes to hexadecimal string
    ///
    /// Delegates to static `RFC_4648.Base16.encode(_:uppercase:)`.
    @inlinable
    public func encoded(uppercase: Bool = false) -> String {
        let bytes: [UInt8] = RFC_4648.Base16.encode(wrapped, uppercase: uppercase)
        return String(decoding: bytes, as: UTF8.self)
    }

    /// Encodes wrapped bytes to hexadecimal string (callable syntax)
    @inlinable
    public func callAsFunction(uppercase: Bool = false) -> String {
        encoded(uppercase: uppercase)
    }

    // MARK: Decoding (hex bytes → raw bytes)

    /// Decodes wrapped hex-encoded bytes into a buffer
    ///
    /// Treats the wrapped bytes as ASCII hex characters and decodes them.
    /// Delegates to static `RFC_4648.Base16.decode(_:into:skipPrefix:)`.
    @inlinable
    @discardableResult
    public func decode<Buffer: RangeReplaceableCollection>(
        into buffer: inout Buffer,
        skipPrefix: Bool = true
    ) -> Bool where Buffer.Element == UInt8 {
        RFC_4648.Base16.decode(wrapped, into: &buffer, skipPrefix: skipPrefix)
    }

    /// Decodes wrapped hex-encoded bytes to raw bytes
    ///
    /// Treats the wrapped bytes as ASCII hex characters and decodes them.
    /// Delegates to static `RFC_4648.Base16.decode(_:skipPrefix:)`.
    @inlinable
    public func decoded(skipPrefix: Bool = true) -> [UInt8]? {
        RFC_4648.Base16.decode(wrapped, skipPrefix: skipPrefix)
    }

    /// Decodes wrapped hex-encoded bytes to a FixedWidthInteger
    ///
    /// Treats the wrapped bytes as ASCII hex characters and decodes them.
    /// Delegates to static `RFC_4648.Base16.decode(_:as:skipPrefix:)`.
    @inlinable
    public func decoded<T: FixedWidthInteger>(
        as type: T.Type = T.self,
        skipPrefix: Bool = true
    ) -> T? {
        RFC_4648.Base16.decode(wrapped, as: type, skipPrefix: skipPrefix)
    }
}

// MARK: - Instance Methods (Convenience) - String

extension RFC_4648.Base16.Wrapper where Wrapped: StringProtocol {
    /// Decodes wrapped hexadecimal string into a buffer
    ///
    /// Delegates to static `RFC_4648.Base16.decode(_:into:skipPrefix:)`.
    @inlinable
    @discardableResult
    public func decode<Buffer: RangeReplaceableCollection>(
        into buffer: inout Buffer,
        skipPrefix: Bool = true
    ) -> Bool where Buffer.Element == UInt8 {
        RFC_4648.Base16.decode(wrapped.utf8, into: &buffer, skipPrefix: skipPrefix)
    }

    /// Decodes wrapped hexadecimal string to bytes
    ///
    /// Delegates to static `RFC_4648.Base16.decode(_:skipPrefix:)`.
    @inlinable
    public func decoded(skipPrefix: Bool = true) -> [UInt8]? {
        RFC_4648.Base16.decode(wrapped, skipPrefix: skipPrefix)
    }

    /// Decodes wrapped hexadecimal string to a FixedWidthInteger
    ///
    /// Delegates to static `RFC_4648.Base16.decode(_:as:skipPrefix:)`.
    @inlinable
    public func decoded<T: FixedWidthInteger>(
        as type: T.Type = T.self,
        skipPrefix: Bool = true
    ) -> T? {
        RFC_4648.Base16.decode(wrapped.utf8, as: type, skipPrefix: skipPrefix)
    }
}

// MARK: - Typealias

extension RFC_4648 {
    /// Ergonomic typealias for Base16 encoding
    ///
    /// While RFC 4648 Section 8 officially names this "Base 16 Encoding",
    /// it's commonly known as hexadecimal. This typealias provides familiar ergonomics.
    public typealias Hex = Base16
}
