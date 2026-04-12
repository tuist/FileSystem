// Time.Second.swift
// Time
//
// Second representation as a refinement type

extension Time {
    /// A second in a minute (0-60, allowing leap second)
    ///
    /// This is a refinement type - an integer constrained to the valid range.
    /// The range is 0-60 to accommodate leap seconds (60th second).
    public struct Second: Sendable, Equatable, Hashable, Comparable {
        /// The second value (0-60)
        public let value: Int

        /// Create a second with validation
        ///
        /// - Parameter value: Second value (0-60, allowing leap second)
        /// - Throws: `Second.Error` if value is not 0-60
        public init(_ value: Int) throws {
            guard (0...60).contains(value) else {
                throw Error.invalidSecond(value)
            }
            self.value = value
        }
    }
}

// MARK: - Error

extension Time.Second {
    /// Errors that can occur when creating a second
    public enum Error: Swift.Error, Sendable, Equatable {
        /// Second must be 0-60 (allowing leap second)
        case invalidSecond(Int)
    }
}

// MARK: - Unchecked Initialization

extension Time.Second {
    /// Create a second without validation (internal use only)
    ///
    /// - Warning: Only use when value is known to be valid (0-60)
    internal init(unchecked value: Int) {
        self.value = value
    }
}

// MARK: - Comparable

extension Time.Second {
    public static func < (lhs: Time.Second, rhs: Time.Second) -> Bool {
        lhs.value < rhs.value
    }
}

extension Time.Second {
    /// Zero nanoseconds
    public static let zero = Time.Second(unchecked: 0)
}
