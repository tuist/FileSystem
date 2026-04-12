// Time.TimezoneOffset.swift
// Time
//
// Type-safe timezone offset representation

extension Time {
    /// Timezone offset from UTC
    ///
    /// Represents the offset from UTC in seconds. Positive values indicate
    /// timezones east of UTC (ahead), negative values indicate west (behind).
    ///
    /// ## Examples
    ///
    /// ```swift
    /// // UTC
    /// let utc = Time.TimezoneOffset.utc
    ///
    /// // EST (UTC-5)
    /// let est = Time.TimezoneOffset(hours: -5)
    ///
    /// // IST (UTC+5:30)
    /// let ist = Time.TimezoneOffset(hours: 5, minutes: 30)
    ///
    /// // From raw seconds
    /// let offset = Time.TimezoneOffset(seconds: 19800)  // +5:30
    /// ```
    public struct TimezoneOffset: Sendable, Equatable, Hashable, Codable {
        /// Offset in seconds from UTC
        ///
        /// Positive values are east of UTC (ahead), negative values are west (behind).
        /// Example: +0500 = 18000, -0800 = -28800
        public let seconds: Int

        /// Creates a timezone offset from seconds
        ///
        /// - Parameter seconds: Offset in seconds (positive = east, negative = west)
        public init(seconds: Int) {
            self.seconds = seconds
        }

        /// Creates a timezone offset from hours and minutes
        ///
        /// - Parameters:
        ///   - hours: Hours offset (positive = east, negative = west)
        ///   - minutes: Additional minutes offset (0-59, sign follows hours)
        ///
        /// ## Examples
        ///
        /// ```swift
        /// Time.TimezoneOffset(hours: -5)           // EST: -5:00
        /// Time.TimezoneOffset(hours: 5, minutes: 30)  // IST: +5:30
        /// Time.TimezoneOffset(hours: -3, minutes: 30) // NST: -3:30
        /// ```
        public init(hours: Int, minutes: Int = 0) {
            let sign = hours < 0 ? -1 : 1
            self.seconds =
                hours * Time.Calendar.Gregorian.TimeConstants.secondsPerHour + sign * minutes
                * Time.Calendar.Gregorian.TimeConstants.secondsPerMinute
        }

        /// UTC timezone offset (zero offset)
        public static let utc = TimezoneOffset(seconds: 0)

        /// Returns the hour component of the offset
        public var hours: Int {
            seconds / Time.Calendar.Gregorian.TimeConstants.secondsPerHour
        }

        /// Returns the minute component of the offset (0-59)
        public var minutes: Int {
            abs(seconds % Time.Calendar.Gregorian.TimeConstants.secondsPerHour)
                / Time.Calendar.Gregorian.TimeConstants.secondsPerMinute
        }

        /// Returns true if this is UTC (zero offset)
        public var isUTC: Bool {
            seconds == 0
        }
    }
}

// MARK: - CustomStringConvertible

extension Time.TimezoneOffset: CustomStringConvertible {
    /// Format as +HH:MM or -HH:MM
    public var description: String {
        if seconds == 0 {
            return "+00:00"
        }

        let sign = seconds >= 0 ? "+" : "-"
        let absHours = abs(hours)
        let absMinutes = minutes

        let hourStr = absHours < 10 ? "0\(absHours)" : "\(absHours)"
        let minStr = absMinutes < 10 ? "0\(absMinutes)" : "\(absMinutes)"

        return "\(sign)\(hourStr):\(minStr)"
    }
}

// MARK: - Comparable

extension Time.TimezoneOffset: Comparable {
    public static func < (lhs: Time.TimezoneOffset, rhs: Time.TimezoneOffset) -> Bool {
        lhs.seconds < rhs.seconds
    }
}
