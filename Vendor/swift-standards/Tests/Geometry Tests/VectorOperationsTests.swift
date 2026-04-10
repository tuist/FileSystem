// VectorOperationsTests.swift
// Tests for vector operations including projection, rejection, and angle calculations.

import Angle
import Testing

@testable import Geometry

@Suite
struct `Vector Projection Tests` {
    @Test
    func `Projection onto parallel vector`() {
        let v: Geometry<Double>.Vector<2> = .init(dx: 4, dy: 0)
        let onto: Geometry<Double>.Vector<2> = .init(dx: 1, dy: 0)

        let projection = v.projection(onto: onto)
        #expect(abs(projection.dx.value - 4) < 1e-10)
        #expect(abs(projection.dy.value) < 1e-10)
    }

    @Test
    func `Projection onto perpendicular vector`() {
        let v: Geometry<Double>.Vector<2> = .init(dx: 4, dy: 0)
        let onto: Geometry<Double>.Vector<2> = .init(dx: 0, dy: 1)

        let projection = v.projection(onto: onto)
        #expect(abs(projection.dx.value) < 1e-10)
        #expect(abs(projection.dy.value) < 1e-10)
    }

    @Test
    func `Projection onto diagonal vector`() {
        let v: Geometry<Double>.Vector<2> = .init(dx: 3, dy: 0)
        let onto: Geometry<Double>.Vector<2> = .init(dx: 1, dy: 1)

        // Projection of (3,0) onto (1,1) should be (1.5, 1.5)
        let projection = v.projection(onto: onto)
        #expect(abs(projection.dx.value - 1.5) < 1e-10)
        #expect(abs(projection.dy.value - 1.5) < 1e-10)
    }

    @Test
    func `Projection onto zero vector`() {
        let v: Geometry<Double>.Vector<2> = .init(dx: 3, dy: 4)
        let onto: Geometry<Double>.Vector<2> = .zero

        let projection = v.projection(onto: onto)
        #expect(abs(projection.dx.value) < 1e-10)
        #expect(abs(projection.dy.value) < 1e-10)
    }
}

@Suite
struct `Vector Rejection Tests` {
    @Test
    func `Rejection from parallel vector`() {
        let v: Geometry<Double>.Vector<2> = .init(dx: 4, dy: 0)
        let from: Geometry<Double>.Vector<2> = .init(dx: 1, dy: 0)

        let rejection = v.rejection(from: from)
        #expect(abs(rejection.dx.value) < 1e-10)
        #expect(abs(rejection.dy.value) < 1e-10)
    }

    @Test
    func `Rejection from perpendicular vector`() {
        let v: Geometry<Double>.Vector<2> = .init(dx: 4, dy: 0)
        let from: Geometry<Double>.Vector<2> = .init(dx: 0, dy: 1)

        let rejection = v.rejection(from: from)
        #expect(abs(rejection.dx.value - 4) < 1e-10)
        #expect(abs(rejection.dy.value) < 1e-10)
    }

    @Test
    func `Rejection from diagonal vector`() {
        let v: Geometry<Double>.Vector<2> = .init(dx: 3, dy: 0)
        let from: Geometry<Double>.Vector<2> = .init(dx: 1, dy: 1)

        // Rejection should be (3,0) - (1.5, 1.5) = (1.5, -1.5)
        let rejection = v.rejection(from: from)
        #expect(abs(rejection.dx.value - 1.5) < 1e-10)
        #expect(abs(rejection.dy.value - (-1.5)) < 1e-10)
    }

    @Test
    func `Projection plus rejection equals original`() {
        let v: Geometry<Double>.Vector<2> = .init(dx: 5, dy: 7)
        let onto: Geometry<Double>.Vector<2> = .init(dx: 3, dy: 4)

        let projection = v.projection(onto: onto)
        let rejection = v.rejection(from: onto)
        let sum = projection + rejection

        #expect(abs(sum.dx.value - v.dx.value) < 1e-10)
        #expect(abs(sum.dy.value - v.dy.value) < 1e-10)
    }

    @Test
    func `Projection and rejection are perpendicular`() {
        let v: Geometry<Double>.Vector<2> = .init(dx: 5, dy: 7)
        let onto: Geometry<Double>.Vector<2> = .init(dx: 3, dy: 4)

        let projection = v.projection(onto: onto)
        let rejection = v.rejection(from: onto)

        let dot = projection.dot(rejection)
        #expect(abs(dot) < 1e-10)
    }
}

@Suite
struct `Vector Angle Tests` {
    @Test
    func `Angle to perpendicular vector`() {
        let v1: Geometry<Double>.Vector<2> = .init(dx: 1, dy: 0)
        let v2: Geometry<Double>.Vector<2> = .init(dx: 0, dy: 1)

        let angle = v1.angle(to: v2)
        #expect(abs(angle.value - Double.pi / 2) < 1e-10)
    }

    @Test
    func `Angle to same direction`() {
        let v1: Geometry<Double>.Vector<2> = .init(dx: 1, dy: 0)
        let v2: Geometry<Double>.Vector<2> = .init(dx: 2, dy: 0)

        let angle = v1.angle(to: v2)
        #expect(abs(angle.value) < 1e-10)
    }

    @Test
    func `Angle to opposite direction`() {
        let v1: Geometry<Double>.Vector<2> = .init(dx: 1, dy: 0)
        let v2: Geometry<Double>.Vector<2> = .init(dx: -1, dy: 0)

        let angle = v1.angle(to: v2)
        #expect(abs(angle.value - Double.pi) < 1e-10)
    }

    @Test
    func `Angle is symmetric in magnitude`() {
        let v1: Geometry<Double>.Vector<2> = .init(dx: 1, dy: 0)
        let v2: Geometry<Double>.Vector<2> = .init(dx: 1, dy: 1)

        let angle1 = v1.angle(to: v2)
        let angle2 = v2.angle(to: v1)

        // Unsigned angle should be the same
        #expect(abs(abs(angle1.value) - abs(angle2.value)) < 1e-10)
    }

    @Test
    func `Signed angle counter-clockwise`() {
        let v1: Geometry<Double>.Vector<2> = .init(dx: 1, dy: 0)
        let v2: Geometry<Double>.Vector<2> = .init(dx: 0, dy: 1)

        let angle = v1.signedAngle(to: v2)
        #expect(angle.value > 0)  // CCW is positive
        #expect(abs(angle.value - Double.pi / 2) < 1e-10)
    }

    @Test
    func `Signed angle clockwise`() {
        let v1: Geometry<Double>.Vector<2> = .init(dx: 1, dy: 0)
        let v2: Geometry<Double>.Vector<2> = .init(dx: 0, dy: -1)

        let angle = v1.signedAngle(to: v2)
        #expect(angle.value < 0)  // CW is negative
        #expect(abs(angle.value - (-(Double.pi / 2))) < 1e-10)
    }
}

@Suite
struct `Vector Distance Tests` {
    @Test
    func `Distance to parallel vectors`() {
        let v1: Geometry<Double>.Vector<2> = .init(dx: 3, dy: 0)
        let v2: Geometry<Double>.Vector<2> = .init(dx: 7, dy: 0)

        let dist = v1.distance(to: v2)
        #expect(abs(dist - 4) < 1e-10)
    }

    @Test
    func `Distance to perpendicular vectors`() {
        let v1: Geometry<Double>.Vector<2> = .init(dx: 3, dy: 0)
        let v2: Geometry<Double>.Vector<2> = .init(dx: 0, dy: 4)

        let dist = v1.distance(to: v2)
        #expect(abs(dist - 5) < 1e-10)
    }

    @Test
    func `Distance to self is zero`() {
        let v: Geometry<Double>.Vector<2> = .init(dx: 3, dy: 4)

        let dist = v.distance(to: v)
        #expect(abs(dist) < 1e-10)
    }
}

@Suite
struct `Vector 3D Cross Product Tests` {
    @Test
    func `Cross product of unit vectors`() {
        let i: Geometry<Double>.Vector<3> = .init(dx: 1, dy: 0, dz: 0)
        let j: Geometry<Double>.Vector<3> = .init(dx: 0, dy: 1, dz: 0)
        let k: Geometry<Double>.Vector<3> = .init(dx: 0, dy: 0, dz: 1)

        let iCrossJ = i.cross(j)
        #expect(abs(iCrossJ.dx) < 1e-10)
        #expect(abs(iCrossJ.dy) < 1e-10)
        #expect(abs(iCrossJ.dz - 1) < 1e-10)

        let jCrossK = j.cross(k)
        #expect(abs(jCrossK.dx - 1) < 1e-10)
        #expect(abs(jCrossK.dy) < 1e-10)
        #expect(abs(jCrossK.dz) < 1e-10)

        let kCrossI = k.cross(i)
        #expect(abs(kCrossI.dx) < 1e-10)
        #expect(abs(kCrossI.dy - 1) < 1e-10)
        #expect(abs(kCrossI.dz) < 1e-10)
    }

    @Test
    func `Cross product anticommutative`() {
        let v1: Geometry<Double>.Vector<3> = .init(dx: 1, dy: 2, dz: 3)
        let v2: Geometry<Double>.Vector<3> = .init(dx: 4, dy: 5, dz: 6)

        let cross1 = v1.cross(v2)
        let cross2 = v2.cross(v1)

        #expect(abs(cross1.dx + cross2.dx) < 1e-10)
        #expect(abs(cross1.dy + cross2.dy) < 1e-10)
        #expect(abs(cross1.dz + cross2.dz) < 1e-10)
    }

    @Test
    func `Cross product perpendicular to both vectors`() {
        let v1: Geometry<Double>.Vector<3> = .init(dx: 1, dy: 2, dz: 3)
        let v2: Geometry<Double>.Vector<3> = .init(dx: 4, dy: 5, dz: 6)

        let cross = v1.cross(v2)

        #expect(abs(v1.dot(cross)) < 1e-10)
        #expect(abs(v2.dot(cross)) < 1e-10)
    }

    @Test
    func `Cross product of parallel vectors is zero`() {
        let v1: Geometry<Double>.Vector<3> = .init(dx: 1, dy: 2, dz: 3)
        let v2: Geometry<Double>.Vector<3> = .init(dx: 2, dy: 4, dz: 6)

        let cross = v1.cross(v2)

        #expect(abs(cross.dx) < 1e-10)
        #expect(abs(cross.dy) < 1e-10)
        #expect(abs(cross.dz) < 1e-10)
    }
}
