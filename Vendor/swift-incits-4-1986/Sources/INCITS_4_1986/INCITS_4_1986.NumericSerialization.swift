// INCITS_4_1986.NumericSerialization.swift
// swift-incits-4-1986
//
// INCITS 4-1986 Section 4.3: Graphic Characters - Numeric Value Serialization
// Authoritative transformations from numeric values to ASCII digit bytes

public import Binary

extension INCITS_4_1986 {
    /// Numeric Value Serialization Operations
    ///
    /// Authoritative implementations for converting numeric values to ASCII digit bytes.
    /// These are the inverse operations of `NumericParsing`.
    ///
    /// Per INCITS 4-1986 Table 7 (Graphic Characters):
    /// - Decimal digits: 0-9 → 0x30-0x39 ('0'-'9')
    /// - Hex digits (uppercase): 10-15 → 0x41-0x46 ('A'-'F')
    /// - Hex digits (lowercase): 10-15 → 0x61-0x66 ('a'-'f')
    ///
    /// ## Category Theory
    ///
    /// Forms an isomorphism with `NumericParsing`:
    /// - `serialize ∘ parse = id` (for valid ASCII digit bytes)
    /// - `parse ∘ serialize = id` (for valid numeric values)
    public enum NumericSerialization {}
}

// MARK: - Single Digit Serialization

extension INCITS_4_1986.NumericSerialization {
    /// Converts a decimal digit value (0-9) to its ASCII byte
    ///
    /// Inverse of `NumericParsing.digit(_:)`.
    ///
    /// - Parameter value: Numeric value 0-9
    /// - Returns: ASCII byte 0x30-0x39 ('0'-'9'), or nil if value > 9
    ///
    /// ## Example
    ///
    /// ```swift
    /// INCITS_4_1986.NumericSerialization.digit(0)  // 0x30 ('0')
    /// INCITS_4_1986.NumericSerialization.digit(5)  // 0x35 ('5')
    /// INCITS_4_1986.NumericSerialization.digit(9)  // 0x39 ('9')
    /// INCITS_4_1986.NumericSerialization.digit(10) // nil
    /// ```
    @inlinable
    public static func digit(_ value: UInt8) -> UInt8? {
        guard value <= 9 else { return nil }
        return INCITS_4_1986.GraphicCharacters.`0` + value
    }

    /// Converts a hex digit value (0-15) to its uppercase ASCII byte
    ///
    /// - Parameter value: Numeric value 0-15
    /// - Returns: ASCII byte for '0'-'9' or 'A'-'F', or nil if value > 15
    @inlinable
    public static func hexDigitUppercase(_ value: UInt8) -> UInt8? {
        switch value {
        case 0...9:
            return INCITS_4_1986.GraphicCharacters.`0` + value
        case 10...15:
            return INCITS_4_1986.GraphicCharacters.A + value - 10
        default:
            return nil
        }
    }

    /// Converts a hex digit value (0-15) to its lowercase ASCII byte
    ///
    /// - Parameter value: Numeric value 0-15
    /// - Returns: ASCII byte for '0'-'9' or 'a'-'f', or nil if value > 15
    @inlinable
    public static func hexDigitLowercase(_ value: UInt8) -> UInt8? {
        switch value {
        case 0...9:
            return INCITS_4_1986.GraphicCharacters.`0` + value
        case 10...15:
            return INCITS_4_1986.GraphicCharacters.a + value - 10
        default:
            return nil
        }
    }
}

// MARK: - Integer Serialization

extension INCITS_4_1986.NumericSerialization {
    /// Serialize an unsigned integer to ASCII decimal bytes
    ///
    /// Writes the decimal representation directly to a byte buffer.
    /// This is the canonical ASCII serialization for unsigned integers.
    ///
    /// ## Example
    ///
    /// ```swift
    /// var buffer: [UInt8] = []
    /// INCITS_4_1986.NumericSerialization.serializeDecimal(42, into: &buffer)
    /// // buffer is now [0x34, 0x32] ("42")
    /// ```
    ///
    /// - Parameters:
    ///   - value: The unsigned integer to serialize
    ///   - buffer: The buffer to append ASCII bytes to
    @inlinable
    public static func serializeDecimal<T: UnsignedInteger, Buffer: RangeReplaceableCollection>(
        _ value: T,
        into buffer: inout Buffer
    ) where Buffer.Element == UInt8 {
        if value == 0 {
            buffer.append(INCITS_4_1986.GraphicCharacters.`0`)
            return
        }

        // Build digits in reverse, then append in correct order
        var n = value
        var digits: [UInt8] = []
        while n > 0 {
            let digit = UInt8(n % 10)
            digits.append(INCITS_4_1986.GraphicCharacters.`0` + digit)
            n /= 10
        }
        buffer.append(contentsOf: digits.reversed())
    }

    /// Serialize a signed integer to ASCII decimal bytes
    ///
    /// Writes the decimal representation directly to a byte buffer,
    /// including a leading '-' for negative values.
    ///
    /// ## Example
    ///
    /// ```swift
    /// var buffer: [UInt8] = []
    /// INCITS_4_1986.NumericSerialization.serializeDecimal(-42, into: &buffer)
    /// // buffer is now [0x2D, 0x34, 0x32] ("-42")
    /// ```
    ///
    /// - Parameters:
    ///   - value: The signed integer to serialize
    ///   - buffer: The buffer to append ASCII bytes to
    @inlinable
    public static func serializeDecimal<T: SignedInteger, Buffer: RangeReplaceableCollection>(
        _ value: T,
        into buffer: inout Buffer
    ) where Buffer.Element == UInt8 {
        if value == 0 {
            buffer.append(INCITS_4_1986.GraphicCharacters.`0`)
            return
        }

        var n = value
        if n < 0 {
            buffer.append(INCITS_4_1986.GraphicCharacters.hyphen)
            n = -n
        }

        // Build digits in reverse, then append in correct order
        var digits: [UInt8] = []
        while n > 0 {
            let digit = UInt8(n % 10)
            digits.append(INCITS_4_1986.GraphicCharacters.`0` + digit)
            n /= 10
        }
        buffer.append(contentsOf: digits.reversed())
    }
}

// MARK: - FixedWidthInteger Conformance

extension Int: @retroactive Binary.Serializable, Binary.ASCII.Serializable {
    public enum Error: Swift.Error {
        case invalidFormat
    }

    /// Serialize Int to ASCII decimal bytes
    @inlinable
    public static func serialize<Buffer: RangeReplaceableCollection>(
        ascii value: Int,
        into buffer: inout Buffer
    ) where Buffer.Element == UInt8 {
        INCITS_4_1986.NumericSerialization.serializeDecimal(value, into: &buffer)
    }

    /// Parse Int from ASCII decimal bytes
    @inlinable
    public init<Bytes: Collection>(
        ascii bytes: Bytes,
        in context: Void
    ) throws(Error) where Bytes.Element == UInt8 {
        var result: Int = 0
        var isNegative = false
        var index = bytes.startIndex

        // Handle sign
        if index < bytes.endIndex {
            let first = bytes[index]
            if first == INCITS_4_1986.GraphicCharacters.hyphen {
                isNegative = true
                index = bytes.index(after: index)
            } else if first == INCITS_4_1986.GraphicCharacters.plusSign {
                index = bytes.index(after: index)
            }
        }

        guard index < bytes.endIndex else { throw .invalidFormat }

        while index < bytes.endIndex {
            guard let digit = INCITS_4_1986.NumericParsing.digit(bytes[index]) else {
                throw .invalidFormat
            }
            result = result * 10 + Int(digit)
            index = bytes.index(after: index)
        }

        self = isNegative ? -result : result
    }
}

extension Int64: @retroactive Binary.Serializable, Binary.ASCII.Serializable {
    public enum Error: Swift.Error {
        case invalidFormat
    }

    /// Serialize Int64 to ASCII decimal bytes
    @inlinable
    public static func serialize<Buffer: RangeReplaceableCollection>(
        ascii value: Int64,
        into buffer: inout Buffer
    ) where Buffer.Element == UInt8 {
        INCITS_4_1986.NumericSerialization.serializeDecimal(value, into: &buffer)
    }

    /// Parse Int64 from ASCII decimal bytes
    @inlinable
    public init<Bytes: Collection>(
        ascii bytes: Bytes,
        in context: Void
    ) throws(Error) where Bytes.Element == UInt8 {
        var result: Int64 = 0
        var isNegative = false
        var index = bytes.startIndex

        // Handle sign
        if index < bytes.endIndex {
            let first = bytes[index]
            if first == INCITS_4_1986.GraphicCharacters.hyphen {
                isNegative = true
                index = bytes.index(after: index)
            } else if first == INCITS_4_1986.GraphicCharacters.plusSign {
                index = bytes.index(after: index)
            }
        }

        guard index < bytes.endIndex else { throw .invalidFormat }

        while index < bytes.endIndex {
            guard let digit = INCITS_4_1986.NumericParsing.digit(bytes[index]) else {
                throw .invalidFormat
            }
            result = result * 10 + Int64(digit)
            index = bytes.index(after: index)
        }

        self = isNegative ? -result : result
    }
}

extension UInt: @retroactive Binary.Serializable, Binary.ASCII.Serializable {
    public enum Error: Swift.Error {
        case invalidFormat
    }

    /// Serialize UInt to ASCII decimal bytes
    @inlinable
    public static func serialize<Buffer: RangeReplaceableCollection>(
        ascii value: UInt,
        into buffer: inout Buffer
    ) where Buffer.Element == UInt8 {
        INCITS_4_1986.NumericSerialization.serializeDecimal(value, into: &buffer)
    }

    /// Parse UInt from ASCII decimal bytes
    @inlinable
    public init<Bytes: Collection>(
        ascii bytes: Bytes,
        in context: Void
    ) throws(Error) where Bytes.Element == UInt8 {
        var result: UInt = 0
        var index = bytes.startIndex

        // Handle optional plus sign
        if index < bytes.endIndex && bytes[index] == INCITS_4_1986.GraphicCharacters.plusSign {
            index = bytes.index(after: index)
        }

        guard index < bytes.endIndex else { throw .invalidFormat }

        while index < bytes.endIndex {
            guard let digit = INCITS_4_1986.NumericParsing.digit(bytes[index]) else {
                throw .invalidFormat
            }
            result = result * 10 + UInt(digit)
            index = bytes.index(after: index)
        }

        self = result
    }
}

extension UInt64: @retroactive Binary.Serializable, Binary.ASCII.Serializable {
    public enum Error: Swift.Error {
        case invalidFormat
    }

    /// Serialize UInt64 to ASCII decimal bytes
    @inlinable
    public static func serialize<Buffer: RangeReplaceableCollection>(
        ascii value: UInt64,
        into buffer: inout Buffer
    ) where Buffer.Element == UInt8 {
        INCITS_4_1986.NumericSerialization.serializeDecimal(value, into: &buffer)
    }

    /// Parse UInt64 from ASCII decimal bytes
    @inlinable
    public init<Bytes: Collection>(
        ascii bytes: Bytes,
        in context: Void
    ) throws(Error) where Bytes.Element == UInt8 {
        var result: UInt64 = 0
        var index = bytes.startIndex

        // Handle optional plus sign
        if index < bytes.endIndex && bytes[index] == INCITS_4_1986.GraphicCharacters.plusSign {
            index = bytes.index(after: index)
        }

        guard index < bytes.endIndex else { throw .invalidFormat }

        while index < bytes.endIndex {
            guard let digit = INCITS_4_1986.NumericParsing.digit(bytes[index]) else {
                throw .invalidFormat
            }
            result = result * 10 + UInt64(digit)
            index = bytes.index(after: index)
        }

        self = result
    }
}
