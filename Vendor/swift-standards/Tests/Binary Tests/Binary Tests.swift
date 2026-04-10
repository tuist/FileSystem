// Binary Tests.swift

import Testing

@testable import Binary

@Suite
struct `Binary.Endianness Tests` {
    @Test
    func `Binary.Endianness cases`() {
        let little: Binary.Endianness = .little
        let big: Binary.Endianness = .big
        #expect(little != big)
    }

    @Test
    func `Binary.Endianness opposite`() {
        #expect(Binary.Endianness.little.opposite == .big)
        #expect(Binary.Endianness.big.opposite == .little)
    }

    @Test
    func `Binary.Endianness negation operator`() {
        #expect(!Binary.Endianness.little == .big)
        #expect(!Binary.Endianness.big == .little)
        #expect(!(!Binary.Endianness.little) == .little)
    }

    @Test
    func `Binary.Endianness CaseIterable`() {
        #expect(Binary.Endianness.allCases.count == 2)
        #expect(Binary.Endianness.allCases.contains(.little))
        #expect(Binary.Endianness.allCases.contains(.big))
    }

    @Test
    func `Binary.Endianness network is big`() {
        #expect(Binary.Endianness.network == .big)
    }

    @Test
    func `Binary.Endianness native detection`() {
        // Should be one of the two valid values
        let native = Binary.Endianness.native
        #expect(native == .little || native == .big)
    }
}

@Suite
struct `Bit.Order Tests` {
    @Test
    func `Bit.Order cases`() {
        let msb: Bit.Order = .msb
        let lsb: Bit.Order = .lsb
        #expect(msb != lsb)
    }

    @Test
    func `Bit.Order opposite`() {
        #expect(Bit.Order.msb.opposite == .lsb)
        #expect(Bit.Order.lsb.opposite == .msb)
    }

    @Test
    func `Bit.Order negation operator`() {
        #expect(!Bit.Order.msb == .lsb)
        #expect(!Bit.Order.lsb == .msb)
    }
}

@Suite
struct FixedWidthIntegerBinaryTests {
    @Test
    func `Byte serialization little endian`() {
        let value: UInt16 = 0x1234
        let bytes = value.bytes(endianness: .little)
        #expect(bytes == [0x34, 0x12])
    }

    @Test
    func `Byte serialization big endian`() {
        let value: UInt16 = 0x1234
        let bytes = value.bytes(endianness: .big)
        #expect(bytes == [0x12, 0x34])
    }

    @Test
    func `Byte deserialization little endian`() {
        let bytes: [UInt8] = [0x34, 0x12]
        let value = UInt16(bytes: bytes, endianness: .little)
        #expect(value == 0x1234)
    }

    @Test
    func `Byte deserialization big endian`() {
        let bytes: [UInt8] = [0x12, 0x34]
        let value = UInt16(bytes: bytes, endianness: .big)
        #expect(value == 0x1234)
    }

    @Test
    func `Rotate left`() {
        let x: UInt8 = 0b11010011
        let rotated = x.rotateLeft(by: 2)
        #expect(rotated == 0b01001111)
    }

    @Test
    func `Rotate right`() {
        let x: UInt8 = 0b11010011
        let rotated = x.rotateRight(by: 2)
        #expect(rotated == 0b11110100)
    }

    @Test
    func `Reverse bits`() {
        let x: UInt8 = 0b11010011
        let reversed = x.reverseBits()
        #expect(reversed == 0b11001011)
    }
}

@Suite
struct ByteArrayTests {
    @Test
    func `Array from integer`() {
        let bytes = [UInt8](UInt16(0x1234), endianness: .little)
        #expect(bytes == [0x34, 0x12])
    }

    @Test
    func `Array from UTF8 string`() {
        let bytes = [UInt8](utf8: "Hi")
        #expect(bytes == [72, 105])
    }

    @Test
    func `Split by separator`() {
        let data: [UInt8] = [1, 2, 0, 0, 3, 4, 0, 0, 5]
        let parts = data.split(separator: [0, 0])
        #expect(parts.count == 3)
        #expect(parts[0] == [1, 2])
        #expect(parts[1] == [3, 4])
        #expect(parts[2] == [5])
    }

    @Test
    func `Join with separator`() {
        let parts: [[UInt8]] = [[1, 2], [3, 4], [5]]
        let joined = parts.joined(separator: [0, 0])
        #expect(joined == [1, 2, 0, 0, 3, 4, 0, 0, 5])
    }
}

@Suite
struct CollectionBytesTests {
    @Test
    func `Trimming bytes`() {
        let bytes: [UInt8] = [0x20, 0x48, 0x69, 0x20]
        let trimmed = bytes.trimming(where: { $0 == 0x20 })
        #expect(Array(trimmed) == [0x48, 0x69])
    }

    @Test
    func `First index of subsequence`() {
        let data: [UInt8] = [0x48, 0x65, 0x6C, 0x6C, 0x6F]  // "Hello"
        let index = data.firstIndex(of: [0x6C, 0x6C])  // "ll"
        #expect(index == 2)
    }

    @Test
    func `Contains subsequence`() {
        let data: [UInt8] = [0x48, 0x65, 0x6C, 0x6C, 0x6F]
        #expect(data.contains([0x65, 0x6C]))  // "el"
        #expect(!data.contains([0x58, 0x59]))  // "XY"
    }
}
