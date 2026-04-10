// Dimension.swift
// Type-safe dimensional measurements.

extension Geometry {
    /// A generic linear measurement parameterized by unit type.
    ///
    /// This is the base type for specific dimensional types like `Width`, `Height`, and `Length`.
    public struct Dimension {
        /// The measurement value
        public var value: Scalar

        /// Create a dimension with the given value
        @inlinable
        public init(_ value: consuming Scalar) {
            self.value = value
        }
    }
}

extension Geometry.Dimension: Sendable where Scalar: Sendable {}
extension Geometry.Dimension: Equatable where Scalar: Equatable {}
extension Geometry.Dimension: Hashable where Scalar: Hashable {}

// MARK: - Codable

extension Geometry.Dimension: Codable where Scalar: Codable {}

// MARK: - AdditiveArithmetic

extension Geometry.Dimension: AdditiveArithmetic where Scalar: AdditiveArithmetic {
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
}

// MARK: - Comparable

extension Geometry.Dimension: Comparable where Scalar: Comparable {
    @inlinable
    @_disfavoredOverload
    public static func < (lhs: borrowing Self, rhs: borrowing Self) -> Bool {
        lhs.value < rhs.value
    }
}

// MARK: - ExpressibleByIntegerLiteral

extension Geometry.Dimension: ExpressibleByIntegerLiteral
where Scalar: ExpressibleByIntegerLiteral {
    @inlinable
    public init(integerLiteral value: Scalar.IntegerLiteralType) {
        self.value = Scalar(integerLiteral: value)
    }
}

// MARK: - ExpressibleByFloatLiteral

extension Geometry.Dimension: ExpressibleByFloatLiteral where Scalar: ExpressibleByFloatLiteral {
    @inlinable
    public init(floatLiteral value: Scalar.FloatLiteralType) {
        self.value = Scalar(floatLiteral: value)
    }
}

// MARK: - Negation

extension Geometry.Dimension where Scalar: SignedNumeric {
    /// Negate
    @inlinable
    public static prefix func - (value: borrowing Self) -> Self {
        Self(-value.value)
    }
}

// MARK: - Multiplication/Division

extension Geometry.Dimension where Scalar: FloatingPoint {
    /// Multiply by a scalar
    @inlinable
    @_disfavoredOverload
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
    @_disfavoredOverload
    public static func / (lhs: borrowing Self, rhs: Scalar) -> Self {
        Self(lhs.value / rhs)
    }
}

// MARK: - Strideable

extension Geometry.Dimension: Strideable where Scalar: Strideable {
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

// MARK: - Functorial Map

extension Geometry.Dimension {
    /// Create a Dimension by transforming the value of another Dimension
    @inlinable
    public init<U, E: Error>(
        _ other: borrowing Geometry<U>.Dimension,
        _ transform: (U) throws(E) -> Scalar
    ) throws(E) {
        self.init(try transform(other.value))
    }

    /// Transform the value using the given closure
    @inlinable
    public func map<E: Error, Result>(
        _ transform: (Scalar) throws(E) -> Result
    ) throws(E) -> Geometry<Result>.Dimension {
        Geometry<Result>.Dimension(try transform(value))
    }
}
