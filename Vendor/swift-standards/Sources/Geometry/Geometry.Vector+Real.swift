// Vector+Real.swift
// Angle and rotation operations for 2D vectors with Real scalar types.

public import Angle
public import RealModule

// MARK: - Angle from Vector

extension Geometry.Vector where N == 2, Scalar: Real & BinaryFloatingPoint {
    /// The angle of this vector from the positive x-axis
    @inlinable
    public var angle: Radian {
        .atan2(y: Double(dy.value), x: Double(dx.value))
    }
}

// MARK: - Scalar Vector at Angle

extension Geometry.Vector where N == 2, Scalar: Real & BinaryFloatingPoint {
    /// Create a unit vector at the given angle
    @inlinable
    public static func unit(at angle: Radian) -> Self {
        Self(dx: Geometry.X(Scalar(angle.cos)), dy: Geometry.Y(Scalar(angle.sin)))
    }

    /// Create a vector with given length at the given angle (polar coordinates)
    @inlinable
    public static func polar(length: Scalar, angle: Radian) -> Self {
        Self(
            dx: Geometry.X(length * Scalar(angle.cos)),
            dy: Geometry.Y(length * Scalar(angle.sin))
        )
    }
}

// MARK: - Angle Between Vectors

extension Geometry.Vector where N == 2, Scalar: Real & BinaryFloatingPoint {
    /// The angle between this vector and another (always positive).
    ///
    /// Returns the unsigned angle in [0, π].
    @inlinable
    public func angle(to other: Self) -> Radian {
        let dotProduct = self.dot(other)
        let magnitudes = self.length * other.length
        guard magnitudes > 0 else { return .zero }
        return .acos(Double(dotProduct / magnitudes))
    }

    /// The signed angle from this vector to another.
    ///
    /// Returns the angle in (-π, π], positive for counter-clockwise rotation.
    @inlinable
    public func signedAngle(to other: Self) -> Radian {
        let cross = self.cross(other)
        let dot = self.dot(other)
        return .atan2(y: Double(cross), x: Double(dot))
    }
}

// MARK: - Rotation

extension Geometry.Vector where N == 2, Scalar: Real & BinaryFloatingPoint {
    /// Rotate this vector by an angle
    @inlinable
    public func rotated(by angle: Radian) -> Self {
        let c = Scalar(angle.cos)
        let s = Scalar(angle.sin)
        let x = dx.value
        let y = dy.value
        return Self(
            dx: Geometry.X(x * c - y * s),
            dy: Geometry.Y(x * s + y * c)
        )
    }

    /// Rotate this vector by an angle in degrees
    @inlinable
    public func rotated(by angle: Degree) -> Self {
        rotated(by: angle.radians)
    }
}
