// Time.Calendar.Gregorian.swift
// Time
//
// Core Gregorian calendar algorithms and constants
// Extracted from RFC 5322 and ISO 8601 common logic

extension Time.Calendar {
    /// Gregorian calendar calculations and constants
    ///
    /// This contains pure Gregorian calendar logic that is shared
    /// across all date-time format implementations (RFC 5322, ISO 8601, etc.).
    ///
    /// ## Design Notes
    ///
    /// - All functions are pure (no side effects)
    /// - Zero Foundation dependency
    /// - Optimized for performance (O(1) algorithms where possible)
    /// - Follows Gregorian calendar rules exactly:
    ///   - Year divisible by 4 is leap year
    ///   - EXCEPT year divisible by 100 is NOT leap year
    ///   - EXCEPT year divisible by 400 IS leap year
    public enum Gregorian {
        // Empty - all functionality in extensions
    }
}

// MARK: - Time Constants

extension Time.Calendar.Gregorian {
    /// Standard time unit conversions
    public enum TimeConstants {
        /// Seconds in one minute (60)
        public static let secondsPerMinute = 60

        /// Seconds in one hour (3600)
        public static let secondsPerHour = 3600

        /// Seconds in one day (86400)
        public static let secondsPerDay = 86400

        /// Days in a common (non-leap) year (365)
        public static let daysPerCommonYear = 365

        /// Days in a leap year (366)
        public static let daysPerLeapYear = 366

        /// Days in a 4-year cycle (1461 = 3*365 + 366)
        public static let daysPer4Years = 1461

        /// Days in a 100-year cycle (36524 = 24*1461 + 365)
        public static let daysPer100Years = 36524

        /// Days in a 400-year cycle (146097 = 97*366 + 303*365)
        public static let daysPer400Years = 146_097
    }
}

// MARK: - Leap Year

extension Time.Calendar.Gregorian {
    /// Determine if a year is a leap year in the Gregorian calendar (type-safe)
    ///
    /// A year is a leap year if:
    /// - Divisible by 4 AND not divisible by 100, OR
    /// - Divisible by 400
    ///
    /// ## Examples
    ///
    /// ```swift
    /// Time.Calendar.Gregorian.isLeapYear(Time.Year(2000))  // true (divisible by 400)
    /// Time.Calendar.Gregorian.isLeapYear(Time.Year(2100))  // false (divisible by 100, not 400)
    /// Time.Calendar.Gregorian.isLeapYear(Time.Year(2024))  // true (divisible by 4, not 100)
    /// Time.Calendar.Gregorian.isLeapYear(Time.Year(2023))  // false
    /// ```
    ///
    /// - Parameter year: The year to check
    /// - Returns: `true` if the year is a leap year, `false` otherwise
    public static func isLeapYear(_ year: Time.Year) -> Bool {
        let y = year.rawValue
        return (y % 4 == 0 && y % 100 != 0) || (y % 400 == 0)
    }

    /// Determine if a year is a leap year (Int version)
    ///
    /// - Parameter year: The year to check
    /// - Returns: `true` if the year is a leap year, `false` otherwise
    public static func isLeapYear(_ year: Int) -> Bool {
        isLeapYear(Time.Year(year))
    }
}

// MARK: - Days in Month

extension Time.Calendar.Gregorian {
    /// Days in each month for a common (non-leap) year
    /// Index 0 = January, Index 11 = December
    private static let daysInCommonYearMonths = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

    /// Days in each month for a leap year
    /// Index 0 = January, Index 11 = December
    private static let daysInLeapYearMonths = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

    /// Get the number of days in a specific month (type-safe)
    ///
    /// This is the primary implementation using refined types.
    /// Since Time.Month guarantees value ∈ [1,12], array indexing is safe by construction.
    ///
    /// - Parameters:
    ///   - year: The year (affects February)
    ///   - month: The month (guaranteed 1-12 by type)
    /// - Returns: Number of days in the month (28-31)
    public static func daysInMonth(_ year: Time.Year, _ month: Time.Month) -> Int {
        let monthArray = isLeapYear(year) ? daysInLeapYearMonths : daysInCommonYearMonths
        // SAFE: month.value is guaranteed to be in range 1-12 by Time.Month invariant
        return monthArray[month.rawValue - 1]
    }

    /// Get the number of days in each month for a given year
    ///
    /// Returns an array of 12 integers representing days in each month.
    /// February has 28 days in common years, 29 in leap years.
    ///
    /// - Parameter year: The year
    /// - Returns: Array of 12 integers (days per month)
    public static func daysInMonths(year: Int) -> [Int] {
        isLeapYear(year) ? daysInLeapYearMonths : daysInCommonYearMonths
    }

    /// Get the number of days in a specific month (internal Int version)
    ///
    /// Internal convenience for epoch conversion code that works with raw Ints.
    ///
    /// - Parameters:
    ///   - year: The year
    ///   - month: The month (must be 1-12, unchecked)
    /// - Returns: Number of days in the month
    internal static func daysInMonth(year: Int, month: Int) -> Int {
        let months = daysInMonths(year: year)
        // UNSAFE: Caller must guarantee month ∈ [1,12]
        return months[month - 1]
    }
}
