// Polygon Tests.swift
// Tests for Geometry.Polygon type.

import Testing

@testable import Geometry

@Suite
struct `Polygon Tests` {

    // MARK: - Initialization

    @Test
    func `Polygon initialization`() {
        let polygon: Geometry<Double>.Polygon = .init(vertices: [
            .init(x: 0, y: 0),
            .init(x: 4, y: 0),
            .init(x: 4, y: 3),
            .init(x: 0, y: 3),
        ])
        #expect(polygon.vertices.count == 4)
        #expect(polygon.vertexCount == 4)
    }

    // MARK: - Validity

    @Test
    func `Valid polygon`() {
        let polygon: Geometry<Double>.Polygon = .init(vertices: [
            .init(x: 0, y: 0),
            .init(x: 1, y: 0),
            .init(x: 0, y: 1),
        ])
        #expect(polygon.isValid)
    }

    @Test
    func `Invalid polygon with 2 vertices`() {
        let polygon: Geometry<Double>.Polygon = .init(vertices: [
            .init(x: 0, y: 0),
            .init(x: 1, y: 0),
        ])
        #expect(!polygon.isValid)
    }

    // MARK: - Edges

    @Test
    func `Edges of triangle`() {
        let polygon: Geometry<Double>.Polygon = .init(vertices: [
            .init(x: 0, y: 0),
            .init(x: 4, y: 0),
            .init(x: 2, y: 3),
        ])
        let edges = polygon.edges
        #expect(edges.count == 3)

        // First edge: (0,0) to (4,0)
        #expect(edges[0].start.x == 0)
        #expect(edges[0].end.x == 4)

        // Last edge connects back to first vertex
        #expect(edges[2].start.x == 2)
        #expect(edges[2].end.x == 0)
    }

    @Test
    func `Edges of square`() {
        let polygon: Geometry<Double>.Polygon = .init(vertices: [
            .init(x: 0, y: 0),
            .init(x: 1, y: 0),
            .init(x: 1, y: 1),
            .init(x: 0, y: 1),
        ])
        let edges = polygon.edges
        #expect(edges.count == 4)
    }

    // MARK: - Area

    @Test
    func `Area of unit square`() {
        let polygon: Geometry<Double>.Polygon = .init(vertices: [
            .init(x: 0, y: 0),
            .init(x: 1, y: 0),
            .init(x: 1, y: 1),
            .init(x: 0, y: 1),
        ])
        #expect(abs(polygon.area - 1) < 1e-10)
    }

    @Test
    func `Area of rectangle`() {
        let polygon: Geometry<Double>.Polygon = .init(vertices: [
            .init(x: 0, y: 0),
            .init(x: 4, y: 0),
            .init(x: 4, y: 3),
            .init(x: 0, y: 3),
        ])
        #expect(abs(polygon.area - 12) < 1e-10)
    }

    @Test
    func `Area of triangle`() {
        let polygon: Geometry<Double>.Polygon = .init(vertices: [
            .init(x: 0, y: 0),
            .init(x: 4, y: 0),
            .init(x: 0, y: 3),
        ])
        #expect(abs(polygon.area - 6) < 1e-10)
    }

    @Test
    func `Signed area CCW is positive`() {
        let polygon: Geometry<Double>.Polygon = .init(vertices: [
            .init(x: 0, y: 0),
            .init(x: 1, y: 0),
            .init(x: 1, y: 1),
            .init(x: 0, y: 1),
        ])
        #expect(polygon.signedDoubleArea > 0)
    }

    @Test
    func `Signed area CW is negative`() {
        let polygon: Geometry<Double>.Polygon = .init(vertices: [
            .init(x: 0, y: 0),
            .init(x: 0, y: 1),
            .init(x: 1, y: 1),
            .init(x: 1, y: 0),
        ])
        #expect(polygon.signedDoubleArea < 0)
    }

    // MARK: - Perimeter

    @Test
    func `Perimeter of unit square`() {
        let polygon: Geometry<Double>.Polygon = .init(vertices: [
            .init(x: 0, y: 0),
            .init(x: 1, y: 0),
            .init(x: 1, y: 1),
            .init(x: 0, y: 1),
        ])
        #expect(abs(polygon.perimeter - 4) < 1e-10)
    }

    @Test
    func `Perimeter of 3-4-5 triangle`() {
        let polygon: Geometry<Double>.Polygon = .init(vertices: [
            .init(x: 0, y: 0),
            .init(x: 3, y: 0),
            .init(x: 0, y: 4),
        ])
        #expect(abs(polygon.perimeter - 12) < 1e-10)
    }

    // MARK: - Centroid

    @Test
    func `Centroid of square`() {
        let polygon: Geometry<Double>.Polygon = .init(vertices: [
            .init(x: 0, y: 0),
            .init(x: 2, y: 0),
            .init(x: 2, y: 2),
            .init(x: 0, y: 2),
        ])
        let centroid = polygon.centroid
        #expect(centroid != nil)
        #expect(abs(centroid!.x.value - 1) < 1e-10)
        #expect(abs(centroid!.y.value - 1) < 1e-10)
    }

    @Test
    func `Centroid of triangle`() {
        let polygon: Geometry<Double>.Polygon = .init(vertices: [
            .init(x: 0, y: 0),
            .init(x: 6, y: 0),
            .init(x: 0, y: 6),
        ])
        let centroid = polygon.centroid!
        #expect(abs(centroid.x.value - 2) < 1e-10)
        #expect(abs(centroid.y.value - 2) < 1e-10)
    }

    // MARK: - Bounding Box

    @Test
    func `Bounding box`() {
        let polygon: Geometry<Double>.Polygon = .init(vertices: [
            .init(x: 1, y: 2),
            .init(x: 5, y: 3),
            .init(x: 4, y: 7),
            .init(x: 2, y: 5),
        ])
        let bbox = polygon.boundingBox!
        #expect(bbox.llx == 1)
        #expect(bbox.lly == 2)
        #expect(bbox.urx == 5)
        #expect(bbox.ury == 7)
    }

    // MARK: - Convexity

    @Test
    func `Square is convex`() {
        let polygon: Geometry<Double>.Polygon = .init(vertices: [
            .init(x: 0, y: 0),
            .init(x: 1, y: 0),
            .init(x: 1, y: 1),
            .init(x: 0, y: 1),
        ])
        #expect(polygon.isConvex)
    }

    @Test
    func `L-shape is not convex`() {
        let polygon: Geometry<Double>.Polygon = .init(vertices: [
            .init(x: 0, y: 0),
            .init(x: 2, y: 0),
            .init(x: 2, y: 1),
            .init(x: 1, y: 1),
            .init(x: 1, y: 2),
            .init(x: 0, y: 2),
        ])
        #expect(!polygon.isConvex)
    }

    @Test
    func `Triangle is always convex`() {
        let polygon: Geometry<Double>.Polygon = .init(vertices: [
            .init(x: 0, y: 0),
            .init(x: 5, y: 0),
            .init(x: 2, y: 4),
        ])
        #expect(polygon.isConvex)
    }

    // MARK: - Winding

    @Test
    func `isCounterClockwise`() {
        let polygon: Geometry<Double>.Polygon = .init(vertices: [
            .init(x: 0, y: 0),
            .init(x: 1, y: 0),
            .init(x: 1, y: 1),
            .init(x: 0, y: 1),
        ])
        #expect(polygon.isCounterClockwise)
        #expect(!polygon.isClockwise)
    }

    @Test
    func `isClockwise`() {
        let polygon: Geometry<Double>.Polygon = .init(vertices: [
            .init(x: 0, y: 0),
            .init(x: 0, y: 1),
            .init(x: 1, y: 1),
            .init(x: 1, y: 0),
        ])
        #expect(polygon.isClockwise)
        #expect(!polygon.isCounterClockwise)
    }

    @Test
    func `Reversed polygon`() {
        let polygon: Geometry<Double>.Polygon = .init(vertices: [
            .init(x: 0, y: 0),
            .init(x: 1, y: 0),
            .init(x: 1, y: 1),
        ])
        let reversed = polygon.reversed
        #expect(reversed.vertices[0] == polygon.vertices[2])
        #expect(polygon.isCounterClockwise != reversed.isCounterClockwise)
    }

    // MARK: - Containment

    @Test
    func `Contains interior point`() {
        let polygon: Geometry<Double>.Polygon = .init(vertices: [
            .init(x: 0, y: 0),
            .init(x: 4, y: 0),
            .init(x: 4, y: 4),
            .init(x: 0, y: 4),
        ])
        let point: Geometry<Double>.Point<2> = .init(x: 2, y: 2)
        #expect(polygon.contains(point))
    }

    @Test
    func `Does not contain exterior point`() {
        let polygon: Geometry<Double>.Polygon = .init(vertices: [
            .init(x: 0, y: 0),
            .init(x: 4, y: 0),
            .init(x: 4, y: 4),
            .init(x: 0, y: 4),
        ])
        let point: Geometry<Double>.Point<2> = .init(x: 10, y: 10)
        #expect(!polygon.contains(point))
    }

    @Test
    func `Contains point in L-shape`() {
        let polygon: Geometry<Double>.Polygon = .init(vertices: [
            .init(x: 0, y: 0),
            .init(x: 2, y: 0),
            .init(x: 2, y: 1),
            .init(x: 1, y: 1),
            .init(x: 1, y: 2),
            .init(x: 0, y: 2),
        ])
        // Point in the bottom-left corner of the L
        let inside: Geometry<Double>.Point<2> = .init(x: 0.5, y: 0.5)
        #expect(polygon.contains(inside))

        // Point in the "cut-out" area
        let outside: Geometry<Double>.Point<2> = .init(x: 1.5, y: 1.5)
        #expect(!polygon.contains(outside))
    }

    @Test
    func `isOnBoundary`() {
        let polygon: Geometry<Double>.Polygon = .init(vertices: [
            .init(x: 0, y: 0),
            .init(x: 4, y: 0),
            .init(x: 4, y: 4),
            .init(x: 0, y: 4),
        ])
        let onEdge: Geometry<Double>.Point<2> = .init(x: 2, y: 0)
        #expect(polygon.isOnBoundary(onEdge))

        let inside: Geometry<Double>.Point<2> = .init(x: 2, y: 2)
        #expect(!polygon.isOnBoundary(inside))
    }

    // MARK: - Transformation

    @Test
    func `Translation`() {
        let polygon: Geometry<Double>.Polygon = .init(vertices: [
            .init(x: 0, y: 0),
            .init(x: 1, y: 0),
            .init(x: 0, y: 1),
        ])
        let translated = polygon.translated(by: .init(dx: 5, dy: 10))
        #expect(translated.vertices[0].x == 5)
        #expect(translated.vertices[0].y == 10)
    }

    @Test
    func `Scaling about centroid`() {
        let polygon: Geometry<Double>.Polygon = .init(vertices: [
            .init(x: 0, y: 0),
            .init(x: 2, y: 0),
            .init(x: 2, y: 2),
            .init(x: 0, y: 2),
        ])
        let scaled = polygon.scaled(by: 2)!
        // Area should be 4x
        #expect(abs(scaled.area - 16) < 1e-10)
        // Centroid should be the same
        let originalCentroid = polygon.centroid!
        let scaledCentroid = scaled.centroid!
        #expect(abs(originalCentroid.x.value - scaledCentroid.x.value) < 1e-10)
        #expect(abs(originalCentroid.y.value - scaledCentroid.y.value) < 1e-10)
    }

    @Test
    func `Scaling about point`() {
        let polygon: Geometry<Double>.Polygon = .init(vertices: [
            .init(x: 0, y: 0),
            .init(x: 1, y: 0),
            .init(x: 1, y: 1),
            .init(x: 0, y: 1),
        ])
        let scaled = polygon.scaled(by: 2, about: polygon.vertices[0])
        #expect(scaled.vertices[0].x == 0)
        #expect(scaled.vertices[0].y == 0)
        #expect(scaled.vertices[1].x == 2)
        #expect(scaled.vertices[2].y == 2)
    }

    // MARK: - Triangulation

    @Test
    func `Triangulate triangle`() {
        let polygon: Geometry<Double>.Polygon = .init(vertices: [
            .init(x: 0, y: 0),
            .init(x: 4, y: 0),
            .init(x: 2, y: 3),
        ])
        let triangles = polygon.triangulate()
        #expect(triangles.count == 1)
    }

    @Test
    func `Triangulate square`() {
        let polygon: Geometry<Double>.Polygon = .init(vertices: [
            .init(x: 0, y: 0),
            .init(x: 4, y: 0),
            .init(x: 4, y: 4),
            .init(x: 0, y: 4),
        ])
        let triangles = polygon.triangulate()
        #expect(triangles.count == 2)

        // Total area should equal original polygon area
        let totalArea = triangles.reduce(0.0) { $0 + $1.area }
        #expect(abs(totalArea - polygon.area) < 1e-10)
    }

    @Test
    func `Triangulate pentagon`() {
        let polygon: Geometry<Double>.Polygon = .init(vertices: [
            .init(x: 0, y: 0),
            .init(x: 4, y: 0),
            .init(x: 5, y: 3),
            .init(x: 2, y: 5),
            .init(x: -1, y: 3),
        ])
        let triangles = polygon.triangulate()
        #expect(triangles.count == 3)  // n - 2 triangles

        let totalArea = triangles.reduce(0.0) { $0 + $1.area }
        #expect(abs(totalArea - polygon.area) < 1e-10)
    }

    // MARK: - Functorial Map

    @Test
    func `Polygon map`() {
        let polygon: Geometry<Double>.Polygon = .init(vertices: [
            .init(x: 0, y: 0),
            .init(x: 1, y: 0),
            .init(x: 0, y: 1),
        ])
        let mapped: Geometry<Float>.Polygon = polygon.map { Float($0) }
        #expect(mapped.vertices.count == 3)
        #expect(mapped.vertices[0].x.value == 0)
        #expect(mapped.vertices[1].x.value == 1)
    }
}
