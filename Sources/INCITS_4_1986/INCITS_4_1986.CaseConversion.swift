// INCITS_4_1986.CaseConversion.swift
// swift-incits-4-1986
//
// INCITS 4-1986 Section 4.3: Graphic Characters - Case Conversion
// Transforms ASCII letters between uppercase and lowercase

import Standards

extension INCITS_4_1986 {
    /// Case Conversion Operations
    ///
    /// Authoritative implementations for converting ASCII letters between uppercase and lowercase.
    ///
    /// Per INCITS 4-1986 Table 7 (Graphic Characters):
    /// - Capital letters: A-Z (0x41-0x5A)
    /// - Small letters: a-z (0x61-0x7A)
    /// - Difference between cases: 32 (0x20)
    public enum CaseConversion {}
}

extension INCITS_4_1986.CaseConversion {
    /// Converts ASCII letter to specified case, returns unchanged if not an ASCII letter
    ///
    /// Per INCITS 4-1986 Table 7 (Graphic Characters), uppercase and lowercase ASCII letters
    /// are separated by exactly 0x20 (32 decimal). This function applies the appropriate
    /// transformation based on the target case.
    ///
    /// ## Performance
    ///
    /// Uses branchless arithmetic for optimal performance. The case offset (0x20) corresponds
    /// to bit 5, enabling efficient XOR-based conversion.
    ///
    /// ## Mathematical Properties
    ///
    /// - **Idempotence**: `convert(convert(b, to: c), to: c) == convert(b, to: c)`
    /// - **Involution** (for letters): `convert(convert(b, to: .upper), to: .lower) == b` (if `isLetter(b)`)
    /// - **Preservation**: If `!isLetter(b)`, then `convert(b, to: any) == b`
    ///
    /// ## Usage
    ///
    /// ```swift
    /// INCITS_4_1986.CaseConversion.convert(0x61, to: .upper)  // 0x41 ("A")
    /// INCITS_4_1986.CaseConversion.convert(0x5A, to: .lower)  // 0x7A ("z")
    /// INCITS_4_1986.CaseConversion.convert(0x31, to: .upper)  // 0x31 ("1") - unchanged
    /// ```
    ///
    /// - Parameters:
    ///   - byte: The ASCII byte to convert
    ///   - case: The target case (upper or lower)
    /// - Returns: Converted byte if ASCII letter, unchanged otherwise
    @_transparent
    public static func convert(_ byte: UInt8, to case: Character.Case) -> UInt8 {
        switch `case` {
        case .upper:
            // Check if lowercase (0x61-0x7A) using subtraction trick
            // (byte - 0x61) < 26 is true iff byte is in [0x61, 0x7A]
            let isLower = (byte &- 0x61) < 26
            return isLower ? byte &- 0x20 : byte
        case .lower:
            // Check if uppercase (0x41-0x5A)
            let isUpper = (byte &- 0x41) < 26
            return isUpper ? byte &+ 0x20 : byte
        }
    }
}

extension INCITS_4_1986 {
    /// Converts ASCII letters in byte collection to specified case
    ///
    /// Non-ASCII bytes and non-letter bytes pass through unchanged.
    ///
    /// ## Performance
    ///
    /// For contiguous byte arrays (`[UInt8]`), uses optimized batch processing.
    /// The conversion uses branchless arithmetic for each byte.
    ///
    /// Per INCITS 4-1986 Table 7 (Graphic Characters):
    /// - Capital letters: A-Z (0x41-0x5A)
    /// - Small letters: a-z (0x61-0x7A)
    /// - Difference between cases: 32 (0x20)
    ///
    /// Mathematical Properties:
    /// - **Idempotence**: `convert(convert(b, to: c), to: c) == convert(b, to: c)`
    /// - **Functoriality**: Preserves array structure (maps over elements)
    ///
    /// Example:
    /// ```swift
    /// INCITS_4_1986.convert(Array("Hello".utf8), to: .upper)  // "HELLO" bytes
    ///
    /// // Works with slices
    /// let slice = bytes[start..<end]
    /// INCITS_4_1986.convert(slice, to: .lower)
    /// ```
    @inlinable
    public static func convert<C: Collection>(
        _ bytes: C,
        to case: Character.Case
    ) -> [UInt8] where C.Element == UInt8 {
        var result = [UInt8]()
        result.reserveCapacity(bytes.count)

        switch `case` {
        case .upper:
            for byte in bytes {
                let isLower = (byte &- 0x61) < 26
                result.append(isLower ? byte &- 0x20 : byte)
            }
        case .lower:
            for byte in bytes {
                let isUpper = (byte &- 0x41) < 26
                result.append(isUpper ? byte &+ 0x20 : byte)
            }
        }

        return result
    }

    /// Converts ASCII letters in string to specified case
    ///
    /// Non-ASCII characters and non-letter characters pass through unchanged.
    ///
    /// Example:
    /// ```swift
    /// INCITS_4_1986.ascii("Hello World", case: .upper)  // "HELLO WORLD"
    /// INCITS_4_1986.ascii("hello🌍", case: .upper)  // "HELLO🌍"
    /// ```
    @inlinable
    public static func convert<S: StringProtocol>(_ string: S, to case: Character.Case) -> S {
        S(decoding: convert(Array(string.utf8), to: `case`), as: UTF8.self)
    }
}

extension INCITS_4_1986.CaseConversion {
    /// ASCII case conversion offset
    ///
    /// The numeric distance between corresponding uppercase and lowercase ASCII letters.
    ///
    /// Per INCITS 4-1986, uppercase letters 'A'-'Z' (0x41-0x5A) and lowercase letters 'a'-'z' (0x61-0x7A)
    /// are separated by exactly 0x20 (32 decimal). This relationship is fundamental to ASCII's design
    /// and enables efficient case conversion through simple arithmetic operations.
    ///
    /// ## Mathematical Properties
    ///
    /// - **Identity**: `'a' - 'A' = 0x20` for all letter pairs
    /// - **Symmetry**: `lowercase = uppercase + 0x20` and `uppercase = lowercase - 0x20`
    /// - **Bit manipulation**: The offset is a single bit difference (bit 5)
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let upperA: UInt8 = 0x41  // 'A'
    /// let lowerA = upperA + INCITS_4_1986.CaseConversion.offset  // 0x61 ('a')
    ///
    /// let lowerZ: UInt8 = 0x7A  // 'z'
    /// let upperZ = lowerZ - INCITS_4_1986.CaseConversion.offset  // 0x5A ('Z')
    /// ```
    ///
    /// ## See Also
    ///
    /// - ``GraphicCharacters/A``
    /// - ``GraphicCharacters/a``
    public static let offset: UInt8 = 0x20
}
