// RFC_4648.Internal.swift
// swift-rfc-4648
//
// Internal shared implementations to eliminate code duplication
// These are implementation details, not public API

// MARK: - Base64 Shared Implementation

extension RFC_4648 {
    /// Internal Base64 encoding implementation shared by Base64 and Base64.URL
    ///
    /// - Parameters:
    ///   - bytes: The bytes to encode
    ///   - buffer: The buffer to append encoded characters to
    ///   - table: The encoding table to use (64 characters)
    ///   - padding: Whether to include padding characters
    @inlinable
    static func encodeBase64<Bytes: Collection, Buffer: RangeReplaceableCollection>(
        _ bytes: Bytes,
        into buffer: inout Buffer,
        table: [UInt8],
        padding: Bool
    ) where Bytes.Element == UInt8, Buffer.Element == UInt8 {
        guard !bytes.isEmpty else { return }

        var iterator = bytes.makeIterator()

        while let b1 = iterator.next() {
            let b2 = iterator.next()
            let b3 = iterator.next()

            // First character: high 6 bits of b1
            buffer.append(table[Int((b1 >> 2) & 0x3F)])

            // Second character: low 2 bits of b1 + high 4 bits of b2
            let c2 = ((b1 << 4) | ((b2 ?? 0) >> 4)) & 0x3F
            buffer.append(table[Int(c2)])

            guard let b2 = b2 else {
                if padding {
                    buffer.append(RFC_4648.padding)
                    buffer.append(RFC_4648.padding)
                }
                break
            }

            // Third character: low 4 bits of b2 + high 2 bits of b3
            let c3 = ((b2 << 2) | ((b3 ?? 0) >> 6)) & 0x3F
            buffer.append(table[Int(c3)])

            guard let b3 = b3 else {
                if padding {
                    buffer.append(RFC_4648.padding)
                }
                break
            }

            // Fourth character: low 6 bits of b3
            buffer.append(table[Int(b3 & 0x3F)])
        }
    }

    /// Internal Base64 decoding implementation shared by Base64 and Base64.URL
    ///
    /// - Parameters:
    ///   - bytes: The encoded bytes to decode
    ///   - buffer: The buffer to append decoded bytes to
    ///   - decodeTable: The decoding table (256 entries, 255 = invalid)
    ///   - requirePadding: Whether to require complete groups of 4
    /// - Returns: `true` if decoding succeeded, `false` if invalid input
    @inlinable
    @discardableResult
    static func decodeBase64<Bytes: Collection, Buffer: RangeReplaceableCollection>(
        _ bytes: Bytes,
        into buffer: inout Buffer,
        decodeTable: [UInt8],
        requirePadding: Bool
    ) -> Bool where Bytes.Element == UInt8, Buffer.Element == UInt8 {
        guard !bytes.isEmpty else { return true }

        var iterator = bytes.makeIterator()
        var values = [UInt8]()
        values.reserveCapacity(4)
        var hasDecodedAny = false

        while true {
            values.removeAll(keepingCapacity: true)
            var paddingCount = 0
            var hitPadding = false

            // Collect up to 4 characters for this group
            while values.count + paddingCount < 4 {
                guard let byte = iterator.next() else { break }
                if byte == RFC_4648.padding {
                    paddingCount += 1
                    hitPadding = true
                    continue
                }
                if byte.ascii.isWhitespace { continue }
                // Padding in the middle is invalid
                if paddingCount > 0 { return false }
                let value = decodeTable[Int(byte)]
                guard value != 255 else { return false }
                values.append(value)
            }

            let totalChars = values.count + paddingCount

            // Handle end of input
            if totalChars == 0 { break }

            // Validation
            if requirePadding {
                // Standard Base64: must have exactly 4 characters per group
                if totalChars != 4 { return false }
            }

            // All-padding without data is invalid
            if values.isEmpty {
                if hitPadding && !hasDecodedAny { return false }
                break
            }

            // Need at least 2 data characters
            guard values.count >= 2 else { return false }
            hasDecodedAny = true

            // First byte: 6 bits from v1 + high 2 bits from v2
            buffer.append((values[0] << 2) | (values[1] >> 4))

            if values.count >= 3 {
                // Second byte: low 4 bits from v2 + high 4 bits from v3
                buffer.append((values[1] << 4) | (values[2] >> 2))

                if values.count >= 4 {
                    // Third byte: low 2 bits from v3 + 6 bits from v4
                    buffer.append((values[2] << 6) | values[3])
                }
            }

            if values.count < 4 { break }
        }

        return hasDecodedAny || true
    }

    /// Internal Base64 to integer decoding shared by Base64 and Base64.URL
    @inlinable
    static func decodeBase64ToInteger<Bytes: Collection, T: FixedWidthInteger>(
        _ bytes: Bytes,
        decodeTable: [UInt8]
    ) -> T? where Bytes.Element == UInt8 {
        guard !bytes.isEmpty else { return 0 }

        var iterator = bytes.makeIterator()
        var result: T = 0
        var bitCount = 0
        let maxBits = T.bitWidth

        while let byte = iterator.next() {
            if byte == RFC_4648.padding { break }
            guard !byte.ascii.isWhitespace else { continue }

            let value = decodeTable[Int(byte)]
            guard value != 255 else { return nil }

            bitCount += 6
            guard bitCount <= maxBits else { return nil }

            result = (result << 6) | T(value)
        }

        return result
    }
}

// MARK: - Base32 Shared Implementation

extension RFC_4648 {
    /// Internal Base32 encoding implementation shared by Base32 and Base32.Hex
    ///
    /// - Parameters:
    ///   - bytes: The bytes to encode
    ///   - buffer: The buffer to append encoded characters to
    ///   - table: The encoding table to use (32 characters)
    ///   - padding: Whether to include padding characters
    @inlinable
    static func encodeBase32<Bytes: Collection, Buffer: RangeReplaceableCollection>(
        _ bytes: Bytes,
        into buffer: inout Buffer,
        table: [UInt8],
        padding: Bool
    ) where Bytes.Element == UInt8, Buffer.Element == UInt8 {
        guard !bytes.isEmpty else { return }

        var iterator = bytes.makeIterator()

        while let b1 = iterator.next() {
            let b2 = iterator.next()
            let b3 = iterator.next()
            let b4 = iterator.next()
            let b5 = iterator.next()

            // First character: high 5 bits of b1
            buffer.append(table[Int((b1 >> 3) & 0x1F)])

            // Second character: low 2 bits of b1 + high 3 bits of b2
            let c2 = ((b1 << 2) | ((b2 ?? 0) >> 6)) & 0x1F
            buffer.append(table[Int(c2)])

            guard let b2 = b2 else {
                if padding {
                    buffer.append(contentsOf: [
                        RFC_4648.padding, RFC_4648.padding,
                        RFC_4648.padding, RFC_4648.padding,
                        RFC_4648.padding, RFC_4648.padding,
                    ])
                }
                break
            }

            // Third character: bits 5-1 of b2
            buffer.append(table[Int((b2 >> 1) & 0x1F)])

            // Fourth character: low 1 bit of b2 + high 4 bits of b3
            let c4 = ((b2 << 4) | ((b3 ?? 0) >> 4)) & 0x1F
            buffer.append(table[Int(c4)])

            guard let b3 = b3 else {
                if padding {
                    buffer.append(contentsOf: [
                        RFC_4648.padding, RFC_4648.padding,
                        RFC_4648.padding, RFC_4648.padding,
                    ])
                }
                break
            }

            // Fifth character: low 4 bits of b3 + high 1 bit of b4
            let c5 = ((b3 << 1) | ((b4 ?? 0) >> 7)) & 0x1F
            buffer.append(table[Int(c5)])

            guard let b4 = b4 else {
                if padding {
                    buffer.append(contentsOf: [RFC_4648.padding, RFC_4648.padding, RFC_4648.padding])
                }
                break
            }

            // Sixth character: bits 6-2 of b4
            buffer.append(table[Int((b4 >> 2) & 0x1F)])

            // Seventh character: low 2 bits of b4 + high 3 bits of b5
            let c7 = ((b4 << 3) | ((b5 ?? 0) >> 5)) & 0x1F
            buffer.append(table[Int(c7)])

            guard let b5 = b5 else {
                if padding {
                    buffer.append(RFC_4648.padding)
                }
                break
            }

            // Eighth character: low 5 bits of b5
            buffer.append(table[Int(b5 & 0x1F)])
        }
    }

    /// Internal Base32 decoding implementation shared by Base32 and Base32.Hex
    ///
    /// - Parameters:
    ///   - bytes: The encoded bytes to decode
    ///   - buffer: The buffer to append decoded bytes to
    ///   - decodeTable: The decoding table (256 entries, 255 = invalid)
    /// - Returns: `true` if decoding succeeded, `false` if invalid input
    @inlinable
    @discardableResult
    static func decodeBase32<Bytes: Collection, Buffer: RangeReplaceableCollection>(
        _ bytes: Bytes,
        into buffer: inout Buffer,
        decodeTable: [UInt8]
    ) -> Bool where Bytes.Element == UInt8, Buffer.Element == UInt8 {
        guard !bytes.isEmpty else { return true }

        var iterator = bytes.makeIterator()
        var values = [UInt8]()
        values.reserveCapacity(8)
        var hasDecodedAny = false

        while true {
            values.removeAll(keepingCapacity: true)
            var hitPadding = false

            // Collect quintets for this group
            while values.count < 8 {
                guard let byte = iterator.next() else { break }
                if byte == RFC_4648.padding {
                    hitPadding = true
                    break
                }
                if byte.ascii.isWhitespace { continue }
                let value = decodeTable[Int(byte)]
                guard value != 255 else { return false }
                values.append(value)
            }

            // All-padding without data is invalid
            if values.isEmpty && hitPadding && !hasDecodedAny { return false }
            if values.isEmpty { break }
            guard values.count >= 2 else { return false }
            hasDecodedAny = true

            // First byte: 5 bits from v1 + high 3 bits from v2
            buffer.append((values[0] << 3) | (values[1] >> 2))

            if values.count >= 4 {
                // Second byte
                buffer.append((values[1] << 6) | (values[2] << 1) | (values[3] >> 4))
            }

            if values.count >= 5 {
                // Third byte
                buffer.append((values[3] << 4) | (values[4] >> 1))
            }

            if values.count >= 7 {
                // Fourth byte
                buffer.append((values[4] << 7) | (values[5] << 2) | (values[6] >> 3))
            }

            if values.count >= 8 {
                // Fifth byte
                buffer.append((values[6] << 5) | values[7])
            }

            if values.count < 8 { break }
        }

        return true
    }

    /// Internal Base32 to integer decoding shared by Base32 and Base32.Hex
    @inlinable
    static func decodeBase32ToInteger<Bytes: Collection, T: FixedWidthInteger>(
        _ bytes: Bytes,
        decodeTable: [UInt8]
    ) -> T? where Bytes.Element == UInt8 {
        guard !bytes.isEmpty else { return 0 }

        var iterator = bytes.makeIterator()
        var result: T = 0
        var bitCount = 0
        let maxBits = T.bitWidth

        while let byte = iterator.next() {
            if byte == RFC_4648.padding { break }
            guard !byte.ascii.isWhitespace else { continue }

            let value = decodeTable[Int(byte)]
            guard value != 255 else { return nil }

            bitCount += 5
            guard bitCount <= maxBits else { return nil }

            result = (result << 5) | T(value)
        }

        return result
    }
}
