// Time.Microsecond.swift
// Time
//
// Microsecond representation as a refinement type

extension Time {
    /// A microsecond (0-999)
    ///
    /// This is a refinement type - an integer constrained to the valid range.
    /// Represents 10^-6 seconds (millionths of a second).
    public struct Microsecond: Sendable, Equatable, Hashable, Comparable {
        /// The microsecond value (0-999)
        public let value: Int

        /// Create a microsecond with validation
        ///
        /// - Parameter value: Microsecond value (0-999)
        /// - Throws: `Microsecond.Error` if value is not 0-999
        public init(_ value: Int) throws {
            guard (0...999).contains(value) else {
                throw Error.invalidMicrosecond(value)
            }
            self.value = value
        }
    }
}

// MARK: - Error

extension Time.Microsecond {
    /// Errors that can occur when creating a microsecond
    public enum Error: Swift.Error, Sendable, Equatable {
        /// Microsecond must be 0-999
        case invalidMicrosecond(Int)
    }
}

// MARK: - Unchecked Initialization

extension Time.Microsecond {
    /// Create a microsecond without validation (internal use only)
    ///
    /// - Warning: Only use when value is known to be valid (0-999)
    internal init(unchecked value: Int) {
        self.value = value
    }
}

// MARK: - Comparable

extension Time.Microsecond {
    public static func < (lhs: Time.Microsecond, rhs: Time.Microsecond) -> Bool {
        lhs.value < rhs.value
    }
}

// MARK: - Constants

extension Time.Microsecond {
    /// Zero microseconds
    public static let zero = Time.Microsecond(unchecked: 0)
}
