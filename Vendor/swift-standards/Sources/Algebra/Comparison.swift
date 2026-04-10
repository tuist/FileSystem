// Comparison.swift
// Three-way comparison result.

/// Result of a three-way comparison: less, equal, or greater.
///
/// Represents the outcome of comparing two ordered values.
///
/// ## Mathematical Properties
///
/// - Antisymmetric: if a < b then b > a
/// - `reversed` swaps less/greater, preserves equal
/// - Corresponds to the signum of (a - b)
///
/// ## Tagged Values
///
/// Use `Comparison.Value<T>` to pair a value with a comparison result:
///
/// ```swift
/// let delta: Comparison.Value<Int> = .init(tag: .less, value: -5)
/// ```
public enum Comparison: Sendable, Hashable, Codable, CaseIterable {
    /// First value is less than second.
    case less

    /// Values are equal.
    case equal

    /// First value is greater than second.
    case greater
}

// MARK: - Reversal

extension Comparison {
    /// The reversed comparison (as if operands were swapped).
    @inlinable
    public var reversed: Comparison {
        switch self {
        case .less: return .greater
        case .equal: return .equal
        case .greater: return .less
        }
    }

    /// Returns the reversed comparison.
    @inlinable
    public static prefix func ! (value: Comparison) -> Comparison {
        value.reversed
    }
}

// MARK: - From Comparable

extension Comparison {
    /// Compares two values and returns the result.
    @inlinable
    public init<T: Comparable>(_ lhs: T, _ rhs: T) {
        if lhs < rhs {
            self = .less
        } else if lhs > rhs {
            self = .greater
        } else {
            self = .equal
        }
    }
}

// MARK: - Boolean Properties

extension Comparison {
    /// True if the comparison is less than.
    @inlinable
    public var isLess: Bool { self == .less }

    /// True if the comparison is equal.
    @inlinable
    public var isEqual: Bool { self == .equal }

    /// True if the comparison is greater than.
    @inlinable
    public var isGreater: Bool { self == .greater }

    /// True if the comparison is less than or equal.
    @inlinable
    public var isLessOrEqual: Bool { self != .greater }

    /// True if the comparison is greater than or equal.
    @inlinable
    public var isGreaterOrEqual: Bool { self != .less }
}

// MARK: - Tagged Value

extension Comparison {
    /// A value paired with a comparison result.
    public typealias Value<Payload> = Tagged<Comparison, Payload>
}
