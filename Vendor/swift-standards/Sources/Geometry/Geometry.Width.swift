// Width.swift
// A type-safe horizontal measurement.

extension Geometry {
    /// A horizontal measurement (width) parameterized by unit type.
    ///
    /// Use `Width` when you need type safety to distinguish horizontal
    /// measurements from vertical ones.
    ///
    /// ## Example
    ///
    /// ```swift
    /// func setDimensions(width: Geometry<Points>.Width, height: Geometry<Points>.Height) {
    ///     // Compiler prevents accidentally swapping width and height
    /// }
    /// ```
    public struct Width {
        /// The width value
        public var value: Scalar

        /// Create a width with the given value
        @inlinable
        public init(_ value: consuming Scalar) {
            self.value = value
        }
    }
}

extension Geometry.Width: Sendable where Scalar: Sendable {}
extension Geometry.Width: Equatable where Scalar: Equatable {}
extension Geometry.Width: Hashable where Scalar: Hashable {}

// MARK: - Codable

extension Geometry.Width: Codable where Scalar: Codable {}

// MARK: - AdditiveArithmetic

extension Geometry.Width: AdditiveArithmetic where Scalar: AdditiveArithmetic {
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

    /// Add a raw scalar to Width
    @inlinable
    @_disfavoredOverload
    public static func + (lhs: borrowing Self, rhs: Scalar) -> Self {
        Self(lhs.value + rhs)
    }

    /// Add Width to a raw scalar
    @inlinable
    @_disfavoredOverload
    public static func + (lhs: Scalar, rhs: borrowing Self) -> Self {
        Self(lhs + rhs.value)
    }

    /// Subtract a raw scalar from Width
    @inlinable
    @_disfavoredOverload
    public static func - (lhs: borrowing Self, rhs: Scalar) -> Self {
        Self(lhs.value - rhs)
    }

    /// Subtract Width from a raw scalar
    @inlinable
    @_disfavoredOverload
    public static func - (lhs: Scalar, rhs: borrowing Self) -> Self {
        Self(lhs - rhs.value)
    }
}

// MARK: - Comparable

extension Geometry.Width: Comparable where Scalar: Comparable {
    @inlinable
    public static func < (lhs: borrowing Self, rhs: borrowing Self) -> Bool {
        lhs.value < rhs.value
    }
}

// MARK: - ExpressibleByIntegerLiteral

extension Geometry.Width: ExpressibleByIntegerLiteral where Scalar: ExpressibleByIntegerLiteral {
    @_disfavoredOverload
    @inlinable
    public init(integerLiteral value: Scalar.IntegerLiteralType) {
        self.value = Scalar(integerLiteral: value)
    }
}

// MARK: - ExpressibleByFloatLiteral

extension Geometry.Width: ExpressibleByFloatLiteral where Scalar: ExpressibleByFloatLiteral {
    @_disfavoredOverload
    @inlinable
    public init(floatLiteral value: Scalar.FloatLiteralType) {
        self.value = Scalar(floatLiteral: value)
    }
}

// MARK: - Negation

extension Geometry.Width where Scalar: SignedNumeric {
    /// Negate
    @inlinable
    public static prefix func - (value: borrowing Self) -> Self {
        Self(-value.value)
    }
}

// MARK: - Multiplication/Division

extension Geometry.Width where Scalar: FloatingPoint {
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

extension Geometry.Width: Strideable where Scalar: Strideable {
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

extension Geometry.Width {
    /// Create a Width by transforming the value of another Width
    @inlinable
    public init<U, E: Error>(
        _ other: borrowing Geometry<U>.Width,
        _ transform: (U) throws(E) -> Scalar
    ) throws(E) {
        self.init(try transform(other.value))
    }

    /// Transform the value using the given closure
    @inlinable
    public func map<Result, E: Error>(
        _ transform: (Scalar) throws(E) -> Result
    ) throws(E) -> Geometry<Result>.Width {
        Geometry<Result>.Width(try transform(value))
    }
}
