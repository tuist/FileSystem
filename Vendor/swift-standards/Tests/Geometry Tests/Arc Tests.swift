// Arc Tests.swift
// Tests for Geometry.Arc type.

import Angle
import Testing

@testable import Geometry
@testable import RealModule

@Suite("Arc Tests")
struct ArcTests {

    // MARK: - Initialization

    @Test
    func `Arc initialization`() {
        let arc: Geometry<Double>.Arc = .init(
            center: .init(x: 10, y: 20),
            radius: 5,
            startAngle: .zero,
            endAngle: .pi
        )
        #expect(arc.center.x == 10)
        #expect(arc.center.y == 20)
        #expect(arc.radius == 5)
        #expect(arc.startAngle == .zero)
        #expect(arc.endAngle.value == Double.pi)
    }

    @Test
    func `Full circle arc`() {
        let arc: Geometry<Double>.Arc = .fullCircle(
            center: .zero,
            radius: 5
        )
        #expect(arc.startAngle == .zero)
        #expect(abs(arc.endAngle.value - 2 * Double.pi) < 1e-10)
        #expect(arc.isFullCircle)
    }

    @Test
    func `Semicircle arc`() {
        let arc: Geometry<Double>.Arc = .semicircle(
            center: .zero,
            radius: 5
        )
        #expect(arc.startAngle == .zero)
        #expect(abs(arc.endAngle.value - Double.pi) < 1e-10)
    }

    @Test
    func `Quarter circle arc`() {
        let arc: Geometry<Double>.Arc = .quarterCircle(
            center: .zero,
            radius: 5
        )
        #expect(arc.startAngle == .zero)
        #expect(abs(arc.endAngle.value - Double.pi / 2) < 1e-10)
    }

    @Test
    func `Quarter circle with start angle`() {
        let arc: Geometry<Double>.Arc = .quarterCircle(
            center: .zero,
            radius: 5,
            startAngle: .halfPi
        )
        #expect(abs(arc.startAngle.value - Double.pi / 2) < 1e-10)
        #expect(abs(arc.endAngle.value - Double.pi) < 1e-10)
    }

    // MARK: - Angle Properties

    @Test
    func `Sweep angle`() {
        let arc: Geometry<Double>.Arc = .init(
            center: .zero,
            radius: 5,
            startAngle: .zero,
            endAngle: .pi
        )
        #expect(abs(arc.sweep.value - Double.pi) < 1e-10)
    }

    @Test
    func `Counter-clockwise sweep`() {
        let arc: Geometry<Double>.Arc = .init(
            center: .zero,
            radius: 5,
            startAngle: .zero,
            endAngle: .pi
        )
        #expect(arc.isCounterClockwise)
    }

    @Test
    func `Clockwise sweep`() {
        let arc: Geometry<Double>.Arc = .init(
            center: .zero,
            radius: 5,
            startAngle: .pi,
            endAngle: .zero
        )
        #expect(!arc.isCounterClockwise)
    }

    @Test
    func `Is full circle`() {
        let full: Geometry<Double>.Arc = .fullCircle(center: .zero, radius: 5)
        #expect(full.isFullCircle)

        let half: Geometry<Double>.Arc = .semicircle(center: .zero, radius: 5)
        #expect(!half.isFullCircle)
    }

    // MARK: - Endpoints

    @Test
    func `Start point`() {
        let arc: Geometry<Double>.Arc = .init(
            center: .zero,
            radius: 5,
            startAngle: .zero,
            endAngle: .pi
        )
        #expect(abs(arc.startPoint.x.value - 5) < 1e-10)
        #expect(abs(arc.startPoint.y.value) < 1e-10)
    }

    @Test
    func `End point`() {
        let arc: Geometry<Double>.Arc = .init(
            center: .zero,
            radius: 5,
            startAngle: .zero,
            endAngle: .pi
        )
        #expect(abs(arc.endPoint.x.value - (-5)) < 1e-10)
        #expect(abs(arc.endPoint.y.value) < 1e-10)
    }

    @Test
    func `Mid point`() {
        let arc: Geometry<Double>.Arc = .init(
            center: .zero,
            radius: 5,
            startAngle: .zero,
            endAngle: .pi
        )
        // Midpoint at pi/2 should be (0, 5)
        #expect(abs(arc.midPoint.x.value) < 1e-10)
        #expect(abs(arc.midPoint.y.value - 5) < 1e-10)
    }

    @Test
    func `Start point with offset center`() {
        let arc: Geometry<Double>.Arc = .init(
            center: .init(x: 10, y: 20),
            radius: 5,
            startAngle: .zero,
            endAngle: .pi
        )
        #expect(abs(arc.startPoint.x.value - 15) < 1e-10)
        #expect(abs(arc.startPoint.y.value - 20) < 1e-10)
    }

    // MARK: - Point at Parameter

    @Test
    func `Point at t=0`() {
        let arc: Geometry<Double>.Arc = .init(
            center: .zero,
            radius: 5,
            startAngle: .zero,
            endAngle: .pi
        )
        let point = arc.point(at: 0)
        #expect(abs(point.x.value - arc.startPoint.x.value) < 1e-10)
        #expect(abs(point.y.value - arc.startPoint.y.value) < 1e-10)
    }

    @Test
    func `Point at t=1`() {
        let arc: Geometry<Double>.Arc = .init(
            center: .zero,
            radius: 5,
            startAngle: .zero,
            endAngle: .pi
        )
        let point = arc.point(at: 1)
        #expect(abs(point.x.value - arc.endPoint.x.value) < 1e-10)
        #expect(abs(point.y.value - arc.endPoint.y.value) < 1e-10)
    }

    @Test
    func `Point at t=0.5`() {
        let arc: Geometry<Double>.Arc = .init(
            center: .zero,
            radius: 5,
            startAngle: .zero,
            endAngle: .pi
        )
        let point = arc.point(at: 0.5)
        #expect(abs(point.x.value - arc.midPoint.x.value) < 1e-10)
        #expect(abs(point.y.value - arc.midPoint.y.value) < 1e-10)
    }

    // MARK: - Tangent

    @Test
    func `Tangent at t=0`() {
        let arc: Geometry<Double>.Arc = .init(
            center: .zero,
            radius: 5,
            startAngle: .zero,
            endAngle: .pi
        )
        // At angle 0, tangent points up (0, 1)
        let tangent = arc.tangent(at: 0)
        #expect(abs(tangent.dx.value) < 1e-10)
        #expect(abs(tangent.dy.value - 1) < 1e-10)
    }

    @Test
    func `Tangent at t=0.5`() {
        let arc: Geometry<Double>.Arc = .init(
            center: .zero,
            radius: 5,
            startAngle: .zero,
            endAngle: .pi
        )
        // At angle pi/2, tangent points left (-1, 0)
        let tangent = arc.tangent(at: 0.5)
        #expect(abs(tangent.dx.value - (-1)) < 1e-10)
        #expect(abs(tangent.dy.value) < 1e-10)
    }

    // MARK: - Length

    @Test
    func `Length of semicircle`() {
        let arc: Geometry<Double>.Arc = .semicircle(center: .zero, radius: 5)
        // Length = pi * r = 5 * pi
        #expect(abs(arc.length - 5 * Double.pi) < 1e-10)
    }

    @Test
    func `Length of full circle`() {
        let arc: Geometry<Double>.Arc = .fullCircle(center: .zero, radius: 5)
        // Length = 2 * pi * r = 10 * pi
        #expect(abs(arc.length - 10 * Double.pi) < 1e-10)
    }

    @Test
    func `Length of quarter circle`() {
        let arc: Geometry<Double>.Arc = .quarterCircle(center: .zero, radius: 4)
        // Length = (pi/2) * r = 2 * pi
        #expect(abs(arc.length - 2 * Double.pi) < 1e-10)
    }

    // MARK: - Bounding Box

    @Test
    func `Bounding box of quarter circle`() {
        let arc: Geometry<Double>.Arc = .quarterCircle(
            center: .zero,
            radius: 5
        )
        let bbox = arc.boundingBox
        #expect(abs(bbox.llx.value) < 1e-10)
        #expect(abs(bbox.lly.value) < 1e-10)
        #expect(abs(bbox.urx.value - 5) < 1e-10)
        #expect(abs(bbox.ury.value - 5) < 1e-10)
    }

    @Test
    func `Bounding box of semicircle`() {
        let arc: Geometry<Double>.Arc = .semicircle(center: .zero, radius: 5)
        let bbox = arc.boundingBox
        #expect(abs(bbox.llx.value - (-5)) < 1e-10)
        #expect(abs(bbox.lly.value) < 1e-10)
        #expect(abs(bbox.urx.value - 5) < 1e-10)
        #expect(abs(bbox.ury.value - 5) < 1e-10)
    }

    @Test
    func `Bounding box of full circle`() {
        let arc: Geometry<Double>.Arc = .fullCircle(center: .zero, radius: 5)
        let bbox = arc.boundingBox
        #expect(abs(bbox.llx.value - (-5)) < 1e-10)
        #expect(abs(bbox.lly.value - (-5)) < 1e-10)
        #expect(abs(bbox.urx.value - 5) < 1e-10)
        #expect(abs(bbox.ury.value - 5) < 1e-10)
    }

    // MARK: - Containment

    @Test
    func `Contains point on arc`() {
        let arc: Geometry<Double>.Arc = .quarterCircle(center: .zero, radius: 5)
        // Point at 45 degrees
        let x = 5 * Double.cos(Double.pi / 4)
        let y = 5 * Double.sin(Double.pi / 4)
        let point: Geometry<Double>.Point<2> = .init(
            x: Geometry<Double>.X(x),
            y: Geometry<Double>.Y(y)
        )
        #expect(arc.contains(point))
    }

    @Test
    func `Does not contain point outside arc range`() {
        let arc: Geometry<Double>.Arc = .quarterCircle(center: .zero, radius: 5)
        // Point at 180 degrees - on circle but outside arc
        let point: Geometry<Double>.Point<2> = .init(x: -5, y: 0)
        #expect(!arc.contains(point))
    }

    @Test
    func `Does not contain point at wrong radius`() {
        let arc: Geometry<Double>.Arc = .quarterCircle(center: .zero, radius: 5)
        // Point at 45 degrees but wrong radius
        let point: Geometry<Double>.Point<2> = .init(x: 3, y: 3)
        #expect(!arc.contains(point))
    }

    // MARK: - Transformation

    @Test
    func `Translation`() {
        let arc: Geometry<Double>.Arc = .semicircle(center: .zero, radius: 5)
        let translated = arc.translated(by: .init(dx: 10, dy: 20))
        #expect(translated.center.x == 10)
        #expect(translated.center.y == 20)
        #expect(translated.radius == 5)
    }

    @Test
    func `Scaling`() {
        let arc: Geometry<Double>.Arc = .semicircle(center: .zero, radius: 5)
        let scaled = arc.scaled(by: 2)
        #expect(scaled.radius == 10)
        #expect(scaled.startAngle == arc.startAngle)
        #expect(scaled.endAngle == arc.endAngle)
    }

    @Test
    func `Reversed arc`() {
        let arc: Geometry<Double>.Arc = .init(
            center: .zero,
            radius: 5,
            startAngle: .zero,
            endAngle: .pi
        )
        let reversed = arc.reversed
        #expect(reversed.startAngle == arc.endAngle)
        #expect(reversed.endAngle == arc.startAngle)
    }

    // MARK: - Bezier Conversion

    @Test
    func `Quarter arc to Beziers`() {
        let arc: Geometry<Double>.Arc = .quarterCircle(center: .zero, radius: 5)
        let beziers = [Geometry<Double>.Bezier](arc: arc)
        #expect(beziers.count == 1)
        #expect(beziers[0].degree == 3)
    }

    @Test
    func `Semicircle to Beziers`() {
        let arc: Geometry<Double>.Arc = .semicircle(center: .zero, radius: 5)
        let beziers = [Geometry<Double>.Bezier](arc: arc)
        #expect(beziers.count == 2)
    }

    @Test
    func `Full circle to Beziers`() {
        let arc: Geometry<Double>.Arc = .fullCircle(center: .zero, radius: 5)
        let beziers = [Geometry<Double>.Bezier](arc: arc)
        #expect(beziers.count == 4)
    }

    @Test
    func `Beziers start and end match arc`() {
        let arc: Geometry<Double>.Arc = .quarterCircle(center: .zero, radius: 5)
        let beziers = [Geometry<Double>.Bezier](arc: arc)

        // First bezier starts at arc start
        let firstBezier = beziers.first!
        #expect(abs(firstBezier.startPoint!.x.value - arc.startPoint.x.value) < 1e-10)
        #expect(abs(firstBezier.startPoint!.y.value - arc.startPoint.y.value) < 1e-10)

        // Last bezier ends at arc end
        let lastBezier = beziers.last!
        #expect(abs(lastBezier.endPoint!.x.value - arc.endPoint.x.value) < 1e-10)
        #expect(abs(lastBezier.endPoint!.y.value - arc.endPoint.y.value) < 1e-10)
    }

    // MARK: - Functorial Map

    @Test
    func `Arc map`() {
        let arc: Geometry<Double>.Arc = .semicircle(center: .zero, radius: 5)
        let mapped: Geometry<Float>.Arc = arc.map { Float($0) }
        #expect(mapped.center.x.value == 0)
        #expect(mapped.radius.value == 5)
    }
}
