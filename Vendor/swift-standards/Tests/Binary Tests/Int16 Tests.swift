import Testing

@testable import Binary

@Suite
struct `Int16 - Byte encoding` {

    // MARK: - Basic encoding

    @Test
    func `Encode to bytes little-endian`() {
        let value: Int16 = 0x1234
        let bytes = value.bytes(endianness: .little)
        #expect(bytes == [0x34, 0x12])
    }

    @Test
    func `Encode to bytes big-endian`() {
        let value: Int16 = 0x1234
        let bytes = value.bytes(endianness: .big)
        #expect(bytes == [0x12, 0x34])
    }

    @Test
    func `Encode zero`() {
        let value: Int16 = 0
        #expect(value.bytes(endianness: .little) == [0x00, 0x00])
        #expect(value.bytes(endianness: .big) == [0x00, 0x00])
    }

    @Test
    func `Encode positive max value`() {
        let value: Int16 = .max  // 0x7FFF
        #expect(value.bytes(endianness: .little) == [0xFF, 0x7F])
        #expect(value.bytes(endianness: .big) == [0x7F, 0xFF])
    }

    @Test
    func `Encode negative value`() {
        let value: Int16 = -1
        #expect(value.bytes(endianness: .little) == [0xFF, 0xFF])
        #expect(value.bytes(endianness: .big) == [0xFF, 0xFF])
    }

    @Test
    func `Encode negative min value`() {
        let value: Int16 = .min  // -0x8000
        #expect(value.bytes(endianness: .little) == [0x00, 0x80])
        #expect(value.bytes(endianness: .big) == [0x80, 0x00])
    }

    // MARK: - Isomorphism property

    @Test
    func `Encode-decode isomorphism little-endian`() {
        // encode ∘ decode ≡ id
        let original: Int16 = 0x1234
        let bytes = original.bytes(endianness: .little)
        let recovered = Int16(bytes: bytes, endianness: .little)
        #expect(recovered == original)
    }

    @Test
    func `Encode-decode isomorphism big-endian`() {
        // encode ∘ decode ≡ id
        let original: Int16 = -0x1234
        let bytes = original.bytes(endianness: .big)
        let recovered = Int16(bytes: bytes, endianness: .big)
        #expect(recovered == original)
    }

    @Test
    func `Round-trip multiple values`() {
        let values: [Int16] = [.min, -1000, -1, 0, 1, 1000, .max]

        for original in values {
            let bytesLE = original.bytes(endianness: .little)
            let recoveredLE = Int16(bytes: bytesLE, endianness: .little)
            #expect(recoveredLE == original)

            let bytesBE = original.bytes(endianness: .big)
            let recoveredBE = Int16(bytes: bytesBE, endianness: .big)
            #expect(recoveredBE == original)
        }
    }

    // MARK: - Byte count

    @Test
    func `Byte count matches memory layout`() {
        let value: Int16 = 0x1234
        let bytes = value.bytes(endianness: .little)
        #expect(bytes.count == MemoryLayout<Int16>.size)
        #expect(bytes.count == 2)
    }
}
