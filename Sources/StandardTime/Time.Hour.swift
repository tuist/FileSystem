// Time.Hour.swift
// Time
//
// Hour representation as a refinement type

extension Time {
    /// An hour in a 24-hour day (0-23)
    ///
    /// This is a refinement type - an integer constrained to the valid range.
    public struct Hour: Sendable, Equatable, Hashable, Comparable {
        /// The hour value (0-23)
        public let value: Int

        /// Create an hour with validation
        ///
        /// - Parameter value: Hour value (0-23)
        /// - Throws: `Hour.Error` if value is not 0-23
        public init(_ value: Int) throws {
            guard (0...23).contains(value) else {
                throw Error.invalidHour(value)
            }
            self.value = value
        }
    }
}

// MARK: - Error

extension Time.Hour {
    /// Errors that can occur when creating an hour
    public enum Error: Swift.Error, Sendable, Equatable {
        /// Hour must be 0-23
        case invalidHour(Int)
    }
}

// MARK: - Unchecked Initialization

extension Time.Hour {
    /// Create an hour without validation (internal use only)
    ///
    /// - Warning: Only use when value is known to be valid (0-23)
    internal init(unchecked value: Int) {
        self.value = value
    }
}

// MARK: - Comparable

extension Time.Hour {
    public static func < (lhs: Time.Hour, rhs: Time.Hour) -> Bool {
        lhs.value < rhs.value
    }
}

// MARK: - Constants

extension Time.Hour {
    /// Zero nanoseconds
    public static let zero = Time.Hour(unchecked: 0)
}
