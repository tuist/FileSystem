// Time.Month.Day.swift
// Time
//
// Day-of-month representation as a dependent refinement type

extension Time.Month {
    /// A day within a month (1-31, validated against month/year)
    ///
    /// This is a **dependent refinement type** - the valid range depends on
    /// the month and year (e.g., February has 28 or 29 days).
    ///
    /// Category Theory: This represents a dependent product type where
    /// the day value depends on (month, year) for its validity.
    ///
    /// Note: Does not conform to `RawRepresentable` because validity depends
    /// on context (month/year), not just the raw value itself.
    public struct Day: Sendable, Equatable, Hashable, Comparable {
        /// The day value (1-31)
        public let rawValue: Int

        /// Create a day with validation against month and year
        ///
        /// This validates that the day is in the valid range for the given month/year.
        /// For example, February 29 is only valid in leap years.
        ///
        /// - Parameters:
        ///   - value: Day value (1-31)
        ///   - month: The month
        ///   - year: The year
        /// - Throws: `Day.Error` if day is invalid for the month/year
        public init(_ value: Int, in month: Time.Month, year: Time.Year) throws {
            let maxDay = month.days(in: year)
            guard (1...maxDay).contains(value) else {
                throw Error.invalidDay(value, month: month, year: year)
            }
            self.rawValue = value
        }
    }
}

// MARK: - Error

extension Time.Month.Day {
    /// Errors that can occur when creating a day
    public enum Error: Swift.Error, Sendable, Equatable {
        /// Day must be valid for the given month and year
        case invalidDay(Int, month: Time.Month, year: Time.Year)
    }
}

// MARK: - Unchecked Initialization

extension Time.Month.Day {
    /// Create a day without validation (internal use only)
    ///
    /// - Warning: Only use when value is known to be valid for the context
    internal init(unchecked value: Int) {
        self.rawValue = value
    }
}

// MARK: - Comparable

extension Time.Month.Day {
    public static func < (lhs: Time.Month.Day, rhs: Time.Month.Day) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

// MARK: - Int Comparison

extension Time.Month.Day {
    /// Compare day with integer value
    public static func == (lhs: Time.Month.Day, rhs: Int) -> Bool {
        lhs.rawValue == rhs
    }

    /// Compare integer value with day
    public static func == (lhs: Int, rhs: Time.Month.Day) -> Bool {
        lhs == rhs.rawValue
    }
}
