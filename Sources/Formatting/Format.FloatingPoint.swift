// Format.FloatingPoint.swift
// Formatting for FloatingPoint types.

import StandardLibraryExtensions

extension Format {
    /// A format for formatting any FloatingPoint value.
    ///
    /// This categorical format works for all FloatingPoint types (Double, Float, etc.).
    /// It provides operations specific to the FloatingPoint category:
    /// - Percentage formatting
    /// - Precision control
    /// - Rounding strategies
    ///
    /// Note: This is a generic categorical formatter that operates across the FloatingPoint category.
    /// It does not conform to `FormatStyle` as it works with multiple input types, not a single FormatInput.
    ///
    /// Use static properties to access predefined formats:
    ///
    /// ```swift
    /// 0.75.formatted(.percent)  // "75%"
    /// Float(0.5).formatted(.percent)  // "50%"
    /// ```
    ///
    /// Chain methods to configure the format:
    ///
    /// ```swift
    /// 0.75.formatted(.percent.rounded())        // "75%"
    /// 0.755.formatted(.percent.precision(2))    // "75.50%"
    /// ```
    public struct FloatingPoint: Sendable {
        let isPercent: Bool
        public let shouldRound: Bool
        public let precisionDigits: Int?

        private init(isPercent: Bool, shouldRound: Bool, precisionDigits: Int?) {
            self.isPercent = isPercent
            self.shouldRound = shouldRound
            self.precisionDigits = precisionDigits
        }

        public init(shouldRound: Bool = false, precisionDigits: Int? = nil) {
            self.isPercent = false
            self.shouldRound = shouldRound
            self.precisionDigits = precisionDigits
        }
    }
}

// MARK: - Format.FloatingPoint Format Method

extension Format.FloatingPoint {
    /// Formats a floating point value.
    ///
    /// This is a generic method that works across all FloatingPoint types.
    public func format<T: Swift.FloatingPoint>(_ value: T) -> String {
        var workingValue = value

        if isPercent {
            workingValue *= T(100)
        }

        if shouldRound {
            workingValue = workingValue.rounded()
        }

        if let precision = precisionDigits {
            let multiplier = T(10).power(precision)
            workingValue = (workingValue * multiplier).rounded() / multiplier
        }

        var result = "\(workingValue)"

        // Strip trailing ".0" for whole numbers (e.g., "10.0" -> "10")
        if result.hasSuffix(".0") {
            result.removeLast(2)
        }

        return isPercent ? result + "%" : result
    }
}

// MARK: - Format.FloatingPoint Static Properties

extension Format.FloatingPoint {
    /// Formats the floating point value as a number.
    ///
    /// ```swift
    /// 3.14159.formatted(.number)  // "3.14159"
    /// ```
    public static var number: Self {
        .init(isPercent: false, shouldRound: false, precisionDigits: nil)
    }

    /// Formats the floating point value as a percentage.
    public static var percent: Self {
        .init(isPercent: true, shouldRound: false, precisionDigits: nil)
    }
}

// MARK: - Format.FloatingPoint Chaining Methods

extension Format.FloatingPoint {
    /// Rounds the value when formatting.
    ///
    /// ```swift
    /// 0.755.formatted(Format.FloatingPoint.percent.rounded())  // "76%"
    /// ```
    public func rounded() -> Self {
        .init(isPercent: isPercent, shouldRound: true, precisionDigits: precisionDigits)
    }

    /// Sets the precision (decimal places) for the formatted value.
    ///
    /// ```swift
    /// 0.12345.formatted(Format.FloatingPoint.percent.precision(2))  // "12.35%"
    /// ```
    public func precision(_ digits: Int) -> Self {
        .init(isPercent: isPercent, shouldRound: shouldRound, precisionDigits: digits)
    }
}

// MARK: - FloatingPoint Extension

extension Swift.FloatingPoint {
    /// Formats this floating point value using the specified format.
    ///
    /// Use this method with static format properties:
    ///
    /// ```swift
    /// let result = 0.75.formatted(.percent)               // "75%"
    /// let result = Float(0.5).formatted(.percent)         // "50%"
    /// let result = 0.755.formatted(.percent.precision(2)) // "75.50%"
    /// ```
    ///
    /// - Parameter format: The floating point format to use.
    /// - Returns: The formatted representation of this floating point value.
    public func formatted(_ format: Format.FloatingPoint) -> String {
        format.format(self)
    }
}
