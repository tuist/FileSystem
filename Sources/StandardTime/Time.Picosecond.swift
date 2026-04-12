// Time.Picosecond.swift
// Time
//
// Picosecond representation as a refinement type

extension Time {
    /// A picosecond (0-999)
    ///
    /// This is a refinement type - an integer constrained to the valid range.
    /// Represents 10^-12 seconds (trillionths of a second).
    public struct Picosecond: Sendable, Equatable, Hashable, Comparable {
        /// The picosecond value (0-999)
        public let value: Int

        /// Create a picosecond with validation
        ///
        /// - Parameter value: Picosecond value (0-999)
        /// - Throws: `Picosecond.Error` if value is not 0-999
        public init(_ value: Int) throws {
            guard (0...999).contains(value) else {
                throw Error.invalidPicosecond(value)
            }
            self.value = value
        }
    }
}

// MARK: - Error

extension Time.Picosecond {
    /// Errors that can occur when creating a picosecond
    public enum Error: Swift.Error, Sendable, Equatable {
        /// Picosecond must be 0-999
        case invalidPicosecond(Int)
    }
}

// MARK: - Unchecked Initialization

extension Time.Picosecond {
    /// Create a picosecond without validation (internal use only)
    ///
    /// - Warning: Only use when value is known to be valid (0-999)
    internal init(unchecked value: Int) {
        self.value = value
    }
}

// MARK: - Comparable

extension Time.Picosecond {
    public static func < (lhs: Time.Picosecond, rhs: Time.Picosecond) -> Bool {
        lhs.value < rhs.value
    }
}

extension Time.Picosecond {
    /// Zero nanoseconds
    public static let zero = Time.Picosecond(unchecked: 0)
}
