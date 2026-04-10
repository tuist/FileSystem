import StandardsTestSupport
import Testing

@testable import Binary

@Suite
struct `FixedWidthInteger - Extensions` {

    // MARK: - rotateLeft(by:)

    @Test
    func `rotateLeft by zero returns original`() {
        let value: UInt8 = 0b11010011
        #expect(value.rotateLeft(by: 0) == value)
    }

    @Test(arguments: [
        (0b11010011 as UInt8, 1, 0b10100111 as UInt8),
        (0b11010011 as UInt8, 2, 0b01001111 as UInt8),
        (0b11010011 as UInt8, 4, 0b00111101 as UInt8),
        (0b10000000 as UInt8, 1, 0b00000001 as UInt8),
    ])
    func `rotateLeft shifts bits circularly`(testCase: (UInt8, Int, UInt8)) {
        let (value, count, expected) = testCase
        #expect(value.rotateLeft(by: count) == expected)
    }

    @Test
    func `rotateLeft by bitWidth returns original`() {
        let value: UInt8 = 0b11010011
        #expect(value.rotateLeft(by: 8) == value)
    }

    @Test
    func `rotateLeft by multiple of bitWidth returns original`() {
        let value: UInt8 = 0b10101010
        #expect(value.rotateLeft(by: 16) == value)
        #expect(value.rotateLeft(by: 24) == value)
    }

    @Test
    func `rotateLeft preserves bit count`() {
        let value: UInt8 = 0b11010011
        let rotated = value.rotateLeft(by: 3)

        #expect(value.nonzeroBitCount == rotated.nonzeroBitCount)
    }

    @Test
    func `rotateLeft works with UInt16`() {
        let value: UInt16 = 0b11000000_00000011
        let rotated = value.rotateLeft(by: 4)
        #expect(rotated == 0b00000000_00111100)
    }

    // MARK: - rotateRight(by:)

    @Test
    func `rotateRight by zero returns original`() {
        let value: UInt8 = 0b11010011
        #expect(value.rotateRight(by: 0) == value)
    }

    @Test(arguments: [
        (0b11010011 as UInt8, 1, 0b11101001 as UInt8),
        (0b11010011 as UInt8, 2, 0b11110100 as UInt8),
        (0b11010011 as UInt8, 4, 0b00111101 as UInt8),
        (0b00000001 as UInt8, 1, 0b10000000 as UInt8),
    ])
    func `rotateRight shifts bits circularly`(testCase: (UInt8, Int, UInt8)) {
        let (value, count, expected) = testCase
        #expect(value.rotateRight(by: count) == expected)
    }

    @Test
    func `rotateRight by bitWidth returns original`() {
        let value: UInt8 = 0b11010011
        #expect(value.rotateRight(by: 8) == value)
    }

    @Test
    func `rotateRight is inverse of rotateLeft`() {
        let value: UInt8 = 0b11010011
        let count = 3

        let leftThenRight = value.rotateLeft(by: count).rotateRight(by: count)
        let rightThenLeft = value.rotateRight(by: count).rotateLeft(by: count)

        #expect(leftThenRight == value)
        #expect(rightThenLeft == value)
    }

    @Test
    func `rotateRight preserves bit count`() {
        let value: UInt8 = 0b11010011
        let rotated = value.rotateRight(by: 5)

        #expect(value.nonzeroBitCount == rotated.nonzeroBitCount)
    }

    // MARK: - reverseBits()

    @Test(arguments: [
        (0b11010011 as UInt8, 0b11001011 as UInt8),
        (0b10000000 as UInt8, 0b00000001 as UInt8),
        (0b00000001 as UInt8, 0b10000000 as UInt8),
        (0b11111111 as UInt8, 0b11111111 as UInt8),
        (0b00000000 as UInt8, 0b00000000 as UInt8),
    ])
    func `reverseBits reverses bit order`(testCase: (UInt8, UInt8)) {
        let (value, expected) = testCase
        #expect(value.reverseBits() == expected)
    }

    @Test
    func `reverseBits is an involution`() {
        let value: UInt8 = 0b11010011
        let reversed = value.reverseBits()
        let doubleReversed = reversed.reverseBits()

        #expect(doubleReversed == value)
    }

    @Test
    func `reverseBits preserves bit count`() {
        let value: UInt8 = 0b11010011
        let reversed = value.reverseBits()

        #expect(value.nonzeroBitCount == reversed.nonzeroBitCount)
    }

    @Test
    func `reverseBits works with UInt16`() {
        let value: UInt16 = 0b10000000_00000001
        let reversed = value.reverseBits()

        #expect(reversed == 0b10000000_00000001)
    }

    @Test
    func `reverseBits palindrome`() {
        let palindrome: UInt8 = 0b10011001
        #expect(palindrome.reverseBits() == palindrome)
    }

    // MARK: - bytes(endianness:)

    @Test
    func `bytes with little endian UInt16`() {
        let value: UInt16 = 0x1234
        let bytes = value.bytes(endianness: .little)

        #expect(bytes.count == 2)
        #expect(bytes[0] == 0x34)
        #expect(bytes[1] == 0x12)
    }

    @Test
    func `bytes with big endian UInt16`() {
        let value: UInt16 = 0x1234
        let bytes = value.bytes(endianness: .big)

        #expect(bytes.count == 2)
        #expect(bytes[0] == 0x12)
        #expect(bytes[1] == 0x34)
    }

    @Test
    func `bytes with little endian UInt32`() {
        let value: UInt32 = 0x1234_5678
        let bytes = value.bytes(endianness: .little)

        #expect(bytes.count == 4)
        #expect(bytes == [0x78, 0x56, 0x34, 0x12])
    }

    @Test
    func `bytes with big endian UInt32`() {
        let value: UInt32 = 0x1234_5678
        let bytes = value.bytes(endianness: .big)

        #expect(bytes.count == 4)
        #expect(bytes == [0x12, 0x34, 0x56, 0x78])
    }

    @Test
    func `bytes count matches memory layout`() {
        let value: UInt64 = 0x1234_5678_9ABC_DEF0
        let bytes = value.bytes()

        #expect(bytes.count == MemoryLayout<UInt64>.size)
    }

    @Test
    func `bytes with zero value`() {
        let value: UInt32 = 0
        let bytes = value.bytes(endianness: .big)

        #expect(bytes.allSatisfy { $0 == 0 })
        #expect(bytes.count == 4)
    }

    @Test
    func `bytes default endianness is little`() {
        let value: UInt16 = 0x1234
        let defaultBytes = value.bytes()
        let littleBytes = value.bytes(endianness: .little)

        #expect(defaultBytes == littleBytes)
    }

    @Test
    func `bytes works with Int8`() {
        let value: Int8 = -1
        let bytes = value.bytes()

        #expect(bytes.count == 1)
        #expect(bytes[0] == 0xFF)
    }

    @Test
    func `bytes works with Int16`() {
        let value: Int16 = 0x1234
        let bigEndian = value.bytes(endianness: .big)

        #expect(bigEndian.count == 2)
        #expect(bigEndian[0] == 0x12)
        #expect(bigEndian[1] == 0x34)
    }
}

@Suite
struct `FixedWidthInteger - Type Specific` {

    @Test
    func `UInt8 rotations`() {
        let value: UInt8 = 0b11010011
        #expect(value.rotateLeft(by: 1) == 0b10100111)
        #expect(value.rotateRight(by: 1) == 0b11101001)
    }

    @Test
    func `UInt16 rotations`() {
        let value: UInt16 = 0b11000000_00000011
        #expect(value.rotateLeft(by: 4) == 0b00000000_00111100)
    }

    @Test
    func `UInt32 rotations`() {
        let value: UInt32 = 0x1234_5678
        let rotated = value.rotateLeft(by: 8)
        #expect(rotated == 0x3456_7812)
    }

    @Test
    func `UInt64 rotations`() {
        let value: UInt64 = 0x1234_5678_9ABC_DEF0
        let rotated = value.rotateLeft(by: 16)
        #expect(rotated == 0x5678_9ABC_DEF0_1234)
    }

    @Test
    func `Int8 bits reverse`() {
        let value: Int8 = 0b01010101  // 85
        let reversed = value.reverseBits()
        // Reversed would be 0b10101010 which is -86 in two's complement
        #expect(reversed == -86)
    }

    @Test
    func `Int16 bits reverse`() {
        let value: Int16 = 0b00000000_11111111  // 255
        let reversed = value.reverseBits()
        // Reversed would be 0b1111111100000000 which is -256 in two's complement
        #expect(reversed == -256)
    }
}

// MARK: - Performance Tests
// TODO: Re-enable when Performance Tests infrastructure is available in Binary Tests
//
// extension `Performance Tests` {
//     @Suite
//     struct `FixedWidthInteger - Performance` {
//         ...
//     }
// }
