// Curvature.swift
// Curve bending direction.

public import Algebra

/// Curvature direction: convex or concave.
///
/// Describes which way a curve bends relative to a reference.
///
/// ## Convention
///
/// - Convex: curves outward (like the outside of a circle)
/// - Concave: curves inward (like the inside of a bowl)
///
/// ## Mathematical Properties
///
/// - Related to second derivative sign
/// - Forms Z₂ group under reflection
///
/// ## Tagged Values
///
/// Use `Curvature.Value<T>` to pair a curvature magnitude with its sign:
///
/// ```swift
/// let curve: Curvature.Value<Double> = .init(tag: .convex, value: 0.5)
/// ```
public enum Curvature: Sendable, Hashable, Codable, CaseIterable {
    /// Curves outward (positive curvature in standard convention).
    case convex

    /// Curves inward (negative curvature in standard convention).
    case concave
}

// MARK: - Opposite

extension Curvature {
    /// The opposite curvature.
    @inlinable
    public var opposite: Curvature {
        switch self {
        case .convex: return .concave
        case .concave: return .convex
        }
    }

    /// Returns the opposite curvature.
    @inlinable
    public static prefix func ! (value: Curvature) -> Curvature {
        value.opposite
    }
}

// MARK: - Tagged Value

extension Curvature {
    /// A value paired with its curvature direction.
    public typealias Value<Payload> = Tagged<Curvature, Payload>
}
