// Radian+Trigonometry.swift
// Trigonometric functions and constants for Radian.

public import RealModule

// MARK: - Trigonometric Functions

extension Radian {
    /// Sine of the angle
    @inlinable
    public var sin: Double { Double.sin(value) }

    /// Cosine of the angle
    @inlinable
    public var cos: Double { Double.cos(value) }

    /// Tangent of the angle
    @inlinable
    public var tan: Double { Double.tan(value) }
}

// MARK: - Inverse Trigonometric Functions

extension Radian {
    /// Create a radian angle from its sine value
    @inlinable
    public static func asin(_ value: Double) -> Self {
        Self(Double.asin(value))
    }

    /// Create a radian angle from its cosine value
    @inlinable
    public static func acos(_ value: Double) -> Self {
        Self(Double.acos(value))
    }

    /// Create a radian angle from its tangent value
    @inlinable
    public static func atan(_ value: Double) -> Self {
        Self(Double.atan(value))
    }

    /// Create a radian angle from y/x coordinates (atan2)
    @inlinable
    public static func atan2(y: Double, x: Double) -> Self {
        Self(Double.atan2(y: y, x: x))
    }
}

// MARK: - Constants

extension Radian {
    /// π radians (180°)
    @inlinable
    public static var pi: Self { Self(Double.pi) }

    /// 2π radians (360°, full circle)
    @inlinable
    public static var twoPi: Self { Self(2 * Double.pi) }

    /// π/2 radians (90°, right angle)
    @inlinable
    public static var halfPi: Self { Self(Double.pi / 2) }

    /// π/4 radians (45°)
    @inlinable
    public static var quarterPi: Self { Self(Double.pi / 4) }

    /// π divided by n (e.g., .pi(over: 2) = π/2)
    @inlinable
    public static func pi(over n: Double) -> Self {
        Self(Double.pi / n)
    }

    /// π multiplied by n (e.g., .pi(times: 2) = 2π)
    @inlinable
    public static func pi(times n: Double) -> Self {
        Self(Double.pi * n)
    }
}

// MARK: - Normalization

extension Radian {
    /// The angle normalized to [0, 2π)
    @inlinable
    public var normalized: Self {
        var result = value.truncatingRemainder(dividingBy: 2 * Double.pi)
        if result < 0 {
            result += 2 * Double.pi
        }
        return Self(result)
    }
}

// MARK: - Conversion

extension Radian {
    /// Create from degrees
    @inlinable
    public init(degrees: Degree) {
        self.value = degrees.value * Double.pi / 180
    }

    /// Convert to degrees
    @inlinable
    public var degrees: Degree {
        Degree(radians: self)
    }
}
