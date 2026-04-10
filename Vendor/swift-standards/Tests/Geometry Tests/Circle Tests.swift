// Circle Tests.swift
// Tests for Geometry.Circle type.

import Angle
import Testing

@testable import Geometry

@Suite
struct `Circle Tests` {

    // MARK: - Initialization

    @Test
    func `Circle initialization`() {
        let circle: Geometry<Double>.Circle = .init(
            center: .init(x: 10, y: 20),
            radius: 5
        )
        #expect(circle.center.x == 10)
        #expect(circle.center.y == 20)
        #expect(circle.radius == 5)
    }

    @Test
    func `Circle at origin with radius`() {
        let circle: Geometry<Double>.Circle = .init(radius: 10)
        #expect(circle.center.x == 0)
        #expect(circle.center.y == 0)
        #expect(circle.radius == 10)
    }

    @Test
    func `Unit circle`() {
        let circle: Geometry<Double>.Circle = .unit
        #expect(circle.center.x == 0)
        #expect(circle.center.y == 0)
        #expect(circle.radius == 1)
    }

    @Test
    func `Circle from circular ellipse`() {
        let ellipse: Geometry<Double>.Ellipse = .circle(center: .init(x: 5, y: 10), radius: 7)
        let circle = Geometry<Double>.Circle(ellipse)
        #expect(circle != nil)
        #expect(circle?.center.x == 5)
        #expect(circle?.center.y == 10)
        #expect(circle?.radius == 7)
    }

    @Test
    func `Circle from non-circular ellipse is nil`() {
        let ellipse: Geometry<Double>.Ellipse = .init(semiMajor: 10, semiMinor: 5)
        let circle = Geometry<Double>.Circle(ellipse)
        #expect(circle == nil)
    }

    // MARK: - Properties

    @Test
    func `Circle diameter`() {
        let circle: Geometry<Double>.Circle = .init(center: .zero, radius: 5)
        #expect(circle.diameter == 10)
    }

    @Test
    func `Circle circumference`() {
        let circle: Geometry<Double>.Circle = .init(center: .zero, radius: 1)
        #expect(abs(circle.circumference - 2 * .pi) < 1e-10)
    }

    @Test
    func `Circle area`() {
        let circle: Geometry<Double>.Circle = .init(center: .zero, radius: 2)
        #expect(abs(circle.area - 4 * .pi) < 1e-10)
    }

    // MARK: - Containment

    @Test
    func `Circle contains center`() {
        let circle: Geometry<Double>.Circle = .init(
            center: .init(x: 5, y: 5),
            radius: 10
        )
        #expect(circle.contains(circle.center))
    }

    @Test
    func `Circle contains interior point`() {
        let circle: Geometry<Double>.Circle = .init(center: .zero, radius: 10)
        let point: Geometry<Double>.Point<2> = .init(x: 3, y: 4)  // distance 5
        #expect(circle.contains(point))
    }

    @Test
    func `Circle contains boundary point`() {
        let circle: Geometry<Double>.Circle = .init(center: .zero, radius: 5)
        let point: Geometry<Double>.Point<2> = .init(x: 3, y: 4)  // distance 5
        #expect(circle.contains(point))
    }

    @Test
    func `Circle does not contain exterior point`() {
        let circle: Geometry<Double>.Circle = .init(center: .zero, radius: 5)
        let point: Geometry<Double>.Point<2> = .init(x: 6, y: 8)  // distance 10
        #expect(!circle.contains(point))
    }

    // MARK: - Point on Circle

    @Test
    func `Point at parameter 0`() {
        let circle: Geometry<Double>.Circle = .init(center: .zero, radius: 5)
        let point = circle.point(at: .zero)
        #expect(abs(point.x.value - 5) < 1e-10)
        #expect(abs(point.y.value) < 1e-10)
    }

    @Test
    func `Point at parameter pi/2`() {
        let circle: Geometry<Double>.Circle = .init(center: .zero, radius: 5)
        let point = circle.point(at: .halfPi)
        #expect(abs(point.x.value) < 1e-10)
        #expect(abs(point.y.value - 5) < 1e-10)
    }

    @Test
    func `Point at parameter pi`() {
        let circle: Geometry<Double>.Circle = .init(center: .zero, radius: 5)
        let point = circle.point(at: .pi)
        #expect(abs(point.x.value - (-5)) < 1e-10)
        #expect(abs(point.y.value) < 1e-10)
    }

    @Test
    func `Point with offset center`() {
        let circle: Geometry<Double>.Circle = .init(
            center: .init(x: 10, y: 20),
            radius: 5
        )
        let point = circle.point(at: .zero)
        #expect(abs(point.x.value - 15) < 1e-10)
        #expect(abs(point.y.value - 20) < 1e-10)
    }

    // MARK: - Tangent

    @Test
    func `Tangent at angle 0`() {
        let circle: Geometry<Double>.Circle = .init(center: .zero, radius: 5)
        let tangent = circle.tangent(at: .zero)
        // At angle 0 (right side), tangent points up (0, 1)
        #expect(abs(tangent.dx.value) < 1e-10)
        #expect(abs(tangent.dy.value - 1) < 1e-10)
    }

    @Test
    func `Tangent at angle pi/2`() {
        let circle: Geometry<Double>.Circle = .init(center: .zero, radius: 5)
        let tangent = circle.tangent(at: .halfPi)
        // At angle pi/2 (top), tangent points left (-1, 0)
        #expect(abs(tangent.dx.value - (-1)) < 1e-10)
        #expect(abs(tangent.dy.value) < 1e-10)
    }

    @Test
    func `Tangent is perpendicular to radius`() {
        let circle: Geometry<Double>.Circle = .init(center: .zero, radius: 5)
        let angle: Radian = .init(Double.pi / 3)
        let point = circle.point(at: angle)
        let tangent = circle.tangent(at: angle)
        // Vector from center to point
        let radius: Geometry<Double>.Vector<2> = .init(dx: point.x, dy: point.y)
        // Dot product should be zero
        let dot = radius.dot(tangent)
        #expect(abs(dot) < 1e-10)
    }

    // MARK: - Bounding Box

    @Test
    func `Bounding box at origin`() {
        let circle: Geometry<Double>.Circle = .init(center: .zero, radius: 5)
        let bbox = circle.boundingBox
        #expect(bbox.llx == -5)
        #expect(bbox.lly == -5)
        #expect(bbox.urx == 5)
        #expect(bbox.ury == 5)
    }

    @Test
    func `Bounding box with offset`() {
        let circle: Geometry<Double>.Circle = .init(
            center: .init(x: 10, y: 20),
            radius: 5
        )
        let bbox = circle.boundingBox
        #expect(bbox.llx == 5)
        #expect(bbox.lly == 15)
        #expect(bbox.urx == 15)
        #expect(bbox.ury == 25)
    }

    // MARK: - Transformation

    @Test
    func `Circle translation`() {
        let circle: Geometry<Double>.Circle = .init(center: .zero, radius: 5)
        let translated = circle.translated(by: .init(dx: 10, dy: 20))
        #expect(translated.center.x == 10)
        #expect(translated.center.y == 20)
        #expect(translated.radius == 5)
    }

    @Test
    func `Circle scaling`() {
        let circle: Geometry<Double>.Circle = .init(center: .zero, radius: 5)
        let scaled = circle.scaled(by: 2)
        #expect(scaled.center.x == 0)
        #expect(scaled.center.y == 0)
        #expect(scaled.radius == 10)
    }

    // MARK: - Line Intersection

    @Test
    func `Line through center intersects at two points`() {
        let circle: Geometry<Double>.Circle = .init(center: .zero, radius: 5)
        let line: Geometry<Double>.Line = .init(
            point: .zero,
            direction: .init(dx: 1, dy: 0)
        )

        let intersections = circle.intersection(with: line)
        #expect(intersections.count == 2)

        let sorted = intersections.sorted { $0.x.value < $1.x.value }
        #expect(abs(sorted[0].x.value - (-5)) < 1e-10)
        #expect(abs(sorted[1].x.value - 5) < 1e-10)
    }

    @Test
    func `Tangent line intersects at one point`() {
        let circle: Geometry<Double>.Circle = .init(center: .zero, radius: 5)
        let line: Geometry<Double>.Line = .init(
            point: .init(x: 5, y: 0),
            direction: .init(dx: 0, dy: 1)
        )

        let intersections = circle.intersection(with: line)
        #expect(intersections.count == 1)
        #expect(abs(intersections[0].x.value - 5) < 1e-10)
        #expect(abs(intersections[0].y.value) < 1e-10)
    }

    @Test
    func `Non-intersecting line`() {
        let circle: Geometry<Double>.Circle = .init(center: .zero, radius: 5)
        let line: Geometry<Double>.Line = .init(
            point: .init(x: 10, y: 0),
            direction: .init(dx: 0, dy: 1)
        )

        let intersections = circle.intersection(with: line)
        #expect(intersections.isEmpty)
    }

    // MARK: - Circle-Circle Intersection

    @Test
    func `Two circles intersect at two points`() {
        let c1: Geometry<Double>.Circle = .init(center: .zero, radius: 5)
        let c2: Geometry<Double>.Circle = .init(
            center: .init(x: 6, y: 0),
            radius: 5
        )

        let intersections = c1.intersection(with: c2)
        #expect(intersections.count == 2)
    }

    @Test
    func `Tangent circles intersect at one point`() {
        let c1: Geometry<Double>.Circle = .init(center: .zero, radius: 5)
        let c2: Geometry<Double>.Circle = .init(
            center: .init(x: 10, y: 0),
            radius: 5
        )

        let intersections = c1.intersection(with: c2)
        #expect(intersections.count == 1)
        #expect(abs(intersections[0].x.value - 5) < 1e-10)
        #expect(abs(intersections[0].y.value) < 1e-10)
    }

    @Test
    func `Separate circles do not intersect`() {
        let c1: Geometry<Double>.Circle = .init(center: .zero, radius: 5)
        let c2: Geometry<Double>.Circle = .init(
            center: .init(x: 20, y: 0),
            radius: 5
        )

        let intersections = c1.intersection(with: c2)
        #expect(intersections.isEmpty)
    }

    @Test
    func `One circle inside another`() {
        let c1: Geometry<Double>.Circle = .init(center: .zero, radius: 10)
        let c2: Geometry<Double>.Circle = .init(center: .zero, radius: 3)

        let intersections = c1.intersection(with: c2)
        #expect(intersections.isEmpty)
    }

    // MARK: - Functorial Map

    @Test
    func `Circle map`() {
        let circle: Geometry<Double>.Circle = .init(center: .zero, radius: 5)
        let mapped: Geometry<Float>.Circle = circle.map { Float($0) }

        #expect(mapped.center.x.value == 0)
        #expect(mapped.center.y.value == 0)
        #expect(mapped.radius.value == 5)
    }
}
