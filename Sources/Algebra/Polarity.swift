// Polarity.swift
// Electric-style polarity.

/// Polarity: positive, negative, or neutral.
///
/// Three-valued classification commonly used for:
/// - Electric charge
/// - Magnetic poles
/// - Electrode designation
///
/// ## Mathematical Properties
///
/// - Similar to Sign but with domain-specific semantics
/// - Neutral is distinct from zero magnitude
/// - Opposite swaps positive/negative, preserves neutral
///
/// ## Tagged Values
///
/// Use `Polarity.Value<T>` to pair a magnitude with its polarity:
///
/// ```swift
/// let charge: Polarity.Value<Double> = .init(tag: .positive, value: 1.6e-19)
/// ```
public enum Polarity: Sendable, Hashable, Codable, CaseIterable {
    /// Positive polarity (anode, north-seeking).
    case positive

    /// Negative polarity (cathode, south-seeking).
    case negative

    /// Neutral (no polarity, uncharged).
    case neutral
}

// MARK: - Opposite

extension Polarity {
    /// The opposite polarity.
    @inlinable
    public var opposite: Polarity {
        switch self {
        case .positive: return .negative
        case .negative: return .positive
        case .neutral: return .neutral
        }
    }

    /// Returns the opposite polarity.
    @inlinable
    public static prefix func ! (value: Polarity) -> Polarity {
        value.opposite
    }
}

// MARK: - Properties

extension Polarity {
    /// True if charged (not neutral).
    @inlinable
    public var isCharged: Bool { self != .neutral }

    /// True if positive.
    @inlinable
    public var isPositive: Bool { self == .positive }

    /// True if negative.
    @inlinable
    public var isNegative: Bool { self == .negative }

    /// True if neutral.
    @inlinable
    public var isNeutral: Bool { self == .neutral }
}

// MARK: - Tagged Value

extension Polarity {
    /// A value paired with its polarity.
    public typealias Value<Payload> = Tagged<Polarity, Payload>
}
