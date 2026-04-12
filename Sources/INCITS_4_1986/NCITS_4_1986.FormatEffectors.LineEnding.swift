//
//  NCITS_4_1986.FormatEffectors.LineEnding.swift
//  swift-incits-4-1986
//
//  Created by Coen ten Thije Boonkkamp on 20/11/2025.
//

extension INCITS_4_1986.FormatEffectors {
    /// Line ending style for ASCII text normalization
    ///
    /// Values derive from INCITS 4-1986 ASCII character definitions:
    /// - CR: CARRIAGE RETURN (0x0D)
    /// - LF: LINE FEED (0x0A)
    ///
    /// All byte values flow from `UInt8.ascii.cr` and `UInt8.ascii.lf` constants - single source of truth.
    public enum LineEnding: Sendable {
        /// Unix style: LINE FEED (0x0A)
        case lf
        /// Old Mac style: CARRIAGE RETURN (0x0D)
        case cr
        /// Windows/Network protocol style: CARRIAGE RETURN + LINE FEED (0x0D 0x0A)
        ///
        /// Required by Internet protocols including HTTP (RFC 9112) and Email (RFC 5322).
        case crlf
    }
}
