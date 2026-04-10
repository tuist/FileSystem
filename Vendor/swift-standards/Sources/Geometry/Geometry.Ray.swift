// Ray.swift
// A half-line (ray) extending from an origin in a direction.

extension Geometry {
    /// A ray (half-line) in 2D space, extending from an origin point in a direction.
    ///
    /// Unlike a line which extends infinitely in both directions, a ray has a
    /// definite starting point (origin) and extends infinitely in only one direction.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let ray = Geometry<Double>.Ray(
    ///     origin: .init(x: 0, y: 0),
    ///     direction: .init(dx: 1, dy: 1)
    /// )
    /// let pointOnRay = ray.point(at: 5)  // (5, 5)
    /// ```
    public struct Ray {
        /// The starting point of the ray
        public var origin: Point<2>

        /// The direction of the ray (not necessarily normalized)
        public var direction: Vector<2>

        /// Create a ray from an origin point and direction vector
        @inlinable
        public init(origin: consuming Point<2>, direction: consuming Vector<2>) {
            self.origin = origin
            self.direction = direction
        }
    }
}

extension Geometry.Ray: Sendable where Scalar: Sendable {}
extension Geometry.Ray: Equatable where Scalar: Equatable {}
extension Geometry.Ray: Hashable where Scalar: Hashable {}

// MARK: - Codable

extension Geometry.Ray: Codable where Scalar: Codable {}

// MARK: - Factory Methods

extension Geometry.Ray where Scalar: AdditiveArithmetic {
    /// Create a ray from the origin to a target point
    @inlinable
    public init(from origin: Geometry.Point<2>, through point: Geometry.Point<2>) {
        self.origin = origin
        self.direction = Geometry.Vector(dx: point.x - origin.x, dy: point.y - origin.y)
    }
}

extension Geometry.Ray where Scalar: FloatingPoint {
    /// Create a ray from an origin point in a cardinal direction
    @inlinable
    public init(origin: Geometry.Point<2>, in cardinalDirection: Geometry.CardinalDirection) {
        self.origin = origin
        self.direction = cardinalDirection.unitVector
    }
}

// MARK: - Properties (FloatingPoint)

extension Geometry.Ray where Scalar: FloatingPoint {
    /// A normalized direction vector (unit length), or nil if direction is zero
    @inlinable
    public var unitDirection: Geometry.Vector<2>? {
        let len = direction.length
        guard len > 0 else { return nil }
        return direction / len
    }

    /// The infinite line containing this ray
    @inlinable
    public var line: Geometry.Line {
        Geometry.Line(point: origin, direction: direction)
    }
}

// MARK: - Point on Ray (FloatingPoint)

extension Geometry.Ray where Scalar: FloatingPoint {
    /// Get a point on the ray at parameter t.
    ///
    /// - Parameter t: The parameter (must be >= 0 for point to be on ray)
    /// - Returns: The point at parameter t
    @inlinable
    public func point(at t: Scalar) -> Geometry.Point<2> {
        Geometry.Point(
            x: Geometry.X(origin.x.value + t * direction.dx.value),
            y: Geometry.Y(origin.y.value + t * direction.dy.value)
        )
    }

    /// Check if a point lies on this ray.
    ///
    /// - Parameter point: The point to check
    /// - Returns: `true` if the point lies on the ray
    @inlinable
    public func contains(_ point: Geometry.Point<2>) -> Bool {
        let lenSq = direction.lengthSquared
        guard lenSq > 0 else { return point == origin }

        let vx = point.x.value - origin.x.value
        let vy = point.y.value - origin.y.value
        let t = (direction.dx.value * vx + direction.dy.value * vy) / lenSq

        // Must be on positive side of ray
        guard t >= 0 else { return false }

        // Check if point is actually on the line (perpendicular distance is zero)
        let projected = self.point(at: t)
        let distSq = point.distanceSquared(to: projected)
        return distSq < Scalar.ulpOfOne * 100
    }
}

// MARK: - Distance (FloatingPoint)

extension Geometry.Ray where Scalar: FloatingPoint {
    /// The perpendicular distance from a point to this ray.
    ///
    /// Returns the distance to the closest point on the ray (including origin).
    ///
    /// - Parameter point: The point to measure from
    /// - Returns: The distance to the closest point on the ray
    @inlinable
    public func distance(to point: Geometry.Point<2>) -> Scalar {
        let lenSq = direction.lengthSquared
        guard lenSq > 0 else {
            return origin.distance(to: point)
        }

        let vx = point.x.value - origin.x.value
        let vy = point.y.value - origin.y.value
        let t = max(0, (direction.dx.value * vx + direction.dy.value * vy) / lenSq)

        let closest = self.point(at: t)
        return point.distance(to: closest)
    }

    /// Get the closest point on the ray to a given point.
    ///
    /// - Parameter point: The external point
    /// - Returns: The closest point on the ray
    @inlinable
    public func closestPoint(to point: Geometry.Point<2>) -> Geometry.Point<2> {
        let lenSq = direction.lengthSquared
        guard lenSq > 0 else { return origin }

        let vx = point.x.value - origin.x.value
        let vy = point.y.value - origin.y.value
        let t = max(0, (direction.dx.value * vx + direction.dy.value * vy) / lenSq)

        return self.point(at: t)
    }
}

// MARK: - Intersection (FloatingPoint)

extension Geometry.Ray where Scalar: FloatingPoint {
    /// Find the intersection point with another ray.
    ///
    /// - Parameter other: Another ray to intersect with
    /// - Returns: The intersection point, or `nil` if rays don't intersect
    @inlinable
    public func intersection(with other: Self) -> Geometry.Point<2>? {
        let d1x = direction.dx.value
        let d1y = direction.dy.value
        let d2x = other.direction.dx.value
        let d2y = other.direction.dy.value

        // Cross product of direction vectors
        let cross = d1x * d2y - d1y * d2x

        // If cross product is near zero, rays are parallel
        guard abs(cross) > Scalar.ulpOfOne else { return nil }

        let dpx = other.origin.x.value - origin.x.value
        let dpy = other.origin.y.value - origin.y.value

        let t1 = (dpx * d2y - dpy * d2x) / cross
        let t2 = (dpx * d1y - dpy * d1x) / cross

        // Both parameters must be non-negative for intersection on both rays
        guard t1 >= 0 && t2 >= 0 else { return nil }

        return point(at: t1)
    }

    /// Find the intersection point with a line.
    ///
    /// - Parameter line: The line to intersect with
    /// - Returns: The intersection point, or `nil` if ray doesn't intersect line
    @inlinable
    public func intersection(with line: Geometry.Line) -> Geometry.Point<2>? {
        let d1x = direction.dx.value
        let d1y = direction.dy.value
        let d2x = line.direction.dx.value
        let d2y = line.direction.dy.value

        // Cross product of direction vectors
        let cross = d1x * d2y - d1y * d2x

        // If cross product is near zero, ray and line are parallel
        guard abs(cross) > Scalar.ulpOfOne else { return nil }

        let dpx = line.point.x.value - origin.x.value
        let dpy = line.point.y.value - origin.y.value

        let t = (dpx * d2y - dpy * d2x) / cross

        // Parameter must be non-negative for intersection on ray
        guard t >= 0 else { return nil }

        return point(at: t)
    }

    /// Find the intersection point with a line segment.
    ///
    /// - Parameter segment: The segment to intersect with
    /// - Returns: The intersection point, or `nil` if ray doesn't intersect segment
    @inlinable
    public func intersection(with segment: Geometry.Line.Segment) -> Geometry.Point<2>? {
        let d1x = direction.dx.value
        let d1y = direction.dy.value
        let d2x = segment.vector.dx.value
        let d2y = segment.vector.dy.value

        // Cross product of direction vectors
        let cross = d1x * d2y - d1y * d2x

        // If cross product is near zero, ray and segment are parallel
        guard abs(cross) > Scalar.ulpOfOne else { return nil }

        let dpx = segment.start.x.value - origin.x.value
        let dpy = segment.start.y.value - origin.y.value

        let t1 = (dpx * d2y - dpy * d2x) / cross
        let t2 = (dpx * d1y - dpy * d1x) / cross

        // t1 must be non-negative (on ray), t2 must be in [0, 1] (on segment)
        guard t1 >= 0 && t2 >= 0 && t2 <= 1 else { return nil }

        return point(at: t1)
    }

    /// Find intersection points with a circle.
    ///
    /// - Parameter circle: The circle to intersect with
    /// - Returns: Array of 0, 1, or 2 intersection points (only points on the ray)
    @inlinable
    public func intersection(with circle: Geometry.Circle) -> [Geometry.Point<2>] {
        // Get all line-circle intersections
        let lineIntersections = circle.intersection(with: line)

        // Filter to only points on the ray (t >= 0)
        return lineIntersections.filter { point in
            let vx = point.x.value - origin.x.value
            let vy = point.y.value - origin.y.value
            let dot = direction.dx.value * vx + direction.dy.value * vy
            return dot >= 0
        }
    }
}

// MARK: - Functorial Map

extension Geometry.Ray {
    /// Create a ray by transforming the coordinates of another ray
    @inlinable
    public init<U, E: Error>(
        _ other: borrowing Geometry<U>.Ray,
        _ transform: (U) throws(E) -> Scalar
    ) throws(E) {
        self.init(
            origin: try Geometry.Point<2>(other.origin, transform),
            direction: try Geometry.Vector<2>(other.direction, transform)
        )
    }

    /// Transform coordinates using the given closure
    @inlinable
    public func map<Result, E: Error>(
        _ transform: (Scalar) throws(E) -> Result
    ) throws(E) -> Geometry<Result>.Ray {
        Geometry<Result>.Ray(
            origin: try origin.map(transform),
            direction: try direction.map(transform)
        )
    }
}

// MARK: - Cardinal Directions

extension Geometry where Scalar: FloatingPoint {
    /// Cardinal directions for creating rays
    public enum CardinalDirection {
        case right, up, left, down

        /// The unit vector for this direction
        @inlinable
        public var unitVector: Geometry.Vector<2> {
            switch self {
            case .right: return Geometry.Vector(dx: 1, dy: 0)
            case .up: return Geometry.Vector(dx: 0, dy: 1)
            case .left: return Geometry.Vector(dx: -1, dy: 0)
            case .down: return Geometry.Vector(dx: 0, dy: -1)
            }
        }
    }
}
