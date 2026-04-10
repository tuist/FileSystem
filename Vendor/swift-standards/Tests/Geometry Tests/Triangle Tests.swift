// Triangle Tests.swift
// Tests for Geometry.Triangle type.

import Testing

@testable import Geometry

@Suite
struct `Triangle Tests` {

    // MARK: - Initialization

    @Test
    func `Triangle initialization`() {
        let triangle: Geometry<Double>.Triangle = .init(
            a: .init(x: 0, y: 0),
            b: .init(x: 4, y: 0),
            c: .init(x: 2, y: 3)
        )
        #expect(triangle.a.x == 0)
        #expect(triangle.a.y == 0)
        #expect(triangle.b.x == 4)
        #expect(triangle.b.y == 0)
        #expect(triangle.c.x == 2)
        #expect(triangle.c.y == 3)
    }

    @Test
    func `Triangle init from vertices array`() {
        let vertices: [Geometry<Double>.Point<2>] = [
            .init(x: 0, y: 0),
            .init(x: 3, y: 0),
            .init(x: 0, y: 4),
        ]
        let triangle = Geometry<Double>.Triangle(vertices: vertices)
        #expect(triangle != nil)
        #expect(triangle!.a.x == 0)
        #expect(triangle!.b.x == 3)
        #expect(triangle!.c.y == 4)
    }

    @Test
    func `Triangle init from wrong size array is nil`() {
        let twoVertices: [Geometry<Double>.Point<2>] = [
            .init(x: 0, y: 0),
            .init(x: 3, y: 0),
        ]
        let triangle = Geometry<Double>.Triangle(vertices: twoVertices)
        #expect(triangle == nil)
    }

    // MARK: - Factory Methods

    @Test
    func `Right triangle factory`() {
        let triangle: Geometry<Double>.Triangle = .right(base: 3, height: 4)
        #expect(triangle.a.x == 0)
        #expect(triangle.a.y == 0)
        #expect(triangle.b.x == 3)
        #expect(triangle.b.y == 0)
        #expect(triangle.c.x == 0)
        #expect(triangle.c.y == 4)
        // Area = 0.5 * base * height = 6
        #expect(abs(triangle.area - 6) < 1e-10)
    }

    @Test
    func `Right triangle at origin`() {
        let origin: Geometry<Double>.Point<2> = .init(x: 5, y: 10)
        let triangle: Geometry<Double>.Triangle = .right(base: 3, height: 4, at: origin)
        #expect(triangle.a.x == 5)
        #expect(triangle.a.y == 10)
        #expect(triangle.b.x == 8)
        #expect(triangle.b.y == 10)
    }

    @Test
    func `Equilateral triangle factory`() {
        let triangle: Geometry<Double>.Triangle = .equilateral(sideLength: 6)
        // All sides should be equal to 6
        let sides = triangle.sideLengths
        #expect(abs(sides.ab - 6) < 1e-10)
        #expect(abs(sides.bc - 6) < 1e-10)
        #expect(abs(sides.ca - 6) < 1e-10)
    }

    @Test
    func `Equilateral triangle at origin`() {
        let origin: Geometry<Double>.Point<2> = .init(x: 10, y: 20)
        let triangle: Geometry<Double>.Triangle = .equilateral(sideLength: 4, at: origin)
        #expect(triangle.a.x == 10)
        #expect(triangle.a.y == 20)
    }

    @Test
    func `Isosceles triangle factory`() {
        let triangle = Geometry<Double>.Triangle.isosceles(base: 6, leg: 5)
        #expect(triangle != nil)
        // Base should be 6
        let sides = triangle!.sideLengths
        #expect(abs(sides.ab - 6) < 1e-10)
        // Two legs should be equal to 5
        #expect(abs(sides.bc - 5) < 1e-10)
        #expect(abs(sides.ca - 5) < 1e-10)
    }

    @Test
    func `Isosceles triangle impossible returns nil`() {
        // Leg too short to reach apex
        let triangle = Geometry<Double>.Triangle.isosceles(base: 10, leg: 2)
        #expect(triangle == nil)
    }

    // MARK: - Properties

    @Test
    func `Vertices array`() {
        let triangle: Geometry<Double>.Triangle = .init(
            a: .init(x: 0, y: 0),
            b: .init(x: 1, y: 0),
            c: .init(x: 0, y: 1)
        )
        let vertices = triangle.vertices
        #expect(vertices.count == 3)
        #expect(vertices[0] == triangle.a)
        #expect(vertices[1] == triangle.b)
        #expect(vertices[2] == triangle.c)
    }

    @Test
    func `Edges tuple`() {
        let triangle: Geometry<Double>.Triangle = .init(
            a: .init(x: 0, y: 0),
            b: .init(x: 4, y: 0),
            c: .init(x: 0, y: 3)
        )
        let edges = triangle.edges
        #expect(edges.ab.start == triangle.a)
        #expect(edges.ab.end == triangle.b)
        #expect(edges.bc.start == triangle.b)
        #expect(edges.bc.end == triangle.c)
        #expect(edges.ca.start == triangle.c)
        #expect(edges.ca.end == triangle.a)
    }

    // MARK: - Area

    @Test
    func `Area of right triangle`() {
        let triangle: Geometry<Double>.Triangle = .init(
            a: .init(x: 0, y: 0),
            b: .init(x: 4, y: 0),
            c: .init(x: 0, y: 3)
        )
        // Area = 0.5 * base * height = 0.5 * 4 * 3 = 6
        #expect(abs(triangle.area - 6) < 1e-10)
    }

    @Test
    func `Signed area CCW`() {
        let triangle: Geometry<Double>.Triangle = .init(
            a: .init(x: 0, y: 0),
            b: .init(x: 4, y: 0),
            c: .init(x: 0, y: 3)
        )
        #expect(triangle.signedArea > 0)
    }

    @Test
    func `Signed area CW`() {
        let triangle: Geometry<Double>.Triangle = .init(
            a: .init(x: 0, y: 0),
            b: .init(x: 0, y: 3),
            c: .init(x: 4, y: 0)
        )
        #expect(triangle.signedArea < 0)
    }

    // MARK: - Perimeter

    @Test
    func `Perimeter of 3-4-5 triangle`() {
        let triangle: Geometry<Double>.Triangle = .init(
            a: .init(x: 0, y: 0),
            b: .init(x: 3, y: 0),
            c: .init(x: 0, y: 4)
        )
        // Perimeter = 3 + 4 + 5 = 12
        #expect(abs(triangle.perimeter - 12) < 1e-10)
    }

    // MARK: - Centroid

    @Test
    func `Centroid`() {
        let triangle: Geometry<Double>.Triangle = .init(
            a: .init(x: 0, y: 0),
            b: .init(x: 6, y: 0),
            c: .init(x: 0, y: 6)
        )
        // Centroid = average of vertices = (2, 2)
        #expect(abs(triangle.centroid.x.value - 2) < 1e-10)
        #expect(abs(triangle.centroid.y.value - 2) < 1e-10)
    }

    // MARK: - Circumcircle

    @Test
    func `Circumcircle of right triangle`() {
        let triangle: Geometry<Double>.Triangle = .init(
            a: .init(x: 0, y: 0),
            b: .init(x: 4, y: 0),
            c: .init(x: 0, y: 3)
        )
        let circumcircle = triangle.circumcircle
        #expect(circumcircle != nil)
        // For right triangle, circumcenter is midpoint of hypotenuse
        #expect(abs(circumcircle!.center.x.value - 2) < 1e-10)
        #expect(abs(circumcircle!.center.y.value - 1.5) < 1e-10)
        // Circumradius = half of hypotenuse = 2.5
        #expect(abs(circumcircle!.radius.value - 2.5) < 1e-10)
    }

    @Test
    func `Circumcircle passes through all vertices`() {
        let triangle: Geometry<Double>.Triangle = .init(
            a: .init(x: 0, y: 0),
            b: .init(x: 5, y: 0),
            c: .init(x: 2, y: 4)
        )
        let circumcircle = triangle.circumcircle!
        let r = circumcircle.radius.value

        let da = circumcircle.center.distance(to: triangle.a)
        let db = circumcircle.center.distance(to: triangle.b)
        let dc = circumcircle.center.distance(to: triangle.c)

        #expect(abs(da - r) < 1e-10)
        #expect(abs(db - r) < 1e-10)
        #expect(abs(dc - r) < 1e-10)
    }

    // MARK: - Incircle

    @Test
    func `Incircle of 3-4-5 triangle`() {
        let triangle: Geometry<Double>.Triangle = .init(
            a: .init(x: 0, y: 0),
            b: .init(x: 3, y: 0),
            c: .init(x: 0, y: 4)
        )
        let incircle = triangle.incircle
        #expect(incircle != nil)
        // Inradius = Area / semi-perimeter = 6 / 6 = 1
        #expect(abs(incircle!.radius.value - 1) < 1e-10)
    }

    // MARK: - Containment

    @Test
    func `Contains centroid`() {
        let triangle: Geometry<Double>.Triangle = .init(
            a: .init(x: 0, y: 0),
            b: .init(x: 4, y: 0),
            c: .init(x: 2, y: 3)
        )
        #expect(triangle.contains(triangle.centroid))
    }

    @Test
    func `Contains vertex`() {
        let triangle: Geometry<Double>.Triangle = .init(
            a: .init(x: 0, y: 0),
            b: .init(x: 4, y: 0),
            c: .init(x: 2, y: 3)
        )
        #expect(triangle.contains(triangle.a))
    }

    @Test
    func `Does not contain exterior point`() {
        let triangle: Geometry<Double>.Triangle = .init(
            a: .init(x: 0, y: 0),
            b: .init(x: 4, y: 0),
            c: .init(x: 2, y: 3)
        )
        let point: Geometry<Double>.Point<2> = .init(x: 10, y: 10)
        #expect(!triangle.contains(point))
    }

    // MARK: - Barycentric Coordinates

    @Test
    func `Barycentric of vertex a`() {
        let triangle: Geometry<Double>.Triangle = .init(
            a: .init(x: 0, y: 0),
            b: .init(x: 4, y: 0),
            c: .init(x: 0, y: 3)
        )
        let bary = triangle.barycentric(triangle.a)
        #expect(bary != nil)
        #expect(abs(bary!.u - 1) < 1e-10)
        #expect(abs(bary!.v) < 1e-10)
        #expect(abs(bary!.w) < 1e-10)
    }

    @Test
    func `Barycentric of centroid`() {
        let triangle: Geometry<Double>.Triangle = .init(
            a: .init(x: 0, y: 0),
            b: .init(x: 3, y: 0),
            c: .init(x: 0, y: 3)
        )
        let bary = triangle.barycentric(triangle.centroid)
        #expect(bary != nil)
        // Centroid has equal barycentric coordinates
        #expect(abs(bary!.u - 1.0 / 3.0) < 1e-10)
        #expect(abs(bary!.v - 1.0 / 3.0) < 1e-10)
        #expect(abs(bary!.w - 1.0 / 3.0) < 1e-10)
    }

    @Test
    func `Barycentric sum is 1`() {
        let triangle: Geometry<Double>.Triangle = .init(
            a: .init(x: 0, y: 0),
            b: .init(x: 5, y: 0),
            c: .init(x: 2, y: 4)
        )
        let point: Geometry<Double>.Point<2> = .init(x: 2, y: 1)
        let bary = triangle.barycentric(point)!
        #expect(abs(bary.u + bary.v + bary.w - 1) < 1e-10)
    }

    // MARK: - Point from Barycentric

    @Test
    func `Point from barycentric vertex`() {
        let triangle: Geometry<Double>.Triangle = .init(
            a: .init(x: 0, y: 0),
            b: .init(x: 4, y: 0),
            c: .init(x: 0, y: 3)
        )
        let point = triangle.point(u: 1, v: 0, w: 0)
        #expect(abs(point.x.value - triangle.a.x.value) < 1e-10)
        #expect(abs(point.y.value - triangle.a.y.value) < 1e-10)
    }

    @Test
    func `Point from barycentric centroid`() {
        let triangle: Geometry<Double>.Triangle = .init(
            a: .init(x: 0, y: 0),
            b: .init(x: 6, y: 0),
            c: .init(x: 0, y: 6)
        )
        let point = triangle.point(u: 1.0 / 3.0, v: 1.0 / 3.0, w: 1.0 / 3.0)
        #expect(abs(point.x.value - 2) < 1e-10)
        #expect(abs(point.y.value - 2) < 1e-10)
    }

    // MARK: - Bounding Box

    @Test
    func `Bounding box`() {
        let triangle: Geometry<Double>.Triangle = .init(
            a: .init(x: 1, y: 2),
            b: .init(x: 5, y: 3),
            c: .init(x: 3, y: 7)
        )
        let bbox = triangle.boundingBox
        #expect(bbox.llx == 1)
        #expect(bbox.lly == 2)
        #expect(bbox.urx == 5)
        #expect(bbox.ury == 7)
    }

    // MARK: - Transformation

    @Test
    func `Translation`() {
        let triangle: Geometry<Double>.Triangle = .init(
            a: .init(x: 0, y: 0),
            b: .init(x: 1, y: 0),
            c: .init(x: 0, y: 1)
        )
        let translated = triangle.translated(by: .init(dx: 5, dy: 10))
        #expect(translated.a.x == 5)
        #expect(translated.a.y == 10)
        #expect(translated.b.x == 6)
        #expect(translated.b.y == 10)
    }

    @Test
    func `Scaling`() {
        let triangle: Geometry<Double>.Triangle = .init(
            a: .init(x: 0, y: 0),
            b: .init(x: 2, y: 0),
            c: .init(x: 0, y: 2)
        )
        let scaled = triangle.scaled(by: 2, about: triangle.a)
        #expect(scaled.a.x == 0)
        #expect(scaled.a.y == 0)
        #expect(scaled.b.x == 4)
        #expect(scaled.c.y == 4)
    }

    // MARK: - Functorial Map

    @Test
    func `Triangle map`() {
        let triangle: Geometry<Double>.Triangle = .init(
            a: .init(x: 0, y: 0),
            b: .init(x: 1, y: 0),
            c: .init(x: 0, y: 1)
        )
        let mapped: Geometry<Float>.Triangle = triangle.map { Float($0) }
        #expect(mapped.a.x.value == 0)
        #expect(mapped.b.x.value == 1)
        #expect(mapped.c.y.value == 1)
    }
}
