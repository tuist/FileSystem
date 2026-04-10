// Chirality.swift
// Handedness (left or right).

public import Algebra

/// Handedness or chirality: left or right.
///
/// Describes asymmetry that distinguishes mirror images, used in:
/// - Coordinate system handedness (left/right-handed)
/// - Molecular chirality
/// - Screw thread direction
/// - Hand dominance
///
/// ## Mathematical Properties
///
/// - Forms Z₂ group under reflection
/// - Mirror operation swaps chirality
/// - Related to determinant sign of transformation matrices
///
/// ## Tagged Values
///
/// Use `Chirality.Value<T>` to pair a value with its handedness:
///
/// ```swift
/// let hand: Chirality.Value<Coordinate> = .init(tag: .right, value: coord)
/// ```
public enum Chirality: Sendable, Hashable, Codable, CaseIterable {
    /// Left-handed (sinistral).
    case left

    /// Right-handed (dextral).
    case right
}

// MARK: - Opposite

extension Chirality {
    /// The opposite chirality (mirror image).
    @inlinable
    public var opposite: Chirality {
        switch self {
        case .left: return .right
        case .right: return .left
        }
    }

    /// Returns the opposite chirality.
    @inlinable
    public static prefix func ! (value: Chirality) -> Chirality {
        value.opposite
    }

    /// Alias for opposite (mirror reflection swaps chirality).
    @inlinable
    public var mirrored: Chirality { opposite }
}

// MARK: - Coordinate System

extension Chirality {
    /// Standard right-handed coordinate system (OpenGL, mathematics).
    public static var standard: Chirality { .right }

    /// Left-handed coordinate system (DirectX, some CAD systems).
    public static var directX: Chirality { .left }
}

// MARK: - Tagged Value

extension Chirality {
    /// A value paired with its chirality.
    public typealias Value<Payload> = Tagged<Chirality, Payload>
}
