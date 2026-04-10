// Geometry.Linear.swift
// An N×N linear transformation matrix parameterized by scalar type.

public import Angle
public import RealModule

extension Geometry {
    /// An N×N linear transformation matrix.
    ///
    /// Linear transformations represent how coordinates are transformed through
    /// matrix multiplication. Elements of GL(n,ℝ), the general linear group of
    /// n×n invertible real matrices.
    ///
    /// The matrix is stored in row-major order:
    /// ```
    /// | rows[0][0]  rows[0][1]  ... |
    /// | rows[1][0]  rows[1][1]  ... |
    /// | ...                         |
    /// ```
    ///
    /// ## Example
    ///
    /// ```swift
    /// let identity = Geometry<Double>.Linear<2>.identity
    /// let scaled = Geometry<Double>.Linear<2>(a: 2, b: 0, c: 0, d: 2)
    /// let composed = identity.concatenating(scaled)
    /// ```
    public struct Linear<let N: Int> {
        /// The matrix elements in row-major order
        public var rows: InlineArray<N, InlineArray<N, Scalar>>

        /// Create a linear transformation from row data
        @inlinable
        public init(_ rows: consuming InlineArray<N, InlineArray<N, Scalar>>) {
            self.rows = rows
        }
    }
}

extension Geometry.Linear: Sendable where Scalar: Sendable {}

// MARK: - Equatable (2D)

extension Geometry.Linear: Equatable where N == 2, Scalar: Equatable {
    @inlinable
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.a == rhs.a && lhs.b == rhs.b && lhs.c == rhs.c && lhs.d == rhs.d
    }
}

// MARK: - Hashable (2D)

extension Geometry.Linear: Hashable where N == 2, Scalar: Hashable {
    @inlinable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(a)
        hasher.combine(b)
        hasher.combine(c)
        hasher.combine(d)
    }
}

// MARK: - Codable (2D)

extension Geometry.Linear: Codable where N == 2, Scalar: Codable {
    private enum CodingKeys: String, CodingKey {
        case a, b, c, d
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let a = try container.decode(Scalar.self, forKey: .a)
        let b = try container.decode(Scalar.self, forKey: .b)
        let c = try container.decode(Scalar.self, forKey: .c)
        let d = try container.decode(Scalar.self, forKey: .d)
        self.init(a: a, b: b, c: c, d: d)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(a, forKey: .a)
        try container.encode(b, forKey: .b)
        try container.encode(c, forKey: .c)
        try container.encode(d, forKey: .d)
    }
}

// MARK: - Subscript

extension Geometry.Linear {
    /// Access element at row, column
    @inlinable
    public subscript(row: Int, col: Int) -> Scalar {
        get { rows[row][col] }
        set { rows[row][col] = newValue }
    }

    /// Access a row
    @inlinable
    public subscript(row row: Int) -> InlineArray<N, Scalar> {
        get { rows[row] }
        set { rows[row] = newValue }
    }
}

// MARK: - Identity

extension Geometry.Linear where Scalar: AdditiveArithmetic & ExpressibleByIntegerLiteral {
    /// The identity matrix
    @inlinable
    public static var identity: Self {
        var rows = InlineArray<N, InlineArray<N, Scalar>>(
            repeating: InlineArray<N, Scalar>(repeating: .zero)
        )
        for i in 0..<N {
            rows[i][i] = 1
        }
        return Self(rows)
    }
}

// MARK: - 2D Convenience (Standard a, b, c, d notation)

extension Geometry.Linear where N == 2 {
    /// Element (0,0) - standard notation: a
    @inlinable
    public var a: Scalar {
        get { rows[0][0] }
        set { rows[0][0] = newValue }
    }

    /// Element (0,1) - standard notation: b
    @inlinable
    public var b: Scalar {
        get { rows[0][1] }
        set { rows[0][1] = newValue }
    }

    /// Element (1,0) - standard notation: c
    @inlinable
    public var c: Scalar {
        get { rows[1][0] }
        set { rows[1][0] = newValue }
    }

    /// Element (1,1) - standard notation: d
    @inlinable
    public var d: Scalar {
        get { rows[1][1] }
        set { rows[1][1] = newValue }
    }

    /// Create a 2×2 matrix with standard notation
    ///
    /// ```
    /// | a  b |
    /// | c  d |
    /// ```
    @inlinable
    public init(a: Scalar, b: Scalar, c: Scalar, d: Scalar) {
        self.init([[a, b], [c, d]])
    }
}

// MARK: - 2D Apply (Type-Safe)

extension Geometry.Linear where N == 2, Scalar: AdditiveArithmetic & Numeric {
    /// Apply linear transformation to a typed 2D point.
    ///
    /// Computes:
    /// ```
    /// | a  b |   | x |   | a*x + b*y |
    /// | c  d | * | y | = | c*x + d*y |
    /// ```
    ///
    /// - Parameter point: The point to transform
    /// - Returns: The transformed point with preserved type safety
    @inlinable
    public func apply(to point: Geometry.Point<2>) -> Geometry.Point<2> {
        let x = point.x.value
        let y = point.y.value
        let newX = a * x + b * y
        let newY = c * x + d * y
        return Geometry.Point(x: .init(newX), y: .init(newY))
    }

    /// Apply linear transformation to typed X and Y coordinates.
    ///
    /// - Parameters:
    ///   - x: The x coordinate
    ///   - y: The y coordinate
    /// - Returns: Tuple of transformed (x, y) with preserved types
    @inlinable
    public func apply(x: Geometry.X, y: Geometry.Y) -> (x: Geometry.X, y: Geometry.Y) {
        let newX = Geometry.X(a * x.value + b * y.value)
        let newY = Geometry.Y(c * x.value + d * y.value)
        return (newX, newY)
    }
}

// MARK: - Determinant & Inversion (2D)

extension Geometry.Linear where N == 2, Scalar: FloatingPoint {
    /// The determinant of the matrix
    @inlinable
    public var determinant: Scalar {
        a * d - b * c
    }

    /// Whether this matrix is invertible
    @inlinable
    public var isInvertible: Bool {
        determinant != 0
    }

    /// The inverse matrix, or nil if not invertible
    @inlinable
    public var inverted: Self? {
        let det = determinant
        guard det != 0 else { return nil }
        let invDet: Scalar = 1 / det
        return Self(
            a: d * invDet,
            b: -b * invDet,
            c: -c * invDet,
            d: a * invDet
        )
    }
}

// MARK: - Composition (2D)

extension Geometry.Linear where N == 2, Scalar: Numeric {
    /// Concatenate with another matrix (self * other)
    ///
    /// The resulting transformation applies `other` first, then `self`.
    @inlinable
    public func concatenating(_ other: Self) -> Self {
        Self(
            a: a * other.a + b * other.c,
            b: a * other.b + b * other.d,
            c: c * other.a + d * other.c,
            d: c * other.b + d * other.d
        )
    }
}

// MARK: - Factory Methods (2D)

extension Geometry.Linear where N == 2, Scalar: FloatingPoint {
    /// Create a uniform scaling matrix
    @inlinable
    public static func scale(_ factor: Scalar) -> Self {
        Self(a: factor, b: 0, c: 0, d: factor)
    }

    /// Create a non-uniform scaling matrix
    @inlinable
    public static func scale(x: Scalar, y: Scalar) -> Self {
        Self(a: x, b: 0, c: 0, d: y)
    }

    /// Create a shear matrix
    @inlinable
    public static func shear(x: Scalar, y: Scalar) -> Self {
        Self(a: 1, b: x, c: y, d: 1)
    }
}

// MARK: - Rotation Factory (cos/sin)

extension Geometry.Linear where N == 2, Scalar: SignedNumeric {
    /// Create a rotation matrix
    ///
    /// - Parameters:
    ///   - cos: Cosine of the rotation angle
    ///   - sin: Sine of the rotation angle
    @inlinable
    public static func rotation(cos: Scalar, sin: Scalar) -> Self {
        Self(a: cos, b: -sin, c: sin, d: cos)
    }
}

// MARK: - Rotation Factory (Real & BinaryFloatingPoint)

extension Geometry.Linear where N == 2, Scalar: Real & BinaryFloatingPoint {
    /// Create a rotation matrix from an angle.
    ///
    /// Works with any `Real & BinaryFloatingPoint` type (Double, Float).
    ///
    /// - Parameter angle: Rotation angle in radians
    /// - Returns: A 2×2 rotation matrix
    @inlinable
    public static func rotation(_ angle: Radian) -> Self {
        let c = Scalar(angle.cos)
        let s = Scalar(angle.sin)
        return Self(a: c, b: -s, c: s, d: c)
    }
}

// MARK: - Decomposition Analysis (2D)

extension Geometry.Linear where N == 2, Scalar == Double {
    /// Extract the rotation angle (approximate, assumes no shear)
    ///
    /// For a pure rotation matrix, this returns the exact angle.
    /// For matrices with scale/shear, this extracts the rotational component.
    @inlinable
    public var rotationAngle: Radian {
        Radian.atan2(y: c, x: a)
    }
}

extension Geometry.Linear where N == 2, Scalar: FloatingPoint {
    /// Extract scale factors (approximate, assumes no shear)
    ///
    /// Returns the scale factors along x and y axes.
    @inlinable
    public var scaleFactors: (x: Scalar, y: Scalar) {
        let sx = (a * a + c * c).squareRoot()
        let sy = (b * b + d * d).squareRoot()
        return (sx, sy)
    }
}
