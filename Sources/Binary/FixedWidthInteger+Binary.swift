// FixedWidthInteger+Binary.swift
// Bit and byte operations for fixed-width integers.

// MARK: - Bit Rotation

extension FixedWidthInteger {
    /// Rotates bits left by specified count.
    ///
    /// Circular left shift preserving all bits.
    /// Distinct from left shift which fills with zeros.
    ///
    /// Category theory: Automorphism in cyclic group of bit positions
    /// `rotateLeft: Z/nZ → Z/nZ` where n = bitWidth
    ///
    /// Example:
    /// ```swift
    /// let x: UInt8 = 0b11010011
    /// x.rotateLeft(by: 2)  // 0b01001111
    /// ```
    public func rotateLeft(by count: Int) -> Self {
        let shift = count % Self.bitWidth
        guard shift != 0 else { return self }

        return (self << shift) | (self >> (Self.bitWidth - shift))
    }

    /// Rotates bits right by specified count.
    ///
    /// Circular right shift preserving all bits.
    /// Distinct from right shift which fills with sign or zeros.
    ///
    /// Category theory: Inverse of rotateLeft in cyclic group
    /// `rotateRight: Z/nZ → Z/nZ` where `rotateRight(k) = rotateLeft(-k)`
    ///
    /// Example:
    /// ```swift
    /// let x: UInt8 = 0b11010011
    /// x.rotateRight(by: 2)  // 0b11110100
    /// ```
    public func rotateRight(by count: Int) -> Self {
        let shift = count % Self.bitWidth
        guard shift != 0 else { return self }

        return (self >> shift) | (self << (Self.bitWidth - shift))
    }

    /// Reverses all bits.
    ///
    /// Reflection operation inverting bit order.
    /// Useful in FFT algorithms, cryptography, and binary protocols.
    ///
    /// Category theory: Involution (self-inverse) `reverseBits ∘ reverseBits = id`
    ///
    /// Example:
    /// ```swift
    /// let x: UInt8 = 0b11010011
    /// x.reverseBits()  // 0b11001011
    /// ```
    public func reverseBits() -> Self {
        var result: Self = 0
        var value = self

        for _ in 0..<Self.bitWidth {
            result <<= 1
            result |= value & 1
            value >>= 1
        }

        return result
    }
}

// MARK: - Byte Serialization

extension FixedWidthInteger {
    /// Converts to byte array with specified endianness.
    ///
    /// Serializes integer to bytes respecting byte order.
    /// Enables portable binary representation.
    ///
    /// Category theory: Homomorphism from integer ring to byte sequences
    /// `bytes: Z → Seq(UInt8)` preserving arithmetic under deserialization
    ///
    /// Example:
    /// ```swift
    /// let x: UInt16 = 0x1234
    /// x.bytes(endianness: .big)     // [0x12, 0x34]
    /// x.bytes(endianness: .little)  // [0x34, 0x12]
    /// ```
    public func bytes(endianness: Binary.Endianness = .little) -> [UInt8] {
        let converted: Self
        switch endianness {
        case .little:
            converted = self.littleEndian
        case .big:
            converted = self.bigEndian
        }

        return Swift.withUnsafeBytes(of: converted) { Array($0) }
    }

    /// Creates an integer from byte array with specified endianness.
    ///
    /// Deserializes bytes to integer respecting byte order.
    /// Inverse operation of `bytes(endianness:)`.
    ///
    /// Category theory: Inverse homomorphism from byte sequences to integers
    /// `init(bytes:endianness:): Seq(UInt8) → Z`, inverse of `bytes(endianness:)`
    ///
    /// Example:
    /// ```swift
    /// let bytes: [UInt8] = [0x12, 0x34, 0x56, 0x78]
    /// let value = UInt32(bytes: bytes, endianness: .big)  // 0x12345678
    /// ```
    ///
    /// - Parameters:
    ///   - bytes: Byte array to deserialize
    ///   - endianness: Byte order of the input bytes (defaults to little-endian)
    /// - Returns: Integer value, or nil if byte count doesn't match type size
    public init?(bytes: [UInt8], endianness: Binary.Endianness = .little) {
        guard bytes.count == MemoryLayout<Self>.size else { return nil }

        let value = bytes.withUnsafeBytes { $0.load(as: Self.self) }

        switch endianness {
        case .little:
            self = Self(littleEndian: value)
        case .big:
            self = Self(bigEndian: value)
        }
    }
}

// MARK: - Array Deserialization

extension Array where Element: FixedWidthInteger {
    /// Creates an array of integers from a flat byte collection.
    ///
    /// - Parameters:
    ///   - bytes: Collection of bytes representing multiple integers
    ///   - endianness: Byte order of the input bytes (defaults to little-endian)
    /// - Returns: Array of integers, or nil if byte count is not a multiple of integer size
    ///
    /// Example:
    /// ```swift
    /// let bytes: [UInt8] = [0x01, 0x00, 0x02, 0x00]
    /// let values = [UInt16](bytes: bytes)  // [1, 2]
    /// ```
    public init?<C: Collection>(bytes: C, endianness: Binary.Endianness = .little)
    where C.Element == UInt8 {
        let elementSize = MemoryLayout<Element>.size
        guard bytes.count % elementSize == 0 else { return nil }

        var result: [Element] = []
        result.reserveCapacity(bytes.count / elementSize)

        let byteArray: [UInt8] = .init(bytes)
        for i in stride(from: 0, to: byteArray.count, by: elementSize) {
            let chunk: [UInt8] = .init(byteArray[i..<i + elementSize])
            guard let element = Element(bytes: chunk, endianness: endianness) else {
                return nil
            }
            result.append(element)
        }

        self = result
    }
}
