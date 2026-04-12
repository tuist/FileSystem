// Format.Numeric.SignDisplayStrategy.swift
// Sign display strategies for numeric formatting.

extension Format.Numeric {
    /// Sign display strategy for numeric formatting
    ///
    /// Controls when and how the sign (+/-) is displayed.
    ///
    /// ## Example
    ///
    /// ```swift
    /// 42.formatted(.number.sign(strategy: .always()))     // "+42"
    /// (-42).formatted(.number.sign(strategy: .never))     // "42"
    /// ```
    public enum SignDisplayStrategy: Sendable, Equatable {
        /// Show sign for negative numbers only (default)
        case automatic

        /// Never show sign
        case never

        /// Always show sign (+ for positive, - for negative)
        ///
        /// - Parameter includingZero: If true, zero displays as "+0"
        case always(includingZero: Bool = false)
    }
}
