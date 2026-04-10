// Radian.swift
// An angle measured in radians (dimensionless).

/// An angle measured in radians.
///
/// Radians are dimensionless - they represent the ratio of arc length to radius.
/// A rotation by π/4 radians is the same abstract rotation regardless of what
/// coordinate system or unit of measurement you're working in.
///
/// ## Example
///
/// ```swift
/// let rightAngle = Radian(.pi / 2)
/// let rotation = Rotation(angle: rightAngle)
/// ```
public struct Radian: Sendable, Hashable, Codable {
    /// The angle value in radians
    public var value: Double

    /// Create a radian angle from a raw value
    @inlinable
    public init(_ value: Double) {
        self.value = value
    }
}

// MARK: - AdditiveArithmetic

extension Radian: AdditiveArithmetic {
    @inlinable
    public static var zero: Self { Self(0) }

    @inlinable
    @_disfavoredOverload
    public static func + (lhs: borrowing Self, rhs: borrowing Self) -> Self {
        Self(lhs.value + rhs.value)
    }

    @inlinable
    @_disfavoredOverload
    public static func - (lhs: borrowing Self, rhs: borrowing Self) -> Self {
        Self(lhs.value - rhs.value)
    }
}

// MARK: - Comparable

extension Radian: Comparable {
    @inlinable
    public static func < (lhs: borrowing Self, rhs: borrowing Self) -> Bool {
        lhs.value < rhs.value
    }
}

// MARK: - Numeric

extension Radian: Numeric {
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
    @_disfavoredOverload
    public static func * (lhs: borrowing Self, rhs: borrowing Self) -> Self {
        Self(lhs.value * rhs.value)
    }

    @inlinable
    @_disfavoredOverload
    public static func *= (lhs: inout Self, rhs: Self) {
        lhs.value *= rhs.value
    }
}

// MARK: - SignedNumeric

extension Radian: SignedNumeric {
    /// Negate the angle
    @inlinable
    @_disfavoredOverload
    public static prefix func - (value: borrowing Self) -> Self {
        Self(-value.value)
    }
}

// MARK: - Division

extension Radian {
    /// Divide by a scalar
    @inlinable
    @_disfavoredOverload
    public static func / (lhs: borrowing Self, rhs: Double) -> Self {
        Self(lhs.value / rhs)
    }

    //    /// Divide angle by angle (returns scalar ratio)
    //    @inlinable
    //    @_disfavoredOverload
    //    public static func / (lhs: borrowing Self, rhs: borrowing Self) -> Double {
    //        lhs.value / rhs.value
    //    }
}

// MARK: - ExpressibleByFloatLiteral

extension Radian: ExpressibleByFloatLiteral {
    @inlinable
    public init(floatLiteral value: Double) {
        self.value = value
    }
}

// MARK: - ExpressibleByIntegerLiteral

extension Radian: ExpressibleByIntegerLiteral {
    @inlinable
    public init(integerLiteral value: Int) {
        self.value = Double(value)
    }
}
