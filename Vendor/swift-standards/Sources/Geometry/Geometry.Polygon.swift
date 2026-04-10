// Polygon.swift
// A polygon defined by an ordered sequence of vertices.

extension Geometry {
    /// A polygon in 2D space defined by an ordered sequence of vertices.
    ///
    /// Vertices are assumed to form a closed polygon (last vertex connects to first).
    /// For positive signed area, vertices should be ordered counter-clockwise.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // A square
    /// let square = Geometry<Double>.Polygon(vertices: [
    ///     .init(x: 0, y: 0),
    ///     .init(x: 1, y: 0),
    ///     .init(x: 1, y: 1),
    ///     .init(x: 0, y: 1)
    /// ])
    /// print(square.area)       // 1.0
    /// print(square.perimeter)  // 4.0
    /// print(square.isConvex)   // true
    /// ```
    public struct Polygon {
        /// The vertices of the polygon in order
        public var vertices: [Point<2>]

        /// Create a polygon from an array of vertices
        @inlinable
        public init(vertices: consuming [Point<2>]) {
            self.vertices = vertices
        }
    }
}

extension Geometry.Polygon: Sendable where Scalar: Sendable {}
extension Geometry.Polygon: Equatable where Scalar: Equatable {}
extension Geometry.Polygon: Hashable where Scalar: Hashable {}

// MARK: - Codable

extension Geometry.Polygon: Codable where Scalar: Codable {}

// MARK: - Basic Properties

extension Geometry.Polygon {
    /// The number of vertices (and edges)
    @inlinable
    public var vertexCount: Int { vertices.count }

    /// Whether the polygon has at least 3 vertices
    @inlinable
    public var isValid: Bool { vertices.count >= 3 }
}

// MARK: - Edges

extension Geometry.Polygon where Scalar: AdditiveArithmetic {
    /// The edges of the polygon as line segments
    @inlinable
    public var edges: [Geometry.Line.Segment] {
        guard vertices.count >= 2 else { return [] }
        var result: [Geometry.Line.Segment] = []
        result.reserveCapacity(vertices.count)
        for i in 0..<vertices.count {
            let next = (i + 1) % vertices.count
            result.append(Geometry.Line.Segment(start: vertices[i], end: vertices[next]))
        }
        return result
    }
}

// MARK: - Area and Perimeter (SignedNumeric)

extension Geometry.Polygon where Scalar: SignedNumeric {
    /// The signed area of the polygon using the shoelace formula.
    ///
    /// Positive if vertices are counter-clockwise, negative if clockwise.
    @inlinable
    public var signedDoubleArea: Scalar {
        guard vertices.count >= 3 else { return .zero }

        var sum: Scalar = .zero
        for i in 0..<vertices.count {
            let j = (i + 1) % vertices.count
            sum += (vertices[i].x.value * vertices[j].y.value)
            sum -= (vertices[j].x.value * vertices[i].y.value)
        }
        return sum
    }
}

extension Geometry.Polygon where Scalar: FloatingPoint {
    /// The area of the polygon (always positive)
    @inlinable
    public var area: Scalar {
        abs(signedDoubleArea) / 2
    }

    /// The perimeter of the polygon
    @inlinable
    public var perimeter: Scalar {
        guard vertices.count >= 2 else { return .zero }

        var sum: Scalar = .zero
        for i in 0..<vertices.count {
            let j = (i + 1) % vertices.count
            sum += vertices[i].distance(to: vertices[j])
        }
        return sum
    }
}

// MARK: - Centroid (FloatingPoint)

extension Geometry.Polygon where Scalar: FloatingPoint {
    /// The centroid (center of mass) of the polygon.
    ///
    /// Returns `nil` if the polygon has zero area.
    @inlinable
    public var centroid: Geometry.Point<2>? {
        guard vertices.count >= 3 else { return nil }

        let a = signedDoubleArea
        guard abs(a) > .ulpOfOne else { return nil }

        var cx: Scalar = .zero
        var cy: Scalar = .zero

        for i in 0..<vertices.count {
            let j = (i + 1) % vertices.count
            let cross =
                vertices[i].x.value * vertices[j].y.value - vertices[j].x.value
                * vertices[i].y.value
            cx += (vertices[i].x.value + vertices[j].x.value) * cross
            cy += (vertices[i].y.value + vertices[j].y.value) * cross
        }

        let factor: Scalar = 1 / (3 * a)
        return Geometry.Point(x: Geometry.X(cx * factor), y: Geometry.Y(cy * factor))
    }
}

// MARK: - Bounding Box (Comparable)

extension Geometry.Polygon where Scalar: Comparable {
    /// The axis-aligned bounding box of the polygon.
    ///
    /// Returns `nil` if the polygon has no vertices.
    @inlinable
    public var boundingBox: Geometry.Rectangle? {
        guard let first = vertices.first else { return nil }

        var minX = first.x.value
        var maxX = first.x.value
        var minY = first.y.value
        var maxY = first.y.value

        for vertex in vertices.dropFirst() {
            minX = min(minX, vertex.x.value)
            maxX = max(maxX, vertex.x.value)
            minY = min(minY, vertex.y.value)
            maxY = max(maxY, vertex.y.value)
        }

        return Geometry.Rectangle(
            llx: Geometry.X(minX),
            lly: Geometry.Y(minY),
            urx: Geometry.X(maxX),
            ury: Geometry.Y(maxY)
        )
    }
}

// MARK: - Convexity (SignedNumeric)

extension Geometry.Polygon where Scalar: SignedNumeric & Comparable {
    /// Whether the polygon is convex.
    ///
    /// A polygon is convex if all interior angles are less than 180 degrees,
    /// which is equivalent to all cross products of consecutive edges having
    /// the same sign.
    @inlinable
    public var isConvex: Bool {
        guard vertices.count >= 3 else { return true }

        var sign: Scalar?

        for i in 0..<vertices.count {
            let j = (i + 1) % vertices.count
            let k = (i + 2) % vertices.count

            let v1x = vertices[j].x.value - vertices[i].x.value
            let v1y = vertices[j].y.value - vertices[i].y.value
            let v2x = vertices[k].x.value - vertices[j].x.value
            let v2y = vertices[k].y.value - vertices[j].y.value

            let cross = v1x * v2y - v1y * v2x

            if let existingSign = sign {
                if cross > .zero && existingSign < .zero { return false }
                if cross < .zero && existingSign > .zero { return false }
            } else if cross != .zero {
                sign = cross
            }
        }

        return true
    }
}

// MARK: - Winding and Orientation

extension Geometry.Polygon where Scalar: SignedNumeric & Comparable {
    /// Whether the vertices are ordered counter-clockwise.
    @inlinable
    public var isCounterClockwise: Bool {
        signedDoubleArea > .zero
    }

    /// Whether the vertices are ordered clockwise.
    @inlinable
    public var isClockwise: Bool {
        signedDoubleArea < .zero
    }

    /// Return a polygon with reversed vertex order.
    @inlinable
    public var reversed: Self {
        Self(vertices: vertices.reversed())
    }
}

// MARK: - Containment (FloatingPoint)

extension Geometry.Polygon where Scalar: FloatingPoint {
    /// Check if a point is inside the polygon using the ray casting algorithm.
    ///
    /// - Parameter point: The point to test
    /// - Returns: `true` if the point is inside the polygon
    @inlinable
    public func contains(_ point: Geometry.Point<2>) -> Bool {
        guard vertices.count >= 3 else { return false }

        var inside = false
        var j = vertices.count - 1

        for i in 0..<vertices.count {
            let vi = vertices[i]
            let vj = vertices[j]

            if (vi.y.value > point.y.value) != (vj.y.value > point.y.value) {
                let slope = (vj.x.value - vi.x.value) / (vj.y.value - vi.y.value)
                let xIntersect = vi.x.value + slope * (point.y.value - vi.y.value)
                if point.x.value < xIntersect {
                    inside.toggle()
                }
            }
            j = i
        }

        return inside
    }

    /// Check if a point is on the boundary of the polygon.
    ///
    /// - Parameter point: The point to test
    /// - Returns: `true` if the point is on any edge
    @inlinable
    public func isOnBoundary(_ point: Geometry.Point<2>) -> Bool {
        for edge in edges {
            if edge.distance(to: point) < .ulpOfOne * 100 {
                return true
            }
        }
        return false
    }
}

// MARK: - Transformation (FloatingPoint)

extension Geometry.Polygon where Scalar: FloatingPoint {
    /// Return a polygon translated by the given vector.
    @inlinable
    public func translated(by vector: Geometry.Vector<2>) -> Self {
        Self(vertices: vertices.map { $0 + vector })
    }

    /// Return a polygon scaled uniformly about its centroid.
    @inlinable
    public func scaled(by factor: Scalar) -> Self? {
        guard let center = centroid else { return nil }
        return scaled(by: factor, about: center)
    }

    /// Return a polygon scaled uniformly about a given point.
    @inlinable
    public func scaled(by factor: Scalar, about point: Geometry.Point<2>) -> Self {
        Self(
            vertices: vertices.map { v in
                Geometry.Point(
                    x: Geometry.X(point.x.value + factor * (v.x.value - point.x.value)),
                    y: Geometry.Y(point.y.value + factor * (v.y.value - point.y.value))
                )
            }
        )
    }
}

// MARK: - Triangulation (FloatingPoint)

extension Geometry.Polygon where Scalar: FloatingPoint {
    /// Triangulate the polygon using ear clipping.
    ///
    /// Works correctly for simple (non-self-intersecting) polygons.
    /// Returns an array of triangles that cover the polygon.
    ///
    /// - Returns: Array of triangles, or empty array if triangulation fails
    @inlinable
    public func triangulate() -> [Geometry.Triangle] {
        guard vertices.count >= 3 else { return [] }
        if vertices.count == 3 {
            return [Geometry.Triangle(a: vertices[0], b: vertices[1], c: vertices[2])]
        }

        // Simple ear clipping - works for convex polygons and many simple polygons
        var remaining = vertices
        var triangles: [Geometry.Triangle] = []
        triangles.reserveCapacity(vertices.count - 2)

        while remaining.count > 3 {
            var earFound = false

            for i in 0..<remaining.count {
                let prev = (i + remaining.count - 1) % remaining.count
                let next = (i + 1) % remaining.count

                let a = remaining[prev]
                let b = remaining[i]
                let c = remaining[next]

                // Check if this is a convex vertex (ear candidate)
                let cross =
                    (b.x.value - a.x.value) * (c.y.value - a.y.value) - (b.y.value - a.y.value)
                    * (c.x.value - a.x.value)

                // For CCW polygon, ears have positive cross product
                guard cross > 0 else { continue }

                // Check if any other vertex is inside this triangle
                let triangle = Geometry.Triangle(a: a, b: b, c: c)
                var isEar = true

                for j in 0..<remaining.count {
                    if j == prev || j == i || j == next { continue }
                    if triangle.contains(remaining[j]) {
                        isEar = false
                        break
                    }
                }

                if isEar {
                    triangles.append(triangle)
                    remaining.remove(at: i)
                    earFound = true
                    break
                }
            }

            if !earFound {
                // Failed to find an ear - polygon might be self-intersecting
                break
            }
        }

        if remaining.count == 3 {
            triangles.append(Geometry.Triangle(a: remaining[0], b: remaining[1], c: remaining[2]))
        }

        return triangles
    }
}

// MARK: - Functorial Map

extension Geometry.Polygon {
    /// Create a polygon by transforming the coordinates of another polygon
    @inlinable
    public init<U, E: Error>(
        _ other: borrowing Geometry<U>.Polygon,
        _ transform: (U) throws(E) -> Scalar
    ) throws(E) {
        var result: [Geometry.Point<2>] = []
        result.reserveCapacity(other.vertices.count)
        for vertex in other.vertices {
            result.append(try Geometry.Point<2>(vertex, transform))
        }
        self.init(vertices: result)
    }

    /// Transform coordinates using the given closure
    @inlinable
    public func map<Result, E: Error>(
        _ transform: (Scalar) throws(E) -> Result
    ) throws(E) -> Geometry<Result>.Polygon {
        var result: [Geometry<Result>.Point<2>] = []
        result.reserveCapacity(vertices.count)
        for vertex in vertices {
            result.append(try vertex.map(transform))
        }
        return Geometry<Result>.Polygon(vertices: result)
    }
}
