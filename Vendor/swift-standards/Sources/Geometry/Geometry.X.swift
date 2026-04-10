// X.swift
// A type-safe horizontal coordinate.

extension Geometry {
    /// A horizontal coordinate (x-position) parameterized by unit type.
    ///
    /// Use `X` when you need type safety to distinguish horizontal
    /// coordinates from vertical ones.
    ///
    /// ## Example
    ///
    /// ```swift
    /// func setPosition(x: Geometry<Points>.X, y: Geometry<Points>.Y) {
    ///     // Compiler prevents accidentally swapping x and y
    /// }
    /// ```
    public struct X {
        /// The x coordinate value
        public var value: Scalar

        /// Create an x coordinate with the given value
        @inlinable
        public init(_ value: consuming Scalar) {
            self.value = value
        }
    }
}

extension Geometry.X: Sendable where Scalar: Sendable {}
extension Geometry.X: Equatable where Scalar: Equatable {}
extension Geometry.X: Hashable where Scalar: Hashable {}

// MARK: - Codable

extension Geometry.X: Codable where Scalar: Codable {}

// MARK: - AdditiveArithmetic

extension Geometry.X: AdditiveArithmetic where Scalar: AdditiveArithmetic {
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

    /// Add a raw scalar to X
    @inlinable
    @_disfavoredOverload
    public static func + (lhs: borrowing Self, rhs: Scalar) -> Self {
        Self(lhs.value + rhs)
    }

    /// Add X to a raw scalar
    @inlinable
    @_disfavoredOverload
    public static func + (lhs: Scalar, rhs: borrowing Self) -> Self {
        Self(lhs + rhs.value)
    }

    /// Subtract a raw scalar from X
    @inlinable
    @_disfavoredOverload
    public static func - (lhs: borrowing Self, rhs: Scalar) -> Self {
        Self(lhs.value - rhs)
    }

    /// Subtract X from a raw scalar
    @inlinable
    @_disfavoredOverload
    public static func - (lhs: Scalar, rhs: borrowing Self) -> Self {
        Self(lhs - rhs.value)
    }
}

// MARK: - Comparable

extension Geometry.X: Comparable where Scalar: Comparable {
    @inlinable
    public static func < (lhs: borrowing Self, rhs: borrowing Self) -> Bool {
        lhs.value < rhs.value
    }
}

//// MARK: - Scalar Comparison
//
// extension Geometry.X where Scalar: Equatable {
//    /// Compare X to a raw scalar value
//    @_disfavoredOverload
//    @inlinable
//    public static func == (lhs: borrowing Self, rhs: Scalar) -> Bool {
//        lhs.value == rhs
//    }
//
//    /// Compare a raw scalar value to X
//    @_disfavoredOverload
//    @inlinable
//    public static func == (lhs: Scalar, rhs: borrowing Self) -> Bool {
//        lhs == rhs.value
//    }
// }

// MARK: - Negation

extension Geometry.X where Scalar: SignedNumeric {
    /// Negate
    @inlinable
    public static prefix func - (value: borrowing Self) -> Self {
        Self(-value.value)
    }
}

// MARK: - Multiplication/Division

extension Geometry.X where Scalar: FloatingPoint {
    /// Multiply by a scalar
    @inlinable
    //    @_disfavoredOverload
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
    //    @_disfavoredOverload
    public static func / (lhs: borrowing Self, rhs: Scalar) -> Self {
        Self(lhs.value / rhs)
    }
}

// MARK: - Squared (for distance calculations)

extension Geometry.X where Scalar: Numeric {
    /// Multiply X by X to get squared length (for distance calculations)
    ///
    /// Dimensionally: [X] * [X] = [L²] (squared length, same as Y*Y)
    /// This allows `dx*dx + dy*dy` to work for distance squared calculations.
    @inlinable
    public static func * (lhs: borrowing Self, rhs: borrowing Self) -> Scalar {
        lhs.value * rhs.value
    }

    /// Multiply X by Y to get a scalar (for cross product calculations)
    ///
    /// Dimensionally: [X] * [Y] = [L²] (area/cross product)
    /// This allows 2D cross product: `a.dx * b.dy - a.dy * b.dx`
    @inlinable
    public static func * (lhs: borrowing Self, rhs: borrowing Geometry.Y) -> Scalar {
        lhs.value * rhs.value
    }
}

// MARK: - Functorial Map

extension Geometry.X {
    /// Create an X coordinate by transforming the value of another X coordinate
    @inlinable
    public init<U, E: Error>(
        _ other: borrowing Geometry<U>.X,
        _ transform: (U) throws(E) -> Scalar
    ) throws(E) {
        self.init(try transform(other.value))
    }

    /// Transform the value using the given closure
    @inlinable
    public func map<Result, E: Error>(
        _ transform: (Scalar) throws(E) -> Result
    ) throws(E) -> Geometry<Result>.X {
        Geometry<Result>.X(try transform(value))
    }
}

// MARK: - ExpressibleByIntegerLiteral

extension Geometry.X: ExpressibleByIntegerLiteral where Scalar: ExpressibleByIntegerLiteral {
    @_disfavoredOverload
    @inlinable
    public init(integerLiteral value: Scalar.IntegerLiteralType) {
        self.init(Scalar(integerLiteral: value))
    }
}

// MARK: - ExpressibleByFloatLiteral

extension Geometry.X: ExpressibleByFloatLiteral where Scalar: ExpressibleByFloatLiteral {
    @_disfavoredOverload
    @inlinable
    public init(floatLiteral value: Scalar.FloatLiteralType) {
        self.init(Scalar(floatLiteral: value))
    }
}

// MARK: - Strideable

extension Geometry.X: Strideable where Scalar: Strideable {
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
