import Testing

@testable import Binary

// UInt8 Base64 and Hex encoding tests have been moved to swift-rfc-4648
// UInt8 ASCII tests have been moved to swift-incits-4-1986

// MARK: - String Conversion Tests

@Test
func `String to bytes conversion`() {
    let string = "Hello, World!"
    let bytes = [UInt8](utf8: string)

    #expect(bytes == Array(string.utf8))
    #expect(bytes.count == 13)
}

@Test
func `Bytes to UTF-8 string conversion`() {
    let bytes: [UInt8] = [72, 101, 108, 108, 111]
    let string = String(bytes)

    #expect(string == "Hello")
}

// ASCII string validation tests have been moved to swift-incits-4-1986

// MARK: - Integer Deserialization Tests

@Test
func `Deserialize UInt32 little-endian`() {
    let bytes: [UInt8] = [0x78, 0x56, 0x34, 0x12]
    let value = UInt32(bytes: bytes, endianness: .little)

    #expect(value == 0x1234_5678)
}

@Test
func `Deserialize UInt32 big-endian`() {
    let bytes: [UInt8] = [0x12, 0x34, 0x56, 0x78]
    let value = UInt32(bytes: bytes, endianness: .big)

    #expect(value == 0x1234_5678)
}

@Test
func `Deserialize with wrong size returns nil`() {
    let bytes: [UInt8] = [0x12, 0x34, 0x56]
    let value = UInt32(bytes: bytes)

    #expect(value == nil)
}

@Test
func `Roundtrip serialization and deserialization`() {
    let original: UInt64 = 0x0123_4567_89AB_CDEF
    let bytes = original.bytes(endianness: .big)
    let deserialized = UInt64(bytes: bytes, endianness: .big)

    #expect(deserialized == original)
}

// MARK: - Subsequence Search Tests

@Test
func `Find subsequence at beginning`() {
    let bytes: [UInt8] = [1, 2, 3, 4, 5]
    let needle: [UInt8] = [1, 2]

    #expect(bytes.firstIndex(of: needle) == 0)
}

@Test
func `Find subsequence in middle`() {
    let bytes: [UInt8] = [1, 2, 3, 4, 5]
    let needle: [UInt8] = [3, 4]

    #expect(bytes.firstIndex(of: needle) == 2)
}

@Test
func `Find subsequence at end`() {
    let bytes: [UInt8] = [1, 2, 3, 4, 5]
    let needle: [UInt8] = [4, 5]

    #expect(bytes.firstIndex(of: needle) == 3)
}

@Test
func `Subsequence not found returns nil`() {
    let bytes: [UInt8] = [1, 2, 3, 4, 5]
    let needle: [UInt8] = [6, 7]

    #expect(bytes.firstIndex(of: needle) == nil)
}

@Test
func `Empty needle returns start index`() {
    let bytes: [UInt8] = [1, 2, 3]
    let needle: [UInt8] = []

    #expect(bytes.firstIndex(of: needle) == 0)
}

// MARK: - Last Index Tests

@Test
func `Find last occurrence at end`() {
    let bytes: [UInt8] = [1, 2, 3, 2, 3]
    let needle: [UInt8] = [2, 3]

    #expect(bytes.lastIndex(of: needle) == 3)
}

@Test
func `Find last occurrence in middle`() {
    let bytes: [UInt8] = [1, 2, 3, 4, 2, 3, 5]
    let needle: [UInt8] = [2, 3]

    #expect(bytes.lastIndex(of: needle) == 4)
}

@Test
func `Find last occurrence at beginning when only one`() {
    let bytes: [UInt8] = [1, 2, 3, 4, 5]
    let needle: [UInt8] = [1, 2]

    #expect(bytes.lastIndex(of: needle) == 0)
}

@Test
func `Last index not found returns nil`() {
    let bytes: [UInt8] = [1, 2, 3, 4, 5]
    let needle: [UInt8] = [6, 7]

    #expect(bytes.lastIndex(of: needle) == nil)
}

@Test
func `Last index with empty needle returns end index`() {
    let bytes: [UInt8] = [1, 2, 3]
    let needle: [UInt8] = []

    #expect(bytes.lastIndex(of: needle) == 3)
}

// MARK: - Contains Tests

@Test
func `Contains subsequence that exists`() {
    let bytes: [UInt8] = [1, 2, 3, 4, 5]

    #expect(bytes.contains([2, 3]) == true)
    #expect(bytes.contains([1]) == true)
    #expect(bytes.contains([5]) == true)
    #expect(bytes.contains([3, 4, 5]) == true)
}

@Test
func `Contains subsequence that doesn't exist`() {
    let bytes: [UInt8] = [1, 2, 3, 4, 5]

    #expect(bytes.contains([6, 7]) == false)
    #expect(bytes.contains([5, 6]) == false)
    #expect(bytes.contains([0]) == false)
}

@Test
func `Contains with empty subsequence`() {
    let bytes: [UInt8] = [1, 2, 3]

    #expect(bytes.contains([]) == true)
}

// MARK: - Edge Case Tests

@Test
func `Search in empty array`() {
    let empty: [UInt8] = []

    #expect(empty.firstIndex(of: [1, 2]) == nil)
    #expect(empty.lastIndex(of: [1, 2]) == nil)
    #expect(empty.contains([1, 2]) == false)
    #expect(empty.firstIndex(of: []) == 0)
    #expect(empty.lastIndex(of: []) == 0)
    #expect(empty.contains([]) == true)
}

@Test
func `Needle larger than haystack`() {
    let bytes: [UInt8] = [1, 2]
    let needle: [UInt8] = [1, 2, 3, 4]

    #expect(bytes.firstIndex(of: needle) == nil)
    #expect(bytes.lastIndex(of: needle) == nil)
    #expect(bytes.contains(needle) == false)
}

@Test
func `Exact match - needle equals haystack`() {
    let bytes: [UInt8] = [1, 2, 3]
    let needle: [UInt8] = [1, 2, 3]

    #expect(bytes.firstIndex(of: needle) == 0)
    #expect(bytes.lastIndex(of: needle) == 0)
    #expect(bytes.contains(needle) == true)
}

@Test
func `Single byte search`() {
    let bytes: [UInt8] = [1, 2, 3, 2, 4]

    #expect(bytes.firstIndex(of: [2]) == 1)
    #expect(bytes.lastIndex(of: [2]) == 3)
    #expect(bytes.contains([2]) == true)
    #expect(bytes.contains([5]) == false)
}

@Test
func `Overlapping patterns`() {
    let bytes: [UInt8] = [1, 1, 1, 2]
    let needle: [UInt8] = [1, 1]

    #expect(bytes.firstIndex(of: needle) == 0)
    #expect(bytes.lastIndex(of: needle) == 1)
}

@Test
func `Large byte sequence performance`() {
    // Create a 10KB array
    let large = [UInt8](repeating: 0xFF, count: 10_000)
    let needle: [UInt8] = [0xFF, 0xFF, 0xFF]

    #expect(large.firstIndex(of: needle) == 0)
    #expect(large.lastIndex(of: needle) == 9_997)
    #expect(large.contains(needle) == true)
}

@Test
func `Pattern at every position`() {
    let bytes: [UInt8] = [1, 1, 1, 1, 1]
    let needle: [UInt8] = [1]

    #expect(bytes.firstIndex(of: needle) == 0)
    #expect(bytes.lastIndex(of: needle) == 4)
    #expect(bytes.contains(needle) == true)
}

// MARK: - Unicode and String Conversion Edge Cases

@Test
func `Empty string conversion`() {
    let empty = [UInt8](utf8: "")
    #expect(empty.isEmpty)
    #expect(String(empty).isEmpty)
}

@Test
func `Multi-byte UTF-8 characters`() {
    // Emoji and multi-byte characters
    let emoji = "Hello 👋 World 🌍"
    let bytes = [UInt8](utf8: emoji)
    let restored = String(bytes)

    #expect(restored == emoji)
    #expect(bytes.count > emoji.count)  // UTF-8 uses multiple bytes
}

@Test
func `Special UTF-8 characters`() {
    let special = "Café résumé naïve"
    let bytes = [UInt8](utf8: special)
    let restored = String(bytes)

    #expect(restored == special)
}

@Test
func `RTL and mixed scripts`() {
    let mixed = "Hello مرحبا שלום 你好"
    let bytes = [UInt8](utf8: mixed)
    let restored = String(bytes)

    #expect(restored == mixed)
}

@Test
func `Null bytes in string`() {
    let withNull: [UInt8] = [72, 101, 108, 108, 111, 0, 87, 111, 114, 108, 100]
    let string = String(withNull)

    #expect(string.contains("\0"))
    #expect(String(withNull).count == 11)
}

@Test
func `Maximum valid UTF-8 sequences`() {
    // 4-byte UTF-8 character (e.g., 𝄞 musical symbol)
    let musical = "𝄞𝄢𝄫"
    let bytes = [UInt8](utf8: musical)
    let restored = String(bytes)

    #expect(restored == musical)
}

@Test
func `Very long string conversion`() {
    let long = String(repeating: "Hello World! ", count: 1000)
    let bytes = [UInt8](utf8: long)
    let restored = String(bytes)

    #expect(restored == long)
    #expect(bytes.count == long.utf8.count)
}

// MARK: - Split Tests

@Test
func `Split on delimiter`() {
    let bytes: [UInt8] = [1, 2, 0, 3, 4, 0, 5]
    let parts = bytes.split(separator: [0])

    #expect(parts.count == 3)
    #expect(parts[0] == [1, 2])
    #expect(parts[1] == [3, 4])
    #expect(parts[2] == [5])
}

@Test
func `Split on multi-byte delimiter`() {
    let bytes: [UInt8] = [1, 2, 255, 255, 3, 4, 255, 255, 5]
    let parts = bytes.split(separator: [255, 255])

    #expect(parts.count == 3)
    #expect(parts[0] == [1, 2])
    #expect(parts[1] == [3, 4])
    #expect(parts[2] == [5])
}

@Test
func `Split with empty separator returns original`() {
    let bytes: [UInt8] = [1, 2, 3]
    let parts = bytes.split(separator: [])

    #expect(parts.count == 1)
    #expect(parts[0] == bytes)
}

@Test
func `Split CRLF delimiters`() {
    let bytes: [UInt8] = Array("Line1\r\nLine2\r\nLine3".utf8)
    let parts = bytes.split(separator: [UInt8](utf8: "\r\n"))

    #expect(parts.count == 3)
    #expect(String(parts[0]) == "Line1")
    #expect(String(parts[1]) == "Line2")
    #expect(String(parts[2]) == "Line3")
}

// MARK: - Mutation Helper Tests

@Test
func `Append UTF-8 string`() {
    var bytes: [UInt8] = [1, 2, 3]
    bytes.append(utf8: "Hi")

    #expect(bytes == [1, 2, 3, 72, 105])
}

@Test
func `Append integer with little-endian`() {
    var bytes: [UInt8] = []
    bytes.append(UInt16(0x1234), endianness: .little)

    #expect(bytes == [0x34, 0x12])
}

@Test
func `Append integer with big-endian`() {
    var bytes: [UInt8] = []
    bytes.append(UInt32(0x1234_5678), endianness: .big)

    #expect(bytes == [0x12, 0x34, 0x56, 0x78])
}

@Test
func `Build complex byte sequence`() {
    var bytes: [UInt8] = []
    bytes.append(utf8: "HTTP/1.1 ")
    bytes.append(UInt16(200), endianness: .big)
    bytes.append(utf8: " OK\r\n")

    let expected: [UInt8] = Array("HTTP/1.1 ".utf8) + [0x00, 0xC8] + Array(" OK\r\n".utf8)
    #expect(bytes == expected)
}

// MARK: - Append Single Byte Tests (Bug Fix Verification)
//
// These tests verify that appending a single UInt8 byte works correctly
// and does not accidentally use the multi-byte FixedWidthInteger append.
// See: https://github.com/swift-standards/swift-standards/issues/XXX

@Test
func `Append single UInt8 byte`() {
    var bytes: [UInt8] = []
    bytes.append(UInt8(0x2F))

    // Should be exactly 1 byte, not 8 bytes
    #expect(bytes.count == 1)
    #expect(bytes == [0x2F])
}

@Test
func `Append explicit UInt8 value`() {
    var bytes: [UInt8] = []
    let slash: UInt8 = 0x2F
    bytes.append(slash)

    #expect(bytes.count == 1)
    #expect(bytes == [47])
}

@Test
func `Append multiple single bytes`() {
    var bytes: [UInt8] = []
    bytes.append(UInt8(0x48))  // 'H'
    bytes.append(UInt8(0x69))  // 'i'

    #expect(bytes.count == 2)
    #expect(bytes == [0x48, 0x69])
    #expect(String(decoding: bytes, as: UTF8.self) == "Hi")
}

@Test
func `Append UInt8 vs multi-byte integer distinction`() {
    // UInt8 should append exactly 1 byte
    var single: [UInt8] = []
    single.append(UInt8(47))
    #expect(single.count == 1)

    // UInt16 should append exactly 2 bytes
    var double: [UInt8] = []
    double.append(UInt16(47), endianness: .little)
    #expect(double.count == 2)
    #expect(double == [47, 0])

    // UInt32 should append exactly 4 bytes
    var quad: [UInt8] = []
    quad.append(UInt32(47), endianness: .little)
    #expect(quad.count == 4)
    #expect(quad == [47, 0, 0, 0])
}

@Test
func `Append UInt8 boundary values`() {
    var bytes: [UInt8] = []

    bytes.append(UInt8(0))  // minimum
    bytes.append(UInt8(127))  // max signed
    bytes.append(UInt8(128))  // min unsigned > signed
    bytes.append(UInt8(255))  // maximum

    #expect(bytes.count == 4)
    #expect(bytes == [0, 127, 128, 255])
}

@Test
func `Append Int8 boundary values`() {
    var bytes: [UInt8] = []

    bytes.append(UInt8(bitPattern: Int8(-128)))  // minimum
    bytes.append(UInt8(bitPattern: Int8(-1)))  // -1
    bytes.append(UInt8(bitPattern: Int8(0)))  // zero
    bytes.append(UInt8(bitPattern: Int8(127)))  // maximum

    #expect(bytes.count == 4)
    #expect(bytes == [128, 255, 0, 127])
}

// MARK: - Generic Collection Tests

@Test
func `Search works with ArraySlice`() {
    let bytes: [UInt8] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
    let slice = bytes[2..<8]  // [2, 3, 4, 5, 6, 7]

    // These should work on ArraySlice<UInt8> too
    #expect(slice.firstIndex(of: [4, 5]) == 4)  // index in original array
    #expect(slice.contains([3, 4, 5]))
    #expect(!slice.contains([0, 1]))  // not in slice
}

@Test
func `Trimming works with generic collection`() {
    let bytes: [UInt8] = [0x20, 0x20, 0x48, 0x69, 0x20]
    let trimmed = bytes.trimming(where: { $0 == 0x20 })

    #expect(Array(trimmed) == [0x48, 0x69])
}
