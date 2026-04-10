// Time.Epoch.Conversion.swift
// Time
//
// Core Unix epoch conversion algorithms
// Extracted from RFC 5322 and ISO 8601 common logic

extension Time.Epoch {
    /// Unix epoch conversion algorithms
    ///
    /// This contains optimized algorithms for converting between
    /// Unix epoch seconds (1970-01-01 00:00:00 UTC) and calendar components.
    ///
    /// ## Performance
    ///
    /// All algorithms are O(1) - constant time with no loops over years.
    /// Uses pure arithmetic based on Gregorian calendar cycle structure.
    ///
    /// ## Design Notes
    ///
    /// - Epoch: January 1, 1970 00:00:00 UTC
    /// - 400-year Gregorian cycle: exactly 146097 days
    /// - Special handling for century boundaries (1970 epoch offset)
    public enum Conversion {
        // Empty - all functionality in extensions
    }
}

// MARK: - Type-Safe Public API

extension Time.Epoch.Conversion {
    /// Calculate seconds since Unix epoch from DateComponents (type-safe)
    ///
    /// Transformation: DateComponents → Int (epoch seconds)
    ///
    /// Note: This only includes whole seconds, not fractional seconds.
    /// Use `dateComponents.totalNanoseconds` to get the sub-second component.
    ///
    /// - Parameter components: The date-time components
    /// - Returns: Seconds since Unix epoch
    public static func secondsSinceEpoch(from components: Time) -> Int {
        secondsSinceEpoch(
            year: components.year,
            month: components.month,
            day: components.day,
            hour: components.hour,
            minute: components.minute,
            second: components.second
        )
    }
}

// MARK: - Internal Type-Safe Implementation

extension Time.Epoch.Conversion {
    /// Calculate seconds since epoch from components (internal type-safe version)
    ///
    /// Uses refined types throughout for maximum type safety.
    /// Only unwraps when doing arithmetic.
    ///
    /// - Parameters:
    ///   - year: The year
    ///   - month: The month (guaranteed 1-12 by type)
    ///   - day: The day (guaranteed valid for month/year by type)
    ///   - hour: The hour (guaranteed 0-23 by type)
    ///   - minute: The minute (guaranteed 0-59 by type)
    ///   - second: The second (guaranteed 0-60 by type)
    /// - Returns: Seconds since Unix epoch
    internal static func secondsSinceEpoch(
        year: Time.Year,
        month: Time.Month,
        day: Time.Month.Day,
        hour: Time.Hour,
        minute: Time.Minute,
        second: Time.Second
    ) -> Int {
        let days = daysSinceEpoch(year: year, month: month, day: day)

        return days * Time.Calendar.Gregorian.TimeConstants.secondsPerDay + hour.value
            * Time.Calendar.Gregorian.TimeConstants.secondsPerHour + minute.value
            * Time.Calendar.Gregorian.TimeConstants.secondsPerMinute + second.value
    }

    /// Extract date-time components from seconds since epoch (internal raw version)
    ///
    /// Internal performance primitive that returns raw tuple.
    /// Values are guaranteed valid by algorithmic construction.
    ///
    /// - Parameter secondsSinceEpoch: Seconds since Unix epoch (UTC)
    /// - Returns: Tuple of (year, month, day, hour, minute, second) - all values valid by construction
    internal static func componentsRaw(
        fromSecondsSinceEpoch secondsSinceEpoch: Int
    ) -> (year: Int, month: Int, day: Int, hour: Int, minute: Int, second: Int) {
        let totalDays = secondsSinceEpoch / Time.Calendar.Gregorian.TimeConstants.secondsPerDay
        let secondsInDay = secondsSinceEpoch % Time.Calendar.Gregorian.TimeConstants.secondsPerDay

        let hour = secondsInDay / Time.Calendar.Gregorian.TimeConstants.secondsPerHour
        let minute =
            (secondsInDay % Time.Calendar.Gregorian.TimeConstants.secondsPerHour)
            / Time.Calendar.Gregorian
            .TimeConstants.secondsPerMinute
        let second = secondsInDay % Time.Calendar.Gregorian.TimeConstants.secondsPerMinute

        // Calculate year, month, day from days since epoch
        let (year, remainingDays) = yearAndDays(fromDaysSinceEpoch: totalDays)

        // Calculate month and day
        let daysInMonths = Time.Calendar.Gregorian.daysInMonths(year: year)
        var month = 1
        var daysInCurrentMonth = remainingDays
        for daysInMonth in daysInMonths {
            if daysInCurrentMonth < daysInMonth {
                break
            }
            daysInCurrentMonth -= daysInMonth
            month += 1
        }

        let day = daysInCurrentMonth + 1

        return (year, month, day, hour, minute, second)
    }
}

// MARK: - Year and Days Calculation (Internal)

extension Time.Epoch.Conversion {
    /// Optimized O(1) calculation of year and remaining days from days since epoch
    ///
    /// Uses pure arithmetic based on Gregorian calendar structure.
    /// The Gregorian calendar has a 400-year cycle with exactly 146097 days.
    ///
    /// ## Algorithm Details
    ///
    /// The 400-year cycle contains:
    /// - 97 leap years and 303 common years
    /// - 100-year periods vary in length due to leap year rules
    ///
    /// Since 1970 is 30 years into the 1600-2000 cycle, the centuries are:
    /// - 1970-2069 (includes year 2000): 36525 days (25 leap years)
    /// - 2070-2169 (year 2100): 36524 days (24 leap years)
    /// - 2170-2269 (year 2200): 36524 days (24 leap years)
    /// - 2270-2369 (year 2300): 36524 days (24 leap years)
    ///
    /// - Parameter days: Days since Unix epoch (can be negative)
    /// - Returns: Tuple of (year, remainingDays) where remainingDays is 0-365
    internal static func yearAndDays(
        fromDaysSinceEpoch days: Int
    ) -> (year: Int, remainingDays: Int) {
        // Gregorian calendar has a 400-year cycle with exactly 146097 days
        // This cycle contains: 97 leap years and 303 common years
        let cyclesOf400 = days / Time.Calendar.Gregorian.TimeConstants.daysPer400Years
        var remainingDays = days % Time.Calendar.Gregorian.TimeConstants.daysPer400Years

        // Within each 400-year cycle, 100-year periods vary:
        // - First 3 periods: 36524 days each (24 leap years, 76 common years)
        // - Last period: 36525 days (25 leap years because year x400 is always a leap year)
        // However, since 1970 is 30 years into a cycle, we need special handling

        // For epoch 1970, we're 30 years into the 1600-2000 cycle
        // So the relevant centuries starting from 1970 are: 2000, 2100, 2200, 2300...
        // 2000 is divisible by 400 (leap year), so 1970-2069 has 25 leap years = 36525 days
        // 2100, 2200, 2300 are not divisible by 400, so they have 24 leap years = 36524 days each

        var cyclesOf100: Int
        if remainingDays >= 36525 {  // First century (1970-2070) includes year 2000
            cyclesOf100 = 1
            remainingDays -= 36525
            // Add remaining centuries (each 36524 days)
            let additionalCenturies = min(
                remainingDays / Time.Calendar.Gregorian.TimeConstants.daysPer100Years,
                2
            )  // Max 2 more (to stay within 400-year cycle)
            cyclesOf100 += additionalCenturies
            remainingDays -=
                additionalCenturies * Time.Calendar.Gregorian.TimeConstants.daysPer100Years
        } else {
            cyclesOf100 = 0
        }

        // Within each 100-year period, 4-year periods have 1461 days
        // (1 leap year, 3 common years)
        // We use min(_, 24) to stay within the 100-year boundary
        let cyclesOf4 = min(remainingDays / Time.Calendar.Gregorian.TimeConstants.daysPer4Years, 24)
        remainingDays -= cyclesOf4 * Time.Calendar.Gregorian.TimeConstants.daysPer4Years

        // Handle remaining 0-3 years, accounting for possible leap year
        var year = 1970 + cyclesOf400 * 400 + cyclesOf100 * 100 + cyclesOf4 * 4

        // Process up to 3 remaining years
        for _ in 0..<3 {
            let daysInYear =
                Time.Calendar.Gregorian.isLeapYear(year)
                ? Time.Calendar.Gregorian.TimeConstants
                    .daysPerLeapYear : Time.Calendar.Gregorian.TimeConstants.daysPerCommonYear
            if remainingDays < daysInYear {
                break
            }
            remainingDays -= daysInYear
            year += 1
        }

        return (year, remainingDays)
    }
}

// MARK: - Days Since Epoch Calculation (Internal)

extension Time.Epoch.Conversion {
    /// Calculate days since Unix epoch for a given date (type-safe)
    ///
    /// Optimized calculation avoiding year-by-year iteration.
    /// Uses formula for counting leap years in a range.
    ///
    /// Uses refined types for maximum type safety - array indexing guaranteed safe.
    ///
    /// - Parameters:
    ///   - year: The year
    ///   - month: The month (guaranteed 1-12 by type)
    ///   - day: The day (guaranteed valid for month/year by type)
    /// - Returns: Days since epoch (1970-01-01)
    internal static func daysSinceEpoch(
        year: Time.Year,
        month: Time.Month,
        day: Time.Month.Day
    ) -> Int {
        // Optimized calculation avoiding year-by-year iteration
        let yearsSince1970 = year.rawValue - 1970

        // Calculate leap years between 1970 and year (exclusive)
        // Count years divisible by 4, subtract those divisible by 100, add back those divisible by 400
        let leapYears: Int
        if yearsSince1970 > 0 {
            let yearBefore = year.rawValue - 1
            leapYears =
                (yearBefore / 4 - 1970 / 4) - (yearBefore / 100 - 1970 / 100)
                + (yearBefore / 400 - 1970 / 400)
        } else {
            leapYears = 0
        }

        var days =
            yearsSince1970 * Time.Calendar.Gregorian.TimeConstants.daysPerCommonYear + leapYears

        // Add days for complete months in current year
        let monthDays = Time.Calendar.Gregorian.daysInMonths(year: year.rawValue)
        // SAFE: month.rawValue guaranteed to be in range 1-12 by Time.Month invariant
        for m in 0..<(month.rawValue - 1) {
            days += monthDays[m]
        }

        // Add remaining days
        days += day.rawValue - 1

        return days
    }
}
