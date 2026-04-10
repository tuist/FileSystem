// Bezier.swift
// Bezier curves of arbitrary degree.

public import Angle

extension Geometry {
    /// A Bezier curve defined by control points.
    ///
    /// Supports curves of any degree:
    /// - Degree 1 (2 points): Linear
    /// - Degree 2 (3 points): Quadratic
    /// - Degree 3 (4 points): Cubic
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Cubic Bezier curve
    /// let curve = Geometry<Double>.Bezier(controlPoints: [
    ///     .init(x: 0, y: 0),
    ///     .init(x: 1, y: 2),
    ///     .init(x: 3, y: 2),
    ///     .init(x: 4, y: 0)
    /// ])
    /// let midpoint = curve.point(at: 0.5)
    /// ```
    public struct Bezier {
        /// The control points defining the curve
        public var controlPoints: [Point<2>]

        /// Create a Bezier curve from control points
        @inlinable
        public init(controlPoints: consuming [Point<2>]) {
            self.controlPoints = controlPoints
        }
    }
}

extension Geometry.Bezier: Sendable where Scalar: Sendable {}
extension Geometry.Bezier: Equatable where Scalar: Equatable {}
extension Geometry.Bezier: Hashable where Scalar: Hashable {}

// MARK: - Codable

extension Geometry.Bezier: Codable where Scalar: Codable {}

// MARK: - Basic Properties

extension Geometry.Bezier {
    /// The degree of the curve (number of control points - 1)
    @inlinable
    public var degree: Int { max(0, controlPoints.count - 1) }

    /// Whether this is a valid Bezier curve (at least 2 control points)
    @inlinable
    public var isValid: Bool { controlPoints.count >= 2 }

    /// The start point of the curve
    @inlinable
    public var startPoint: Geometry.Point<2>? { controlPoints.first }

    /// The end point of the curve
    @inlinable
    public var endPoint: Geometry.Point<2>? { controlPoints.last }
}

// MARK: - Convenience Initializers

extension Geometry.Bezier {
    /// Create a linear (degree 1) Bezier curve
    @inlinable
    public static func linear(
        from start: Geometry.Point<2>,
        to end: Geometry.Point<2>
    ) -> Self {
        Self(controlPoints: [start, end])
    }

    /// Create a quadratic (degree 2) Bezier curve
    @inlinable
    public static func quadratic(
        from start: Geometry.Point<2>,
        control: Geometry.Point<2>,
        to end: Geometry.Point<2>
    ) -> Self {
        Self(controlPoints: [start, control, end])
    }

    /// Create a cubic (degree 3) Bezier curve
    @inlinable
    public static func cubic(
        from start: Geometry.Point<2>,
        control1: Geometry.Point<2>,
        control2: Geometry.Point<2>,
        to end: Geometry.Point<2>
    ) -> Self {
        Self(controlPoints: [start, control1, control2, end])
    }
}

// MARK: - Evaluation (FloatingPoint)

extension Geometry.Bezier where Scalar: FloatingPoint {
    /// Evaluate the curve at parameter t using de Casteljau's algorithm.
    ///
    /// - Parameter t: Parameter in [0, 1] (0 = start, 1 = end)
    /// - Returns: The point on the curve at parameter t
    @inlinable
    public func point(at t: Scalar) -> Geometry.Point<2>? {
        guard isValid else { return nil }

        // de Casteljau's algorithm
        var points = controlPoints
        while points.count > 1 {
            var next: [Geometry.Point<2>] = []
            next.reserveCapacity(points.count - 1)
            for i in 0..<(points.count - 1) {
                let p = points[i].lerp(to: points[i + 1], t: t)
                next.append(p)
            }
            points = next
        }
        return points.first
    }

    /// Evaluate the derivative (tangent vector) at parameter t.
    ///
    /// - Parameter t: Parameter in [0, 1]
    /// - Returns: The tangent vector at parameter t, or nil if curve is invalid
    @inlinable
    public func derivative(at t: Scalar) -> Geometry.Vector<2>? {
        guard controlPoints.count >= 2 else { return nil }

        // Derivative of Bezier curve is n * Bezier(P[i+1] - P[i])
        let n = Scalar(controlPoints.count - 1)

        // Create derivative control points
        var derivPoints: [Geometry.Point<2>] = []
        derivPoints.reserveCapacity(controlPoints.count - 1)
        for i in 0..<(controlPoints.count - 1) {
            let dx = controlPoints[i + 1].x.value - controlPoints[i].x.value
            let dy = controlPoints[i + 1].y.value - controlPoints[i].y.value
            derivPoints.append(Geometry.Point(x: Geometry.X(dx), y: Geometry.Y(dy)))
        }

        // Evaluate the derivative curve
        var points = derivPoints
        while points.count > 1 {
            var next: [Geometry.Point<2>] = []
            next.reserveCapacity(points.count - 1)
            for i in 0..<(points.count - 1) {
                let p = points[i].lerp(to: points[i + 1], t: t)
                next.append(p)
            }
            points = next
        }

        guard let p = points.first else { return nil }
        return Geometry.Vector(dx: Geometry.X(n * p.x.value), dy: Geometry.Y(n * p.y.value))
    }

    /// Get the tangent direction (normalized) at parameter t.
    ///
    /// - Parameter t: Parameter in [0, 1]
    /// - Returns: The unit tangent vector, or nil if tangent is zero
    @inlinable
    public func tangent(at t: Scalar) -> Geometry.Vector<2>? {
        guard let d = derivative(at: t) else { return nil }
        let len = d.length
        guard len > 0 else { return nil }
        return d / len
    }

    /// Get the normal direction (perpendicular to tangent) at parameter t.
    ///
    /// - Parameter t: Parameter in [0, 1]
    /// - Returns: The unit normal vector (rotated 90° CCW from tangent)
    @inlinable
    public func normal(at t: Scalar) -> Geometry.Vector<2>? {
        guard let tang = tangent(at: t) else { return nil }
        // Rotate 90° counter-clockwise
        return Geometry.Vector(dx: Geometry.X(-tang.dy.value), dy: Geometry.Y(tang.dx.value))
    }
}

// MARK: - Subdivision (FloatingPoint)

extension Geometry.Bezier where Scalar: FloatingPoint {
    /// Split the curve at parameter t into two curves.
    ///
    /// Uses de Casteljau's algorithm to compute the split.
    ///
    /// - Parameter t: Parameter in [0, 1] where to split
    /// - Returns: Tuple of (left curve, right curve), or nil if invalid
    @inlinable
    public func split(at t: Scalar) -> (left: Self, right: Self)? {
        guard isValid else { return nil }

        var leftPoints: [Geometry.Point<2>] = []
        var rightPoints: [Geometry.Point<2>] = []

        leftPoints.reserveCapacity(controlPoints.count)
        rightPoints.reserveCapacity(controlPoints.count)

        var points = controlPoints
        leftPoints.append(points.first!)
        rightPoints.insert(points.last!, at: 0)

        while points.count > 1 {
            var next: [Geometry.Point<2>] = []
            next.reserveCapacity(points.count - 1)
            for i in 0..<(points.count - 1) {
                let p = points[i].lerp(to: points[i + 1], t: t)
                next.append(p)
            }
            leftPoints.append(next.first!)
            rightPoints.insert(next.last!, at: 0)
            points = next
        }

        return (Self(controlPoints: leftPoints), Self(controlPoints: rightPoints))
    }

    /// Subdivide the curve into multiple segments for approximation.
    ///
    /// - Parameter segments: Number of segments to create
    /// - Returns: Array of points along the curve
    @inlinable
    public func subdivide(into segments: Int) -> [Geometry.Point<2>] {
        guard segments > 0 else { return [] }

        var points: [Geometry.Point<2>] = []
        points.reserveCapacity(segments + 1)

        for i in 0...segments {
            let t = Scalar(i) / Scalar(segments)
            if let p = point(at: t) {
                points.append(p)
            }
        }

        return points
    }
}

// MARK: - Bounding Box (Comparable)

extension Geometry.Bezier where Scalar: Comparable {
    /// A conservative bounding box (control point hull).
    ///
    /// This is the axis-aligned bounding box of the control points,
    /// which always contains the curve.
    @inlinable
    public var boundingBoxConservative: Geometry.Rectangle? {
        guard let first = controlPoints.first else { return nil }

        var minX = first.x.value
        var maxX = first.x.value
        var minY = first.y.value
        var maxY = first.y.value

        for point in controlPoints.dropFirst() {
            minX = min(minX, point.x.value)
            maxX = max(maxX, point.x.value)
            minY = min(minY, point.y.value)
            maxY = max(maxY, point.y.value)
        }

        return Geometry.Rectangle(
            llx: Geometry.X(minX),
            lly: Geometry.Y(minY),
            urx: Geometry.X(maxX),
            ury: Geometry.Y(maxY)
        )
    }
}

// MARK: - Length Approximation (FloatingPoint)

extension Geometry.Bezier where Scalar: FloatingPoint {
    /// Approximate the arc length of the curve.
    ///
    /// Uses subdivision to approximate the length by summing chord lengths.
    ///
    /// - Parameter segments: Number of segments for approximation (default 100)
    /// - Returns: Approximate arc length
    @inlinable
    public func length(segments: Int = 100) -> Scalar {
        let points = subdivide(into: segments)
        guard points.count >= 2 else { return .zero }

        var len: Scalar = .zero
        for i in 0..<(points.count - 1) {
            len += points[i].distance(to: points[i + 1])
        }
        return len
    }
}

// MARK: - Transformation (FloatingPoint)

extension Geometry.Bezier where Scalar: FloatingPoint {
    /// Return a curve translated by the given vector.
    @inlinable
    public func translated(by vector: Geometry.Vector<2>) -> Self {
        Self(controlPoints: controlPoints.map { $0 + vector })
    }

    /// Return a curve scaled uniformly about its start point.
    @inlinable
    public func scaled(by factor: Scalar) -> Self? {
        guard let start = startPoint else { return nil }
        return scaled(by: factor, about: start)
    }

    /// Return a curve scaled uniformly about a given point.
    @inlinable
    public func scaled(by factor: Scalar, about point: Geometry.Point<2>) -> Self {
        Self(
            controlPoints: controlPoints.map { p in
                Geometry.Point(
                    x: Geometry.X(point.x.value + factor * (p.x.value - point.x.value)),
                    y: Geometry.Y(point.y.value + factor * (p.y.value - point.y.value))
                )
            }
        )
    }

    /// Return the curve with reversed direction.
    @inlinable
    public var reversed: Self {
        Self(controlPoints: controlPoints.reversed())
    }
}

// MARK: - Ellipse Approximation (BinaryFloatingPoint)

extension Geometry.Bezier where Scalar: BinaryFloatingPoint {
    /// Create cubic Bezier curves that approximate an ellipse.
    ///
    /// Uses the standard technique of splitting the ellipse into 4 quadrants,
    /// each approximated by a cubic Bezier curve.
    ///
    /// - Parameter ellipse: The ellipse to approximate
    /// - Returns: Array of 4 cubic Bezier curves approximating the ellipse
    @inlinable
    public static func approximating(_ ellipse: Geometry.Ellipse) -> [Self] {
        // Control point factor for 90° arc approximation
        // k = (4/3) * tan(π/8) ≈ 0.5522847498
        let k: Scalar = Scalar(0.5522847498307936)

        let cx: Scalar = ellipse.center.x.value
        let cy: Scalar = ellipse.center.y.value
        let a: Scalar = ellipse.semiMajor.value
        let b: Scalar = ellipse.semiMinor.value
        let cosR: Scalar = Scalar(ellipse.rotation.cos)
        let sinR: Scalar = Scalar(ellipse.rotation.sin)

        // Helper to rotate a point around the center
        func rotated(x: Scalar, y: Scalar) -> Geometry.Point<2> {
            let rx: Scalar = x * cosR - y * sinR
            let ry: Scalar = x * sinR + y * cosR
            return Geometry.Point(
                x: Geometry.X(cx + rx),
                y: Geometry.Y(cy + ry)
            )
        }

        // Cardinal points on the unrotated ellipse (relative to center)
        let right = rotated(x: a, y: Scalar(0))
        let top = rotated(x: Scalar(0), y: b)
        let left = rotated(x: -a, y: Scalar(0))
        let bottom = rotated(x: Scalar(0), y: -b)

        // Control point offsets
        let ka: Scalar = k * a
        let kb: Scalar = k * b

        // Control points for each quadrant
        // Quadrant 1: right to top
        let c1_1 = rotated(x: a, y: kb)
        let c1_2 = rotated(x: ka, y: b)

        // Quadrant 2: top to left
        let c2_1 = rotated(x: -ka, y: b)
        let c2_2 = rotated(x: -a, y: kb)

        // Quadrant 3: left to bottom
        let c3_1 = rotated(x: -a, y: -kb)
        let c3_2 = rotated(x: -ka, y: -b)

        // Quadrant 4: bottom to right
        let c4_1 = rotated(x: ka, y: -b)
        let c4_2 = rotated(x: a, y: -kb)

        return [
            .cubic(from: right, control1: c1_1, control2: c1_2, to: top),
            .cubic(from: top, control1: c2_1, control2: c2_2, to: left),
            .cubic(from: left, control1: c3_1, control2: c3_2, to: bottom),
            .cubic(from: bottom, control1: c4_1, control2: c4_2, to: right),
        ]
    }

    /// Create cubic Bezier curves that approximate a circle.
    ///
    /// - Parameter circle: The circle to approximate
    /// - Returns: Array of 4 cubic Bezier curves approximating the circle
    @inlinable
    public static func approximating(_ circle: Geometry.Circle) -> [Self] {
        approximating(Geometry.Ellipse(circle))
    }
}

// MARK: - Functorial Map

extension Geometry.Bezier {
    /// Create a curve by transforming the coordinates of another curve
    @inlinable
    public init<U, E: Error>(
        _ other: borrowing Geometry<U>.Bezier,
        _ transform: (U) throws(E) -> Scalar
    ) throws(E) {
        var result: [Geometry.Point<2>] = []
        result.reserveCapacity(other.controlPoints.count)
        for point in other.controlPoints {
            result.append(try Geometry.Point<2>(point, transform))
        }
        self.init(controlPoints: result)
    }

    /// Transform coordinates using the given closure
    @inlinable
    public func map<Result, E: Error>(
        _ transform: (Scalar) throws(E) -> Result
    ) throws(E) -> Geometry<Result>.Bezier {
        var result: [Geometry<Result>.Point<2>] = []
        result.reserveCapacity(controlPoints.count)
        for point in controlPoints {
            result.append(try point.map(transform))
        }
        return Geometry<Result>.Bezier(controlPoints: result)
    }
}
