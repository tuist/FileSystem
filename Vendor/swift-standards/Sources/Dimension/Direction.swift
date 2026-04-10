// Direction.swift
// The canonical binary orientation.

/// Direction along an axis (positive or negative).
///
/// `Direction` is the **canonical** orientation type - it represents pure
/// polarity without domain-specific interpretation. All other orientation
/// types (`Horizontal`, `Vertical`, `Depth`, `Temporal`) are isomorphic
/// to Direction and can convert to/from it.
///
/// ## Mathematical Background
///
/// Direction is isomorphic to:
/// - Z/2Z (integers mod 2)
/// - The multiplicative group {-1, +1}
/// - `Bool` (true/false)
/// - The finite set 2 = {0, 1}
///
/// It is the **initial algebra** (free model) of the `Orientation` theory.
///
/// ## Usage
///
/// ```swift
/// let direction: Direction = .positive
/// let reversed = !direction  // .negative
///
/// // Convert to domain-specific orientation:
/// let horizontal = Horizontal(direction: direction)  // .rightward
/// let vertical = Vertical(direction: direction)      // .upward
/// ```
public enum Direction: Sendable, Hashable, Codable {
    /// Positive direction (increasing coordinate values).
    case positive

    /// Negative direction (decreasing coordinate values).
    case negative
}

// MARK: - Orientation Conformance

extension Direction: Orientation {
    /// The opposite direction.
    @inlinable
    public var opposite: Direction {
        switch self {
        case .positive: return .negative
        case .negative: return .positive
        }
    }

    /// The canonical direction (self, since Direction is canonical).
    @inlinable
    public var direction: Direction { self }

    /// Creates a direction (identity, since Direction is canonical).
    @inlinable
    public init(direction: Direction) { self = direction }

    /// All cases.
    public static let allCases: [Direction] = [.positive, .negative]
}

// MARK: - Sign

extension Direction {
    /// The sign multiplier for this direction.
    ///
    /// - `.positive` returns `1`
    /// - `.negative` returns `-1`
    @inlinable
    public var sign: Int {
        switch self {
        case .positive: return 1
        case .negative: return -1
        }
    }

    /// Creates a direction from a sign.
    ///
    /// - Parameter sign: A positive or negative number
    /// - Returns: `.positive` if sign >= 0, `.negative` otherwise
    @inlinable
    public init(sign: Int) {
        self = sign >= 0 ? .positive : .negative
    }
}
