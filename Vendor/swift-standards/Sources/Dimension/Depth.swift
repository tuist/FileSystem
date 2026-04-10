// Depth.swift
// Depth (Z) axis orientation and oriented values.

/// Depth (Z) axis orientation.
///
/// `Depth` is an enum representing pure Z-axis orientation, with a nested
/// `Value` struct for oriented magnitudes.
///
/// ## Pure Orientation
///
/// Use `Depth` directly for coordinate system conventions:
///
/// ```swift
/// let d: Depth = .forward
/// switch d {
/// case .forward: print("Z into screen")
/// case .backward: print("Z out of screen")
/// }
/// ```
///
/// ## Coordinate System Conventions
///
/// - **Forward** (left-handed, DirectX, Metal): Z into the screen
/// - **Backward** (right-handed, OpenGL, mathematics): Z out of screen
///
/// ## Oriented Values
///
/// Use `Depth.Value<Scalar>` for values with explicit direction:
///
/// ```swift
/// let offset = Depth.Value(direction: .forward, value: 10.0)
/// ```
public enum Depth: Sendable, Hashable, Codable {
    /// Z axis increases away from viewer (into the screen).
    case forward

    /// Z axis increases toward viewer (out of the screen).
    case backward
}

// MARK: - Orientation Conformance

extension Depth: Orientation {
    /// The underlying canonical direction.
    @inlinable
    public var direction: Direction {
        switch self {
        case .forward: return .positive
        case .backward: return .negative
        }
    }

    /// Creates a depth orientation from a canonical direction.
    @inlinable
    public init(direction: Direction) {
        switch direction {
        case .positive: self = .forward
        case .negative: self = .backward
        }
    }

    /// The opposite orientation.
    @inlinable
    public var opposite: Depth {
        switch self {
        case .forward: return .backward
        case .backward: return .forward
        }
    }

    /// All cases.
    public static let allCases: [Depth] = [.forward, .backward]
}

// MARK: - Pattern Matching Support

extension Depth {
    /// Whether this is forward orientation.
    @inlinable
    public var isForward: Bool { self == .forward }

    /// Whether this is backward orientation.
    @inlinable
    public var isBackward: Bool { self == .backward }
}

// MARK: - CustomStringConvertible

extension Depth: CustomStringConvertible {
    public var description: String {
        switch self {
        case .forward: return "forward"
        case .backward: return "backward"
        }
    }
}
