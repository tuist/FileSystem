// Sign.swift
// Three-valued sign classification.

/// Three-valued sign: positive, negative, or zero.
///
/// Unlike `Direction` (which is binary), `Sign` includes zero as a distinct case,
/// making it suitable for complete numeric classification.
///
/// ## Mathematical Properties
///
/// - Forms a monoid under multiplication with identity `positive`
/// - `zero` is absorbing: zero × anything = zero
/// - Negation swaps positive/negative, preserves zero
///
/// ## Tagged Values
///
/// Use `Sign.Value<T>` to pair a value with its sign:
///
/// ```swift
/// let delta: Sign.Value<Double> = .init(tag: .negative, value: 3.14)
/// ```
public enum Sign: Sendable, Hashable, Codable, CaseIterable {
    /// Greater than zero.
    case positive

    /// Less than zero.
    case negative

    /// Equal to zero.
    case zero
}

// MARK: - Negation

extension Sign {
    /// The negated sign.
    @inlinable
    public var negated: Sign {
        switch self {
        case .positive: return .negative
        case .negative: return .positive
        case .zero: return .zero
        }
    }

    /// Returns the negated sign.
    @inlinable
    public static prefix func - (value: Sign) -> Sign {
        value.negated
    }
}

// MARK: - Multiplication

extension Sign {
    /// The sign resulting from multiplying two signed values.
    @inlinable
    public func multiplying(_ other: Sign) -> Sign {
        switch (self, other) {
        case (.zero, _), (_, .zero): return .zero
        case (.positive, .positive), (.negative, .negative): return .positive
        case (.positive, .negative), (.negative, .positive): return .negative
        }
    }
}

// MARK: - Numeric Detection

extension Sign {
    /// Determines the sign of a comparable value.
    @inlinable
    public init<T: Comparable & AdditiveArithmetic>(_ value: T) {
        if value > .zero {
            self = .positive
        } else if value < .zero {
            self = .negative
        } else {
            self = .zero
        }
    }
}

// MARK: - Tagged Value

extension Sign {
    /// A value paired with its sign.
    public typealias Value<Payload> = Tagged<Sign, Payload>
}
