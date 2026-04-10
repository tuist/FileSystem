// Circle.swift
// A circle defined by center and radius.

public import Angle

extension Geometry {
    /// A circle in 2D space defined by its center and radius.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let circle = Geometry<Double>.Circle(
    ///     center: .init(x: 100, y: 100),
    ///     radius: 50
    /// )
    /// print(circle.area)           // ~7853.98
    /// print(circle.circumference)  // ~314.16
    /// ```
    public struct Circle {
        /// The center point of the circle
        public var center: Point<2>

        /// The radius of the circle
        public var radius: Length

        /// Create a circle with the given center and radius
        @inlinable
        public init(center: consuming Point<2>, radius: consuming Length) {
            self.center = center
            self.radius = radius
        }
    }
}

extension Geometry.Circle: Sendable where Scalar: Sendable {}
extension Geometry.Circle: Equatable where Scalar: Equatable {}
extension Geometry.Circle: Hashable where Scalar: Hashable {}

// MARK: - Codable

extension Geometry.Circle: Codable where Scalar: Codable {}

// MARK: - Convenience Initializers

extension Geometry.Circle {
    /// Create a circle with center at origin and given radius
    @inlinable
    public init(radius: Geometry.Length) where Scalar: AdditiveArithmetic {
        self.init(center: .zero, radius: radius)
    }
}

extension Geometry.Circle where Scalar: FloatingPoint {
    /// Create a circle from an ellipse, if the ellipse is actually circular.
    ///
    /// - Parameter ellipse: The ellipse to convert
    /// - Returns: A circle if the ellipse has equal semi-axes, `nil` otherwise
    @inlinable
    public init?(_ ellipse: Geometry.Ellipse) {
        let diff: Scalar = ellipse.semiMajor.value - ellipse.semiMinor.value
        guard abs(diff) < Scalar.ulpOfOne else { return nil }
        self.init(center: ellipse.center, radius: ellipse.semiMajor)
    }
}

// MARK: - Static Properties

extension Geometry.Circle where Scalar: ExpressibleByIntegerLiteral & AdditiveArithmetic {
    /// A unit circle centered at the origin with radius 1
    @inlinable
    public static var unit: Self {
        Self(center: .zero, radius: 1)
    }
}

// MARK: - Properties (FloatingPoint)

extension Geometry.Circle where Scalar: FloatingPoint {
    /// The diameter of the circle (2 * radius)
    @inlinable
    public var diameter: Geometry.Length {
        let two: Scalar = Scalar(2)
        return Geometry.Length(radius.value * two)
    }

    /// The circumference of the circle (2 * π * radius)
    @inlinable
    public var circumference: Scalar {
        let two: Scalar = Scalar(2)
        let r: Scalar = radius.value
        return two * Scalar.pi * r
    }

    /// The area of the circle (π * radius²)
    @inlinable
    public var area: Scalar {
        let r: Scalar = radius.value
        return Scalar.pi * r * r
    }

    /// The bounding rectangle of the circle
    @inlinable
    public var boundingBox: Geometry.Rectangle {
        let r: Scalar = radius.value
        let cx: Scalar = center.x.value
        let cy: Scalar = center.y.value
        return Geometry.Rectangle(
            llx: Geometry.X(cx - r),
            lly: Geometry.Y(cy - r),
            urx: Geometry.X(cx + r),
            ury: Geometry.Y(cy + r)
        )
    }
}

// MARK: - Containment (FloatingPoint)

extension Geometry.Circle where Scalar: FloatingPoint {
    /// Check if a point is inside or on the circle.
    ///
    /// - Parameter point: The point to test
    /// - Returns: `true` if the point is inside or on the circle boundary
    @inlinable
    public func contains(_ point: Geometry.Point<2>) -> Bool {
        let distSq: Scalar = center.distanceSquared(to: point)
        let r: Scalar = radius.value
        return distSq <= r * r
    }

    /// Check if a point is strictly inside the circle (not on boundary).
    ///
    /// - Parameter point: The point to test
    /// - Returns: `true` if the point is strictly inside the circle
    @inlinable
    public func containsInterior(_ point: Geometry.Point<2>) -> Bool {
        let distSq: Scalar = center.distanceSquared(to: point)
        let r: Scalar = radius.value
        return distSq < r * r
    }

    /// Check if this circle contains another circle entirely.
    ///
    /// - Parameter other: The circle to test
    /// - Returns: `true` if `other` is entirely inside this circle
    @inlinable
    public func contains(_ other: Self) -> Bool {
        let dist: Scalar = center.distance(to: other.center)
        return dist + other.radius.value <= radius.value
    }
}

// MARK: - Point on Circle (BinaryFloatingPoint)

extension Geometry.Circle where Scalar: BinaryFloatingPoint {
    /// Get the point on the circle at the given angle (measured from positive x-axis).
    ///
    /// - Parameter angle: The angle in radians
    /// - Returns: The point on the circle at that angle
    @inlinable
    public func point(at angle: Radian) -> Geometry.Point<2> {
        let c: Scalar = Scalar(angle.cos)
        let s: Scalar = Scalar(angle.sin)
        let r: Scalar = radius.value
        let cx: Scalar = center.x.value
        let cy: Scalar = center.y.value
        return Geometry.Point(
            x: Geometry.X(cx + r * c),
            y: Geometry.Y(cy + r * s)
        )
    }

    /// Get the tangent vector at the given angle (unit length, perpendicular to radius).
    ///
    /// - Parameter angle: The angle in radians
    /// - Returns: The unit tangent vector (counter-clockwise direction)
    @inlinable
    public func tangent(at angle: Radian) -> Geometry.Vector<2> {
        // Tangent is perpendicular to radius, pointing counter-clockwise
        let c: Scalar = Scalar(angle.cos)
        let s: Scalar = Scalar(angle.sin)
        return Geometry.Vector(
            dx: Geometry.X(-s),
            dy: Geometry.Y(c)
        )
    }

    /// Get the closest point on the circle to a given point.
    ///
    /// - Parameter point: The external point
    /// - Returns: The closest point on the circle boundary
    @inlinable
    public func closestPoint(to point: Geometry.Point<2>) -> Geometry.Point<2> {
        let v: Geometry.Vector<2> = Geometry.Vector(dx: point.x - center.x, dy: point.y - center.y)
        let len: Scalar = v.length
        let zero: Scalar = Scalar(0)
        let r: Scalar = radius.value
        let cx: Scalar = center.x.value
        let cy: Scalar = center.y.value
        guard len > zero else {
            // Point is at center, return any point on circle
            return Geometry.Point(
                x: Geometry.X(cx + r),
                y: center.y
            )
        }
        let scale: Scalar = r / len
        let vdx: Scalar = v.dx.value
        let vdy: Scalar = v.dy.value
        return Geometry.Point(
            x: Geometry.X(cx + vdx * scale),
            y: Geometry.Y(cy + vdy * scale)
        )
    }
}

// MARK: - Intersection (FloatingPoint)

extension Geometry.Circle where Scalar: FloatingPoint {
    /// Check if this circle intersects another circle.
    ///
    /// - Parameter other: The other circle
    /// - Returns: `true` if circles intersect or touch
    @inlinable
    public func intersects(_ other: Self) -> Bool {
        let dist: Scalar = center.distance(to: other.center)
        let sumRadii: Scalar = radius.value + other.radius.value
        let diffRadii: Scalar = abs(radius.value - other.radius.value)
        return dist <= sumRadii && dist >= diffRadii
    }

    /// Find intersection points with a line.
    ///
    /// - Parameter line: The line to intersect with
    /// - Returns: Array of 0, 1, or 2 intersection points
    @inlinable
    public func intersection(with line: Geometry.Line) -> [Geometry.Point<2>] {
        // Vector from line point to center
        let cx: Scalar = center.x.value
        let cy: Scalar = center.y.value
        let lpx: Scalar = line.point.x.value
        let lpy: Scalar = line.point.y.value
        let fx: Scalar = lpx - cx
        let fy: Scalar = lpy - cy
        let dx: Scalar = line.direction.dx.value
        let dy: Scalar = line.direction.dy.value
        let r: Scalar = radius.value

        // Quadratic equation coefficients: at² + bt + c = 0
        let a: Scalar = dx * dx + dy * dy
        let two: Scalar = Scalar(2)
        let four: Scalar = Scalar(4)
        let b: Scalar = two * (fx * dx + fy * dy)
        let c: Scalar = fx * fx + fy * fy - r * r

        let discriminant: Scalar = b * b - four * a * c
        let zero: Scalar = Scalar(0)

        guard discriminant >= zero else { return [] }

        if discriminant == zero {
            // Tangent line - one intersection
            let t: Scalar = -b / (two * a)
            return [line.point(at: t)]
        }

        // Two intersections
        let sqrtDisc: Scalar = discriminant.squareRoot()
        let t1: Scalar = (-b - sqrtDisc) / (two * a)
        let t2: Scalar = (-b + sqrtDisc) / (two * a)
        return [line.point(at: t1), line.point(at: t2)]
    }

    /// Find intersection points with another circle.
    ///
    /// - Parameter other: The other circle
    /// - Returns: Array of 0, 1, or 2 intersection points
    @inlinable
    public func intersection(with other: Self) -> [Geometry.Point<2>] {
        let d: Scalar = center.distance(to: other.center)
        let r1: Scalar = radius.value
        let r2: Scalar = other.radius.value
        let zero: Scalar = Scalar(0)
        let two: Scalar = Scalar(2)

        // No intersection if circles are too far apart or one contains the other
        guard d <= r1 + r2 && d >= abs(r1 - r2) && d > zero else {
            if d == zero && r1 == r2 {
                // Coincident circles - infinite intersections, return empty
                return []
            }
            return []
        }

        // Distance from center to the line connecting intersection points
        let a: Scalar = (r1 * r1 - r2 * r2 + d * d) / (two * d)
        let hSq: Scalar = r1 * r1 - a * a

        // Handle numerical precision for tangent case
        guard hSq >= zero else { return [] }
        let h: Scalar = hSq.squareRoot()

        // Point P2 on the line between centers
        let cx: Scalar = center.x.value
        let cy: Scalar = center.y.value
        let ocx: Scalar = other.center.x.value
        let ocy: Scalar = other.center.y.value
        let dx: Scalar = (ocx - cx) / d
        let dy: Scalar = (ocy - cy) / d
        let px: Scalar = cx + a * dx
        let py: Scalar = cy + a * dy

        if h == zero {
            // Tangent circles - one intersection
            return [Geometry.Point(x: Geometry.X(px), y: Geometry.Y(py))]
        }

        // Two intersections
        return [
            Geometry.Point(
                x: Geometry.X(px + h * dy),
                y: Geometry.Y(py - h * dx)
            ),
            Geometry.Point(
                x: Geometry.X(px - h * dy),
                y: Geometry.Y(py + h * dx)
            ),
        ]
    }
}

// MARK: - Transformation (FloatingPoint)

extension Geometry.Circle where Scalar: FloatingPoint {
    /// Return a circle translated by the given vector.
    @inlinable
    public func translated(by vector: Geometry.Vector<2>) -> Self {
        Self(center: center + vector, radius: radius)
    }

    /// Return a circle scaled uniformly about its center.
    @inlinable
    public func scaled(by factor: Scalar) -> Self {
        Self(center: center, radius: Geometry.Length(radius.value * factor))
    }

    /// Return a circle scaled uniformly about a given point.
    @inlinable
    public func scaled(by factor: Scalar, about point: Geometry.Point<2>) -> Self {
        let px: Scalar = point.x.value
        let py: Scalar = point.y.value
        let cx: Scalar = center.x.value
        let cy: Scalar = center.y.value
        let newCenter: Geometry.Point<2> = Geometry.Point(
            x: Geometry.X(px + factor * (cx - px)),
            y: Geometry.Y(py + factor * (cy - py))
        )
        return Self(center: newCenter, radius: Geometry.Length(radius.value * factor))
    }
}

// MARK: - Functorial Map

extension Geometry.Circle {
    /// Create a circle by transforming the coordinates of another circle
    @inlinable
    public init<U, E: Error>(
        _ other: borrowing Geometry<U>.Circle,
        _ transform: (U) throws(E) -> Scalar
    ) throws(E) {
        self.init(
            center: try Geometry.Point<2>(other.center, transform),
            radius: try Geometry.Length(other.radius, transform)
        )
    }

    /// Transform coordinates using the given closure
    @inlinable
    public func map<Result, E: Error>(
        _ transform: (Scalar) throws(E) -> Result
    ) throws(E) -> Geometry<Result>.Circle {
        Geometry<Result>.Circle(
            center: try center.map(transform),
            radius: try radius.map(transform)
        )
    }
}

// MARK: - Bézier Approximation

extension Geometry.Circle where Scalar: BinaryFloatingPoint {
    /// A cubic Bézier curve segment
    public struct BezierSegment {
        /// Start point
        public let start: Geometry.Point<2>
        /// First control point
        public let control1: Geometry.Point<2>
        /// Second control point
        public let control2: Geometry.Point<2>
        /// End point
        public let end: Geometry.Point<2>

        /// Create a Bézier segment with the given control points
        @inlinable
        public init(
            start: Geometry.Point<2>,
            control1: Geometry.Point<2>,
            control2: Geometry.Point<2>,
            end: Geometry.Point<2>
        ) {
            self.start = start
            self.control1 = control1
            self.control2 = control2
            self.end = end
        }
    }
}

extension Geometry.Circle.BezierSegment: Sendable where Scalar: Sendable {}

extension Geometry.Circle where Scalar: BinaryFloatingPoint {
    /// The 4 cubic Bézier curves that approximate this circle.
    ///
    /// Uses the standard constant k = 0.5522847498 (4/3 * (√2 - 1))
    /// which provides an excellent approximation of a circle.
    ///
    /// The curves start at the 3 o'clock position and proceed clockwise:
    /// 1. 3 o'clock to 6 o'clock (bottom-right quadrant)
    /// 2. 6 o'clock to 9 o'clock (bottom-left quadrant)
    /// 3. 9 o'clock to 12 o'clock (top-left quadrant)
    /// 4. 12 o'clock to 3 o'clock (top-right quadrant)
    @inlinable
    public var bezierCurves: [BezierSegment] {
        let k: Scalar = Scalar(0.5522847498) * radius.value
        let cx = center.x.value
        let cy = center.y.value
        let r = radius.value

        // Cardinal points
        let right = Geometry.Point<2>(x: .init(cx + r), y: .init(cy))
        let bottom = Geometry.Point<2>(x: .init(cx), y: .init(cy - r))
        let left = Geometry.Point<2>(x: .init(cx - r), y: .init(cy))
        let top = Geometry.Point<2>(x: .init(cx), y: .init(cy + r))

        return [
            // Bottom-right quadrant (3 o'clock to 6 o'clock)
            BezierSegment(
                start: right,
                control1: Geometry.Point<2>(x: .init(cx + r), y: .init(cy - k)),
                control2: Geometry.Point<2>(x: .init(cx + k), y: .init(cy - r)),
                end: bottom
            ),
            // Bottom-left quadrant (6 o'clock to 9 o'clock)
            BezierSegment(
                start: bottom,
                control1: Geometry.Point<2>(x: .init(cx - k), y: .init(cy - r)),
                control2: Geometry.Point<2>(x: .init(cx - r), y: .init(cy - k)),
                end: left
            ),
            // Top-left quadrant (9 o'clock to 12 o'clock)
            BezierSegment(
                start: left,
                control1: Geometry.Point<2>(x: .init(cx - r), y: .init(cy + k)),
                control2: Geometry.Point<2>(x: .init(cx - k), y: .init(cy + r)),
                end: top
            ),
            // Top-right quadrant (12 o'clock to 3 o'clock)
            BezierSegment(
                start: top,
                control1: Geometry.Point<2>(x: .init(cx + k), y: .init(cy + r)),
                control2: Geometry.Point<2>(x: .init(cx + r), y: .init(cy + k)),
                end: right
            ),
        ]
    }

    /// The starting point for rendering this circle as Bézier curves (3 o'clock position)
    @inlinable
    public var bezierStartPoint: Geometry.Point<2> {
        Geometry.Point<2>(x: .init(center.x.value + radius.value), y: center.y)
    }
}
