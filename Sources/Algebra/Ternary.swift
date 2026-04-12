// Ternary.swift
// Balanced ternary digit (-1, 0, +1).

/// A balanced ternary digit: negative, zero, or positive.
///
/// Used in balanced ternary numeral systems where digits are -1, 0, +1.
/// Also known as a "trit" (ternary digit).
///
/// ## Mathematical Properties
///
/// - More symmetric than binary: negation is simple sign flip
/// - No separate sign bit needed in balanced ternary
/// - Arithmetic operations have natural carry/borrow behavior
///
/// ## Tagged Values
///
/// Use `Ternary.Value<T>` to pair a value with a ternary digit:
///
/// ```swift
/// let coefficient: Ternary.Value<Double> = .init(tag: .positive, value: 1.0)
/// ```
public enum Ternary: Int, Sendable, Hashable, Codable, CaseIterable {
    /// Negative one (-1).
    case negative = -1

    /// Zero (0).
    case zero = 0

    /// Positive one (+1).
    case positive = 1
}

// MARK: - Negation

extension Ternary {
    /// The negated ternary value.
    @inlinable
    public var negated: Ternary {
        switch self {
        case .negative: return .positive
        case .zero: return .zero
        case .positive: return .negative
        }
    }

    /// Returns the negated value.
    @inlinable
    public static prefix func - (value: Ternary) -> Ternary {
        value.negated
    }
}

// MARK: - Arithmetic

extension Ternary {
    /// The integer value (-1, 0, or +1).
    @inlinable
    public var intValue: Int { rawValue }

    /// Multiplies two ternary values.
    @inlinable
    public func multiplying(_ other: Ternary) -> Ternary {
        Ternary(rawValue: self.rawValue * other.rawValue) ?? .zero
    }
}

// MARK: - From Sign

extension Ternary {
    /// Creates a ternary value from a sign.
    @inlinable
    public init(_ sign: Sign) {
        switch sign {
        case .positive: self = .positive
        case .negative: self = .negative
        case .zero: self = .zero
        }
    }
}

// MARK: - Tagged Value

extension Ternary {
    /// A value paired with a ternary digit.
    public typealias Value<Payload> = Tagged<Ternary, Payload>
}
