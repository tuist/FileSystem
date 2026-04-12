// Time.Femtosecond.swift
// Time
//
// Femtosecond representation as a refinement type

extension Time {
    /// A femtosecond (0-999)
    ///
    /// This is a refinement type - an integer constrained to the valid range.
    /// Represents 10^-15 seconds (quadrillionths of a second).
    public struct Femtosecond: Sendable, Equatable, Hashable, Comparable {
        /// The femtosecond value (0-999)
        public let value: Int

        /// Create a femtosecond with validation
        ///
        /// - Parameter value: Femtosecond value (0-999)
        /// - Throws: `Femtosecond.Error` if value is not 0-999
        public init(_ value: Int) throws {
            guard (0...999).contains(value) else {
                throw Error.invalidFemtosecond(value)
            }
            self.value = value
        }
    }
}

// MARK: - Error

extension Time.Femtosecond {
    /// Errors that can occur when creating a femtosecond
    public enum Error: Swift.Error, Sendable, Equatable {
        /// Femtosecond must be 0-999
        case invalidFemtosecond(Int)
    }
}

// MARK: - Unchecked Initialization

extension Time.Femtosecond {
    /// Create a femtosecond without validation (internal use only)
    ///
    /// - Warning: Only use when value is known to be valid (0-999)
    internal init(unchecked value: Int) {
        self.value = value
    }
}

// MARK: - Comparable

extension Time.Femtosecond {
    public static func < (lhs: Time.Femtosecond, rhs: Time.Femtosecond) -> Bool {
        lhs.value < rhs.value
    }
}

// MARK: - Constants

extension Time.Femtosecond {
    /// Zero femtoseconds
    public static let zero = Time.Femtosecond(unchecked: 0)
}
