// Time.Yoctosecond.swift
// Time
//
// Yoctosecond representation as a refinement type

extension Time {
    /// A yoctosecond (0-999)
    ///
    /// This is a refinement type - an integer constrained to the valid range.
    /// Represents 10^-24 seconds (septillionths of a second).
    /// This is the smallest SI time unit.
    public struct Yoctosecond: Sendable, Equatable, Hashable, Comparable {
        /// The yoctosecond value (0-999)
        public let value: Int

        /// Create a yoctosecond with validation
        ///
        /// - Parameter value: Yoctosecond value (0-999)
        /// - Throws: `Yoctosecond.Error` if value is not 0-999
        public init(_ value: Int) throws {
            guard (0...999).contains(value) else {
                throw Error.invalidYoctosecond(value)
            }
            self.value = value
        }
    }
}

// MARK: - Error

extension Time.Yoctosecond {
    /// Errors that can occur when creating a yoctosecond
    public enum Error: Swift.Error, Sendable, Equatable {
        /// Yoctosecond must be 0-999
        case invalidYoctosecond(Int)
    }
}

// MARK: - Unchecked Initialization

extension Time.Yoctosecond {
    /// Create a yoctosecond without validation (internal use only)
    ///
    /// - Warning: Only use when value is known to be valid (0-999)
    internal init(unchecked value: Int) {
        self.value = value
    }
}

// MARK: - Comparable

extension Time.Yoctosecond {
    public static func < (lhs: Time.Yoctosecond, rhs: Time.Yoctosecond) -> Bool {
        lhs.value < rhs.value
    }
}

extension Time.Yoctosecond {
    /// Zero nanoseconds
    public static let zero = Time.Yoctosecond(unchecked: 0)
}
