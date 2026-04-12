// Time.Nanosecond.swift
// Time
//
// Nanosecond representation as a refinement type

extension Time {
    /// A nanosecond (0-999)
    ///
    /// This is a refinement type - an integer constrained to the valid range.
    /// Represents 10^-9 seconds (billionths of a second).
    ///
    /// Note: When used as a fractional second component (e.g., in timestamps),
    /// this typically represents 0-999,999,999 nanoseconds within a second.
    /// This type represents the nanosecond digit (0-999) within a microsecond.
    public struct Nanosecond: Sendable, Equatable, Hashable, Comparable {
        /// The nanosecond value (0-999)
        public let value: Int

        /// Create a nanosecond with validation
        ///
        /// - Parameter value: Nanosecond value (0-999)
        /// - Throws: `Nanosecond.Error` if value is not 0-999
        public init(_ value: Int) throws {
            guard (0...999).contains(value) else {
                throw Error.invalidNanosecond(value)
            }
            self.value = value
        }
    }
}

// MARK: - Error

extension Time.Nanosecond {
    /// Errors that can occur when creating a nanosecond
    public enum Error: Swift.Error, Sendable, Equatable {
        /// Nanosecond must be 0-999
        case invalidNanosecond(Int)
    }
}

// MARK: - Unchecked Initialization

extension Time.Nanosecond {
    /// Create a nanosecond without validation (internal use only)
    ///
    /// - Warning: Only use when value is known to be valid (0-999)
    internal init(unchecked value: Int) {
        self.value = value
    }
}

// MARK: - Comparable

extension Time.Nanosecond {
    public static func < (lhs: Time.Nanosecond, rhs: Time.Nanosecond) -> Bool {
        lhs.value < rhs.value
    }
}

// MARK: - Constants

extension Time.Nanosecond {
    /// Zero nanoseconds
    public static let zero = Time.Nanosecond(unchecked: 0)
}
