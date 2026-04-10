// Ellipse Tests.swift
// Tests for Geometry.Ellipse type.

import Angle
import Testing

@testable import Geometry

@Suite
struct `Ellipse Tests` {

    // MARK: - Initialization

    @Test
    func `Ellipse initialization`() {
        let ellipse: Geometry<Double>.Ellipse = .init(
            center: .init(x: 10, y: 20),
            semiMajor: 8,
            semiMinor: 5,
            rotation: .zero
        )
        #expect(ellipse.center.x == 10)
        #expect(ellipse.center.y == 20)
        #expect(ellipse.semiMajor == 8)
        #expect(ellipse.semiMinor == 5)
        #expect(ellipse.rotation == .zero)
    }

    @Test
    func `Axis-aligned ellipse at origin`() {
        let ellipse: Geometry<Double>.Ellipse = .init(semiMajor: 10, semiMinor: 5)
        #expect(ellipse.center.x == 0)
        #expect(ellipse.center.y == 0)
        #expect(ellipse.rotation == .zero)
    }

    @Test
    func `Circle as special ellipse`() {
        let ellipse: Geometry<Double>.Ellipse = .circle(
            center: .init(x: 5, y: 5),
            radius: 10
        )
        #expect(ellipse.semiMajor == 10)
        #expect(ellipse.semiMinor == 10)
    }

    // MARK: - Axis Properties

    @Test
    func `Major and minor axes`() {
        let ellipse: Geometry<Double>.Ellipse = .init(semiMajor: 10, semiMinor: 5)
        #expect(ellipse.majorAxis == 20)
        #expect(ellipse.minorAxis == 10)
    }

    // MARK: - Eccentricity

    @Test
    func `Eccentricity of circle is zero`() {
        let ellipse: Geometry<Double>.Ellipse = .circle(center: .zero, radius: 10)
        #expect(abs(ellipse.eccentricity) < 1e-10)
    }

    @Test
    func `Eccentricity of elongated ellipse`() {
        let ellipse: Geometry<Double>.Ellipse = .init(semiMajor: 5, semiMinor: 3)
        // e = sqrt(1 - (b/a)^2) = sqrt(1 - 9/25) = sqrt(16/25) = 4/5 = 0.8
        #expect(abs(ellipse.eccentricity - 0.8) < 1e-10)
    }

    // MARK: - Foci

    @Test
    func `Foci of axis-aligned ellipse`() {
        let ellipse: Geometry<Double>.Ellipse = .init(semiMajor: 5, semiMinor: 3)
        let foci = ellipse.foci
        // c = sqrt(a^2 - b^2) = sqrt(25 - 9) = 4
        #expect(abs(foci.f1.x.value - (-4)) < 1e-10)
        #expect(abs(foci.f1.y.value) < 1e-10)
        #expect(abs(foci.f2.x.value - 4) < 1e-10)
        #expect(abs(foci.f2.y.value) < 1e-10)
    }

    @Test
    func `Foci of circle are coincident`() {
        let ellipse: Geometry<Double>.Ellipse = .circle(center: .zero, radius: 5)
        let foci = ellipse.foci
        #expect(abs(foci.f1.x.value) < 1e-10)
        #expect(abs(foci.f1.y.value) < 1e-10)
        #expect(abs(foci.f2.x.value) < 1e-10)
        #expect(abs(foci.f2.y.value) < 1e-10)
    }

    // MARK: - Area and Perimeter

    @Test
    func `Area of ellipse`() {
        let ellipse: Geometry<Double>.Ellipse = .init(semiMajor: 5, semiMinor: 3)
        // Area = π * a * b = π * 5 * 3 = 15π
        #expect(abs(ellipse.area - 15 * .pi) < 1e-10)
    }

    @Test
    func `Perimeter approximation`() {
        // For a circle, perimeter = 2πr
        let circle: Geometry<Double>.Ellipse = .circle(center: .zero, radius: 5)
        #expect(abs(circle.perimeter - 10 * .pi) < 0.01)  // Ramanujan is exact for circles
    }

    // MARK: - isCircle

    @Test
    func `isCircle for circle`() {
        let ellipse: Geometry<Double>.Ellipse = .circle(center: .zero, radius: 5)
        #expect(ellipse.isCircle)
    }

    @Test
    func `isCircle for non-circle`() {
        let ellipse: Geometry<Double>.Ellipse = .init(semiMajor: 10, semiMinor: 5)
        #expect(!ellipse.isCircle)
    }

    // MARK: - Point on Ellipse

    @Test
    func `Point at parameter 0`() {
        let ellipse: Geometry<Double>.Ellipse = .init(semiMajor: 10, semiMinor: 5)
        let point = ellipse.point(at: .zero)
        #expect(abs(point.x.value - 10) < 1e-10)
        #expect(abs(point.y.value) < 1e-10)
    }

    @Test
    func `Point at parameter pi/2`() {
        let ellipse: Geometry<Double>.Ellipse = .init(semiMajor: 10, semiMinor: 5)
        let point = ellipse.point(at: .halfPi)
        #expect(abs(point.x.value) < 1e-10)
        #expect(abs(point.y.value - 5) < 1e-10)
    }

    @Test
    func `Point at parameter pi`() {
        let ellipse: Geometry<Double>.Ellipse = .init(semiMajor: 10, semiMinor: 5)
        let point = ellipse.point(at: .pi)
        #expect(abs(point.x.value - (-10)) < 1e-10)
        #expect(abs(point.y.value) < 1e-10)
    }

    // MARK: - Containment

    @Test
    func `Contains center`() {
        let ellipse: Geometry<Double>.Ellipse = .init(
            center: .init(x: 5, y: 5),
            semiMajor: 10,
            semiMinor: 5
        )
        #expect(ellipse.contains(ellipse.center))
    }

    @Test
    func `Contains point on boundary`() {
        let ellipse: Geometry<Double>.Ellipse = .init(semiMajor: 10, semiMinor: 5)
        let point: Geometry<Double>.Point<2> = .init(x: 10, y: 0)
        #expect(ellipse.contains(point))
    }

    @Test
    func `Contains interior point`() {
        let ellipse: Geometry<Double>.Ellipse = .init(semiMajor: 10, semiMinor: 5)
        let point: Geometry<Double>.Point<2> = .init(x: 5, y: 2)
        #expect(ellipse.contains(point))
    }

    @Test
    func `Does not contain exterior point`() {
        let ellipse: Geometry<Double>.Ellipse = .init(semiMajor: 10, semiMinor: 5)
        let point: Geometry<Double>.Point<2> = .init(x: 15, y: 0)
        #expect(!ellipse.contains(point))
    }

    // MARK: - Bounding Box

    @Test
    func `Bounding box axis-aligned`() {
        let ellipse: Geometry<Double>.Ellipse = .init(semiMajor: 10, semiMinor: 5)
        let bbox = ellipse.boundingBox
        #expect(abs(bbox.llx.value - (-10)) < 1e-10)
        #expect(abs(bbox.lly.value - (-5)) < 1e-10)
        #expect(abs(bbox.urx.value - 10) < 1e-10)
        #expect(abs(bbox.ury.value - 5) < 1e-10)
    }

    @Test
    func `Bounding box with center offset`() {
        let ellipse: Geometry<Double>.Ellipse = .init(
            center: .init(x: 10, y: 20),
            semiMajor: 5,
            semiMinor: 3
        )
        let bbox = ellipse.boundingBox
        #expect(abs(bbox.llx.value - 5) < 1e-10)
        #expect(abs(bbox.lly.value - 17) < 1e-10)
        #expect(abs(bbox.urx.value - 15) < 1e-10)
        #expect(abs(bbox.ury.value - 23) < 1e-10)
    }

    // MARK: - Transformation

    @Test
    func `Translation`() {
        let ellipse: Geometry<Double>.Ellipse = .init(semiMajor: 10, semiMinor: 5)
        let translated = ellipse.translated(by: .init(dx: 5, dy: 10))
        #expect(translated.center.x == 5)
        #expect(translated.center.y == 10)
        #expect(translated.semiMajor == 10)
        #expect(translated.semiMinor == 5)
    }

    @Test
    func `Scaling`() {
        let ellipse: Geometry<Double>.Ellipse = .init(semiMajor: 10, semiMinor: 5)
        let scaled = ellipse.scaled(by: 2)
        #expect(scaled.semiMajor == 20)
        #expect(scaled.semiMinor == 10)
    }

    @Test
    func `Rotation`() {
        let ellipse: Geometry<Double>.Ellipse = .init(semiMajor: 10, semiMinor: 5)
        let rotated = ellipse.rotated(by: .halfPi)
        #expect(abs(rotated.rotation.value - Double.pi / 2) < 1e-10)
    }

    // MARK: - Circle Conversion

    @Test
    func `Circle from circular ellipse`() {
        let ellipse: Geometry<Double>.Ellipse = .circle(center: .zero, radius: 5)
        let circle = Geometry<Double>.Circle(ellipse)
        #expect(circle != nil)
        #expect(circle?.radius == 5)
    }

    @Test
    func `Circle from non-circular ellipse is nil`() {
        let ellipse: Geometry<Double>.Ellipse = .init(semiMajor: 10, semiMinor: 5)
        let circle = Geometry<Double>.Circle(ellipse)
        #expect(circle == nil)
    }

    @Test
    func `Ellipse from circle`() {
        let circle: Geometry<Double>.Circle = .init(center: .init(x: 5, y: 10), radius: 7)
        let ellipse = Geometry<Double>.Ellipse(circle)
        #expect(ellipse.center.x == 5)
        #expect(ellipse.center.y == 10)
        #expect(ellipse.semiMajor == 7)
        #expect(ellipse.semiMinor == 7)
        #expect(ellipse.rotation == .zero)
        #expect(ellipse.isCircle)
    }

    // MARK: - Functorial Map

    @Test
    func `Ellipse map`() {
        let ellipse: Geometry<Double>.Ellipse = .init(semiMajor: 10, semiMinor: 5)
        let mapped: Geometry<Float>.Ellipse = ellipse.map { Float($0) }
        #expect(mapped.semiMajor.value == 10)
        #expect(mapped.semiMinor.value == 5)
    }
}
