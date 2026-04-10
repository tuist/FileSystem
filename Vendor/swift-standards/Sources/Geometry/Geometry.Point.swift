// Point.swift
// A fixed-size coordinate with compile-time known dimensions.

extension Geometry {
    /// A fixed-size coordinate/position with compile-time known dimensions.
    ///
    /// `Point` represents a position in N-dimensional space, as opposed to `Vector`
    /// which represents a displacement. This distinction enables clearer semantics:
    /// - Points can be translated by vectors
    /// - The difference of two points is a vector
    ///
    /// Uses Swift 6.2 integer generic parameters (SE-0452) for type-safe
    /// dimension checking at compile time.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let origin: Geometry.Point<2> = .zero
    /// let position = Geometry.Point(x: 72.0, y: 144.0)
    /// let position3D = Geometry.Point(x: 1.0, y: 2.0, z: 3.0)
    /// ```
    public struct Point<let N: Int> {
        /// The point coordinates stored inline
        public var coordinates: InlineArray<N, Scalar>

        /// Create a point from an inline array of coordinates
        @inlinable
        public init(_ coordinates: consuming InlineArray<N, Scalar>) {
            self.coordinates = coordinates
        }
    }
}

extension Geometry.Point: Sendable where Scalar: Sendable {}

// MARK: - Equatable

extension Geometry.Point: Equatable where Scalar: Equatable {
    @inlinable
    public static func == (lhs: borrowing Self, rhs: borrowing Self) -> Bool {
        for i in 0..<N {
            if lhs.coordinates[i] != rhs.coordinates[i] {
                return false
            }
        }
        return true
    }
}

// MARK: - Hashable

extension Geometry.Point: Hashable where Scalar: Hashable {
    @inlinable
    public func hash(into hasher: inout Hasher) {
        for i in 0..<N {
            hasher.combine(coordinates[i])
        }
    }
}

// MARK: - Typealiases

extension Geometry {
    /// A 2D point
    public typealias Point2 = Point<2>

    /// A 3D point
    public typealias Point3 = Point<3>

    /// A 4D point
    public typealias Point4 = Point<4>
}

// MARK: - Codable

extension Geometry.Point: Codable where Scalar: Codable {
    public init(from decoder: any Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var coordinates = InlineArray<N, Scalar>(repeating: try container.decode(Scalar.self))
        for i in 1..<N {
            coordinates[i] = try container.decode(Scalar.self)
        }
        self.coordinates = coordinates
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.unkeyedContainer()
        for i in 0..<N {
            try container.encode(coordinates[i])
        }
    }
}

// MARK: - Subscript

extension Geometry.Point {
    /// Access coordinate by index
    @inlinable
    public subscript(index: Int) -> Scalar {
        get { coordinates[index] }
        set { coordinates[index] = newValue }
    }
}

// MARK: - Functorial Map

extension Geometry.Point {
    /// Create a point by transforming each coordinate of another point
    @inlinable
    public init<U, E: Error>(
        _ other: borrowing Geometry<U>.Point<N>,
        _ transform: (U) throws(E) -> Scalar
    ) throws(E) {
        var coords = InlineArray<N, Scalar>(repeating: try transform(other.coordinates[0]))
        for i in 1..<N {
            coords[i] = try transform(other.coordinates[i])
        }
        self.init(coords)
    }

    /// Transform each coordinate using the given closure
    @inlinable
    public func map<Result, E: Error>(
        _ transform: (Scalar) throws(E) -> Result
    ) throws(E) -> Geometry<Result>.Point<N> {
        var result = InlineArray<N, Result>(repeating: try transform(coordinates[0]))
        for i in 1..<N {
            result[i] = try transform(coordinates[i])
        }
        return Geometry<Result>.Point<N>(result)
    }
}

// MARK: - Zero

extension Geometry.Point where Scalar: AdditiveArithmetic {
    /// The origin point (all coordinates zero)
    @inlinable
    public static var zero: Self {
        Self(InlineArray(repeating: .zero))
    }
}

// MARK: - Affine Arithmetic

extension Geometry.Point where Scalar: AdditiveArithmetic {
    /// Subtract two points to get the displacement vector between them.
    ///
    /// In affine geometry, the difference of two points is a vector representing
    /// the displacement from `rhs` to `lhs`. This is mathematically correct:
    /// `P - Q = v` means "the vector from Q to P".
    ///
    /// - Note: `Point + Point` is intentionally not provided as it has no
    ///   mathematical meaning in affine geometry. Use `Point + Vector` instead.
    @inlinable
    @_disfavoredOverload
    public static func - (lhs: borrowing Self, rhs: borrowing Self) -> Geometry.Vector<N> {
        var result = InlineArray<N, Scalar>(repeating: lhs.coordinates[0] - rhs.coordinates[0])
        for i in 1..<N {
            result[i] = lhs.coordinates[i] - rhs.coordinates[i]
        }
        return Geometry.Vector(result)
    }

    /// Translate a point by a vector (generic N-dimensional).
    ///
    /// This is the fundamental affine operation: displacing a point by a vector.
    @inlinable
    @_disfavoredOverload
    public static func + (lhs: borrowing Self, rhs: borrowing Geometry.Vector<N>) -> Self {
        var result = lhs.coordinates
        for i in 0..<N {
            result[i] = lhs.coordinates[i] + rhs.components[i]
        }
        return Self(result)
    }

    /// Translate a point backwards by a vector (generic N-dimensional).
    @inlinable
    @_disfavoredOverload
    public static func - (lhs: borrowing Self, rhs: borrowing Geometry.Vector<N>) -> Self {
        var result = lhs.coordinates
        for i in 0..<N {
            result[i] = lhs.coordinates[i] - rhs.components[i]
        }
        return Self(result)
    }
}

// MARK: - 2D Convenience

extension Geometry.Point where N == 2 {
    /// The x coordinate (type-safe)
    @inlinable
    public var x: Geometry.X {
        get { Geometry.X(coordinates[0]) }
        set { coordinates[0] = newValue.value }
    }

    /// The y coordinate (type-safe)
    @inlinable
    public var y: Geometry.Y {
        get { Geometry.Y(coordinates[1]) }
        set { coordinates[1] = newValue.value }
    }

    /// Create a 2D point with the given coordinates (type-safe)
    @inlinable
    public init(x: Geometry.X, y: Geometry.Y) {
        self.init([x.value, y.value])
    }

    /// Create a 2D point from raw scalar values
    @_disfavoredOverload
    @inlinable
    public init(x: Scalar, y: Scalar) {
        self.init([x, y])
    }
}

// MARK: - 3D Convenience

extension Geometry.Point where N == 3 {
    /// The x coordinate
    @inlinable
    public var x: Scalar {
        get { coordinates[0] }
        set { coordinates[0] = newValue }
    }

    /// The y coordinate
    @inlinable
    public var y: Scalar {
        get { coordinates[1] }
        set { coordinates[1] = newValue }
    }

    /// The z coordinate
    @inlinable
    public var z: Scalar {
        get { coordinates[2] }
        set { coordinates[2] = newValue }
    }

    /// Create a 3D point with the given coordinates
    @inlinable
    public init(x: Scalar, y: Scalar, z: Scalar) {
        self.init([x, y, z])
    }

    /// Create a 3D point from a 2D point with z coordinate
    @inlinable
    public init(_ point2: Geometry.Point<2>, z: Scalar) {
        self.init(x: point2.x.value, y: point2.y.value, z: z)
    }
}

// MARK: - 4D Convenience

extension Geometry.Point where N == 4 {
    /// The x coordinate
    @inlinable
    public var x: Scalar {
        get { coordinates[0] }
        set { coordinates[0] = newValue }
    }

    /// The y coordinate
    @inlinable
    public var y: Scalar {
        get { coordinates[1] }
        set { coordinates[1] = newValue }
    }

    /// The z coordinate
    @inlinable
    public var z: Scalar {
        get { coordinates[2] }
        set { coordinates[2] = newValue }
    }

    /// The w coordinate
    @inlinable
    public var w: Scalar {
        get { coordinates[3] }
        set { coordinates[3] = newValue }
    }

    /// Create a 4D point with the given coordinates
    @inlinable
    public init(x: Scalar, y: Scalar, z: Scalar, w: Scalar) {
        self.init([x, y, z, w])
    }

    /// Create a 4D point from a 3D point with w coordinate
    @inlinable
    public init(_ point3: Geometry.Point<3>, w: Scalar) {
        self.init(x: point3.x, y: point3.y, z: point3.z, w: w)
    }
}

// MARK: - Zip

extension Geometry.Point {
    /// Combine two points component-wise
    @inlinable
    public static func zip(_ a: Self, _ b: Self, _ combine: (Scalar, Scalar) -> Scalar) -> Self {
        var result = a.coordinates
        for i in 0..<N {
            result[i] = combine(a.coordinates[i], b.coordinates[i])
        }
        return Self(result)
    }
}

// MARK: - 2D Point Translation (AdditiveArithmetic)

extension Geometry.Point where N == 2, Scalar: AdditiveArithmetic {
    /// Translate point by delta values
    @inlinable
    public func translated(dx: Scalar, dy: Scalar) -> Self {
        Self(x: x + dx, y: y + dy)
    }

    /// Translate point by a vector
    @inlinable
    public func translated(by vector: Geometry.Vector<2>) -> Self {
        Self(x: x + vector.dx, y: y + vector.dy)
    }

    /// The vector from this point to another
    @inlinable
    public func vector(to other: Self) -> Geometry.Vector<2> {
        Geometry.Vector(dx: other.x - x, dy: other.y - y)
    }
}

// MARK: - 2D Point Distance (FloatingPoint)

extension Geometry.Point where N == 2, Scalar: FloatingPoint {
    /// The squared distance to another point
    @inlinable
    public func distanceSquared(to other: Self) -> Scalar {
        let dx = other.x - x
        let dy = other.y - y
        return dx * dx + dy * dy
    }

    /// The distance to another point
    @inlinable
    public func distance(to other: Self) -> Scalar {
        distanceSquared(to: other).squareRoot()
    }

    /// Project this point onto a line.
    ///
    /// - Parameter line: The line to project onto
    /// - Returns: The closest point on the line, or `nil` if line has zero-length direction
    @inlinable
    public func projection(onto line: Geometry.Line) -> Self? {
        line.projection(of: self)
    }

    /// Reflect this point across a line.
    ///
    /// - Parameter line: The line to reflect across
    /// - Returns: The reflected point, or `nil` if line has zero-length direction
    @inlinable
    public func reflection(across line: Geometry.Line) -> Self? {
        line.reflection(of: self)
    }

    /// The perpendicular distance from this point to a line.
    ///
    /// - Parameter line: The line to measure distance to
    /// - Returns: The perpendicular distance, or `nil` if line has zero-length direction
    @inlinable
    public func distance(to line: Geometry.Line) -> Scalar? {
        line.distance(to: self)
    }

    /// Linear interpolation between two points.
    ///
    /// - Parameters:
    ///   - other: The target point
    ///   - t: The interpolation parameter (0 = self, 1 = other)
    /// - Returns: The interpolated point
    @inlinable
    public func lerp(to other: Self, t: Scalar) -> Self {
        Self(
            x: Geometry.X(x.value + t * (other.x.value - x.value)),
            y: Geometry.Y(y.value + t * (other.y.value - y.value))
        )
    }

    /// The midpoint between two points.
    @inlinable
    public func midpoint(to other: Self) -> Self {
        Self(
            x: Geometry.X((x.value + other.x.value) / 2),
            y: Geometry.Y((y.value + other.y.value) / 2)
        )
    }
}

// MARK: - 3D Point Translation (AdditiveArithmetic)

extension Geometry.Point where N == 3, Scalar: AdditiveArithmetic {
    /// Translate point by delta values
    @inlinable
    public func translated(dx: Scalar, dy: Scalar, dz: Scalar) -> Self {
        Self(x: x + dx, y: y + dy, z: z + dz)
    }

    /// Translate point by a vector
    @inlinable
    public func translated(by vector: Geometry.Vector<3>) -> Self {
        Self(x: x + vector.dx, y: y + vector.dy, z: z + vector.dz)
    }

    /// The vector from this point to another
    @inlinable
    public func vector(to other: Self) -> Geometry.Vector<3> {
        Geometry.Vector(dx: other.x - x, dy: other.y - y, dz: other.z - z)
    }
}

// MARK: - 3D Point Distance (FloatingPoint)

extension Geometry.Point where N == 3, Scalar: FloatingPoint {
    /// The squared distance to another point
    @inlinable
    public func distanceSquared(to other: Self) -> Scalar {
        let dx = other.x - x
        let dy = other.y - y
        let dz = other.z - z
        return dx * dx + dy * dy + dz * dz
    }

    /// The distance to another point
    @inlinable
    public func distance(to other: Self) -> Scalar {
        distanceSquared(to: other).squareRoot()
    }
}
