// Bound.swift
// Interval endpoint position.

/// Position of an interval endpoint: lower or upper.
///
/// Identifies which end of an interval a value represents.
///
/// ## Mathematical Properties
///
/// - Forms Z₂ group under swap
/// - Related to min/max operations
///
/// ## Tagged Values
///
/// Use `Bound.Value<T>` to pair a value with its bound position:
///
/// ```swift
/// let limit: Bound.Value<Double> = .init(tag: .lower, value: 0.0)
/// ```
public enum Bound: Sendable, Hashable, Codable, CaseIterable {
    /// Lower bound (minimum, left endpoint).
    case lower

    /// Upper bound (maximum, right endpoint).
    case upper
}

// MARK: - Opposite

extension Bound {
    /// The opposite bound.
    @inlinable
    public var opposite: Bound {
        switch self {
        case .lower: return .upper
        case .upper: return .lower
        }
    }

    /// Returns the opposite bound.
    @inlinable
    public static prefix func ! (value: Bound) -> Bound {
        value.opposite
    }
}

// MARK: - Aliases

extension Bound {
    /// Alias for lower bound.
    public static var min: Bound { .lower }

    /// Alias for upper bound.
    public static var max: Bound { .upper }

    /// Alias for lower (left endpoint).
    public static var left: Bound { .lower }

    /// Alias for upper (right endpoint).
    public static var right: Bound { .upper }
}

// MARK: - Tagged Value

extension Bound {
    /// A value paired with its bound position.
    public typealias Value<Payload> = Tagged<Bound, Payload>
}
