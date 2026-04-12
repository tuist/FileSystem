// Array+Bytes.swift
// Byte array utilities.

// MARK: - Single Integer Serialization

extension [UInt8] {
    /// Creates a byte array from any fixed-width integer.
    ///
    /// - Parameters:
    ///   - value: The integer value to convert
    ///   - endianness: Byte order for the output bytes (defaults to little-endian)
    ///
    /// Example:
    /// ```swift
    /// let int32Bytes = [UInt8](Int32(256), endianness: .little)  // [0, 1, 0, 0]
    /// let int32BytesBE = [UInt8](Int32(256), endianness: .big)   // [0, 0, 1, 0]
    /// ```
    public init<T: FixedWidthInteger>(_ value: T, endianness: Binary.Endianness = .little) {
        let converted: T
        switch endianness {
        case .little:
            converted = value.littleEndian
        case .big:
            converted = value.bigEndian
        }
        self = Swift.withUnsafeBytes(of: converted) { Array($0) }
    }
}

// MARK: - Collection Serialization

extension [UInt8] {
    /// Creates a byte array from a collection of fixed-width integers.
    ///
    /// - Parameters:
    ///   - values: Collection of integers to convert
    ///   - endianness: Byte order for the output bytes (defaults to little-endian)
    ///
    /// Example:
    /// ```swift
    /// let bytes = [UInt8](serializing: [Int16(1), Int16(2)], endianness: .little)
    /// // [1, 0, 2, 0] (4 bytes total)
    /// ```
    public init<C: Collection>(serializing values: C, endianness: Binary.Endianness = .little)
    where C.Element: FixedWidthInteger {
        var result: [UInt8] = []
        result.reserveCapacity(values.count * MemoryLayout<C.Element>.size)
        for value in values {
            result.append(contentsOf: [UInt8](value, endianness: endianness))
        }
        self = result
    }
}

// MARK: - String Conversions

extension [UInt8] {
    /// Creates a byte array from a UTF-8 encoded string.
    ///
    /// - Parameter string: The string to convert to UTF-8 bytes
    ///
    /// Example:
    /// ```swift
    /// let bytes = [UInt8](utf8: "Hello")  // [72, 101, 108, 108, 111]
    /// ```
    public init(utf8 string: some StringProtocol) {
        self = Array(string.utf8)
    }
}

// MARK: - Splitting

extension [UInt8] {
    /// Splits the byte array at all occurrences of a delimiter sequence.
    ///
    /// - Parameter separator: The byte sequence to split on
    /// - Returns: Array of byte arrays split at the delimiter
    ///
    /// Example:
    /// ```swift
    /// let data: [UInt8] = [1, 2, 0, 0, 3, 4, 0, 0, 5]
    /// let parts = data.split(separator: [0, 0])
    /// // [[1, 2], [3, 4], [5]]
    /// ```
    public func split(separator: [UInt8]) -> [[UInt8]] {
        guard !separator.isEmpty else { return [self] }

        var result: [[UInt8]] = []
        var start = 0

        while start < count {
            guard start + separator.count <= count else {
                result.append(Array(self[start...]))
                break
            }

            var found = false
            for i in start...(count - separator.count)
            where self[i..<i + separator.count].elementsEqual(separator) {
                result.append(Array(self[start..<i]))
                start = i + separator.count
                found = true
                break
            }

            if !found {
                result.append(Array(self[start...]))
                break
            }
        }

        return result
    }
}

// MARK: - Mutation Helpers

extension [UInt8] {
    /// Appends a 16-bit integer as bytes with specified endianness.
    public mutating func append(_ value: UInt16, endianness: Binary.Endianness = .little) {
        append(contentsOf: value.bytes(endianness: endianness))
    }

    /// Appends a 32-bit integer as bytes with specified endianness.
    public mutating func append(_ value: UInt32, endianness: Binary.Endianness = .little) {
        append(contentsOf: value.bytes(endianness: endianness))
    }

    /// Appends a 64-bit integer as bytes with specified endianness.
    public mutating func append(_ value: UInt64, endianness: Binary.Endianness = .little) {
        append(contentsOf: value.bytes(endianness: endianness))
    }

    /// Appends a signed 16-bit integer as bytes with specified endianness.
    public mutating func append(_ value: Int16, endianness: Binary.Endianness = .little) {
        append(contentsOf: value.bytes(endianness: endianness))
    }

    /// Appends a signed 32-bit integer as bytes with specified endianness.
    public mutating func append(_ value: Int32, endianness: Binary.Endianness = .little) {
        append(contentsOf: value.bytes(endianness: endianness))
    }

    /// Appends a signed 64-bit integer as bytes with specified endianness.
    public mutating func append(_ value: Int64, endianness: Binary.Endianness = .little) {
        append(contentsOf: value.bytes(endianness: endianness))
    }

    /// Appends a platform-sized integer as bytes with specified endianness.
    public mutating func append(_ value: Int, endianness: Binary.Endianness = .little) {
        append(contentsOf: value.bytes(endianness: endianness))
    }

    /// Appends an unsigned platform-sized integer as bytes with specified endianness.
    public mutating func append(_ value: UInt, endianness: Binary.Endianness = .little) {
        append(contentsOf: value.bytes(endianness: endianness))
    }
}

// MARK: - Joining Byte Arrays

extension [[UInt8]] {
    /// Joins byte arrays with a separator, pre-allocating exact capacity.
    ///
    /// Efficiently concatenates an array of byte arrays with a separator between each element.
    ///
    /// - Parameter separator: The byte sequence to insert between each element
    /// - Returns: A single byte array with all elements joined by the separator
    @inlinable
    public func joined(separator: [UInt8]) -> [UInt8] {
        guard !isEmpty else { return [] }
        guard count > 1 else { return self[0] }

        let totalBytes = reduce(0) { $0 + $1.count }
        let totalSeparators = separator.count * (count - 1)
        let totalCapacity = totalBytes + totalSeparators

        var result: [UInt8] = []
        result.reserveCapacity(totalCapacity)

        var isFirst = true
        for element in self {
            if !isFirst {
                result.append(contentsOf: separator)
            }
            result.append(contentsOf: element)
            isFirst = false
        }

        return result
    }

    /// Joins byte arrays without a separator.
    ///
    /// - Returns: A single byte array with all elements concatenated
    @inlinable
    public func joined() -> [UInt8] {
        guard !isEmpty else { return [] }
        guard count > 1 else { return self[0] }

        let totalBytes = reduce(0) { $0 + $1.count }

        var result: [UInt8] = []
        result.reserveCapacity(totalBytes)

        for element in self {
            result.append(contentsOf: element)
        }

        return result
    }
}
