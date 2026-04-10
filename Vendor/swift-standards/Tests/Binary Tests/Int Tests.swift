import Testing

@testable import Binary

@Suite
struct `Int - Byte serialization` {

    @Test
    func `Round-trip conversion preserves value`() {
        let value: Int = 42
        let bytes = [UInt8](value)
        let recovered = Int(bytes: bytes)
        #expect(recovered == value)
    }

    @Test
    func `Little-endian encoding matches expected bytes`() {
        let value: Int = 0x0102_0304_0506_0708
        let bytes = [UInt8](value, endianness: .little)

        #if arch(x86_64) || arch(arm64)
            // On 64-bit systems, Int is 8 bytes
            #expect(bytes.count == 8)
            #expect(bytes[0] == 0x08)
            #expect(bytes[1] == 0x07)
            #expect(bytes[2] == 0x06)
            #expect(bytes[3] == 0x05)
            #expect(bytes[4] == 0x04)
            #expect(bytes[5] == 0x03)
            #expect(bytes[6] == 0x02)
            #expect(bytes[7] == 0x01)
        #else
            // On 32-bit systems, Int is 4 bytes
            #expect(bytes.count == 4)
            #expect(bytes[0] == 0x08)
            #expect(bytes[1] == 0x07)
            #expect(bytes[2] == 0x06)
            #expect(bytes[3] == 0x05)
        #endif
    }

    @Test
    func `Big-endian encoding matches expected bytes`() {
        let value: Int = 0x0102_0304_0506_0708
        let bytes = [UInt8](value, endianness: .big)

        #if arch(x86_64) || arch(arm64)
            // On 64-bit systems, Int is 8 bytes
            #expect(bytes.count == 8)
            #expect(bytes[0] == 0x01)
            #expect(bytes[1] == 0x02)
            #expect(bytes[2] == 0x03)
            #expect(bytes[3] == 0x04)
            #expect(bytes[4] == 0x05)
            #expect(bytes[5] == 0x06)
            #expect(bytes[6] == 0x07)
            #expect(bytes[7] == 0x08)
        #else
            // On 32-bit systems, Int is 4 bytes
            #expect(bytes.count == 4)
            #expect(bytes[0] == 0x05)
            #expect(bytes[1] == 0x06)
            #expect(bytes[2] == 0x07)
            #expect(bytes[3] == 0x08)
        #endif
    }

    @Test
    func `Decoding with little-endian`() {
        let bytes: [UInt8] = [0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08]
        let value = Int(bytes: bytes, endianness: .little)

        #if arch(x86_64) || arch(arm64)
            #expect(value == 0x0807_0605_0403_0201)
        #else
            // On 32-bit, only use first 4 bytes
            let value32 = Int(bytes: Array(bytes.prefix(4)), endianness: .littleEndian)
            #expect(value32 == 0x0403_0201)
        #endif
    }

    @Test
    func `Decoding with big-endian`() {
        let bytes: [UInt8] = [0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08]
        let value = Int(bytes: bytes, endianness: .big)

        #if arch(x86_64) || arch(arm64)
            #expect(value == 0x0102_0304_0506_0708)
        #else
            // On 32-bit, only use first 4 bytes
            let value32 = Int(bytes: Array(bytes.prefix(4)), endianness: .bigEndian)
            #expect(value32 == 0x0102_0304)
        #endif
    }

    @Test
    func `Decoding fails with incorrect byte count`() {
        let bytes: [UInt8] = [0x01, 0x02, 0x03]
        let value = Int(bytes: bytes)
        #expect(value == nil)
    }

    @Test
    func `Zero value round-trip`() {
        let value: Int = 0
        let bytes = [UInt8](value)
        let recovered = Int(bytes: bytes)
        #expect(recovered == value)
    }

    @Test
    func `Negative value round-trip`() {
        let value: Int = -42
        let bytes = [UInt8](value)
        let recovered = Int(bytes: bytes)
        #expect(recovered == value)
    }
}

@Suite
struct `[Int] - Byte serialization` {

    @Test
    func `Array round-trip conversion`() {
        let values: [Int] = [1, 2, 3, 4, 5]
        let bytes = [UInt8](serializing: values)
        let recovered = [Int](bytes: bytes)
        #expect(recovered == values)
    }

    @Test
    func `Empty array round-trip`() {
        let values: [Int] = []
        let bytes = [UInt8](serializing: values)
        let recovered = [Int](bytes: bytes)
        #expect(recovered == values)
    }

    @Test
    func `Array with different endianness`() {
        let values: [Int] = [1, 2, 3]
        let bytesLE = [UInt8](serializing: values, endianness: .little)
        let bytesBE = [UInt8](serializing: values, endianness: .big)

        let recoveredLE = [Int](bytes: bytesLE, endianness: .little)
        let recoveredBE = [Int](bytes: bytesBE, endianness: .big)

        #expect(recoveredLE == values)
        #expect(recoveredBE == values)
    }

    @Test
    func `Array decoding fails with incorrect byte count`() {
        // Not a multiple of Int size
        let bytes: [UInt8] = [0x01, 0x02, 0x03]
        let values = [Int](bytes: bytes)
        #expect(values == nil)
    }

    @Test
    func `Array with negative values`() {
        let values: [Int] = [-1, -2, -3]
        let bytes = [UInt8](serializing: values)
        let recovered = [Int](bytes: bytes)
        #expect(recovered == values)
    }
}
