// Winding.swift
// Rotational direction around an axis.

public import Algebra

/// Rotational winding direction: clockwise or counterclockwise.
///
/// Describes the direction of rotation around an axis, commonly used
/// in geometry, graphics, and physics.
///
/// ## Convention
///
/// The interpretation depends on viewing direction:
/// - In 2D: looking at the XY plane from +Z
/// - In 3D: depends on the axis of rotation and handedness
///
/// ## Mathematical Properties
///
/// - Forms Z₂ group under reversal
/// - Related to sign of angular velocity
/// - Determines polygon vertex order (convexity tests)
///
/// ## Tagged Values
///
/// Use `Winding.Value<T>` to pair a rotation with its direction:
///
/// ```swift
/// let rotation: Winding.Value<Angle> = .init(tag: .counterclockwise, value: .degrees(45))
/// ```
public enum Winding: Sendable, Hashable, Codable, CaseIterable {
    /// Rotation in the direction of clock hands (negative angular direction).
    case clockwise

    /// Rotation opposite to clock hands (positive angular direction).
    case counterclockwise
}

// MARK: - Opposite

extension Winding {
    /// The opposite winding direction.
    @inlinable
    public var opposite: Winding {
        switch self {
        case .clockwise: return .counterclockwise
        case .counterclockwise: return .clockwise
        }
    }

    /// Returns the opposite winding direction.
    @inlinable
    public static prefix func ! (value: Winding) -> Winding {
        value.opposite
    }
}

// MARK: - Aliases

extension Winding {
    /// Alias for clockwise (CW).
    public static var cw: Winding { .clockwise }

    /// Alias for counterclockwise (CCW).
    public static var ccw: Winding { .counterclockwise }
}

// MARK: - Tagged Value

extension Winding {
    /// A value paired with its winding direction.
    public typealias Value<Payload> = Tagged<Winding, Payload>
}
