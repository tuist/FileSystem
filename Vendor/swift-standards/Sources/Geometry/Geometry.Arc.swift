// Arc.swift
// A circular arc defined by center, radius, and angle range.

public import Angle
public import RealModule

extension Geometry {
    /// A circular arc in 2D space.
    ///
    /// An arc is a portion of a circle defined by center, radius, and angle range.
    /// Angles are measured counter-clockwise from the positive x-axis.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Quarter circle arc
    /// let arc = Geometry<Double>.Arc(
    ///     center: .init(x: 0, y: 0),
    ///     radius: 10,
    ///     startAngle: .zero,
    ///     endAngle: .pi / 2
    /// )
    /// print(arc.length)  // ~15.71 (quarter of circumference)
    /// ```
    public struct Arc {
        /// The center of the arc's circle
        public var center: Point<2>

        /// The radius of the arc
        public var radius: Length

        /// The starting angle (from positive x-axis, counter-clockwise)
        public var startAngle: Radian

        /// The ending angle (from positive x-axis, counter-clockwise)
        public var endAngle: Radian

        /// Create an arc with center, radius, and angle range
        @inlinable
        public init(
            center: consuming Point<2>,
            radius: consuming Length,
            startAngle: consuming Radian,
            endAngle: consuming Radian
        ) {
            self.center = center
            self.radius = radius
            self.startAngle = startAngle
            self.endAngle = endAngle
        }
    }
}

extension Geometry.Arc: Sendable where Scalar: Sendable {}
extension Geometry.Arc: Equatable where Scalar: Equatable {}
extension Geometry.Arc: Hashable where Scalar: Hashable {}

// MARK: - Codable

extension Geometry.Arc: Codable where Scalar: Codable {}

// MARK: - Factory Methods

extension Geometry.Arc {
    /// Create a full circle arc
    @inlinable
    public static func fullCircle(center: Geometry.Point<2>, radius: Geometry.Length) -> Self {
        Self(center: center, radius: radius, startAngle: .zero, endAngle: .twoPi)
    }

    /// Create a semicircle arc
    @inlinable
    public static func semicircle(
        center: Geometry.Point<2>,
        radius: Geometry.Length,
        startAngle: Radian = .zero
    ) -> Self {
        Self(center: center, radius: radius, startAngle: startAngle, endAngle: startAngle + .pi)
    }

    /// Create a quarter circle arc
    @inlinable
    public static func quarterCircle(
        center: Geometry.Point<2>,
        radius: Geometry.Length,
        startAngle: Radian = .zero
    ) -> Self {
        Self(center: center, radius: radius, startAngle: startAngle, endAngle: startAngle + .halfPi)
    }
}

// MARK: - Angle Properties

extension Geometry.Arc {
    /// The angular span of the arc
    @inlinable
    public var sweep: Radian {
        endAngle - startAngle
    }

    /// Whether this arc sweeps counter-clockwise (positive sweep)
    @inlinable
    public var isCounterClockwise: Bool {
        sweep.value > 0
    }

    /// Whether this arc represents a full circle or more
    @inlinable
    public var isFullCircle: Bool {
        abs(sweep.value) >= Radian.twoPi.value
    }
}

// MARK: - Endpoints (Real & BinaryFloatingPoint)

extension Geometry.Arc where Scalar: Real & BinaryFloatingPoint {
    /// The starting point of the arc
    @inlinable
    public var startPoint: Geometry.Point<2> {
        Geometry.Point(
            x: Geometry.X(center.x.value + radius.value * Scalar(startAngle.cos)),
            y: Geometry.Y(center.y.value + radius.value * Scalar(startAngle.sin))
        )
    }

    /// The ending point of the arc
    @inlinable
    public var endPoint: Geometry.Point<2> {
        Geometry.Point(
            x: Geometry.X(center.x.value + radius.value * Scalar(endAngle.cos)),
            y: Geometry.Y(center.y.value + radius.value * Scalar(endAngle.sin))
        )
    }

    /// The midpoint of the arc
    @inlinable
    public var midPoint: Geometry.Point<2> {
        let midAngle = (startAngle + endAngle) / 2.0
        return Geometry.Point(
            x: Geometry.X(center.x.value + radius.value * Scalar(midAngle.cos)),
            y: Geometry.Y(center.y.value + radius.value * Scalar(midAngle.sin))
        )
    }
}

// MARK: - Point on Arc (Real & BinaryFloatingPoint)

extension Geometry.Arc where Scalar: Real & BinaryFloatingPoint {
    /// Get a point on the arc at parameter t.
    ///
    /// - Parameter t: Parameter in [0, 1] (0 = start, 1 = end)
    /// - Returns: The point on the arc at that parameter
    @inlinable
    public func point(at t: Scalar) -> Geometry.Point<2> {
        let angle = Radian(startAngle.value + Double(t) * sweep.value)
        return Geometry.Point(
            x: Geometry.X(center.x.value + radius.value * Scalar(angle.cos)),
            y: Geometry.Y(center.y.value + radius.value * Scalar(angle.sin))
        )
    }

    /// Get the tangent direction at parameter t.
    ///
    /// - Parameter t: Parameter in [0, 1]
    /// - Returns: The unit tangent vector
    @inlinable
    public func tangent(at t: Scalar) -> Geometry.Vector<2> {
        let angle = Radian(startAngle.value + Double(t) * sweep.value)
        // Tangent is perpendicular to radius, in direction of sweep
        let sign: Scalar = sweep.value >= 0 ? 1 : -1
        return Geometry.Vector(
            dx: Geometry.X(-sign * Scalar(angle.sin)),
            dy: Geometry.Y(sign * Scalar(angle.cos))
        )
    }
}

// MARK: - Length (Real & BinaryFloatingPoint)

extension Geometry.Arc where Scalar: Real & BinaryFloatingPoint {
    /// The arc length
    @inlinable
    public var length: Scalar {
        Scalar(abs(sweep.value)) * radius.value
    }
}

// MARK: - Bounding Box (Real & BinaryFloatingPoint)

extension Geometry.Arc where Scalar: Real & BinaryFloatingPoint {
    /// The axis-aligned bounding box of the arc
    @inlinable
    public var boundingBox: Geometry.Rectangle {
        let cx: Scalar = center.x.value
        let cy: Scalar = center.y.value
        let r: Scalar = radius.value

        // Special case for full circle or more
        if isFullCircle {
            return Geometry.Rectangle(
                llx: Geometry.X(cx - r),
                lly: Geometry.Y(cy - r),
                urx: Geometry.X(cx + r),
                ury: Geometry.Y(cy + r)
            )
        }

        var minX: Scalar = min(startPoint.x.value, endPoint.x.value)
        var maxX: Scalar = max(startPoint.x.value, endPoint.x.value)
        var minY: Scalar = min(startPoint.y.value, endPoint.y.value)
        var maxY: Scalar = max(startPoint.y.value, endPoint.y.value)

        // Check if arc crosses cardinal directions
        let start: Radian = startAngle.normalized
        let end: Radian = endAngle.normalized

        func containsAngle(_ angle: Radian) -> Bool {
            if sweep.value >= 0 {
                if start <= end {
                    return angle >= start && angle <= end
                } else {
                    return angle >= start || angle <= end
                }
            } else {
                if start >= end {
                    return angle <= start && angle >= end
                } else {
                    return angle <= start || angle >= end
                }
            }
        }

        // Right (0°)
        if containsAngle(.zero) {
            maxX = max(maxX, cx + r)
        }
        // Top (90°)
        if containsAngle(.halfPi) {
            maxY = max(maxY, cy + r)
        }
        // Left (180°)
        if containsAngle(.pi) {
            minX = min(minX, cx - r)
        }
        // Bottom (270°)
        if containsAngle(.pi * 1.5) {
            minY = min(minY, cy - r)
        }

        return Geometry.Rectangle(
            llx: Geometry.X(minX),
            lly: Geometry.Y(minY),
            urx: Geometry.X(maxX),
            ury: Geometry.Y(maxY)
        )
    }
}

// MARK: - Containment (Real & BinaryFloatingPoint)

extension Geometry.Arc where Scalar: Real & BinaryFloatingPoint {
    /// Check if a point lies on the arc.
    ///
    /// - Parameter point: The point to test
    /// - Returns: `true` if the point is on the arc (within tolerance)
    @inlinable
    public func contains(_ point: Geometry.Point<2>) -> Bool {
        // Check if point is at correct distance from center
        let dist = center.distance(to: point)
        guard abs(dist - radius.value) < .ulpOfOne * 100 else { return false }

        // Check if point's angle is within the arc
        let dx = point.x.value - center.x.value
        let dy = point.y.value - center.y.value
        let pointAngle = Radian.atan2(y: Double(dy), x: Double(dx))

        return angleIsInArc(pointAngle)
    }

    /// Check if an angle falls within the arc's range
    @inlinable
    internal func angleIsInArc(_ angle: Radian) -> Bool {
        let normAngle = angle.normalized
        let normStart = startAngle.normalized
        let normEnd = endAngle.normalized

        if sweep.value >= 0 {
            if normStart <= normEnd {
                return normAngle >= normStart && normAngle <= normEnd
            } else {
                return normAngle >= normStart || normAngle <= normEnd
            }
        } else {
            if normStart >= normEnd {
                return normAngle <= normStart && normAngle >= normEnd
            } else {
                return normAngle <= normStart || normAngle >= normEnd
            }
        }
    }
}

// MARK: - Array of Beziers from Arc

extension Array {
    /// Create an array of cubic Bezier curves approximating an arc.
    ///
    /// Uses the standard approximation where each Bezier spans at most 90°.
    ///
    /// - Parameter arc: The arc to approximate
    @inlinable
    public init<Scalar: Real & BinaryFloatingPoint>(
        arc: Geometry<Scalar>.Arc
    ) where Element == Geometry<Scalar>.Bezier {
        let sweepValue = arc.sweep.value
        guard abs(sweepValue) > 0 else {
            self = []
            return
        }

        // Maximum angle per Bezier segment (90° = π/2)
        let maxAngle = Double.pi / 2

        // Number of segments needed
        let segmentCount = Int((abs(sweepValue) / maxAngle).rounded(.up))
        let segmentAngle = sweepValue / Double(segmentCount)

        var beziers: [Geometry<Scalar>.Bezier] = []
        beziers.reserveCapacity(segmentCount)

        var currentAngle = arc.startAngle

        for _ in 0..<segmentCount {
            let nextAngle = currentAngle + Radian(segmentAngle)

            // Create Bezier for this segment
            let bezier = Self.arcSegmentToBezier(
                arc: arc,
                from: currentAngle,
                to: nextAngle
            )
            beziers.append(bezier)

            currentAngle = nextAngle
        }

        self = beziers
    }

    /// Convert a single arc segment (≤90°) to a cubic Bezier
    @inlinable
    internal static func arcSegmentToBezier<Scalar: Real & BinaryFloatingPoint>(
        arc: Geometry<Scalar>.Arc,
        from startAngle: Radian,
        to endAngle: Radian
    ) -> Geometry<Scalar>.Bezier where Element == Geometry<Scalar>.Bezier {
        let sweep = endAngle - startAngle
        let halfSweep = sweep.value / 2

        // Control point distance factor
        let k = Scalar(4.0 / 3.0) * Scalar.tan(Scalar(halfSweep / 2))

        let p0 = Geometry<Scalar>.Point(
            x: Geometry<Scalar>.X(arc.center.x.value + arc.radius.value * Scalar(startAngle.cos)),
            y: Geometry<Scalar>.Y(arc.center.y.value + arc.radius.value * Scalar(startAngle.sin))
        )

        let p3 = Geometry<Scalar>.Point(
            x: Geometry<Scalar>.X(arc.center.x.value + arc.radius.value * Scalar(endAngle.cos)),
            y: Geometry<Scalar>.Y(arc.center.y.value + arc.radius.value * Scalar(endAngle.sin))
        )

        // Tangent directions at start and end
        let t0x = -Scalar(startAngle.sin)
        let t0y = Scalar(startAngle.cos)
        let t1x = -Scalar(endAngle.sin)
        let t1y = Scalar(endAngle.cos)

        let p1 = Geometry<Scalar>.Point(
            x: Geometry<Scalar>.X(p0.x.value + k * arc.radius.value * t0x),
            y: Geometry<Scalar>.Y(p0.y.value + k * arc.radius.value * t0y)
        )

        let p2 = Geometry<Scalar>.Point(
            x: Geometry<Scalar>.X(p3.x.value - k * arc.radius.value * t1x),
            y: Geometry<Scalar>.Y(p3.y.value - k * arc.radius.value * t1y)
        )

        return .cubic(from: p0, control1: p1, control2: p2, to: p3)
    }
}

// MARK: - Transformation (Real & BinaryFloatingPoint)

extension Geometry.Arc where Scalar: Real & BinaryFloatingPoint {
    /// Return an arc translated by the given vector.
    @inlinable
    public func translated(by vector: Geometry.Vector<2>) -> Self {
        Self(center: center + vector, radius: radius, startAngle: startAngle, endAngle: endAngle)
    }

    /// Return an arc scaled uniformly about its center.
    @inlinable
    public func scaled(by factor: Scalar) -> Self {
        Self(
            center: center,
            radius: Geometry.Length(radius.value * factor),
            startAngle: startAngle,
            endAngle: endAngle
        )
    }

    /// Return the arc with reversed direction.
    @inlinable
    public var reversed: Self {
        Self(center: center, radius: radius, startAngle: endAngle, endAngle: startAngle)
    }
}

// MARK: - Functorial Map

extension Geometry.Arc {
    /// Create an arc by transforming the coordinates of another arc
    @inlinable
    public init<U, E: Error>(
        _ other: borrowing Geometry<U>.Arc,
        _ transform: (U) throws(E) -> Scalar
    ) throws(E) {
        self.init(
            center: try Geometry.Point<2>(other.center, transform),
            radius: try Geometry.Length(other.radius, transform),
            startAngle: other.startAngle,
            endAngle: other.endAngle
        )
    }

    /// Transform coordinates using the given closure
    @inlinable
    public func map<Result, E: Error>(
        _ transform: (Scalar) throws(E) -> Result
    ) throws(E) -> Geometry<Result>.Arc {
        Geometry<Result>.Arc(
            center: try center.map(transform),
            radius: try radius.map(transform),
            startAngle: startAngle,
            endAngle: endAngle
        )
    }
}
