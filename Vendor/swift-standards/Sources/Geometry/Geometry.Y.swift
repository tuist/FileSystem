// Y.swift
// A type-safe vertical coordinate.

extension Geometry {
    /// A vertical coordinate (y-position) parameterized by unit type.
    ///
    /// Use `Y` when you need type safety to distinguish vertical
    /// coordinates from horizontal ones.
    ///
    /// ## Example
    ///
    /// ```swift
    /// func setPosition(x: Geometry<Points>.X, y: Geometry<Points>.Y) {
    ///     // Compiler prevents accidentally swapping x and y
    /// }
    /// ```
    public struct Y {
        /// The y coordinate value
        public var value: Scalar

        /// Create a y coordinate with the given value
        @inlinable
        public init(_ value: consuming Scalar) {
            self.value = value
        }
    }
}

extension Geometry.Y: Sendable where Scalar: Sendable {}
extension Geometry.Y: Equatable where Scalar: Equatable {}
extension Geometry.Y: Hashable where Scalar: Hashable {}

// MARK: - Codable

extension Geometry.Y: Codable where Scalar: Codable {}

// MARK: - AdditiveArithmetic

extension Geometry.Y: AdditiveArithmetic where Scalar: AdditiveArithmetic {
    @inlinable
    public static var zero: Self {
        Self(.zero)
    }

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

    /// Add a raw scalar to Y
    @inlinable
    @_disfavoredOverload
    public static func + (lhs: borrowing Self, rhs: Scalar) -> Self {
        Self(lhs.value + rhs)
    }

    /// Add Y to a raw scalar
    @inlinable
    @_disfavoredOverload
    public static func + (lhs: Scalar, rhs: borrowing Self) -> Self {
        Self(lhs + rhs.value)
    }

    /// Subtract a raw scalar from Y
    @inlinable
    @_disfavoredOverload
    public static func - (lhs: borrowing Self, rhs: Scalar) -> Self {
        Self(lhs.value - rhs)
    }

    /// Subtract Y from a raw scalar
    @inlinable
    @_disfavoredOverload
    public static func - (lhs: Scalar, rhs: borrowing Self) -> Self {
        Self(lhs - rhs.value)
    }
}

// MARK: - Comparable

extension Geometry.Y: Comparable where Scalar: Comparable {
    @inlinable
    public static func < (lhs: borrowing Self, rhs: borrowing Self) -> Bool {
        lhs.value < rhs.value
    }
}

//// MARK: - Scalar Comparison
//
// extension Geometry.Y where Scalar: Equatable {
//    /// Compare Y to a raw scalar value
//    @_disfavoredOverload
//    @inlinable
//    public static func == (lhs: borrowing Self, rhs: Scalar) -> Bool {
//        lhs.value == rhs
//    }
//
//    /// Compare a raw scalar value to Y
//    @_disfavoredOverload
//    @inlinable
//    public static func == (lhs: Scalar, rhs: borrowing Self) -> Bool {
//        lhs == rhs.value
//    }
// }

// MARK: - Negation

extension Geometry.Y where Scalar: SignedNumeric {
    /// Negate
    @inlinable
    public static prefix func - (value: borrowing Self) -> Self {
        Self(-value.value)
    }
}

// MARK: - Multiplication/Division

extension Geometry.Y where Scalar: FloatingPoint {
    /// Multiply by a scalar
    @inlinable
    public static func * (lhs: borrowing Self, rhs: Scalar) -> Self {
        Self(lhs.value * rhs)
    }

    /// Multiply scalar by value
    @inlinable
    @_disfavoredOverload
    public static func * (lhs: Scalar, rhs: borrowing Self) -> Self {
        Self(lhs * rhs.value)
    }

    /// Divide by a scalar
    @inlinable
    public static func / (lhs: borrowing Self, rhs: Scalar) -> Self {
        Self(lhs.value / rhs)
    }
}

// MARK: - Squared (for distance calculations)

extension Geometry.Y where Scalar: Numeric {
    /// Multiply Y by Y to get squared length (for distance calculations)
    ///
    /// Dimensionally: [Y] * [Y] = [L²] (squared length, same as X*X)
    /// This allows `dx*dx + dy*dy` to work for distance squared calculations.
    @inlinable
    public static func * (lhs: borrowing Self, rhs: borrowing Self) -> Scalar {
        lhs.value * rhs.value
    }

    /// Multiply Y by X to get a scalar (for cross product calculations)
    ///
    /// Dimensionally: [Y] * [X] = [L²] (area/cross product)
    /// This allows 2D cross product: `a.dx * b.dy - a.dy * b.dx`
    @inlinable
    public static func * (lhs: borrowing Self, rhs: borrowing Geometry.X) -> Scalar {
        lhs.value * rhs.value
    }
}

// MARK: - Functorial Map

extension Geometry.Y {
    /// Create a Y coordinate by transforming the value of another Y coordinate
    @inlinable
    public init<U, E: Error>(
        _ other: borrowing Geometry<U>.Y,
        _ transform: (U) throws(E) -> Scalar
    ) throws(E) {
        self.init(try transform(other.value))
    }

    /// Transform the value using the given closure
    @inlinable
    public func map<Result, E: Error>(
        _ transform: (Scalar) throws(E) -> Result
    ) throws(E) -> Geometry<Result>.Y {
        Geometry<Result>.Y(try transform(value))
    }
}

// MARK: - ExpressibleByIntegerLiteral

extension Geometry.Y: ExpressibleByIntegerLiteral where Scalar: ExpressibleByIntegerLiteral {
    @_disfavoredOverload
    @inlinable
    public init(integerLiteral value: Scalar.IntegerLiteralType) {
        self.init(Scalar(integerLiteral: value))
    }
}

// MARK: - ExpressibleByFloatLiteral

extension Geometry.Y: ExpressibleByFloatLiteral where Scalar: ExpressibleByFloatLiteral {
    @_disfavoredOverload
    @inlinable
    public init(floatLiteral value: Scalar.FloatLiteralType) {
        self.init(Scalar(floatLiteral: value))
    }
}

// MARK: - Strideable

extension Geometry.Y: Strideable where Scalar: Strideable {
    public typealias Stride = Scalar.Stride

    @inlinable
    public func distance(to other: Self) -> Stride {
        value.distance(to: other.value)
    }

    @inlinable
    public func advanced(by n: Stride) -> Self {
        Self(value.advanced(by: n))
    }
}
