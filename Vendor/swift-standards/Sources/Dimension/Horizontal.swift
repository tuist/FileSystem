// Horizontal.swift
// Horizontal (X) axis orientation and oriented values.

/// Horizontal (X) axis orientation.
///
/// `Horizontal` is an enum representing pure X-axis orientation, with a nested
/// `Value` struct for oriented magnitudes.
///
/// ## Pure Orientation
///
/// Use `Horizontal` directly for coordinate system conventions:
///
/// ```swift
/// let h: Horizontal = .rightward
/// switch h {
/// case .rightward: print("X increases right")
/// case .leftward: print("X increases left")
/// }
/// ```
///
/// ## Oriented Values
///
/// Use `Horizontal.Value<Scalar>` for values with explicit direction:
///
/// ```swift
/// let offset = Horizontal.Value(direction: .rightward, value: 10.0)
/// ```
public enum Horizontal: Sendable, Hashable, Codable {
    /// X axis increases rightward (standard convention).
    case rightward

    /// X axis increases leftward.
    case leftward
}

// MARK: - Orientation Conformance

extension Horizontal: Orientation {
    /// The underlying canonical direction.
    @inlinable
    public var direction: Direction {
        switch self {
        case .rightward: return .positive
        case .leftward: return .negative
        }
    }

    /// Creates a horizontal orientation from a canonical direction.
    @inlinable
    public init(direction: Direction) {
        switch direction {
        case .positive: self = .rightward
        case .negative: self = .leftward
        }
    }

    /// The opposite orientation.
    @inlinable
    public var opposite: Horizontal {
        switch self {
        case .rightward: return .leftward
        case .leftward: return .rightward
        }
    }

    /// All cases.
    public static let allCases: [Horizontal] = [.rightward, .leftward]
}

// MARK: - Pattern Matching Support

extension Horizontal {
    /// Whether this is rightward orientation.
    @inlinable
    public var isRightward: Bool { self == .rightward }

    /// Whether this is leftward orientation.
    @inlinable
    public var isLeftward: Bool { self == .leftward }
}

// MARK: - CustomStringConvertible

extension Horizontal: CustomStringConvertible {
    public var description: String {
        switch self {
        case .rightward: return "rightward"
        case .leftward: return "leftward"
        }
    }
}
