// Ellipse.swift
// An ellipse defined by center, semi-axes, and rotation.

public import Angle

extension Geometry {
    /// An ellipse in 2D space defined by center, semi-axes, and rotation.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let ellipse = Geometry<Double>.Ellipse(
    ///     center: .init(x: 0, y: 0),
    ///     semiMajor: 10,
    ///     semiMinor: 5,
    ///     rotation: .zero
    /// )
    /// print(ellipse.area)  // ~157.08
    /// ```
    public struct Ellipse {
        /// The center of the ellipse
        public var center: Point<2>

        /// The semi-major axis length (larger radius)
        public var semiMajor: Length

        /// The semi-minor axis length (smaller radius)
        public var semiMinor: Length

        /// The rotation angle (counter-clockwise from x-axis to major axis)
        public var rotation: Radian

        /// Create an ellipse with center, semi-axes, and rotation
        @inlinable
        public init(
            center: consuming Point<2>,
            semiMajor: consuming Length,
            semiMinor: consuming Length,
            rotation: consuming Radian = .zero
        ) {
            self.center = center
            self.semiMajor = semiMajor
            self.semiMinor = semiMinor
            self.rotation = rotation
        }
    }
}

extension Geometry.Ellipse: Sendable where Scalar: Sendable {}
extension Geometry.Ellipse: Equatable where Scalar: Equatable {}
extension Geometry.Ellipse: Hashable where Scalar: Hashable {}

// MARK: - Codable

extension Geometry.Ellipse: Codable where Scalar: Codable {}

// MARK: - Convenience Initializers

extension Geometry.Ellipse where Scalar: AdditiveArithmetic {
    /// Create an axis-aligned ellipse centered at the origin
    @inlinable
    public init(semiMajor: Geometry.Length, semiMinor: Geometry.Length) {
        self.init(center: .zero, semiMajor: semiMajor, semiMinor: semiMinor, rotation: .zero)
    }
}

extension Geometry.Ellipse where Scalar: FloatingPoint {
    /// Create a circle as a special case of ellipse
    @inlinable
    public static func circle(center: Geometry.Point<2>, radius: Geometry.Length) -> Self {
        Self(center: center, semiMajor: radius, semiMinor: radius, rotation: .zero)
    }
}

// MARK: - Geometric Properties (FloatingPoint)

extension Geometry.Ellipse where Scalar: FloatingPoint {
    /// The major axis length (2 * semiMajor)
    @inlinable
    public var majorAxis: Scalar {
        semiMajor.value * 2
    }

    /// The minor axis length (2 * semiMinor)
    @inlinable
    public var minorAxis: Scalar {
        semiMinor.value * 2
    }

    /// The eccentricity of the ellipse (0 = circle, approaching 1 = more elongated)
    @inlinable
    public var eccentricity: Scalar {
        let a: Scalar = semiMajor.value
        let b: Scalar = semiMinor.value
        let aSq: Scalar = a * a
        let bSq: Scalar = b * b
        return ((aSq - bSq) / aSq).squareRoot()
    }

    /// The linear eccentricity (distance from center to focus)
    @inlinable
    public var focalDistance: Scalar {
        let a: Scalar = semiMajor.value
        let b: Scalar = semiMinor.value
        let aSq: Scalar = a * a
        let bSq: Scalar = b * b
        return (aSq - bSq).squareRoot()
    }
}

// MARK: - Foci (BinaryFloatingPoint)

extension Geometry.Ellipse where Scalar: BinaryFloatingPoint {
    /// The two foci of the ellipse
    @inlinable
    public var foci: (f1: Geometry.Point<2>, f2: Geometry.Point<2>) {
        let c: Scalar = focalDistance
        let cosVal: Scalar = Scalar(rotation.cos)
        let sinVal: Scalar = Scalar(rotation.sin)

        let dx: Scalar = c * cosVal
        let dy: Scalar = c * sinVal

        let cx: Scalar = center.x.value
        let cy: Scalar = center.y.value

        return (
            Geometry.Point(
                x: Geometry.X(cx - dx),
                y: Geometry.Y(cy - dy)
            ),
            Geometry.Point(
                x: Geometry.X(cx + dx),
                y: Geometry.Y(cy + dy)
            )
        )
    }
}

// MARK: - Area and Perimeter (FloatingPoint)

extension Geometry.Ellipse where Scalar: FloatingPoint {
    /// The area of the ellipse (π * a * b)
    @inlinable
    public var area: Scalar {
        let a: Scalar = semiMajor.value
        let b: Scalar = semiMinor.value
        return Scalar.pi * a * b
    }

    /// The approximate perimeter using Ramanujan's approximation
    @inlinable
    public var perimeter: Scalar {
        let a: Scalar = semiMajor.value
        let b: Scalar = semiMinor.value
        let diff: Scalar = a - b
        let sum: Scalar = a + b
        let h: Scalar = (diff * diff) / (sum * sum)
        let four: Scalar = Scalar(4)
        let three: Scalar = Scalar(3)
        let ten: Scalar = Scalar(10)
        let one: Scalar = Scalar(1)
        let sqrtTerm: Scalar = (four - three * h).squareRoot()
        return Scalar.pi * sum * (one + three * h / (ten + sqrtTerm))
    }

    /// Whether this ellipse is actually a circle
    @inlinable
    public var isCircle: Bool {
        let diff: Scalar = semiMajor.value - semiMinor.value
        return abs(diff) < Scalar.ulpOfOne
    }
}

// MARK: - Point on Ellipse (BinaryFloatingPoint)

extension Geometry.Ellipse where Scalar: BinaryFloatingPoint {
    /// Get a point on the ellipse at parameter t.
    ///
    /// - Parameter t: The parameter angle in radians (not the actual angle from center)
    /// - Returns: The point on the ellipse
    @inlinable
    public func point(at t: Radian) -> Geometry.Point<2> {
        let cosT: Scalar = Scalar(t.cos)
        let sinT: Scalar = Scalar(t.sin)
        let a: Scalar = semiMajor.value
        let b: Scalar = semiMinor.value

        // Point on unrotated ellipse
        let x: Scalar = a * cosT
        let y: Scalar = b * sinT

        // Rotate by ellipse rotation
        let cosR: Scalar = Scalar(rotation.cos)
        let sinR: Scalar = Scalar(rotation.sin)

        let cx: Scalar = center.x.value
        let cy: Scalar = center.y.value

        return Geometry.Point(
            x: Geometry.X(cx + x * cosR - y * sinR),
            y: Geometry.Y(cy + x * sinR + y * cosR)
        )
    }

    /// Get the tangent vector at parameter t.
    ///
    /// - Parameter t: The parameter angle in radians
    /// - Returns: The tangent vector (not normalized)
    @inlinable
    public func tangent(at t: Radian) -> Geometry.Vector<2> {
        let cosT: Scalar = Scalar(t.cos)
        let sinT: Scalar = Scalar(t.sin)
        let a: Scalar = semiMajor.value
        let b: Scalar = semiMinor.value

        // Derivative of point on unrotated ellipse
        let dx: Scalar = -a * sinT
        let dy: Scalar = b * cosT

        // Rotate by ellipse rotation
        let cosR: Scalar = Scalar(rotation.cos)
        let sinR: Scalar = Scalar(rotation.sin)

        return Geometry.Vector(
            dx: Geometry.X(dx * cosR - dy * sinR),
            dy: Geometry.Y(dx * sinR + dy * cosR)
        )
    }
}

// MARK: - Containment (BinaryFloatingPoint)

extension Geometry.Ellipse where Scalar: BinaryFloatingPoint {
    /// Check if a point is inside or on the ellipse.
    ///
    /// - Parameter point: The point to test
    /// - Returns: `true` if the point is inside or on the ellipse boundary
    @inlinable
    public func contains(_ point: Geometry.Point<2>) -> Bool {
        // Transform point to ellipse-local coordinates
        let dx: Scalar = point.x.value - center.x.value
        let dy: Scalar = point.y.value - center.y.value

        // Rotate by -rotation to align with axes
        let cosR: Scalar = Scalar(rotation.cos)
        let sinR: Scalar = Scalar(rotation.sin)
        let localX: Scalar = dx * cosR + dy * sinR
        let localY: Scalar = -dx * sinR + dy * cosR

        // Check ellipse equation: (x/a)² + (y/b)² ≤ 1
        let a: Scalar = semiMajor.value
        let b: Scalar = semiMinor.value
        let aSq: Scalar = a * a
        let bSq: Scalar = b * b
        let one: Scalar = Scalar(1)
        return (localX * localX) / aSq + (localY * localY) / bSq <= one
    }
}

// MARK: - Bounding Box (BinaryFloatingPoint)

extension Geometry.Ellipse where Scalar: BinaryFloatingPoint {
    /// The axis-aligned bounding box of the ellipse
    @inlinable
    public var boundingBox: Geometry.Rectangle {
        let a: Scalar = semiMajor.value
        let b: Scalar = semiMinor.value
        let cosR: Scalar = Scalar(rotation.cos)
        let sinR: Scalar = Scalar(rotation.sin)

        let aSq: Scalar = a * a
        let bSq: Scalar = b * b
        let cosSq: Scalar = cosR * cosR
        let sinSq: Scalar = sinR * sinR

        // Half-widths of the bounding box
        let halfWidth: Scalar = (aSq * cosSq + bSq * sinSq).squareRoot()
        let halfHeight: Scalar = (aSq * sinSq + bSq * cosSq).squareRoot()

        let cx: Scalar = center.x.value
        let cy: Scalar = center.y.value

        return Geometry.Rectangle(
            llx: Geometry.X(cx - halfWidth),
            lly: Geometry.Y(cy - halfHeight),
            urx: Geometry.X(cx + halfWidth),
            ury: Geometry.Y(cy + halfHeight)
        )
    }
}

// MARK: - Circle Conversion (FloatingPoint)

extension Geometry.Ellipse where Scalar: FloatingPoint {
    /// Create an ellipse from a circle.
    ///
    /// The resulting ellipse has equal semi-major and semi-minor axes
    /// equal to the circle's radius, with zero rotation.
    @inlinable
    public init(_ circle: Geometry.Circle) {
        self.init(
            center: circle.center,
            semiMajor: circle.radius,
            semiMinor: circle.radius,
            rotation: .zero
        )
    }
}

// MARK: - Transformation (FloatingPoint)

extension Geometry.Ellipse where Scalar: FloatingPoint {
    /// Return an ellipse translated by the given vector.
    @inlinable
    public func translated(by vector: Geometry.Vector<2>) -> Self {
        Self(
            center: center + vector,
            semiMajor: semiMajor,
            semiMinor: semiMinor,
            rotation: rotation
        )
    }

    /// Return an ellipse scaled uniformly about its center.
    @inlinable
    public func scaled(by factor: Scalar) -> Self {
        Self(
            center: center,
            semiMajor: Geometry.Length(semiMajor.value * factor),
            semiMinor: Geometry.Length(semiMinor.value * factor),
            rotation: rotation
        )
    }

    /// Return an ellipse rotated about its center.
    @inlinable
    public func rotated(by angle: Radian) -> Self {
        Self(
            center: center,
            semiMajor: semiMajor,
            semiMinor: semiMinor,
            rotation: rotation + angle
        )
    }
}

// MARK: - Functorial Map

extension Geometry.Ellipse {
    /// Create an ellipse by transforming the coordinates of another ellipse
    @inlinable
    public init<U, E: Error>(
        _ other: borrowing Geometry<U>.Ellipse,
        _ transform: (U) throws(E) -> Scalar
    ) throws(E) {
        self.init(
            center: try Geometry.Point<2>(other.center, transform),
            semiMajor: try Geometry.Length(other.semiMajor, transform),
            semiMinor: try Geometry.Length(other.semiMinor, transform),
            rotation: other.rotation
        )
    }

    /// Transform coordinates using the given closure
    @inlinable
    public func map<Result, E: Error>(
        _ transform: (Scalar) throws(E) -> Result
    ) throws(E) -> Geometry<Result>.Ellipse {
        Geometry<Result>.Ellipse(
            center: try center.map(transform),
            semiMajor: try semiMajor.map(transform),
            semiMinor: try semiMinor.map(transform),
            rotation: rotation
        )
    }
}
