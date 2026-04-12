// RangeReplaceableCollection+Bytes.swift
// Mutation helpers for byte collections.

// MARK: - Byte Mutation Helpers

extension RangeReplaceableCollection<UInt8> {
    /// Appends a UTF-8 string as bytes.
    ///
    /// - Parameter string: The string to append as UTF-8 bytes
    ///
    /// Example:
    /// ```swift
    /// var buffer: [UInt8] = []
    /// buffer.append(utf8: "Hello")  // [72, 101, 108, 108, 111]
    /// ```
    public mutating func append(utf8 string: some StringProtocol) {
        append(contentsOf: string.utf8)
    }

    /// Appends a single byte.
    ///
    /// - Parameter value: The byte value to append
    ///
    /// Example:
    /// ```swift
    /// var buffer: [UInt8] = []
    /// buffer.append(UInt8(0x41))  // [65]
    /// ```
    public mutating func append(_ value: UInt8) {
        append(contentsOf: CollectionOfOne(value))
    }
}
