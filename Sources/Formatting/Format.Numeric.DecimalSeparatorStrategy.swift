// Format.Numeric.DecimalSeparatorStrategy.swift
// Decimal separator display strategies for numeric formatting.

extension Format.Numeric {
    /// Decimal separator display strategy
    ///
    /// Controls when the decimal separator (.) is shown.
    ///
    /// ## Example
    ///
    /// ```swift
    /// 42.formatted(.number.decimalSeparator(strategy: .always))    // "42."
    /// 42.5.formatted(.number.decimalSeparator(strategy: .always))  // "42.5"
    /// ```
    public enum DecimalSeparatorStrategy: Sendable, Equatable {
        /// Show decimal separator only when there are fraction digits (default)
        case automatic

        /// Always show decimal separator, even for whole numbers
        case always
    }
}
