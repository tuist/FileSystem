// INCITS_4_1986.LineEndingDetection.swift
// swift-incits-4-1986
//
// INCITS 4-1986 Section 4.1.2: Format Effectors - Line Ending Detection
// Authoritative operations for detecting line ending styles in strings

import Standards

extension INCITS_4_1986 {
    /// Line Ending Detection Operations
    ///
    /// Authoritative implementations for detecting and analyzing line ending styles
    /// in string data per INCITS 4-1986 format effectors.
    ///
    /// Per INCITS 4-1986 Section 7.5 (CR) and Section 7.22 (LF):
    /// - CR (0x0D): CARRIAGE RETURN - moves to first character position
    /// - LF (0x0A): LINE FEED - advances to next line
    /// - CRLF: Combination used by Internet protocols (RFC 9112, RFC 5322)
    public enum LineEndingDetection {}
}

extension INCITS_4_1986.LineEndingDetection {
    /// Detects the line ending style used in the string
    ///
    /// Returns the first line ending type found, or `nil` if no line endings are present.
    /// Prioritizes CRLF detection since it contains both CR and LF as a unit.
    ///
    /// ## Detection Priority
    ///
    /// 1. **CRLF** (0x0D 0x0A): Checked first because it's a two-byte sequence
    /// 2. **CR** (0x0D): Standalone carriage return
    /// 3. **LF** (0x0A): Standalone line feed
    ///
    /// This ordering ensures that CRLF sequences are not misidentified as separate
    /// CR and LF line endings.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// INCITS_4_1986.LineEndingDetection.detect("line1\nline2")       // .lf
    /// INCITS_4_1986.LineEndingDetection.detect("line1\rline2")       // .cr
    /// INCITS_4_1986.LineEndingDetection.detect("line1\r\nline2")     // .crlf
    /// INCITS_4_1986.LineEndingDetection.detect("no line endings")    // nil
    /// ```
    ///
    /// - Parameter string: The string to analyze
    /// - Returns: The detected line ending type, or `nil` if none found
    @inlinable
    public static func detect<S: StringProtocol>(_ string: S) -> INCITS_4_1986.FormatEffectors.LineEnding? {
        // Check CRLF first (two-byte sequence takes precedence)
        // We need to check for the CRLF sequence as a substring
        let crlf = S(decoding: INCITS_4_1986.ControlCharacters.crlf, as: UTF8.self)
        let cr = S(decoding: [INCITS_4_1986.ControlCharacters.cr], as: UTF8.self)
        let lf = S(decoding: [INCITS_4_1986.ControlCharacters.lf], as: UTF8.self)

        if string.contains(crlf) {
            return .crlf
        } else if string.contains(cr) {
            return .cr
        } else if string.contains(lf) {
            return .lf
        }
        return nil
    }

    /// Tests if the string contains mixed line ending styles
    ///
    /// Detects if the string uses more than one line ending style (LF, CR, CRLF).
    /// This is useful for validation and normalization workflows.
    ///
    /// ## Detection Logic
    ///
    /// The method distinguishes between:
    /// - **CRLF sequences**: Treated as a single line ending unit
    /// - **Standalone CR**: CR not followed by LF
    /// - **Standalone LF**: LF not preceded by CR
    ///
    /// Returns `true` if two or more of these categories are present.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// // Consistent line endings
    /// INCITS_4_1986.LineEndingDetection.hasMixedLineEndings("line1\nline2\nline3")      // false
    /// INCITS_4_1986.LineEndingDetection.hasMixedLineEndings("line1\r\nline2\r\nline3")  // false
    ///
    /// // Mixed line endings
    /// INCITS_4_1986.LineEndingDetection.hasMixedLineEndings("line1\nline2\r\nline3")    // true
    /// INCITS_4_1986.LineEndingDetection.hasMixedLineEndings("line1\rline2\nline3")      // true
    /// ```
    ///
    /// - Parameter string: The string to analyze
    /// - Returns: `true` if multiple line ending styles are present
    @inlinable
    public static func hasMixedLineEndings<S: StringProtocol>(_ string: S) -> Bool {
        let bytes = Array(string.utf8)
        var hasCRLF = false
        var hasStandaloneCR = false
        var hasStandaloneLF = false

        var i = 0
        while i < bytes.count {
            let byte = bytes[i]

            if byte == INCITS_4_1986.ControlCharacters.cr {
                // Check if this CR is part of CRLF
                if i + 1 < bytes.count && bytes[i + 1] == INCITS_4_1986.ControlCharacters.lf {
                    hasCRLF = true
                    i += 2  // Skip both CR and LF
                    continue
                } else {
                    hasStandaloneCR = true
                    i += 1
                    continue
                }
            } else if byte == INCITS_4_1986.ControlCharacters.lf {
                hasStandaloneLF = true
                i += 1
                continue
            }

            i += 1
        }

        // Count different types
        let typeCount = [hasCRLF, hasStandaloneCR, hasStandaloneLF].filter { $0 }.count
        return typeCount > 1
    }
}
