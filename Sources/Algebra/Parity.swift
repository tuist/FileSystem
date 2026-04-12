// Parity.swift
// Classification of integers by divisibility by 2.

/// Classification of integers as even or odd.
///
/// Parity partitions integers into two equivalence classes under modulo 2.
///
/// ## Mathematical Properties
///
/// - Forms Z₂ group under addition: even + even = even, odd + odd = even, etc.
/// - Multiplication: even × anything = even, odd × odd = odd
/// - `opposite` is identity for even, swaps for odd under certain operations
///
/// ## Tagged Values
///
/// Use `Parity.Value<T>` to pair a value with its known parity:
///
/// ```swift
/// let evenCount: Parity.Value<Int> = .init(tag: .even, value: 42)
/// ```
public enum Parity: Sendable, Hashable, Codable, CaseIterable {
    /// Divisible by 2 (remainder 0).
    case even

    /// Not divisible by 2 (remainder 1).
    case odd
}

// MARK: - Opposite

extension Parity {
    /// The opposite parity.
    @inlinable
    public var opposite: Parity {
        switch self {
        case .even: return .odd
        case .odd: return .even
        }
    }

    /// Returns the opposite parity.
    @inlinable
    public static prefix func ! (value: Parity) -> Parity {
        value.opposite
    }
}

// MARK: - Arithmetic Properties

extension Parity {
    /// The parity resulting from adding two values with known parities.
    @inlinable
    public func adding(_ other: Parity) -> Parity {
        switch (self, other) {
        case (.even, .even), (.odd, .odd): return .even
        case (.even, .odd), (.odd, .even): return .odd
        }
    }

    /// The parity resulting from multiplying two values with known parities.
    @inlinable
    public func multiplying(_ other: Parity) -> Parity {
        switch (self, other) {
        case (.odd, .odd): return .odd
        default: return .even
        }
    }
}

// MARK: - Integer Detection

extension Parity {
    /// Determines the parity of an integer.
    @inlinable
    public init<T: BinaryInteger>(_ value: T) {
        self = value.isMultiple(of: 2) ? .even : .odd
    }
}

// MARK: - Tagged Value

extension Parity {
    /// A value paired with its parity.
    public typealias Value<Payload> = Tagged<Parity, Payload>
}
