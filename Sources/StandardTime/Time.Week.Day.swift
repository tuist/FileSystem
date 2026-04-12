// Time.Weekday.swift
// Time
//
// Weekday representation with initializer-based calculation
// Supports different numbering conventions (ISO 8601 and Gregorian/Western)

extension Time {
    public typealias Weekday = Time.Week.Day
}

extension Time.Week {
    /// Day of the week
    ///
    /// Represents the seven days of the week as an abstract semantic value,
    /// independent of any numbering convention or naming system.
    ///
    /// This is **pure, format-agnostic representation**. Format-specific
    /// interpretations (numbering systems, localized names, etc.) are defined
    /// in format packages (RFC 5322, ISO 8601, etc.) via extensions.
    ///
    /// ## Examples
    ///
    /// ```swift
    /// // Calculate weekday from a Gregorian calendar date
    /// let weekday = try Time.Weekday(year: 2024, month: 1, day: 15)
    /// // weekday == .monday
    ///
    /// // Format-specific extensions provide numbering/names:
    /// // RFC_5322.DateTime.weekdayNumber(weekday) -> 1
    /// // ISO_8601.DateTime.weekdayNumber(weekday) -> 1
    /// ```
    public enum Day: Sendable, Equatable, Hashable, CaseIterable {
        case sunday
        case monday
        case tuesday
        case wednesday
        case thursday
        case friday
        case saturday
    }
}

extension Time.Week.Day {
    /// Errors that can occur when calculating weekday from date components
    public enum Error: Swift.Error, Sendable, Equatable {
        /// Month must be 1-12
        case invalidMonth(Int)

        /// Day must be valid for the given month and year
        case invalidDay(Int, month: Int, year: Int)
    }
}

extension Time.Weekday {

    /// Calculate the weekday for a given Gregorian calendar date using refined types
    ///
    /// Uses Zeller's congruence algorithm to determine the day of the week.
    /// This initializer is total (cannot fail) because all parameters are already validated.
    ///
    /// - Parameters:
    ///   - year: The year (validated Time.Year)
    ///   - month: The month (validated Time.Month, 1-12)
    ///   - day: The day of the month (validated Time.Month.Day, 1-31)
    ///
    /// ## Example
    ///
    /// ```swift
    /// let year = Time.Year(2024)
    /// let month = try Time.Month(1)
    /// let day = try Time.Month.Day(15, in: month, year: year)
    /// let weekday = Time.Weekday(year: year, month: month, day: day)
    /// // weekday == .monday
    /// ```
    public init(
        year: Time.Year,
        month: Time.Month,
        day: Time.Month.Day
    ) {
        var y = year.rawValue
        var m = month.rawValue

        // Zeller's congruence: treat Jan/Feb as months 13/14 of previous year
        if m < 3 {
            m += 12
            y -= 1
        }

        let q = day.rawValue
        let K = y % 100
        let J = y / 100

        // Zeller's formula
        let h = (q + ((13 * (m + 1)) / 5) + K + (K / 4) + (J / 4) - (2 * J)) % 7

        // Convert from Zeller's (0=Saturday) to Gregorian (0=Sunday)
        // Modulo 7 always returns 0-6, so this switch is exhaustive
        let gregorianDay = (h + 6) % 7

        switch gregorianDay {
        case 0: self = .sunday
        case 1: self = .monday
        case 2: self = .tuesday
        case 3: self = .wednesday
        case 4: self = .thursday
        case 5: self = .friday
        default: self = .saturday  // Must be 6 (only remaining case)
        }
    }

    /// Calculate the weekday for a given Gregorian calendar date using raw integers
    ///
    /// Convenience initializer for when you have raw integer values.
    /// Validates the date components and constructs refined types.
    ///
    /// - Parameters:
    ///   - year: The year value
    ///   - month: The month value (1-12)
    ///   - day: The day of the month (1-31, validated against month/year)
    /// - Throws: `Time.Weekday.Error` if date components are invalid
    ///
    /// ## Example
    ///
    /// ```swift
    /// let weekday = try Time.Weekday(year: 2024, month: 1, day: 15)
    /// // weekday == .monday
    /// ```
    public init(year: Int, month: Int, day: Int) throws {
        let y = Time.Year(year)

        guard let m = try? Time.Month(month) else {
            throw Error.invalidMonth(month)
        }

        guard let d = try? Time.Month.Day(day, in: m, year: y) else {
            throw Error.invalidDay(day, month: month, year: year)
        }

        self.init(year: y, month: m, day: d)
    }
}
