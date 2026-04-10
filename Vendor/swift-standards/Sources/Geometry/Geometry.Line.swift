// Line.swift
// An infinite line and its bounded segment in 2D space.

extension Geometry {
    /// An infinite line in 2D space.
    ///
    /// A line extends infinitely in both directions and can be defined by:
    /// - A point and a direction vector
    /// - Two distinct points
    ///
    /// For a bounded portion of a line, see `Line.Segment`.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Line through origin with direction (1, 1)
    /// let diagonal = Geometry<Double>.Line(
    ///     point: .init(x: 0, y: 0),
    ///     direction: .init(dx: 1, dy: 1)
    /// )
    ///
    /// // Line through two points
    /// let line = Geometry<Double>.Line(
    ///     from: .init(x: 0, y: 0),
    ///     to: .init(x: 10, y: 10)
    /// )
    /// ```
    public struct Line {
        /// A point on the line
        public var point: Point<2>

        /// The direction vector of the line (not necessarily normalized)
        public var direction: Vector<2>

        /// Create a line from a point and direction vector
        @inlinable
        public init(point: consuming Point<2>, direction: consuming Vector<2>) {
            self.point = point
            self.direction = direction
        }
    }
}

extension Geometry.Line: Sendable where Scalar: Sendable {}
extension Geometry.Line: Equatable where Scalar: Equatable {}
extension Geometry.Line: Hashable where Scalar: Hashable {}

// MARK: - Codable

extension Geometry.Line: Codable where Scalar: Codable {}

// MARK: - Factory Methods (AdditiveArithmetic)

extension Geometry.Line where Scalar: AdditiveArithmetic {
    /// Create a line through two points
    ///
    /// - Parameters:
    ///   - from: First point on the line
    ///   - to: Second point on the line
    @inlinable
    public init(from: Geometry.Point<2>, to: Geometry.Point<2>) {
        self.point = from
        self.direction = Geometry.Vector(dx: to.x - from.x, dy: to.y - from.y)
    }
}

// MARK: - FloatingPoint Operations

extension Geometry.Line where Scalar: FloatingPoint {
    /// A normalized direction vector (unit length)
    @inlinable
    public var normalizedDirection: Geometry.Vector<2> {
        direction.normalized
    }

    /// Get a point on the line at parameter t
    ///
    /// - Parameter t: The parameter (0 = base point, 1 = base point + direction)
    /// - Returns: The point at parameter t
    @inlinable
    public func point(at t: Scalar) -> Geometry.Point<2> {
        Geometry.Point(
            x: point.x + t * direction.dx,
            y: point.y + t * direction.dy
        )
    }

    /// The perpendicular distance from a point to this line.
    ///
    /// - Returns: The perpendicular distance, or `nil` if the line has zero-length direction vector.
    @inlinable
    public func distance(to other: Geometry.Point<2>) -> Scalar? {
        let len = direction.length
        guard len != 0 else { return nil }
        let v = Geometry.Vector(dx: other.x - point.x, dy: other.y - point.y)
        let cross = direction.dx * v.dy - direction.dy * v.dx
        return abs(cross) / len
    }

    /// Find the intersection point with another line.
    ///
    /// - Parameter other: Another line to intersect with
    /// - Returns: The intersection point, or `nil` if lines are parallel or coincident
    @inlinable
    public func intersection(with other: Self) -> Geometry.Point<2>? {
        // Cross product of direction vectors
        let cross = direction.dx * other.direction.dy - direction.dy * other.direction.dx

        // If cross product is near zero, lines are parallel
        guard abs(cross) > .ulpOfOne else { return nil }

        // Vector from this line's point to other line's point
        let dp = Geometry.Vector(
            dx: other.point.x - point.x,
            dy: other.point.y - point.y
        )

        // Parameter t for this line
        let t = (dp.dx * other.direction.dy - dp.dy * other.direction.dx) / cross

        return point(at: t)
    }

    /// Project a point onto this line.
    ///
    /// - Parameter point: The point to project
    /// - Returns: The closest point on the line, or `nil` if line has zero-length direction
    @inlinable
    public func projection(of other: Geometry.Point<2>) -> Geometry.Point<2>? {
        let lenSq = direction.dx * direction.dx + direction.dy * direction.dy
        guard lenSq != 0 else { return nil }

        let v = Geometry.Vector(dx: other.x - point.x, dy: other.y - point.y)
        let dot = direction.dx * v.dx + direction.dy * v.dy
        let t = dot / lenSq

        return point(at: t)
    }

    /// Reflect a point across this line.
    ///
    /// - Parameter point: The point to reflect
    /// - Returns: The reflected point, or `nil` if line has zero-length direction
    @inlinable
    public func reflection(of other: Geometry.Point<2>) -> Geometry.Point<2>? {
        guard let projected = projection(of: other) else { return nil }

        // Reflection = 2 * projection - original point
        return Geometry.Point(
            x: Geometry.X(2 * projected.x.value - other.x.value),
            y: Geometry.Y(2 * projected.y.value - other.y.value)
        )
    }
}

// MARK: - Line.Segment

extension Geometry.Line {
    /// A bounded segment of a line between two endpoints.
    ///
    /// A segment is the finite portion of a line between two points.
    /// Unlike a line which extends infinitely, a segment has definite
    /// start and end points.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let segment = Geometry<Double>.Line.Segment(
    ///     start: .init(x: 0, y: 0),
    ///     end: .init(x: 100, y: 100)
    /// )
    /// print(segment.length)  // 141.42...
    /// ```
    public struct Segment {
        /// The start point
        public var start: Geometry.Point<2>

        /// The end point
        public var end: Geometry.Point<2>

        /// Create a line segment between two points
        @inlinable
        public init(start: consuming Geometry.Point<2>, end: consuming Geometry.Point<2>) {
            self.start = start
            self.end = end
        }
    }
}

extension Geometry.Line.Segment: Sendable where Scalar: Sendable {}
extension Geometry.Line.Segment: Equatable where Scalar: Equatable {}
extension Geometry.Line.Segment: Hashable where Scalar: Hashable {}

// MARK: - Segment Codable

extension Geometry.Line.Segment: Codable where Scalar: Codable {}

// MARK: - Segment Reversed

extension Geometry.Line.Segment {
    /// Return the segment with reversed direction
    @inlinable
    public var reversed: Self {
        Self(start: end, end: start)
    }
}

// MARK: - Segment Vector (AdditiveArithmetic)

extension Geometry.Line.Segment where Scalar: AdditiveArithmetic {
    /// The vector from start to end
    @inlinable
    public var vector: Geometry.Vector2 {
        Geometry.Vector2(dx: end.x - start.x, dy: end.y - start.y)
    }

    /// The infinite line containing this segment
    @inlinable
    public var line: Geometry.Line {
        Geometry.Line(point: start, direction: vector)
    }
}

// MARK: - Segment FloatingPoint Operations

extension Geometry.Line.Segment where Scalar: FloatingPoint {
    /// The squared length of the segment
    ///
    /// Use this when comparing lengths to avoid the sqrt computation.
    @inlinable
    public var lengthSquared: Scalar {
        vector.lengthSquared
    }

    /// The length of the segment
    @inlinable
    public var length: Scalar {
        vector.length
    }

    /// The midpoint of the segment
    @inlinable
    public var midpoint: Geometry.Point<2> {
        Geometry.Point(
            x: (start.x + end.x) / 2,
            y: (start.y + end.y) / 2
        )
    }

    /// Get a point along the segment at parameter t
    ///
    /// - Parameter t: Parameter from 0 (start) to 1 (end)
    /// - Returns: The interpolated point
    @inlinable
    public func point(at t: Scalar) -> Geometry.Point<2> {
        let x = start.x + t * (end.x - start.x)
        let y = start.y + t * (end.y - start.y)
        return Geometry.Point(x: x, y: y)
    }

    /// Find the intersection point with another line segment.
    ///
    /// Uses parametric line intersection with bounds checking.
    ///
    /// - Parameter other: Another segment to intersect with
    /// - Returns: The intersection point if segments intersect, `nil` otherwise
    @inlinable
    public func intersection(with other: Self) -> Geometry.Point<2>? {
        let d1 = vector
        let d2 = other.vector

        // Cross product of direction vectors
        let cross = d1.dx * d2.dy - d1.dy * d2.dx

        // If cross product is near zero, segments are parallel
        guard abs(cross) > .ulpOfOne else { return nil }

        // Vector from this segment's start to other segment's start
        let dp = Geometry.Vector(
            dx: other.start.x - start.x,
            dy: other.start.y - start.y
        )

        // Parameters for both segments
        let t1 = (dp.dx * d2.dy - dp.dy * d2.dx) / cross
        let t2 = (dp.dx * d1.dy - dp.dy * d1.dx) / cross

        // Check if intersection is within both segments [0, 1]
        guard t1 >= 0 && t1 <= 1 && t2 >= 0 && t2 <= 1 else { return nil }

        return point(at: t1)
    }

    /// Check if this segment intersects with another segment.
    ///
    /// - Parameter other: Another segment to check
    /// - Returns: `true` if segments intersect
    @inlinable
    public func intersects(with other: Self) -> Bool {
        intersection(with: other) != nil
    }

    /// The perpendicular distance from a point to this segment.
    ///
    /// Returns the distance to the closest point on the segment (including endpoints).
    ///
    /// - Parameter point: The point to measure from
    /// - Returns: The distance to the closest point on the segment
    @inlinable
    public func distance(to other: Geometry.Point<2>) -> Scalar {
        let v = vector
        let lenSq = v.dx * v.dx + v.dy * v.dy

        // Degenerate segment (point)
        if lenSq == 0 {
            let dx = other.x.value - start.x.value
            let dy = other.y.value - start.y.value
            return (dx * dx + dy * dy).squareRoot()
        }

        // Project point onto line, clamping to segment
        let w = Geometry.Vector(dx: other.x - start.x, dy: other.y - start.y)
        let t = max(0, min(1, (v.dx * w.dx + v.dy * w.dy) / lenSq))

        let closest = point(at: t)
        let dx = other.x.value - closest.x.value
        let dy = other.y.value - closest.y.value
        return (dx * dx + dy * dy).squareRoot()
    }
}

// MARK: - Backward Compatibility Typealias

extension Geometry {
    /// A line segment between two points.
    ///
    /// This is a typealias for `Line.Segment` for backward compatibility.
    /// Prefer using `Geometry.Line.Segment` for new code.
    public typealias LineSegment = Line.Segment
}

// MARK: - Functorial Map (Line)

extension Geometry.Line {
    /// Create a line by transforming the coordinates of another line
    @inlinable
    public init<U, E: Error>(
        _ other: borrowing Geometry<U>.Line,
        _ transform: (U) throws(E) -> Scalar
    ) throws(E) {
        self.init(
            point: try Geometry.Point<2>(other.point, transform),
            direction: try Geometry.Vector<2>(other.direction, transform)
        )
    }

    /// Transform coordinates using the given closure
    @inlinable
    public func map<Result, E: Error>(
        _ transform: (Scalar) throws(E) -> Result
    ) throws(E) -> Geometry<Result>.Line {
        Geometry<Result>.Line(
            point: try point.map(transform),
            direction: try direction.map(transform)
        )
    }
}

// MARK: - Functorial Map (Line.Segment)

extension Geometry.Line.Segment {
    /// Create a segment by transforming the coordinates of another segment
    @inlinable
    public init<U, E: Error>(
        _ other: borrowing Geometry<U>.Line.Segment,
        _ transform: (U) throws(E) -> Scalar
    ) throws(E) {
        self.init(
            start: try Geometry.Point<2>(other.start, transform),
            end: try Geometry.Point<2>(other.end, transform)
        )
    }

    /// Transform coordinates using the given closure
    @inlinable
    public func map<Result, E: Error>(
        _ transform: (Scalar) throws(E) -> Result
    ) throws(E) -> Geometry<Result>.Line.Segment {
        Geometry<Result>.Line.Segment(
            start: try start.map(transform),
            end: try end.map(transform)
        )
    }
}
