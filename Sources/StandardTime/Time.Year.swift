// Time.Year.swift
// Time
//
// Year representation as a refinement type

extension Time {
    /// A year in the Gregorian calendar
    ///
    /// This is a newtype wrapper providing type safety for year values.
    /// No range restrictions - supports any integer year (including BC years as negative).
    public struct Year: RawRepresentable, Sendable, Equatable, Hashable, Comparable {
        /// The year value
        public let rawValue: Int

        /// Create a year
        ///
        /// No validation - any integer year is allowed.
        /// Negative years represent BC/BCE years.
        ///
        /// - Parameter rawValue: The year value
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        /// Create a year (convenience)
        ///
        /// - Parameter value: The year value
        public init(_ value: Int) {
            self.rawValue = value
        }
    }
}

// MARK: - Comparable

extension Time.Year {
    public static func < (lhs: Time.Year, rhs: Time.Year) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

// MARK: - Convenience

extension Time.Year {
    /// Check if this year is a leap year in the Gregorian calendar
    public var isLeapYear: Bool {
        Time.Calendar.Gregorian.isLeapYear(self)
    }
}

// MARK: - ExpressibleByIntegerLiteral

extension Time.Year: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self.init(value)
    }
}
