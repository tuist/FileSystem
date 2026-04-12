// INCITS_4_1986.Validation.swift
// swift-incits-4-1986
//
// INCITS 4-1986: ASCII Validation
// Validates that bytes conform to the 7-bit ASCII range (0x00-0x7F)

import Standards

extension INCITS_4_1986 {
    /// Returns true if the byte is valid ASCII (0x00-0x7F)
    ///
    /// Per INCITS 4-1986 Section 4: The coded character set consists of
    /// 128 characters represented by 7-bit combinations (0/0 to 7/15).
    /// Valid ASCII bytes have values 0-127 (0x00-0x7F).
    ///
    /// Example:
    /// ```swift
    /// INCITS_4_1986.isASCII(0x41)  // true ('A')
    /// INCITS_4_1986.isASCII(0x7F)  // true (DEL - last ASCII)
    /// INCITS_4_1986.isASCII(0x80)  // false (first non-ASCII)
    /// INCITS_4_1986.isASCII(0xFF)  // false
    /// ```
    @_transparent
    public static func isASCII(_ byte: UInt8) -> Bool {
        byte <= 0x7F
    }

    /// Returns true if all bytes are valid ASCII (0x00-0x7F)
    ///
    /// Per INCITS 4-1986 Section 4: The coded character set consists of
    /// 128 characters represented by 7-bit combinations (0/0 to 7/15).
    ///
    /// ## Performance
    ///
    /// For collections with contiguous storage (Array, ContiguousArray, ArraySlice, etc.),
    /// this uses SIMD-style processing (8 bytes at a time) for ~10x speedup
    /// on large inputs. Non-contiguous collections fall back to byte-by-byte.
    ///
    /// Example:
    /// ```swift
    /// INCITS_4_1986.isAllASCII([104, 101, 108, 108, 111])  // true
    /// INCITS_4_1986.isAllASCII([104, 255, 108])  // false
    ///
    /// // Works with slices
    /// let slice = bytes[start..<end]
    /// INCITS_4_1986.isAllASCII(slice)
    /// ```
    @inlinable
    public static func isAllASCII<C: Collection>(
        _ bytes: C
    ) -> Bool where C.Element == UInt8 {
        // Fast path: SIMD-accelerated for any contiguous storage
        if let result = bytes.withContiguousStorageIfAvailable({ _isAllASCIIFast($0) }) {
            return result
        }
        // Generic path: delegate to authoritative predicate
        return bytes.allSatisfy(\.ascii.isASCII)
    }

    /// SIMD-style ASCII validation for contiguous buffers
    ///
    /// Processes 8 bytes at a time by checking if any byte has its high bit set.
    /// The mask 0x8080808080808080 tests bit 7 of each byte simultaneously.
    @usableFromInline
    internal static func _isAllASCIIFast(_ buffer: UnsafeBufferPointer<UInt8>) -> Bool {
        guard let base = buffer.baseAddress else { return true }
        let count = buffer.count

        var i = 0

        // Process 8 bytes at a time using UInt64
        // Check if any of the 8 bytes has the high bit set
        let highBitMask: UInt64 = 0x8080_8080_8080_8080
        while i + 8 <= count {
            let chunk = base.advanced(by: i).withMemoryRebound(to: UInt64.self, capacity: 1) { $0.pointee }
            if chunk & highBitMask != 0 {
                return false
            }
            i += 8
        }

        // Handle remaining bytes (0-7)
        while i < count {
            if base[i] > 0x7F {
                return false
            }
            i += 1
        }

        return true
    }
}
