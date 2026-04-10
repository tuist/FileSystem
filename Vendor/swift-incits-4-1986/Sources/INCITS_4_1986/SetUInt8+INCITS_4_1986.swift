//
//  Set<UInt8>+INCITS_4_1986.swift
//  swift-incits-4-1986
//
//  Created by Coen ten Thije Boonkkamp on 24/11/2025.
//

extension Set<UInt8>.ASCII {
    /// ASCII whitespace characters as Set<UInt8>
    ///
    /// Derived from the canonical byte-level definition in `INCITS_4_1986.whitespaces`.
    /// Per INCITS 4-1986, these are the only four whitespace characters in US-ASCII:
    /// - U+0020 (SPACE)
    /// - U+0009 (HORIZONTAL TAB)
    /// - U+000A (LINE FEED)
    /// - U+000D (CARRIAGE RETURN)
    ///
    /// This is explicitly ASCII-only and does not include Unicode whitespace
    /// characters (e.g., U+00A0 NO-BREAK SPACE, U+2003 EM SPACE).
    ///
    /// The ASCII-only definition enables optimized byte-level processing
    /// in string trimming operations without Unicode normalization overhead.
    public static let whitespaces: Set<UInt8> = Set(
        INCITS_4_1986.whitespaces
    )
}
