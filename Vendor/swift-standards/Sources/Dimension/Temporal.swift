// Temporal.swift
// Temporal (W/T) axis orientation and oriented values.

/// Temporal (W/T) axis orientation.
///
/// `Temporal` is an enum representing pure time-axis orientation, with a nested
/// `Value` struct for oriented magnitudes.
///
/// ## Pure Orientation
///
/// Use `Temporal` directly for time direction conventions:
///
/// ```swift
/// let t: Temporal = .future
/// switch t {
/// case .future: print("time flows forward")
/// case .past: print("time flows backward")
/// }
/// ```
///
/// ## Usage in Physics
///
/// In Minkowski spacetime, time is typically the fourth coordinate.
/// The choice of `.future` vs `.past` affects:
/// - Light cone orientation
/// - Causality direction
/// - Proper time calculations
///
/// ## Oriented Values
///
/// Use `Temporal.Value<Scalar>` for durations with explicit direction:
///
/// ```swift
/// let delta = Temporal.Value(direction: .future, value: 10.0)
/// ```
public enum Temporal: Sendable, Hashable, Codable {
    /// Time increases toward the future.
    case future

    /// Time increases toward the past.
    case past
}

// MARK: - Orientation Conformance

extension Temporal: Orientation {
    /// The underlying canonical direction.
    @inlinable
    public var direction: Direction {
        switch self {
        case .future: return .positive
        case .past: return .negative
        }
    }

    /// Creates a temporal orientation from a canonical direction.
    @inlinable
    public init(direction: Direction) {
        switch direction {
        case .positive: self = .future
        case .negative: self = .past
        }
    }

    /// The opposite orientation.
    @inlinable
    public var opposite: Temporal {
        switch self {
        case .future: return .past
        case .past: return .future
        }
    }

    /// All cases.
    public static let allCases: [Temporal] = [.future, .past]
}

// MARK: - Pattern Matching Support

extension Temporal {
    /// Whether this is future orientation.
    @inlinable
    public var isFuture: Bool { self == .future }

    /// Whether this is past orientation.
    @inlinable
    public var isPast: Bool { self == .past }
}

// MARK: - CustomStringConvertible

extension Temporal: CustomStringConvertible {
    public var description: String {
        switch self {
        case .future: return "future"
        case .past: return "past"
        }
    }
}
