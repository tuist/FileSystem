// INCITS_4_1986.FormatEffectors.swift
// swift-incits-4-1986
//
// INCITS 4-1986 Section 4.1.2: Format Effectors
// Format effectors control the layout and positioning of information

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
    public enum FormatEffectors {}
}

extension INCITS_4_1986 {
    /// Normalizes ASCII line endings in byte collection to the specified style
    ///
    /// Canonical byte-level operation. Converts all line endings to target format.
    ///
    /// Per INCITS 4-1986 Section 7.5 (CR) and Section 7.22 (LF):
    /// - CR (0x0D): CARRIAGE RETURN - moves to first character position
    /// - LF (0x0A): LINE FEED - advances to next line
    /// - CRLF: Combination used by Internet protocols (RFC 9112, RFC 5322)
    ///
    /// Mathematical Properties:
    /// - **Idempotence**: `normalized(normalized(b, to: e), to: e) == normalized(b, to: e)`
    /// - **Preservation**: If `b` contains no line endings, `normalized(b, to: any) == b`
    ///
    /// Example:
    /// ```swift
    /// let bytes: [UInt8] = [0x6C, 0x0A, 0x6D]  // "l\nm"
    /// INCITS_4_1986.normalized(bytes, to: .crlf)  // [0x6C, 0x0D, 0x0A, 0x6D]
    ///
    /// // Works with slices
    /// let slice = bytes[start..<end]
    /// INCITS_4_1986.normalized(slice, to: .lf)
    /// ```
    public static func normalized<C: Collection>(
        _ bytes: C,
        to lineEnding: INCITS_4_1986.FormatEffectors.LineEnding
    ) -> [UInt8] where C.Element == UInt8 {
        // Fast path: if no line ending characters exist, return as-is
        // Single pass check is faster than two separate contains() calls
        if !bytes.contains(where: { $0 == .ascii.cr || $0 == .ascii.lf }) {
            return Array(bytes)
        }

        // Determine target line ending sequence inline
        let cr = UInt8.ascii.cr
        let lf = UInt8.ascii.lf
        let target = [UInt8](ascii: lineEnding)

        var result = [UInt8]()
        result.reserveCapacity(bytes.count + (lineEnding == .crlf ? bytes.count / 10 : 0))

        var iterator = bytes.makeIterator()
        var lookahead: UInt8? = iterator.next()

        while let byte = lookahead {
            lookahead = iterator.next()

            if byte == cr {
                // Check for CRLF sequence
                if lookahead == lf {
                    // CRLF → target
                    result.append(contentsOf: target)
                    lookahead = iterator.next()  // consume the LF
                } else {
                    // CR → target
                    result.append(contentsOf: target)
                }
            } else if byte == lf {
                // LF → target
                result.append(contentsOf: target)
            } else {
                // Regular byte, preserve as-is
                result.append(byte)
            }
        }

        return result
    }
}
