// Rotation.swift
// An N-dimensional rotation (element of SO(n), dimensionless).

public import Angle
public import Geometry

/// An N-dimensional rotation.
///
/// Rotations are dimensionless - they represent an angular displacement
/// independent of any coordinate system's units. An element of SO(n),
/// the special orthogonal group.
///
/// Internally stored as an orthogonal matrix with determinant +1.
/// For 2D, convenience constructors accept an angle directly.
/// For 3D, quaternion or axis-angle representations can be used.
///
/// ## Example
///
/// ```swift
/// let rotation2D = Rotation<2>(angle: .pi / 4)  // 45° rotation
/// let matrix = rotation2D.matrix  // Get the 2×2 rotation matrix
/// ```
public struct Rotation<let N: Int>: Sendable {
    /// The rotation matrix (orthogonal, determinant = +1)
    public var matrix: Linear<N>

    /// Create a rotation from an orthogonal matrix
    ///
    /// - Precondition: The matrix should be orthogonal with determinant +1.
    ///   This is not validated for performance reasons.
    @inlinable
    public init(matrix: Linear<N>) {
        self.matrix = matrix
    }
}

// MARK: - Equatable (2D)
// Rotation uses Linear<N> which has manual conformances for N == 2

extension Rotation: Equatable where N == 2 {
    @inlinable
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.matrix == rhs.matrix
    }
}

// MARK: - Hashable (2D)

extension Rotation: Hashable where N == 2 {
    @inlinable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(matrix)
    }
}

// MARK: - Codable (2D)

extension Rotation: Codable where N == 2 {
    private enum CodingKeys: String, CodingKey {
        case matrix
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let matrix = try container.decode(Linear<2>.self, forKey: .matrix)
        self.init(matrix: matrix)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(matrix, forKey: .matrix)
    }
}

// MARK: - Identity

extension Rotation {
    /// The identity rotation (no rotation)
    @inlinable
    public static var identity: Self {
        Self(matrix: .identity)
    }
}

// MARK: - 2D Rotation

extension Rotation where N == 2 {
    /// The rotation angle
    ///
    /// For a 2D rotation matrix:
    /// ```
    /// | cos(θ)  -sin(θ) |
    /// | sin(θ)   cos(θ) |
    /// ```
    @inlinable
    public var angle: Radian {
        get { matrix.rotationAngle }
        set { self = Self(angle: newValue) }
    }

    /// Create a 2D rotation from an angle
    @inlinable
    public init(angle: Radian) {
        let c = angle.cos
        let s = angle.sin
        self.init(matrix: Linear(a: c, b: -s, c: s, d: c))
    }

    /// Create a 2D rotation from an angle in degrees
    @inlinable
    public init(degrees: Degree) {
        self.init(angle: degrees.radians)
    }

    /// Create a 2D rotation from cos and sin values
    @inlinable
    public init(cos: Double, sin: Double) {
        self.init(matrix: Linear(a: cos, b: -sin, c: sin, d: cos))
    }
}

// MARK: - Composition

extension Rotation {
    /// Compose two rotations
    ///
    /// The resulting rotation applies `other` first, then `self`.
    @inlinable
    public func concatenating(_ other: Self) -> Self where N == 2 {
        Self(matrix: matrix.concatenating(other.matrix))
    }
}

extension Rotation where N == 2 {
    /// The inverse rotation
    ///
    /// For orthogonal matrices, the inverse equals the transpose.
    @inlinable
    public var inverted: Self {
        // For 2D: transpose is simple
        Self(
            matrix: Linear(
                a: matrix.a,
                b: matrix.c,  // swapped
                c: matrix.b,  // swapped
                d: matrix.d
            )
        )
    }
}

// MARK: - 2D Convenience Operations

extension Rotation where N == 2 {
    /// Rotate by an additional angle
    @inlinable
    public func rotated(by angle: Radian) -> Self {
        concatenating(Self(angle: angle))
    }

    /// Rotate by an additional angle in degrees
    @inlinable
    public func rotated(by degrees: Degree) -> Self {
        rotated(by: degrees.radians)
    }
}

// MARK: - Common 2D Rotations

extension Rotation where N == 2 {
    /// 90° counter-clockwise rotation
    public static var quarterTurn: Self {
        Self(angle: .halfPi)
    }

    /// 180° rotation
    public static var halfTurn: Self {
        Self(angle: .pi)
    }

    /// 90° clockwise rotation
    public static var quarterTurnClockwise: Self {
        Self(angle: -.halfPi)
    }
}
