// Boundary.swift
// Interval endpoint inclusivity.

/// Inclusivity of an interval endpoint: open or closed.
///
/// Determines whether an endpoint value is included in the interval.
///
/// ## Convention
///
/// - Closed: endpoint included (≤ or ≥)
/// - Open: endpoint excluded (< or >)
///
/// ## Mathematical Properties
///
/// - Forms Z₂ group under toggle
/// - Combines with Bound for full endpoint specification
///
/// ## Tagged Values
///
/// Use `Boundary.Value<T>` to pair a value with its inclusivity:
///
/// ```swift
/// let endpoint: Boundary.Value<Double> = .init(tag: .closed, value: 1.0)
/// ```
public enum Boundary: Sendable, Hashable, Codable, CaseIterable {
    /// Endpoint is included (≤ or ≥).
    case closed

    /// Endpoint is excluded (< or >).
    case open
}

// MARK: - Opposite

extension Boundary {
    /// The opposite boundary type.
    @inlinable
    public var opposite: Boundary {
        switch self {
        case .closed: return .open
        case .open: return .closed
        }
    }

    /// Returns the opposite boundary type.
    @inlinable
    public static prefix func ! (value: Boundary) -> Boundary {
        value.opposite
    }

    /// Alias for opposite.
    @inlinable
    public var toggled: Boundary { opposite }
}

// MARK: - Properties

extension Boundary {
    /// True if the boundary is inclusive.
    @inlinable
    public var isInclusive: Bool { self == .closed }

    /// True if the boundary is exclusive.
    @inlinable
    public var isExclusive: Bool { self == .open }
}

// MARK: - Tagged Value

extension Boundary {
    /// A value paired with its boundary type.
    public typealias Value<Payload> = Tagged<Boundary, Payload>
}
