// Geometry.AffineTransform.swift
// A 2D affine transformation: linear transformation + translation.

public import Angle
public import RealModule

extension Geometry {
    /// A 2D affine transformation.
    ///
    /// An affine transformation consists of:
    /// - A **linear** part (rotation, scale, shear) - dimensionless
    /// - A **translation** part - in coordinate system units
    ///
    /// The matrix representation is:
    /// ```
    /// | a  b  tx |     | linear    translation |
    /// | c  d  ty |  =  |                       |
    /// | 0  0  1  |     | 0  0  1               |
    /// ```
    ///
    /// ## Dimensional Analysis
    ///
    /// For a point transformation `(x', y') = (x, y) * M + (tx, ty)`:
    /// ```
    /// x' = a*x + c*y + tx
    /// y' = b*x + d*y + ty
    /// ```
    /// - Linear coefficients `(a, b, c, d)` are dimensionless ratios
    /// - Translation `(tx, ty)` has the same units as coordinates
    ///
    /// ## Example
    ///
    /// ```swift
    /// let transform = Geometry<Points>.AffineTransform(
    ///     linear: .rotation(.pi / 4),
    ///     translation: .init(x: 100, y: 50)
    /// )
    /// ```
    public struct AffineTransform {
        /// The linear transformation (rotation, scale, shear)
        public var linear: Geometry.Linear<2>

        /// The translation (displacement)
        public var translation: Translation

        /// Create an affine transform from linear and translation components
        @inlinable
        public init(linear: Geometry.Linear<2>, translation: Translation) {
            self.linear = linear
            self.translation = translation
        }
    }
}

extension Geometry.AffineTransform: Sendable where Scalar: Sendable {}
extension Geometry.AffineTransform: Equatable where Scalar: Equatable {}
extension Geometry.AffineTransform: Hashable where Scalar: Hashable {}
extension Geometry.AffineTransform: Codable where Scalar: Codable {}

// MARK: - Identity

extension Geometry.AffineTransform where Scalar: AdditiveArithmetic & ExpressibleByIntegerLiteral {
    /// The identity transform (no transformation)
    @inlinable
    public static var identity: Self {
        Self(linear: .identity, translation: .zero)
    }
}

// MARK: - Convenience Initializers

extension Geometry.AffineTransform where Scalar: AdditiveArithmetic {
    /// Create from just a linear transformation (no translation)
    @inlinable
    public init(linear: Geometry.Linear<2>) {
        self.init(linear: linear, translation: .zero)
    }
}

extension Geometry.AffineTransform where Scalar: AdditiveArithmetic & ExpressibleByIntegerLiteral {
    /// Create from just a translation (identity linear)
    @inlinable
    public init(translation: Geometry.Translation) {
        self.init(linear: .identity, translation: translation)
    }
}

// MARK: - Symmetry Initializers
// See Symmetry module for init(_ rotation:), init(_ scale:), init(_ shear:)

// MARK: - Component Access (Standard Notation)

extension Geometry.AffineTransform {
    /// Linear coefficient a (row 0, col 0)
    @inlinable
    public var a: Scalar {
        get { linear.a }
        set { linear.a = newValue }
    }

    /// Linear coefficient b (row 0, col 1)
    @inlinable
    public var b: Scalar {
        get { linear.b }
        set { linear.b = newValue }
    }

    /// Linear coefficient c (row 1, col 0)
    @inlinable
    public var c: Scalar {
        get { linear.c }
        set { linear.c = newValue }
    }

    /// Linear coefficient d (row 1, col 1)
    @inlinable
    public var d: Scalar {
        get { linear.d }
        set { linear.d = newValue }
    }

    /// Translation x component (type-safe)
    @inlinable
    public var tx: Geometry.X {
        get { translation.x }
        set { translation.x = newValue }
    }

    /// Translation y component (type-safe)
    @inlinable
    public var ty: Geometry.Y {
        get { translation.y }
        set { translation.y = newValue }
    }
}

// MARK: - Raw Component Initializer

extension Geometry.AffineTransform {
    /// Create an affine transform with raw matrix components
    ///
    /// - Parameters:
    ///   - a, b, c, d: Dimensionless linear transformation coefficients
    ///   - tx, ty: Translation in coordinate units (raw scalar values)
    @inlinable
    public init(a: Scalar, b: Scalar, c: Scalar, d: Scalar, tx: Scalar, ty: Scalar) {
        self.linear = Geometry.Linear(a: a, b: b, c: c, d: d)
        self.translation = Geometry.Translation(x: tx, y: ty)
    }

    /// Create an affine transform with typed translation components
    ///
    /// - Parameters:
    ///   - a, b, c, d: Dimensionless linear transformation coefficients
    ///   - tx, ty: Translation in coordinate units (type-safe)
    @inlinable
    public init(a: Scalar, b: Scalar, c: Scalar, d: Scalar, tx: Geometry.X, ty: Geometry.Y) {
        self.linear = Geometry.Linear(a: a, b: b, c: c, d: d)
        self.translation = Geometry.Translation(x: tx, y: ty)
    }
}

// MARK: - Composition

extension Geometry.AffineTransform where Scalar: FloatingPoint {
    /// Concatenate with another transform (self * other)
    ///
    /// The resulting transform applies `other` first, then `self`.
    @inlinable
    public func concatenating(_ other: Self) -> Self {
        // Linear part: matrix multiplication
        let newLinear = linear.concatenating(other.linear)

        // Translation part: apply self's linear to other's translation, then add self's translation
        let otherTx = other.translation.x.value
        let otherTy = other.translation.y.value
        let newTx = linear.a * otherTx + linear.b * otherTy + translation.x.value
        let newTy = linear.c * otherTx + linear.d * otherTy + translation.y.value

        return Self(
            linear: newLinear,
            translation: Geometry.Translation(x: newTx, y: newTy)
        )
    }
}

// MARK: - Factory Methods

extension Geometry.AffineTransform where Scalar: FloatingPoint & ExpressibleByIntegerLiteral {
    /// Create a translation transform
    @inlinable
    public static func translation(x: Scalar, y: Scalar) -> Self {
        Self(linear: .identity, translation: Geometry.Translation(x: x, y: y))
    }

    /// Create a translation transform from a vector
    @inlinable
    public static func translation(_ vector: Geometry.Vector<2>) -> Self {
        Self(translation: Geometry.Translation(vector))
    }

    /// Create a uniform scaling transform
    @inlinable
    public static func scale(_ factor: Scalar) -> Self {
        Self(linear: .scale(factor))
    }

    /// Create a non-uniform scaling transform
    @inlinable
    public static func scale(x: Scalar, y: Scalar) -> Self {
        Self(linear: .scale(x: x, y: y))
    }

    /// Create a shear transform
    @inlinable
    public static func shear(x: Scalar, y: Scalar) -> Self {
        Self(linear: .shear(x: x, y: y))
    }
}

// MARK: - Rotation Factory (Real & BinaryFloatingPoint)

extension Geometry.AffineTransform where Scalar: Real & BinaryFloatingPoint {
    /// Create a rotation transform
    @inlinable
    public static func rotation(_ angle: Radian) -> Self {
        Self(linear: .rotation(angle), translation: .zero)
    }

    /// Create a rotation transform from degrees
    @inlinable
    public static func rotation(_ angle: Degree) -> Self {
        Self(linear: .rotation(angle.radians), translation: .zero)
    }
}
//
//// MARK: - Rotation Factory (Float)
//
// extension Geometry.AffineTransform where Scalar == Float {
//    /// Create a rotation transform
//    @inlinable
//    public static func rotation(_ angle: Radian) -> Self {
//        Self(linear: .rotation(angle), translation: .zero)
//    }
//
//    /// Create a rotation transform from degrees
//    @inlinable
//    public static func rotation(_ angle: Degree) -> Self {
//        Self(linear: .rotation(angle.radians), translation: .zero)
//    }
// }

// MARK: - Fluent Modifiers

extension Geometry.AffineTransform where Scalar: FloatingPoint & ExpressibleByIntegerLiteral {
    /// Return a new transform with translation applied
    @inlinable
    public func translated(x: Scalar, y: Scalar) -> Self {
        concatenating(.translation(x: x, y: y))
    }

    /// Return a new transform with translation applied
    @inlinable
    public func translated(by vector: Geometry.Vector<2>) -> Self {
        concatenating(.translation(vector))
    }

    /// Return a new transform with uniform scaling applied
    @inlinable
    public func scaled(by factor: Scalar) -> Self {
        concatenating(.scale(factor))
    }

    /// Return a new transform with non-uniform scaling applied
    @inlinable
    public func scaled(x: Scalar, y: Scalar) -> Self {
        concatenating(.scale(x: x, y: y))
    }
}

extension Geometry.AffineTransform where Scalar: Real & BinaryFloatingPoint {
    /// Return a new transform with rotation applied
    @inlinable
    public func rotated(by angle: Radian) -> Self {
        concatenating(.rotation(angle))
    }

    /// Return a new transform with rotation applied
    @inlinable
    public func rotated(by angle: Degree) -> Self {
        concatenating(.rotation(angle))
    }
}

// MARK: - Inversion

extension Geometry.AffineTransform where Scalar: FloatingPoint {
    /// The determinant of the linear part
    @inlinable
    public var determinant: Scalar {
        linear.determinant
    }

    /// Whether this transform is invertible
    @inlinable
    public var isInvertible: Bool {
        linear.isInvertible
    }

    /// The inverse transform, or nil if not invertible
    @inlinable
    public var inverted: Self? {
        guard let invLinear = linear.inverted else { return nil }

        // inv(T) = -inv(L) * t
        let tx = translation.x.value
        let ty = translation.y.value
        let newTx = -(invLinear.a * tx + invLinear.b * ty)
        let newTy = -(invLinear.c * tx + invLinear.d * ty)

        return Self(
            linear: invLinear,
            translation: Geometry.Translation(x: newTx, y: newTy)
        )
    }
}

// MARK: - Apply Transform

extension Geometry.AffineTransform where Scalar: FloatingPoint {
    /// Apply transform to a point
    @inlinable
    public func apply(to point: Geometry.Point<2>) -> Geometry.Point<2> {
        let px = point.x.value
        let py = point.y.value
        let newX = linear.a * px + linear.b * py + translation.x.value
        let newY = linear.c * px + linear.d * py + translation.y.value
        return Geometry.Point(x: Geometry.X(newX), y: Geometry.Y(newY))
    }

    /// Apply transform to a vector (ignores translation)
    @inlinable
    public func apply(to vector: Geometry.Vector<2>) -> Geometry.Vector<2> {
        let vx = vector.dx.value
        let vy = vector.dy.value
        let newDx = linear.a * vx + linear.b * vy
        let newDy = linear.c * vx + linear.d * vy
        return Geometry.Vector(dx: Geometry.X(newDx), dy: Geometry.Y(newDy))
    }

    /// Apply transform to a size (uses absolute values)
    @inlinable
    public func apply(to size: Geometry.Size<2>) -> Geometry.Size<2> {
        let w = size.width.value
        let h = size.height.value
        let newW = abs(linear.a * w + linear.b * h)
        let newH = abs(linear.c * w + linear.d * h)
        return Geometry.Size(width: .init(newW), height: .init(newH))
    }
}

// MARK: - Monoid

extension Geometry.AffineTransform where Scalar: FloatingPoint & ExpressibleByIntegerLiteral {
    /// Compose multiple transforms into a single transform
    ///
    /// The transforms are applied in order: first in array is applied first.
    @inlinable
    public static func composed(_ transforms: [Self]) -> Self {
        transforms.reduce(.identity) { $0.concatenating($1) }
    }

    /// Compose multiple transforms into a single transform
    @inlinable
    public static func composed(_ transforms: Self...) -> Self {
        composed(transforms)
    }
}
