// Time.Millisecond.swift
// Time
//
// Millisecond representation as a refinement type

extension Time {
    /// A millisecond (0-999)
    ///
    /// This is a refinement type - an integer constrained to the valid range.
    /// Represents 10^-3 seconds (thousandths of a second).
    public struct Millisecond: Sendable, Equatable, Hashable, Comparable {
        /// The millisecond value (0-999)
        public let value: Int

        /// Create a millisecond with validation
        ///
        /// - Parameter value: Millisecond value (0-999)
        /// - Throws: `Millisecond.Error` if value is not 0-999
        public init(_ value: Int) throws {
            guard (0...999).contains(value) else {
                throw Error.invalidMillisecond(value)
            }
            self.value = value
        }
    }
}

// MARK: - Error

extension Time.Millisecond {
    /// Errors that can occur when creating a millisecond
    public enum Error: Swift.Error, Sendable, Equatable {
        /// Millisecond must be 0-999
        case invalidMillisecond(Int)
    }
}

// MARK: - Unchecked Initialization

extension Time.Millisecond {
    /// Create a millisecond without validation (internal use only)
    ///
    /// - Warning: Only use when value is known to be valid (0-999)
    internal init(unchecked value: Int) {
        self.value = value
    }
}

// MARK: - Comparable

extension Time.Millisecond {
    public static func < (lhs: Time.Millisecond, rhs: Time.Millisecond) -> Bool {
        lhs.value < rhs.value
    }
}

// MARK: - Constants

extension Time.Millisecond {
    /// Zero milliseconds
    public static let zero = Time.Millisecond(unchecked: 0)
}
