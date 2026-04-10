// Scalar.swift
// A generic scalar value.

extension Geometry {
    /// A generic scalar value.
    ///
    /// `Scalar` wraps a value of the geometry's unit type,
    /// providing type safety for measurements in different coordinate systems.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let value: Geometry<Double>.Scalar = .init(72.0)
    /// ```
    public struct Scalar {
        /// The underlying value
        public var value: Scalar

        /// Create a scalar with the given value
        @inlinable
        public init(_ value: consuming Scalar) {
            self.value = value
        }
    }
}

extension Geometry.Scalar: Sendable where Scalar: Sendable {}
extension Geometry.Scalar: Equatable where Scalar: Equatable {}
extension Geometry.Scalar: Hashable where Scalar: Hashable {}

// MARK: - Codable

extension Geometry.Scalar: Codable where Scalar: Codable {}

// MARK: - Zero

extension Geometry.Scalar where Scalar: AdditiveArithmetic {
    /// Zero scalar
    @inlinable
    public static var zero: Self { Self(.zero) }
}

// MARK: - AdditiveArithmetic

extension Geometry.Scalar: AdditiveArithmetic where Scalar: AdditiveArithmetic {
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

extension Geometry.Scalar: Comparable where Scalar: Comparable {
    @inlinable
    @_disfavoredOverload
    public static func < (lhs: borrowing Self, rhs: borrowing Self) -> Bool {
        lhs.value < rhs.value
    }
}

// MARK: - ExpressibleByFloatLiteral

extension Geometry.Scalar: ExpressibleByFloatLiteral where Scalar: ExpressibleByFloatLiteral {
    @inlinable
    public init(floatLiteral value: Scalar.FloatLiteralType) {
        self.value = Scalar(floatLiteral: value)
    }
}

// MARK: - ExpressibleByIntegerLiteral

extension Geometry.Scalar: ExpressibleByIntegerLiteral where Scalar: ExpressibleByIntegerLiteral {
    @inlinable
    public init(integerLiteral value: Scalar.IntegerLiteralType) {
        self.value = Scalar(integerLiteral: value)
    }
}

// MARK: - Negation (SignedNumeric)

extension Geometry.Scalar where Scalar: SignedNumeric {
    /// Negate
    @inlinable
    public static prefix func - (value: borrowing Self) -> Self {
        Self(-value.value)
    }
}

// MARK: - Functorial Map

extension Geometry.Scalar {
    /// Create a scalar by transforming the value of another scalar
    @inlinable
    public init<U, E: Error>(
        _ other: borrowing Geometry<U>.Scalar,
        _ transform: (U) throws(E) -> Scalar
    ) throws(E) {
        self.init(try transform(other.value))
    }

    /// Transform the value using the given closure
    @inlinable
    public func map<Result, E: Error>(
        _ transform: (Scalar) throws(E) -> Result
    ) throws(E) -> Geometry<Result>.Scalar {
        Geometry<Result>.Scalar(try transform(value))
    }
}

// MARK: - Multiplication/Division (FloatingPoint)

extension Geometry.Scalar where Scalar: FloatingPoint {
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
