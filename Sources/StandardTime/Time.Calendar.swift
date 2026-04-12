// Time.Calendar.swift
// Time
//
// Calendar system as a first-class value

extension Time {
    /// A calendar system with its rules and algorithms
    ///
    /// This represents a calendar system as a first-class value that can be
    /// passed around and used polymorphically. Different calendar systems
    /// (Gregorian, Julian, Islamic, etc.) are represented as instances.
    ///
    /// ## Design Notes
    ///
    /// Calendar is a value type containing the essential algorithms that define
    /// a calendar system: leap year calculation and days per month.
    ///
    /// Uses refined types (Time.Year, Time.Month) for type safety.
    ///
    /// ## Available Calendars
    ///
    /// - `Time.Calendar.gregorian`: The Gregorian calendar (current international standard)
    ///
    /// ## Category Theory
    ///
    /// This represents calendars as **morphisms** (functions) rather than data,
    /// making them composable and allowing for polymorphic calendar operations.
    public struct Calendar: Sendable {
        /// Determine if a year is a leap year
        public let isLeapYear: @Sendable (Time.Year) -> Bool

        /// Get the number of days in a specific month
        public let daysInMonth: @Sendable (Time.Year, Time.Month) -> Int

        /// Create a calendar with custom algorithms
        ///
        /// - Parameters:
        ///   - isLeapYear: Function to determine if a year is a leap year
        ///   - daysInMonth: Function to get days in a month (year, month) -> days
        public init(
            isLeapYear: @escaping @Sendable (Time.Year) -> Bool,
            daysInMonth: @escaping @Sendable (Time.Year, Time.Month) -> Int
        ) {
            self.isLeapYear = isLeapYear
            self.daysInMonth = daysInMonth
        }
    }
}

// MARK: - Standard Calendars

extension Time.Calendar {
    /// The Gregorian calendar
    ///
    /// The internationally accepted civil calendar, established by Pope Gregory XIII in 1582.
    ///
    /// ## Leap Year Rules
    ///
    /// - Divisible by 4: leap year
    /// - EXCEPT divisible by 100: not leap year
    /// - EXCEPT divisible by 400: leap year
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let calendar = Time.Calendar.gregorian
    /// let year = Time.Year(2024)
    /// calendar.isLeapYear(year)  // true
    ///
    /// let month = try Time.Month(2)
    /// calendar.daysInMonth(year, month)  // 29
    /// ```
    public static let gregorian = Time.Calendar(
        isLeapYear: Time.Calendar.Gregorian.isLeapYear,
        daysInMonth: Time.Calendar.Gregorian.daysInMonth
    )
}
