// Time.Attosecond.swift
// Time
//
// Attosecond representation as a refinement type

extension Time {
    /// An attosecond (0-999)
    ///
    /// This is a refinement type - an integer constrained to the valid range.
    /// Represents 10^-18 seconds (quintillionths of a second).
    public struct Attosecond: Sendable, Equatable, Hashable, Comparable {
        /// The attosecond value (0-999)
        public let value: Int

        /// Create an attosecond with validation
        ///
        /// - Parameter value: Attosecond value (0-999)
        /// - Throws: `Attosecond.Error` if value is not 0-999
        public init(_ value: Int) throws {
            guard (0...999).contains(value) else {
                throw Error.invalidAttosecond(value)
            }
            self.value = value
        }
    }
}

// MARK: - Error

extension Time.Attosecond {
    /// Errors that can occur when creating an attosecond
    public enum Error: Swift.Error, Sendable, Equatable {
        /// Attosecond must be 0-999
        case invalidAttosecond(Int)
    }
}

// MARK: - Unchecked Initialization

extension Time.Attosecond {
    /// Create an attosecond without validation (internal use only)
    ///
    /// - Warning: Only use when value is known to be valid (0-999)
    internal init(unchecked value: Int) {
        self.value = value
    }
}

// MARK: - Comparable

extension Time.Attosecond {
    public static func < (lhs: Time.Attosecond, rhs: Time.Attosecond) -> Bool {
        lhs.value < rhs.value
    }
}

// MARK: - Constants

extension Time.Attosecond {
    /// Zero attoseconds
    public static let zero = Time.Attosecond(unchecked: 0)
}
