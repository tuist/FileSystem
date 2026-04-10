// Time.Epoch.swift
// Time
//
// Epoch as a first-class reference point in time

extension Time {
    /// An epoch - a reference point in time
    ///
    /// An epoch represents a specific moment in time used as a reference point
    /// for measuring time intervals. Different systems use different epochs.
    ///
    /// ## Design Notes
    ///
    /// Epoch is a value type representing the reference date. This makes epochs
    /// first-class values that can be passed around and compared.
    ///
    /// ## Available Epochs
    ///
    /// - `Time.Epoch.unix`: Unix epoch (1970-01-01 00:00:00 UTC)
    /// - `Time.Epoch.ntp`: NTP epoch (1900-01-01 00:00:00 UTC)
    /// - `Time.Epoch.gps`: GPS epoch (1980-01-06 00:00:00 UTC)
    ///
    /// ## Category Theory
    ///
    /// An epoch is an **initial object** in the category of time measurements -
    /// a distinguished starting point from which all other times are measured.
    public struct Epoch: Sendable, Equatable, Hashable {
        /// The reference date of this epoch
        public let referenceDate: Time

        /// Create an epoch with a reference date
        ///
        /// - Parameter referenceDate: The reference date for this epoch
        public init(referenceDate: Time) {
            self.referenceDate = referenceDate
        }
    }
}

// MARK: - Standard Epochs

extension Time.Epoch {
    /// Unix epoch (1970-01-01 00:00:00 UTC)
    ///
    /// The reference point for Unix time, used by POSIX systems and most
    /// modern computing platforms.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let epoch = Time.Epoch.unix
    /// let seconds = Time.Epoch.Conversion.secondsSinceEpoch(
    ///     year: 2024, month: 1, day: 1
    /// )
    /// ```
    public static let unix = Time.Epoch(
        referenceDate: .unchecked(
            year: 1970,
            month: 1,
            day: 1,
            hour: 0,
            minute: 0,
            second: 0
        )
    )

    /// NTP epoch (1900-01-01 00:00:00 UTC)
    ///
    /// The reference point for Network Time Protocol (NTP), which predates Unix epoch by 70 years.
    ///
    /// NTP chose 1900 to allow for dates in the early 20th century and uses a 64-bit timestamp
    /// format (32-bit seconds + 32-bit fractional seconds).
    public static let ntp = Time.Epoch(
        referenceDate: .unchecked(
            year: 1900,
            month: 1,
            day: 1,
            hour: 0,
            minute: 0,
            second: 0
        )
    )

    /// GPS epoch (1980-01-06 00:00:00 UTC)
    ///
    /// The reference point for Global Positioning System time, which began at
    /// midnight on January 6, 1980.
    ///
    /// GPS time does not observe leap seconds (unlike UTC), so it gradually
    /// diverges from UTC. As of 2024, GPS time is 18 seconds ahead of UTC.
    public static let gps = Time.Epoch(
        referenceDate: .unchecked(
            year: 1980,
            month: 1,
            day: 6,
            hour: 0,
            minute: 0,
            second: 0
        )
    )

    /// TAI epoch (1958-01-01 00:00:00)
    ///
    /// Reference instant used for International Atomic Time (TAI), a
    /// continuous atomic timescale without leap seconds. At this epoch
    /// TAI was defined to coincide with UT2; afterwards they diverge.
    ///
    /// This is mainly useful if you ever add explicit UTC↔TAI conversion
    /// with a leap-second table.
    public static let tai = Time.Epoch(
        referenceDate: .unchecked(
            year: 1958,
            month: 1,
            day: 1,
            hour: 0,
            minute: 0,
            second: 0,
            millisecond: 0,
            microsecond: 0,
            nanosecond: 0
        )
    )

    /// Windows FILETIME / NTFS epoch (1601-01-01 00:00:00 UTC)
    ///
    /// Used by Win32 `FILETIME`, NTFS, Active Directory, and related
    /// APIs. Timestamps are expressed as 100-nanosecond intervals since
    /// this epoch.
    public static let windowsFileTime = Time.Epoch(
        referenceDate: .unchecked(
            year: 1601,
            month: 1,
            day: 1,
            hour: 0,
            minute: 0,
            second: 0,
            millisecond: 0,
            microsecond: 0,
            nanosecond: 0
        )
    )

    /// Apple / Core Foundation absolute time epoch (2001-01-01 00:00:00 UTC)
    ///
    /// Core Foundation's `CFAbsoluteTime` and `CFDate` measure seconds
    /// relative to this reference date.
    ///
    /// Useful when bridging to/from Apple platforms without pulling in
    /// Foundation.
    public static let appleAbsolute = Time.Epoch(
        referenceDate: .unchecked(
            year: 2001,
            month: 1,
            day: 1,
            hour: 0,
            minute: 0,
            second: 0,
            millisecond: 0,
            microsecond: 0,
            nanosecond: 0
        )
    )
}
