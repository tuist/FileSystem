// Format.Numeric.Notation.swift
// Notation styles for numeric formatting.

extension Format.Numeric {
    /// Notation style for numeric formatting
    ///
    /// Controls how numbers are represented (standard, compact, or scientific).
    ///
    /// ## Example
    ///
    /// ```swift
    /// 1000.formatted(.number.notation(.compactName))   // "1K"
    /// 1234.formatted(.number.notation(.scientific))    // "1.234E3"
    /// ```
    public enum Notation: Sendable, Equatable {
        /// Automatic notation (default decimal representation)
        case automatic

        /// Compact notation using suffixes (K, M, B)
        ///
        /// - 1,000 → "1K"
        /// - 1,000,000 → "1M"
        /// - 1,000,000,000 → "1B"
        case compactName

        /// Scientific notation with exponent
        ///
        /// - 1234 → "1.234E3"
        /// - 0.00123 → "1.23E-3"
        case scientific
    }
}
