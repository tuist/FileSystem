// Time.Month.swift
// Time
//
// Month representation as a refinement type

extension Time {
    /// A month in the Gregorian calendar (1-12)
    ///
    /// This is a refinement type - an integer constrained to the valid range.
    /// Month names are format-specific and defined in format packages.
    public struct Month: RawRepresentable, Sendable, Equatable, Hashable, Comparable {
        /// The month value (1-12)
        public let rawValue: Int

        /// Create a month with validation
        ///
        /// - Parameter rawValue: Month value (1-12)
        /// - Returns: `nil` if value is not 1-12
        public init?(rawValue: Int) {
            guard (1...12).contains(rawValue) else {
                return nil
            }
            self.rawValue = rawValue
        }

        /// Create a month with validation (throwing)
        ///
        /// - Parameter value: Month value (1-12)
        /// - Throws: `Month.Error` if value is not 1-12
        public init(_ value: Int) throws {
            guard (1...12).contains(value) else {
                throw Error.invalidMonth(value)
            }
            self.rawValue = value
        }
    }
}

// MARK: - Error

extension Time.Month {
    /// Errors that can occur when creating a month
    public enum Error: Swift.Error, Sendable, Equatable {
        /// Month must be 1-12
        case invalidMonth(Int)
    }
}

// MARK: - Unchecked Initialization

extension Time.Month {
    /// Create a month without validation (internal use only)
    ///
    /// - Warning: Only use when value is known to be valid (1-12)
    internal init(unchecked value: Int) {
        self.rawValue = value
    }
}

// MARK: - Comparable

extension Time.Month {
    public static func < (lhs: Time.Month, rhs: Time.Month) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

// MARK: - Int Comparison

extension Time.Month {
    /// Compare month with integer value
    public static func == (lhs: Time.Month, rhs: Int) -> Bool {
        lhs.rawValue == rhs
    }

    /// Compare integer value with month
    public static func == (lhs: Int, rhs: Time.Month) -> Bool {
        lhs == rhs.rawValue
    }
}

// MARK: - Convenience

extension Time.Month {
    /// Number of days in this month for a given year
    ///
    /// - Parameter year: The year (affects February in leap years)
    /// - Returns: Number of days (28-31)
    public func days(in year: Time.Year) -> Int {
        Time.Calendar.Gregorian.daysInMonth(year, self)
    }
}

// MARK: - Common Months

extension Time.Month {
    /// January (month 1)
    public static let january = Self(unchecked: 1)

    /// February (month 2)
    public static let february = Self(unchecked: 2)

    /// March (month 3)
    public static let march = Self(unchecked: 3)

    /// April (month 4)
    public static let april = Self(unchecked: 4)

    /// May (month 5)
    public static let may = Self(unchecked: 5)

    /// June (month 6)
    public static let june = Self(unchecked: 6)

    /// July (month 7)
    public static let july = Self(unchecked: 7)

    /// August (month 8)
    public static let august = Self(unchecked: 8)

    /// September (month 9)
    public static let september = Self(unchecked: 9)

    /// October (month 10)
    public static let october = Self(unchecked: 10)

    /// November (month 11)
    public static let november = Self(unchecked: 11)

    /// December (month 12)
    public static let december = Self(unchecked: 12)
}
