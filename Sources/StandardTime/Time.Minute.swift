// Time.Minute.swift
// Time
//
// Minute representation as a refinement type

extension Time {
    /// A minute in an hour (0-59)
    ///
    /// This is a refinement type - an integer constrained to the valid range.
    public struct Minute: Sendable, Equatable, Hashable, Comparable {
        /// The minute value (0-59)
        public let value: Int

        /// Create a minute with validation
        ///
        /// - Parameter value: Minute value (0-59)
        /// - Throws: `Minute.Error` if value is not 0-59
        public init(_ value: Int) throws {
            guard (0...59).contains(value) else {
                throw Error.invalidMinute(value)
            }
            self.value = value
        }
    }
}

// MARK: - Error

extension Time.Minute {
    /// Errors that can occur when creating a minute
    public enum Error: Swift.Error, Sendable, Equatable {
        /// Minute must be 0-59
        case invalidMinute(Int)
    }
}

// MARK: - Unchecked Initialization

extension Time.Minute {
    /// Create a minute without validation (internal use only)
    ///
    /// - Warning: Only use when value is known to be valid (0-59)
    internal init(unchecked value: Int) {
        self.value = value
    }
}

// MARK: - Comparable

extension Time.Minute {
    public static func < (lhs: Time.Minute, rhs: Time.Minute) -> Bool {
        lhs.value < rhs.value
    }
}

extension Time.Minute {
    /// Zero nanoseconds
    public static let zero = Time.Minute(unchecked: 0)
}
