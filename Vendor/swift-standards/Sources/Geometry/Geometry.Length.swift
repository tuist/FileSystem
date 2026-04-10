// Length.swift
// A type-safe general linear measurement.

extension Geometry {
    /// A general linear measurement (length) parameterized by unit type.
    ///
    /// Use `Length` for measurements that aren't specifically horizontal or vertical,
    /// such as distances, radii, or line thicknesses.
    ///
    /// ## Example
    ///
    /// ```swift
    /// func drawCircle(center: Geometry<Points>.Point<2>, radius: Geometry<Points>.Length) {
    ///     // ...
    /// }
    /// ```
    public struct Length {
        /// The length value
        public var value: Scalar

        /// Create a length with the given value
        @inlinable
        public init(_ value: consuming Scalar) {
            self.value = value
        }
    }
}

extension Geometry.Length: Sendable where Scalar: Sendable {}
extension Geometry.Length: Equatable where Scalar: Equatable {}
extension Geometry.Length: Hashable where Scalar: Hashable {}

// MARK: - Codable

extension Geometry.Length: Codable where Scalar: Codable {}

// MARK: - AdditiveArithmetic

extension Geometry.Length: AdditiveArithmetic where Scalar: AdditiveArithmetic {
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

extension Geometry.Length: Comparable where Scalar: Comparable {
    @inlinable
    @_disfavoredOverload
    public static func < (lhs: borrowing Self, rhs: borrowing Self) -> Bool {
        lhs.value < rhs.value
    }
}

// MARK: - ExpressibleByIntegerLiteral

extension Geometry.Length: ExpressibleByIntegerLiteral where Scalar: ExpressibleByIntegerLiteral {
    @inlinable
    public init(integerLiteral value: Scalar.IntegerLiteralType) {
        self.value = Scalar(integerLiteral: value)
    }
}

// MARK: - ExpressibleByFloatLiteral

extension Geometry.Length: ExpressibleByFloatLiteral where Scalar: ExpressibleByFloatLiteral {
    @inlinable
    public init(floatLiteral value: Scalar.FloatLiteralType) {
        self.value = Scalar(floatLiteral: value)
    }
}

// MARK: - Negation

extension Geometry.Length where Scalar: SignedNumeric {
    /// Negate
    @inlinable
    public static prefix func - (value: borrowing Self) -> Self {
        Self(-value.value)
    }
}

// MARK: - Multiplication/Division

extension Geometry.Length where Scalar: FloatingPoint {
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

extension Geometry.Length: Strideable where Scalar: Strideable {
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

extension Geometry.Length {
    /// Create a Length by transforming the value of another Length
    @inlinable
    public init<U, E: Error>(
        _ other: borrowing Geometry<U>.Length,
        _ transform: (U) throws(E) -> Scalar
    ) throws(E) {
        self.init(try transform(other.value))
    }

    /// Transform the value using the given closure
    @inlinable
    public func map<Result, E: Error>(
        _ transform: (Scalar) throws(E) -> Result
    ) throws(E) -> Geometry<Result>.Length {
        Geometry<Result>.Length(try transform(value))
    }
}
