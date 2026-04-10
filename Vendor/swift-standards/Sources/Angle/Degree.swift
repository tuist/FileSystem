// Degree.swift
// An angle measured in degrees (dimensionless).

/// An angle measured in degrees.
///
/// Degrees are dimensionless - they represent a fraction of a full rotation.
/// Like radians, a rotation by 45° is the same abstract rotation regardless
/// of coordinate system.
///
/// ## Example
///
/// ```swift
/// let rightAngle = Degree(90)
/// let inRadians = rightAngle.radians  // π/2
/// ```
public struct Degree: Sendable, Hashable, Codable {
    /// The angle value in degrees
    public var value: Double

    /// Create a degree angle from a raw value
    @inlinable
    public init(_ value: Double) {
        self.value = value
    }
}

// MARK: - AdditiveArithmetic

extension Degree: AdditiveArithmetic {
    @inlinable
    public static var zero: Self { Self(0) }

    @inlinable
    public static func + (lhs: borrowing Self, rhs: borrowing Self) -> Self {
        Self(lhs.value + rhs.value)
    }

    @inlinable
    public static func - (lhs: borrowing Self, rhs: borrowing Self) -> Self {
        Self(lhs.value - rhs.value)
    }
}

// MARK: - Comparable

extension Degree: Comparable {
    @inlinable
    public static func < (lhs: borrowing Self, rhs: borrowing Self) -> Bool {
        lhs.value < rhs.value
    }
}

// MARK: - Numeric

extension Degree: Numeric {
    public typealias Magnitude = Self

    @inlinable
    public var magnitude: Self {
        Self(value.magnitude)
    }

    @inlinable
    public init?<T: BinaryInteger>(exactly source: T) {
        guard let value = Double(exactly: source) else { return nil }
        self.value = value
    }

    /// Multiply two angles (scaling)
    @inlinable
    public static func * (lhs: borrowing Self, rhs: borrowing Self) -> Self {
        Self(lhs.value * rhs.value)
    }

    @inlinable
    public static func *= (lhs: inout Self, rhs: Self) {
        lhs.value *= rhs.value
    }
}

// MARK: - SignedNumeric

extension Degree: SignedNumeric {
    /// Negate the angle
    @inlinable
    public static prefix func - (value: borrowing Self) -> Self {
        Self(-value.value)
    }
}

// MARK: - Division

extension Degree {
    /// Divide by a scalar
    @inlinable
    @_disfavoredOverload
    public static func / (lhs: borrowing Self, rhs: Double) -> Self {
        Self(lhs.value / rhs)
    }

    /// Divide angle by angle (returns scalar ratio)
    @inlinable
    @_disfavoredOverload
    public static func / (lhs: borrowing Self, rhs: borrowing Self) -> Double {
        lhs.value / rhs.value
    }
}

// MARK: - ExpressibleByFloatLiteral

extension Degree: ExpressibleByFloatLiteral {
    @inlinable
    public init(floatLiteral value: Double) {
        self.value = value
    }
}

// MARK: - ExpressibleByIntegerLiteral

extension Degree: ExpressibleByIntegerLiteral {
    @inlinable
    public init(integerLiteral value: Int) {
        self.value = Double(value)
    }
}

// MARK: - Common Angles

extension Degree {
    /// 90° (right angle)
    public static let rightAngle = Self(90)

    /// 180° (straight angle)
    public static let straight = Self(180)

    /// 360° (full circle)
    public static let fullCircle = Self(360)

    /// 45°
    public static let fortyFive = Self(45)

    /// 60°
    public static let sixty = Self(60)

    /// 30°
    public static let thirty = Self(30)
}

// MARK: - Conversion

extension Degree {
    /// Create from radians
    @inlinable
    public init(radians: Radian) {
        self.value = radians.value * 180 / Double.pi
    }

    /// Convert to radians
    @inlinable
    public var radians: Radian {
        Radian(degrees: self)
    }
}

// MARK: - Trigonometry (via Radian)

extension Degree {
    /// Sine of the angle
    @inlinable
    public var sin: Double { radians.sin }

    /// Cosine of the angle
    @inlinable
    public var cos: Double { radians.cos }

    /// Tangent of the angle
    @inlinable
    public var tan: Double { radians.tan }
}
