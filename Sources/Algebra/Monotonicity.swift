// Monotonicity.swift
// Function monotonic behavior.

/// Monotonic behavior: increasing, decreasing, or constant.
///
/// Describes how a function's output changes relative to its input.
///
/// ## Mathematical Properties
///
/// - Monotone functions preserve or reverse order
/// - Composition of monotonic functions is monotonic
/// - Constant is identity for this classification
///
/// ## Tagged Values
///
/// Use `Monotonicity.Value<T>` to pair a function with its behavior:
///
/// ```swift
/// let trend: Monotonicity.Value<Slope> = .init(tag: .increasing, value: 0.5)
/// ```
public enum Monotonicity: Sendable, Hashable, Codable, CaseIterable {
    /// Output increases as input increases.
    case increasing

    /// Output decreases as input increases.
    case decreasing

    /// Output remains the same regardless of input.
    case constant
}

// MARK: - Reversal

extension Monotonicity {
    /// The reversed monotonicity (as if input were negated).
    @inlinable
    public var reversed: Monotonicity {
        switch self {
        case .increasing: return .decreasing
        case .decreasing: return .increasing
        case .constant: return .constant
        }
    }

    /// Returns the reversed monotonicity.
    @inlinable
    public static prefix func ! (value: Monotonicity) -> Monotonicity {
        value.reversed
    }
}

// MARK: - Composition

extension Monotonicity {
    /// The monotonicity of composing two monotonic functions.
    @inlinable
    public func composing(_ other: Monotonicity) -> Monotonicity {
        switch (self, other) {
        case (.constant, _), (_, .constant): return .constant
        case (.increasing, .increasing), (.decreasing, .decreasing): return .increasing
        case (.increasing, .decreasing), (.decreasing, .increasing): return .decreasing
        }
    }
}

// MARK: - Properties

extension Monotonicity {
    /// True if strictly increasing.
    @inlinable
    public var isIncreasing: Bool { self == .increasing }

    /// True if strictly decreasing.
    @inlinable
    public var isDecreasing: Bool { self == .decreasing }

    /// True if constant.
    @inlinable
    public var isConstant: Bool { self == .constant }

    /// True if non-decreasing (increasing or constant).
    @inlinable
    public var isNonDecreasing: Bool { self != .decreasing }

    /// True if non-increasing (decreasing or constant).
    @inlinable
    public var isNonIncreasing: Bool { self != .increasing }
}

// MARK: - Tagged Value

extension Monotonicity {
    /// A value paired with its monotonicity.
    public typealias Value<Payload> = Tagged<Monotonicity, Payload>
}
