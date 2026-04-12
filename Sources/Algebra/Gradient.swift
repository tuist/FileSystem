// Gradient.swift
// Direction of change.

/// Direction of change: ascending or descending.
///
/// Binary classification of whether values are increasing or decreasing.
///
/// ## Mathematical Properties
///
/// - Forms Z₂ group under reversal
/// - Related to sign of first derivative
///
/// ## Tagged Values
///
/// Use `Gradient.Value<T>` to pair a slope with its direction:
///
/// ```swift
/// let slope: Gradient.Value<Double> = .init(tag: .ascending, value: 0.5)
/// ```
public enum Gradient: Sendable, Hashable, Codable, CaseIterable {
    /// Values are increasing (positive slope).
    case ascending

    /// Values are decreasing (negative slope).
    case descending
}

// MARK: - Opposite

extension Gradient {
    /// The opposite gradient direction.
    @inlinable
    public var opposite: Gradient {
        switch self {
        case .ascending: return .descending
        case .descending: return .ascending
        }
    }

    /// Returns the opposite gradient.
    @inlinable
    public static prefix func ! (value: Gradient) -> Gradient {
        value.opposite
    }
}

// MARK: - Aliases

extension Gradient {
    /// Alias for ascending.
    public static var rising: Gradient { .ascending }

    /// Alias for descending.
    public static var falling: Gradient { .descending }

    /// Alias for ascending.
    public static var up: Gradient { .ascending }

    /// Alias for descending.
    public static var down: Gradient { .descending }
}

// MARK: - Tagged Value

extension Gradient {
    /// A value paired with its gradient direction.
    public typealias Value<Payload> = Tagged<Gradient, Payload>
}
