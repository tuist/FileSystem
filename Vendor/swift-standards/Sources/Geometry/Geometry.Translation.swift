// Geometry.Translation.swift
// A 2D translation (displacement) in an affine space.

extension Geometry {
    /// A 2D translation (displacement) in an affine space.
    ///
    /// Translation is parameterized by the scalar type because it represents
    /// an actual displacement in the coordinate system - unlike rotation or
    /// scale which are dimensionless.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let offset: Geometry<Points>.Translation = .init(x: 72, y: 144)
    /// ```
    public struct Translation {
        /// Horizontal displacement
        public var x: Geometry.X

        /// Vertical displacement
        public var y: Geometry.Y

        /// Create a translation with typed X and Y components
        @inlinable
        public init(x: Geometry.X, y: Geometry.Y) {
            self.x = x
            self.y = y
        }
    }
}

extension Geometry.Translation: Sendable where Scalar: Sendable {}
extension Geometry.Translation: Equatable where Scalar: Equatable {}
extension Geometry.Translation: Hashable where Scalar: Hashable {}
extension Geometry.Translation: Codable where Scalar: Codable {}

// MARK: - Convenience Initializers

extension Geometry.Translation {
    /// Create a translation from raw scalar values
    @inlinable
    public init(x: Scalar, y: Scalar) {
        self.x = Geometry.X(x)
        self.y = Geometry.Y(y)
    }

    /// Create a translation from a vector
    @inlinable
    public init(_ vector: Geometry.Vector<2>) {
        self.x = vector.dx
        self.y = vector.dy
    }
}

// MARK: - Zero

extension Geometry.Translation where Scalar: AdditiveArithmetic {
    /// Zero translation (no displacement)
    @inlinable
    public static var zero: Self {
        Self(x: .zero, y: .zero)
    }
}

// MARK: - AdditiveArithmetic

extension Geometry.Translation: AdditiveArithmetic where Scalar: AdditiveArithmetic {
    @inlinable
    @_disfavoredOverload
    public static func + (lhs: borrowing Self, rhs: borrowing Self) -> Self {
        Self(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    @inlinable
    @_disfavoredOverload
    public static func - (lhs: borrowing Self, rhs: borrowing Self) -> Self {
        Self(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
}

// MARK: - Negation

extension Geometry.Translation where Scalar: SignedNumeric {
    /// Negate the translation
    @inlinable
    public static prefix func - (value: borrowing Self) -> Self {
        Self(x: -value.x, y: -value.y)
    }
}

// MARK: - Conversion to Vector

extension Geometry.Translation {
    /// Convert to a 2D vector
    @inlinable
    public var vector: Geometry.Vector<2> {
        Geometry.Vector(dx: x, dy: y)
    }
}
