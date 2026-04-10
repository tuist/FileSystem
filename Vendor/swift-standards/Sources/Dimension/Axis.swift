// Axis.swift
// A coordinate axis in N-dimensional space.

/// A coordinate axis in N-dimensional space.
///
/// An axis identifies a dimension of a coordinate system, independent of
/// its orientation or direction. The type is parameterized by the number
/// of dimensions N, providing compile-time safety for dimensional operations.
///
/// ## Mathematical Background
///
/// In linear algebra, an axis is simply a basis vector direction in a
/// coordinate system. For an N-dimensional space, there are exactly N axes,
/// indexed from 0 to N-1.
///
/// Common naming conventions:
/// - `primary` (axis 0): typically X, horizontal
/// - `secondary` (axis 1): typically Y, vertical
/// - `tertiary` (axis 2): typically Z, depth
/// - `quaternary` (axis 3): typically W, fourth dimension
///
/// ## Structure
///
/// - `Axis<N>`: The axis identity, parameterized by dimension count
/// - `Axis.Direction`: Direction along any axis (`.positive`, `.negative`)
/// - `Axis.Vertical`: Y-axis orientation convention (`.upward`, `.downward`)
/// - `Axis.Horizontal`: X-axis orientation convention (`.rightward`, `.leftward`)
///
/// ## Usage
///
/// ```swift
/// let axis2D: Axis<2> = .primary
/// let axis3D: Axis<3> = .tertiary
/// let perpendicular = Axis<2>.primary.perpendicular  // .secondary
///
/// // Iterate over all axes
/// for axis in Axis<3>.allCases { ... }
/// ```
public struct Axis<let N: Int>: Sendable, Hashable {
    /// The zero-based index of this axis (0 to N-1).
    public let rawValue: Int

    /// Create an axis from a raw index value.
    ///
    /// - Parameter rawValue: The axis index (must be 0 to N-1)
    /// - Returns: The axis, or nil if the index is out of bounds
    @inlinable
    public init?(_ rawValue: Int) {
        guard rawValue >= 0 && rawValue < N else { return nil }
        self.rawValue = rawValue
    }

    /// Create an axis from a raw value without bounds checking.
    @usableFromInline
    init(unchecked rawValue: Int) {
        self.rawValue = rawValue
    }
}

// MARK: - Codable

extension Axis: Codable {
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(Int.self)
        guard let axis = Self(value) else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Axis index \(value) out of bounds for \(N)-dimensional space"
                )
            )
        }
        self = axis
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

// MARK: - 1D

extension Axis where N == 1 {
    /// The first axis (index 0).
    @inlinable
    public static var primary: Self { Self(unchecked: 0) }
}

// MARK: - 2D

extension Axis where N == 2 {
    /// The first axis (index 0, typically X/horizontal).
    @inlinable
    public static var primary: Self { Self(unchecked: 0) }

    /// The second axis (index 1, typically Y/vertical).
    @inlinable
    public static var secondary: Self { Self(unchecked: 1) }

    /// The axis perpendicular to this one.
    ///
    /// In 2D, each axis has exactly one perpendicular axis:
    /// - `.primary.perpendicular` returns `.secondary`
    /// - `.secondary.perpendicular` returns `.primary`
    @inlinable
    public var perpendicular: Self {
        Self(unchecked: 1 - rawValue)
    }
}

// MARK: - 3D

extension Axis where N == 3 {
    /// The first axis (index 0, typically X/horizontal).
    @inlinable
    public static var primary: Self { Self(unchecked: 0) }

    /// The second axis (index 1, typically Y/vertical).
    @inlinable
    public static var secondary: Self { Self(unchecked: 1) }

    /// The third axis (index 2, typically Z/depth).
    @inlinable
    public static var tertiary: Self { Self(unchecked: 2) }
}

// MARK: - 4D

extension Axis where N == 4 {
    /// The first axis (index 0, typically X).
    @inlinable
    public static var primary: Self { Self(unchecked: 0) }

    /// The second axis (index 1, typically Y).
    @inlinable
    public static var secondary: Self { Self(unchecked: 1) }

    /// The third axis (index 2, typically Z).
    @inlinable
    public static var tertiary: Self { Self(unchecked: 2) }

    /// The fourth axis (index 3, typically W).
    @inlinable
    public static var quaternary: Self { Self(unchecked: 3) }
}
