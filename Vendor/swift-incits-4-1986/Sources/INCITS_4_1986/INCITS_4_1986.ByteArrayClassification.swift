// INCITS_4_1986.ByteArrayClassification.swift
// swift-incits-4-1986
//
// INCITS 4-1986: Byte Array Classification Operations
// Authoritative predicates for testing properties of byte arrays

import Standards

extension INCITS_4_1986 {
    /// Byte Array Classification Operations
    ///
    /// Authoritative implementations of byte array-level classification tests per INCITS 4-1986.
    /// All byte array predicates are defined here as the single source of truth.
    ///
    /// ## Architecture
    ///
    /// These operations delegate to the authoritative single-byte predicates in
    /// ``CharacterClassification`` via the `UInt8.ascii` accessor. This ensures
    /// consistency and maintainability while achieving identical performance
    /// (the compiler optimizes `allSatisfy` to match inline loops).
    ///
    /// ## Performance
    ///
    /// For contiguous arrays, SIMD-accelerated paths are used where applicable
    /// (e.g., `containsNonASCII` processes 8 bytes at a time).
    public enum ByteArrayClassification {}
}

extension INCITS_4_1986.ByteArrayClassification {
    // MARK: - Collection Predicates

    /// Returns true if all bytes are ASCII whitespace characters
    ///
    /// Tests whether every byte in the array is one of the four ASCII whitespace characters:
    /// SPACE (0x20), HORIZONTAL TAB (0x09), LINE FEED (0x0A), or CARRIAGE RETURN (0x0D).
    ///
    /// Returns `true` for empty arrays (vacuous truth).
    @inlinable
    public static func isAllWhitespace<Bytes: Collection>(_ bytes: Bytes) -> Bool where Bytes.Element == UInt8 {
        bytes.allSatisfy(\.ascii.isWhitespace)
    }

    /// Returns true if all bytes are ASCII digits (0-9)
    ///
    /// Tests whether every byte in the array is an ASCII digit (0x30-0x39).
    ///
    /// Returns `true` for empty arrays (vacuous truth).
    @inlinable
    public static func isAllDigits<Bytes: Collection>(_ bytes: Bytes) -> Bool where Bytes.Element == UInt8 {
        bytes.allSatisfy(\.ascii.isDigit)
    }

    /// Returns true if all bytes are ASCII letters (A-Z, a-z)
    ///
    /// Tests whether every byte in the array is an ASCII letter (uppercase or lowercase).
    ///
    /// Returns `true` for empty arrays (vacuous truth).
    @inlinable
    public static func isAllLetters<Bytes: Collection>(_ bytes: Bytes) -> Bool where Bytes.Element == UInt8 {
        bytes.allSatisfy(\.ascii.isLetter)
    }

    /// Returns true if all bytes are ASCII alphanumeric (A-Z, a-z, 0-9)
    ///
    /// Tests whether every byte in the array is either an ASCII letter or digit.
    ///
    /// Returns `true` for empty arrays (vacuous truth).
    @inlinable
    public static func isAllAlphanumeric<Bytes: Collection>(_ bytes: Bytes) -> Bool where Bytes.Element == UInt8 {
        bytes.allSatisfy(\.ascii.isAlphanumeric)
    }

    /// Returns true if all bytes are ASCII control characters
    ///
    /// Tests whether every byte in the array is an ASCII control character (0x00-0x1F or 0x7F).
    ///
    /// Returns `true` for empty arrays (vacuous truth).
    @inlinable
    public static func isAllControl<Bytes: Collection>(_ bytes: Bytes) -> Bool where Bytes.Element == UInt8 {
        bytes.allSatisfy(\.ascii.isControl)
    }

    /// Returns true if all bytes are ASCII visible characters
    ///
    /// Tests whether every byte in the array is a visible ASCII character (0x21-0x7E).
    /// Visible characters exclude SPACE and all control characters.
    ///
    /// Returns `true` for empty arrays (vacuous truth).
    @inlinable
    public static func isAllVisible<Bytes: Collection>(_ bytes: Bytes) -> Bool where Bytes.Element == UInt8 {
        bytes.allSatisfy(\.ascii.isVisible)
    }

    /// Returns true if all bytes are ASCII printable characters
    ///
    /// Tests whether every byte in the array is a printable ASCII character (0x20-0x7E).
    /// Printable characters include SPACE and all graphic characters.
    ///
    /// Returns `true` for empty arrays (vacuous truth).
    @inlinable
    public static func isAllPrintable<Bytes: Collection>(_ bytes: Bytes) -> Bool where Bytes.Element == UInt8 {
        bytes.allSatisfy(\.ascii.isPrintable)
    }

    /// Returns true if all letter bytes are lowercase
    ///
    /// Tests whether every ASCII letter in the array is lowercase.
    /// Non-letter bytes are ignored.
    ///
    /// Returns `true` for arrays with no letters.
    @inlinable
    public static func isAllLowercase<Bytes: Collection>(_ bytes: Bytes) -> Bool where Bytes.Element == UInt8 {
        !bytes.contains(where: \.ascii.isUppercase)
    }

    /// Returns true if all letter bytes are uppercase
    ///
    /// Tests whether every ASCII letter in the array is uppercase.
    /// Non-letter bytes are ignored.
    ///
    /// Returns `true` for arrays with no letters.
    @inlinable
    public static func isAllUppercase<Bytes: Collection>(_ bytes: Bytes) -> Bool where Bytes.Element == UInt8 {
        !bytes.contains(where: \.ascii.isLowercase)
    }

    /// Returns true if array contains any non-ASCII bytes
    ///
    /// Tests whether any byte in the array is outside the valid ASCII range (>= 0x80).
    ///
    /// ## Performance
    ///
    /// For collections with contiguous storage (Array, ContiguousArray, ArraySlice, etc.),
    /// uses SIMD-accelerated checking (8 bytes at a time).
    ///
    /// Returns `false` for empty arrays.
    @inlinable
    public static func containsNonASCII<Bytes: Collection>(_ bytes: Bytes) -> Bool where Bytes.Element == UInt8 {
        // Fast path: SIMD-accelerated for any contiguous storage
        if let result = bytes.withContiguousStorageIfAvailable({ !INCITS_4_1986._isAllASCIIFast($0) }) {
            return result
        }
        // Generic path: delegate to authoritative predicate
        return bytes.contains { !$0.ascii.isASCII }
    }

    /// Returns true if array contains at least one hex digit byte
    ///
    /// Tests whether any byte in the array is an ASCII hex digit (0-9, A-F, a-f).
    ///
    /// Returns `false` for empty arrays.
    @inlinable
    public static func containsHexDigit<Bytes: Collection>(_ bytes: Bytes) -> Bool where Bytes.Element == UInt8 {
        bytes.contains(where: \.ascii.isHexDigit)
    }
}
