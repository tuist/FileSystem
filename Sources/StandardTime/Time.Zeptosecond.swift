// Time.Zeptosecond.swift
// Time
//
// Zeptosecond representation as a refinement type

extension Time {
    /// A zeptosecond (0-999)
    ///
    /// This is a refinement type - an integer constrained to the valid range.
    /// Represents 10^-21 seconds (sextillionths of a second).
    public struct Zeptosecond: Sendable, Equatable, Hashable, Comparable {
        /// The zeptosecond value (0-999)
        public let value: Int

        /// Create a zeptosecond with validation
        ///
        /// - Parameter value: Zeptosecond value (0-999)
        /// - Throws: `Zeptosecond.Error` if value is not 0-999
        public init(_ value: Int) throws {
            guard (0...999).contains(value) else {
                throw Error.invalidZeptosecond(value)
            }
            self.value = value
        }
    }
}

// MARK: - Error

extension Time.Zeptosecond {
    /// Errors that can occur when creating a zeptosecond
    public enum Error: Swift.Error, Sendable, Equatable {
        /// Zeptosecond must be 0-999
        case invalidZeptosecond(Int)
    }
}

// MARK: - Unchecked Initialization

extension Time.Zeptosecond {
    /// Create a zeptosecond without validation (internal use only)
    ///
    /// - Warning: Only use when value is known to be valid (0-999)
    internal init(unchecked value: Int) {
        self.value = value
    }
}

// MARK: - Comparable

extension Time.Zeptosecond {
    public static func < (lhs: Time.Zeptosecond, rhs: Time.Zeptosecond) -> Bool {
        lhs.value < rhs.value
    }
}

extension Time.Zeptosecond {
    /// Zero nanoseconds
    public static let zero = Time.Zeptosecond(unchecked: 0)
}
