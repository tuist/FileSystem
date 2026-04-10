// TrigonometryTests.swift
// Tests for trigonometric extensions on Geometry types.

import Angle
import Geometry
import RealModule
import Testing

@Suite
struct `Trigonometry Tests` {

    // MARK: - Radian Trigonometry

    @Test
    func `Radian sin/cos/tan`() {
        let angle: Radian = .pi(over: 2)
        #expect(abs(angle.sin - 1.0) < 1e-10)
        #expect(abs(angle.cos) < 1e-10)

        let angle45: Radian = .pi(over: 4)
        #expect(abs(angle45.tan - 1.0) < 1e-10)
    }

    @Test
    func `Radian constants`() {
        #expect(abs(Radian.pi - .pi) < 1e-10)
        #expect(abs(Radian.pi(times: 2) - 2 * Radian.pi) < 1e-10)
        #expect(abs(Radian.pi(over: 2) - .pi / 2) < 1e-10)
        #expect(abs(Radian.pi(over: 4) - .pi / 4) < 1e-10)
        #expect(abs(Radian.pi(over: 3) - .pi / 3) < 1e-10)
        #expect(abs(Radian.pi(over: 6) - .pi / 6) < 1e-10)
    }

    @Test
    func `Inverse trigonometric functions`() {
        let angle = Radian.asin(0.5)
        #expect(abs(angle - .pi / 6) < 1e-10)

        let angle2 = Radian.acos(0.5)
        #expect(abs(angle2 - .pi / 3) < 1e-10)

        let angle3 = Radian.atan(1.0)
        #expect(abs(angle3 - .pi / 4) < 1e-10)

        let angle4 = Radian.atan2(y: 1.0, x: 1.0)
        #expect(abs(angle4 - .pi / 4) < 1e-10)
    }

    // MARK: - Degree Trigonometry

    @Test
    func `Degree to Radian conversion`() {
        let deg90: Degree = .rightAngle
        #expect(abs(deg90.radians - .pi / 2) < 1e-10)

        let deg180: Degree = .straight
        #expect(abs(deg180.radians - .pi) < 1e-10)

        let deg360: Degree = .fullCircle
        #expect(abs(deg360.radians - 2 * Radian.pi) < 1e-10)
    }

    @Test
    func `Radian to Degree conversion`() {
        let rad: Radian = .pi
        #expect(abs(rad.degrees - 180.0) < 1e-10)

        let rad2: Radian = .pi(over: 2)
        #expect(abs(rad2.degrees - 90.0) < 1e-10)
    }

    @Test
    func `Degree sin/cos/tan`() {
        let deg30: Degree = .thirty
        #expect(abs(deg30.sin - 0.5) < 1e-10)

        let deg60: Degree = .sixty
        #expect(abs(deg60.cos - 0.5) < 1e-10)

        let deg45: Degree = .fortyFive
        #expect(abs(deg45.tan - 1.0) < 1e-10)
    }

    @Test
    func `Degree constants`() {
        #expect(Degree.rightAngle == 90)
        #expect(Degree.straight == 180)
        #expect(Degree.fullCircle == 360)
        #expect(Degree.fortyFive == 45)
        #expect(Degree.sixty == 60)
        #expect(Degree.thirty == 30)
    }

    // MARK: - AffineTransform Rotation

    @Test
    func `AffineTransform rotation from Radian`() {
        let transform = Geometry<Double>.AffineTransform.rotation(.pi(over: 2))
        let point = Geometry<Double>.Point(x: 1.0, y: 0.0)
        let rotated = transform.apply(to: point)

        #expect(abs(rotated.x.value) < 1e-10)
        #expect(abs(rotated.y.value - 1.0) < 1e-10)
    }

    @Test
    func `AffineTransform rotation from Degree`() {
        let transform = Geometry<Double>.AffineTransform.rotation(Degree.rightAngle)
        let point = Geometry<Double>.Point(x: 1.0, y: 0.0)
        let rotated = transform.apply(to: point)

        #expect(abs(rotated.x.value) < 1e-10)
        #expect(abs(rotated.y.value - 1.0) < 1e-10)
    }

    // MARK: - Vector Trigonometry

    @Test
    func `Vector angle`() {
        let v1 = Geometry<Double>.Vector(dx: 1.0, dy: 0.0)
        #expect(abs(v1.angle) < 1e-10)

        let v2 = Geometry<Double>.Vector(dx: 0.0, dy: 1.0)
        #expect(abs(v2.angle - .pi / 2) < 1e-10)

        let v3 = Geometry<Double>.Vector(dx: 1.0, dy: 1.0)
        #expect(abs(v3.angle - .pi / 4) < 1e-10)
    }

    @Test
    func `Vector unit at angle`() {
        let v = Geometry<Double>.Vector.unit(at: .pi(over: 4))
        let expected = 1.0 / Double.sqrt(2.0)
        #expect(abs(v.dx.value - expected) < 1e-10)
        #expect(abs(v.dy.value - expected) < 1e-10)
    }

    @Test
    func `Vector polar`() {
        let v = Geometry<Double>.Vector.polar(length: 2.0, angle: .pi(over: 6))
        #expect(abs(v.dx.value - Double.sqrt(3.0)) < 1e-10)
        #expect(abs(v.dy.value - 1.0) < 1e-10)
    }

    @Test
    func `Vector angle between`() {
        let v1 = Geometry<Double>.Vector(dx: 1.0, dy: 0.0)
        let v2 = Geometry<Double>.Vector(dx: 0.0, dy: 1.0)
        let angle = v1.angle(to: v2)
        #expect(abs(angle - .pi / 2) < 1e-10)
    }

    @Test
    func `Vector rotation`() {
        let v = Geometry<Double>.Vector(dx: 1.0, dy: 0.0)
        let rotated = v.rotated(by: .pi(over: 2))
        #expect(abs(rotated.dx.value) < 1e-10)
        #expect(abs(rotated.dy.value - 1.0) < 1e-10)
    }

    // MARK: - Point Trigonometry

    @Test
    func `Point polar coordinates`() {
        let p = Geometry<Double>.Point.polar(radius: 2.0, angle: .pi(over: 3))
        #expect(abs(p.x.value - 1.0) < 1e-10)
        #expect(abs(p.y.value - Double.sqrt(3.0)) < 1e-10)
    }

    @Test
    func `Point angle and radius`() {
        let p = Geometry<Double>.Point(x: 3.0, y: 4.0)
        #expect(abs(p.radius - 5.0) < 1e-10)

        let p2 = Geometry<Double>.Point(x: 1.0, y: 1.0)
        #expect(abs(p2.angle - .pi / 4) < 1e-10)
    }

    @Test
    func `Point rotation around origin`() {
        let p = Geometry<Double>.Point(x: 1.0, y: 0.0)
        let rotated = p.rotated(by: .pi(over: 2))
        #expect(abs(rotated.x.value) < 1e-10)
        #expect(abs(rotated.y.value - 1.0) < 1e-10)
    }

    @Test
    func `Point rotation around center`() {
        let p = Geometry<Double>.Point(x: 2.0, y: 0.0)
        let center = Geometry<Double>.Point(x: 1.0, y: 0.0)
        let rotated = p.rotated(by: .pi(over: 2), around: center)
        #expect(abs(rotated.x.value - 1.0) < 1e-10)
        #expect(abs(rotated.y.value - 1.0) < 1e-10)
    }
}
