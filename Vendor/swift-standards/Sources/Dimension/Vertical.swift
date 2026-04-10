// Vertical.swift
// Vertical (Y) axis orientation and oriented values.

/// Vertical (Y) axis orientation.
///
/// `Vertical` is an enum representing pure Y-axis orientation, with a nested
/// `Value` struct for oriented magnitudes.
///
/// ## Pure Orientation
///
/// Use `Vertical` directly for coordinate system conventions:
///
/// ```swift
/// let v: Vertical = .upward
/// switch v {
/// case .upward: print("Y increases up")
/// case .downward: print("Y increases down")
/// }
/// ```
///
/// ## Coordinate System Conventions
///
/// - **Upward** (standard Cartesian, PDF): Lower Y values at bottom
/// - **Downward** (screen coordinates, CSS): Lower Y values at top
///
/// ## Oriented Values
///
/// Use `Vertical.Value<Scalar>` for values with explicit direction:
///
/// ```swift
/// let offset = Vertical.Value(direction: .upward, value: 10.0)
/// ```
public enum Vertical: Sendable, Hashable, Codable {
    /// Y axis increases upward (standard Cartesian convention).
    case upward

    /// Y axis increases downward (screen coordinate convention).
    case downward
}

// MARK: - Orientation Conformance

extension Vertical: Orientation {
    /// The underlying canonical direction.
    @inlinable
    public var direction: Direction {
        switch self {
        case .upward: return .positive
        case .downward: return .negative
        }
    }

    /// Creates a vertical orientation from a canonical direction.
    @inlinable
    public init(direction: Direction) {
        switch direction {
        case .positive: self = .upward
        case .negative: self = .downward
        }
    }

    /// The opposite orientation.
    @inlinable
    public var opposite: Vertical {
        switch self {
        case .upward: return .downward
        case .downward: return .upward
        }
    }

    /// All cases.
    public static let allCases: [Vertical] = [.upward, .downward]
}

// MARK: - Pattern Matching Support

extension Vertical {
    /// Whether this is upward orientation.
    @inlinable
    public var isUpward: Bool { self == .upward }

    /// Whether this is downward orientation.
    @inlinable
    public var isDownward: Bool { self == .downward }
}

// MARK: - CustomStringConvertible

extension Vertical: CustomStringConvertible {
    public var description: String {
        switch self {
        case .upward: return "upward"
        case .downward: return "downward"
        }
    }
}
