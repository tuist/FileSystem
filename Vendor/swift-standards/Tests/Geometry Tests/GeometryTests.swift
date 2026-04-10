// GeometryTests.swift

import Angle
import Symmetry
import Testing

@testable import Geometry

// MARK: - Test Unit Type

/// A custom unit type for testing
struct TestUnit: AdditiveArithmetic, Comparable, Codable, Hashable,
    ExpressibleByIntegerLiteral, ExpressibleByFloatLiteral
{
    let value: Double

    init(_ value: Double) {
        self.value = value
    }

    init(integerLiteral value: Int) {
        self.value = Double(value)
    }

    init(floatLiteral value: Double) {
        self.value = value
    }

    static var zero: TestUnit { TestUnit(0) }

    static func + (lhs: TestUnit, rhs: TestUnit) -> TestUnit {
        TestUnit(lhs.value + rhs.value)
    }

    static func - (lhs: TestUnit, rhs: TestUnit) -> TestUnit {
        TestUnit(lhs.value - rhs.value)
    }

    static func < (lhs: TestUnit, rhs: TestUnit) -> Bool {
        lhs.value < rhs.value
    }
}

// MARK: - Geometry Unit Tests

@Suite
struct GeometryUnitTests {
    @Test
    func `Double conforms to Geometry Unit`() {
        let point: Geometry<Double>.Point<2> = .init(x: 10, y: 20)
        #expect(point.x == 10)
    }

    @Test
    func `Custom type conforms to Geometry Unit`() {
        let point: Geometry<TestUnit>.Point<2> = .init(x: 10, y: 20)
        #expect(point.x == 10)
    }
}

// MARK: - Scalar Tests

@Suite
struct ScalarTests {
    @Test
    func `Scalar basic operations`() {
        let a: Geometry<Double>.Scalar = 10.0
        let b: Geometry<Double>.Scalar = 5.0

        #expect((a + b) == 15)
        #expect((a - b) == 5)
        #expect((a * 2) == 20)
        #expect((a / 2) == 5)
        #expect((-a) == -10)
    }

    @Test
    func `Scalar comparison`() {
        let a: Geometry<Double>.Scalar = 10.0
        let b: Geometry<Double>.Scalar = 20.0

        #expect(a < b)
        #expect(b > a)
    }

    @Test
    func `Scalar with custom unit`() {
        let a: Geometry<TestUnit>.Scalar = 10
        let b: Geometry<TestUnit>.Scalar = 5
        let sum = a + b
        #expect(sum == 15)
    }
}

// MARK: - Point Tests

@Suite
struct PointTests {
    @Test
    func `Creates point with coordinates`() {
        let point: Geometry<TestUnit>.Point<2> = .init(x: 10, y: 20)
        #expect(point.x == 10)
        #expect(point.y == 20)
    }

    @Test
    func `Zero point`() {
        let zero: Geometry<TestUnit>.Point<2> = .zero
        #expect(zero.x == 0)
        #expect(zero.y == 0)
    }

    @Test
    func `Point subtraction returns Vector`() {
        // In affine geometry, Point - Point = Vector (the displacement)
        let a: Geometry<TestUnit>.Point<2> = .init(x: 10, y: 20)
        let b: Geometry<TestUnit>.Point<2> = .init(x: 5, y: 15)
        let displacement: Geometry<TestUnit>.Vector<2> = a - b
        #expect(displacement.dx == 5)
        #expect(displacement.dy == 5)
    }

    @Test
    func `Double point translation`() {
        let point: Geometry<Double>.Point<2> = .init(x: 10, y: 20)
        let moved = point.translated(dx: 5, dy: 10)
        #expect(moved.x == 15)
        #expect(moved.y == 30)
    }

    @Test
    func `Double point distance`() {
        let a: Geometry<Double>.Point<2> = .init(x: 0, y: 0)
        let b: Geometry<Double>.Point<2> = .init(x: 3, y: 4)
        #expect(a.distance(to: b) == 5)
    }

    @Test
    func `Point plus vector`() {
        let point: Geometry<Double>.Point<2> = .init(x: 10, y: 20)
        let vector: Geometry<Double>.Vector2 = .init(dx: 5, dy: 10)
        let result = point + vector
        #expect(result.x == 15)
        #expect(result.y == 30)
    }
}

// MARK: - Vector2 Tests

@Suite
struct Vector2Tests {
    @Test
    func `Creates vector`() {
        let v: Geometry<Double>.Vector2 = .init(dx: 3, dy: 4)
        #expect(v.dx == 3)
        #expect(v.dy == 4)
    }

    @Test
    func `Vector length`() {
        let v: Geometry<Double>.Vector2 = .init(dx: 3, dy: 4)
        #expect(v.length == 5)
        #expect(v.lengthSquared == 25)
    }

    @Test
    func `Vector normalization`() {
        let v: Geometry<Double>.Vector2 = .init(dx: 3, dy: 4)
        let n = v.normalized
        #expect(abs(n.length - 1.0) < 0.0001)
    }

    @Test
    func `Vector dot product`() {
        let a: Geometry<Double>.Vector2 = .init(dx: 1, dy: 0)
        let b: Geometry<Double>.Vector2 = .init(dx: 0, dy: 1)
        #expect(a.dot(b) == 0)  // perpendicular
    }

    @Test
    func `Vector cross product`() {
        let a: Geometry<Double>.Vector2 = .init(dx: 1, dy: 0)
        let b: Geometry<Double>.Vector2 = .init(dx: 0, dy: 1)
        #expect(a.cross(b) == 1)  // counter-clockwise
    }

    @Test
    func `Vector arithmetic`() {
        let a: Geometry<Double>.Vector2 = .init(dx: 10, dy: 20)
        let b: Geometry<Double>.Vector2 = .init(dx: 5, dy: 10)

        #expect((a + b).dx == 15)
        #expect((a - b).dx == 5)
        #expect((a * 2).dx == 20)
        #expect((a / 2).dx == 5)
    }
}

// MARK: - Size Tests

@Suite
struct SizeTests {
    @Test
    func `Creates size with dimensions`() {
        let size: Geometry<TestUnit>.Size<2> = .init(width: 100, height: 200)
        #expect(size.width == 100)
        #expect(size.height == 200)
    }

    @Test
    func `Zero size`() {
        let zero: Geometry<TestUnit>.Size<2> = .zero
        #expect(zero.width == 0)
        #expect(zero.height == 0)
    }
}

// MARK: - Rectangle Tests

@Suite
struct RectangleTests {
    @Test
    func `Creates rectangle from corners`() {
        let rect: Geometry<TestUnit>.Rectangle = .init(llx: 10, lly: 20, urx: 110, ury: 220)
        #expect(rect.llx == 10)
        #expect(rect.lly == 20)
        #expect(rect.urx == 110)
        #expect(rect.ury == 220)
    }

    @Test
    func `Creates rectangle from origin and size`() {
        let rect: Geometry<TestUnit>.Rectangle = .init(x: 10, y: 20, width: 100, height: 200)
        #expect(rect.llx == 10)
        #expect(rect.lly == 20)
        #expect(rect.width == 100)
        #expect(rect.height == 200)
    }

    @Test
    func `Rectangle contains point`() {
        let rect: Geometry<Double>.Rectangle = .init(x: 0, y: 0, width: 100, height: 100)
        let inside: Geometry<Double>.Point<2> = .init(x: 50, y: 50)
        let outside: Geometry<Double>.Point<2> = .init(x: 150, y: 150)

        #expect(rect.contains(inside))
        #expect(!rect.contains(outside))
    }

    @Test
    func `Rectangle intersection`() {
        let a: Geometry<Double>.Rectangle = .init(x: 0, y: 0, width: 100, height: 100)
        let b: Geometry<Double>.Rectangle = .init(x: 50, y: 50, width: 100, height: 100)

        #expect(a.intersects(b))

        let intersection = a.intersection(b)!
        #expect(intersection.llx == 50)
        #expect(intersection.lly == 50)
        #expect(intersection.urx == 100)
        #expect(intersection.ury == 100)
    }

    @Test
    func `Rectangle union`() {
        let a: Geometry<Double>.Rectangle = .init(x: 0, y: 0, width: 50, height: 50)
        let b: Geometry<Double>.Rectangle = .init(x: 50, y: 50, width: 50, height: 50)

        let union = a.union(b)
        #expect(union.minX == 0)
        #expect(union.minY == 0)
        #expect(union.maxX == 100)
        #expect(union.maxY == 100)
    }

    @Test
    func `Rectangle inset`() {
        let rect: Geometry<Double>.Rectangle = .init(x: 0, y: 0, width: 100, height: 100)
        let inset = rect.insetBy(dx: 10, dy: 20)

        #expect(inset.llx == 10)
        #expect(inset.lly == 20)
        #expect(inset.urx == 90)
        #expect(inset.ury == 80)
    }

    @Test
    func `Rectangle center`() {
        let rect: Geometry<Double>.Rectangle = .init(x: 0, y: 0, width: 100, height: 100)
        #expect(rect.midX == 50)
        #expect(rect.midY == 50)
        #expect(rect.center.x == 50)
        #expect(rect.center.y == 50)
    }

    @Test
    func `Rectangle corners`() {
        let rect: Geometry<TestUnit>.Rectangle = .init(x: 10, y: 20, width: 100, height: 200)

        let ll = rect.corner(.lowerLeft)
        #expect(ll.x == 10)
        #expect(ll.y == 20)

        let ur = rect.corner(.upperRight)
        #expect(ur.x == 110)
        #expect(ur.y == 220)
    }
}

// MARK: - Radian Tests

@Suite
struct RadianTests {
    @Test
    func `Radian zero`() {
        let zero: Radian = .zero
        #expect(zero == 0)
    }

    @Test
    func `Radian arithmetic`() {
        let a: Radian = .init(1.0)
        let b: Radian = .init(2.0)
        let sum = a + b
        #expect(sum == 3.0)
    }

    @Test
    func `Radian comparable`() {
        let a: Radian = .init(1.0)
        let b: Radian = .init(2.0)
        #expect(a < b)
    }
}

// MARK: - Degree Tests

@Suite
struct DegreeTests {
    @Test
    func `Degree zero`() {
        let zero: Degree = .zero
        #expect(zero == 0)
    }

    @Test
    func `Degree arithmetic`() {
        let a: Degree = .init(45)
        let b: Degree = .init(45)
        let sum = a + b
        #expect(sum == 90)
    }

    @Test
    func `Degree comparable`() {
        let a: Degree = .init(45)
        let b: Degree = .init(90)
        #expect(a < b)
    }

    @Test
    func `Degree literal`() {
        let deg: Degree = 90.0
        #expect(deg == 90)
    }
}

// MARK: - AffineTransform Tests

@Suite
struct AffineTransformTests {
    @Test
    func `Identity transform`() {
        let transform: Geometry<Double>.AffineTransform = .identity
        let point: Geometry<Double>.Point<2> = .init(x: 10, y: 20)
        let result = transform.apply(to: point)

        #expect(result.x == 10)
        #expect(result.y == 20)
    }

    @Test
    func `Translation transform`() {
        let transform: Geometry<Double>.AffineTransform = .translation(x: 100, y: 50)
        let point: Geometry<Double>.Point<2> = .init(x: 10, y: 20)
        let result = transform.apply(to: point)

        #expect(result.x == 110)
        #expect(result.y == 70)
    }

    @Test
    func `Scale transform`() {
        let transform: Geometry<Double>.AffineTransform = .scale(2)
        let point: Geometry<Double>.Point<2> = .init(x: 10, y: 20)
        let result = transform.apply(to: point)

        #expect(result.x == 20)
        #expect(result.y == 40)
    }

    @Test
    func `Rotation transform`() {
        // 90 degree rotation
        let transform: Geometry<Double>.AffineTransform = .rotation(.halfPi)
        let point: Geometry<Double>.Point<2> = .init(x: 1, y: 0)
        let result = transform.apply(to: point)

        #expect(abs(result.x.value - 0) < 0.0001)
        #expect(abs(result.y.value - 1) < 0.0001)
    }

    @Test
    func `Transform concatenation`() {
        let translate: Geometry<Double>.AffineTransform = .translation(x: 10, y: 0)
        let scale: Geometry<Double>.AffineTransform = .scale(2)

        // Scale first, then translate
        let combined = translate.concatenating(scale)

        let point: Geometry<Double>.Point<2> = .init(x: 5, y: 5)
        let result = combined.apply(to: point)

        // 5 * 2 = 10, then + 10 = 20
        #expect(result.x == 20)
        #expect(result.y == 10)
    }

    @Test
    func `Transform inversion`() {
        let transform: Geometry<Double>.AffineTransform = .translation(x: 100, y: 50)
        let inverse = transform.inverted!

        let point: Geometry<Double>.Point<2> = .init(x: 110, y: 70)
        let result = inverse.apply(to: point)

        #expect(abs(result.x.value - 10) < 0.0001)
        #expect(abs(result.y.value - 20) < 0.0001)
    }
}

// MARK: - LineSegment Tests

@Suite
struct LineSegmentTests {
    @Test
    func `Line segment length`() {
        let segment: Geometry<Double>.LineSegment = .init(
            start: .init(x: 0, y: 0),
            end: .init(x: 3, y: 4)
        )
        #expect(segment.length == 5)
    }

    @Test
    func `Line segment midpoint`() {
        let segment: Geometry<Double>.LineSegment = .init(
            start: .init(x: 0, y: 0),
            end: .init(x: 10, y: 10)
        )
        #expect(segment.midpoint.x == 5)
        #expect(segment.midpoint.y == 5)
    }

    @Test
    func `Line segment point at parameter`() {
        let segment: Geometry<Double>.LineSegment = .init(
            start: .init(x: 0, y: 0),
            end: .init(x: 10, y: 10)
        )

        let quarter = segment.point(at: 0.25)
        #expect(quarter.x == 2.5)
        #expect(quarter.y == 2.5)
    }

    @Test
    func `Line segment vector`() {
        let segment: Geometry<Double>.LineSegment = .init(
            start: .init(x: 10, y: 20),
            end: .init(x: 30, y: 50)
        )
        #expect(segment.vector.dx == 20)
        #expect(segment.vector.dy == 30)
    }
}

// MARK: - Line Tests

@Suite
struct LineTests {
    @Test
    func `Line from point and direction`() {
        let line: Geometry<Double>.Line = .init(
            point: .init(x: 0, y: 0),
            direction: .init(dx: 1, dy: 1)
        )
        #expect(line.point.x == 0)
        #expect(line.point.y == 0)
        #expect(line.direction.dx == 1)
        #expect(line.direction.dy == 1)
    }

    @Test
    func `Line from two points`() {
        let line: Geometry<Double>.Line = .init(
            from: .init(x: 0, y: 0),
            to: .init(x: 10, y: 20)
        )
        #expect(line.point.x == 0)
        #expect(line.point.y == 0)
        #expect(line.direction.dx == 10)
        #expect(line.direction.dy == 20)
    }

    @Test
    func `Line point at parameter`() {
        let line: Geometry<Double>.Line = .init(
            point: .init(x: 0, y: 0),
            direction: .init(dx: 10, dy: 10)
        )
        let p = line.point(at: 0.5)
        #expect(p.x == 5)
        #expect(p.y == 5)
    }

    @Test
    func `Line distance to point`() {
        // Horizontal line y = 0
        let line: Geometry<Double>.Line = .init(
            point: .init(x: 0, y: 0),
            direction: .init(dx: 1, dy: 0)
        )
        // Point at (5, 3) should be distance 3 from line
        let point: Geometry<Double>.Point<2> = .init(x: 5, y: 3)
        #expect(line.distance(to: point) == 3)

        // Zero direction vector returns nil
        let degenerateLine: Geometry<Double>.Line = .init(
            point: .init(x: 0, y: 0),
            direction: .init(dx: 0, dy: 0)
        )
        #expect(degenerateLine.distance(to: point) == nil)
    }

    @Test
    func `Line Segment via nested type`() {
        // Test that Line.Segment works the same as LineSegment
        let segment: Geometry<Double>.Line.Segment = .init(
            start: .init(x: 0, y: 0),
            end: .init(x: 3, y: 4)
        )
        #expect(segment.length == 5)
    }

    @Test
    func `Segment to Line conversion`() {
        let segment: Geometry<Double>.Line.Segment = .init(
            start: .init(x: 10, y: 20),
            end: .init(x: 30, y: 50)
        )
        let line = segment.line
        #expect(line.point.x == 10)
        #expect(line.point.y == 20)
        #expect(line.direction.dx == 20)
        #expect(line.direction.dy == 30)
    }
}

// MARK: - EdgeInsets Tests

@Suite
struct EdgeInsetsTests {
    @Test
    func `Creates edge insets`() {
        let insets: Geometry<TestUnit>.EdgeInsets = .init(
            top: 10,
            leading: 20,
            bottom: 30,
            trailing: 40
        )
        #expect(insets.top == 10)
        #expect(insets.leading == 20)
        #expect(insets.bottom == 30)
        #expect(insets.trailing == 40)
    }

    @Test
    func `Creates uniform edge insets`() {
        let insets: Geometry<TestUnit>.EdgeInsets = .init(all: 10)
        #expect(insets.top == 10)
        #expect(insets.leading == 10)
        #expect(insets.bottom == 10)
        #expect(insets.trailing == 10)
    }

    @Test
    func `Zero edge insets`() {
        let zero: Geometry<TestUnit>.EdgeInsets = .zero
        #expect(zero.top == 0)
        #expect(zero.leading == 0)
        #expect(zero.bottom == 0)
        #expect(zero.trailing == 0)
    }
}

// MARK: - Dimension Tests

@Suite
struct DimensionTests {
    @Test
    func `Width comparison`() {
        let a: Geometry<TestUnit>.Width = .init(10)
        let b: Geometry<TestUnit>.Width = .init(20)
        #expect(a < b)
    }

    @Test
    func `Height addition`() {
        let a: Geometry<TestUnit>.Height = .init(10)
        let b: Geometry<TestUnit>.Height = .init(20)
        let sum = a + b
        #expect(sum == 30)
    }

    @Test
    func `Length zero`() {
        let zero: Geometry<TestUnit>.Length = .zero
        #expect(zero == 0)
    }

    @Test
    func `Width literals`() {
        let w: Geometry<Double>.Width = 100.0
        #expect(w == 100)

        let wInt: Geometry<Double>.Width = 50
        #expect(wInt == 50)
    }

    @Test
    func `Height negation`() {
        let h: Geometry<Double>.Height = .init(10)
        let neg = -h
        #expect(neg == -10)
    }

    @Test
    func `Length multiplication and division`() {
        let len: Geometry<Double>.Length = .init(10)
        #expect((len * 2) == 20)
        #expect((2 * len) == 20)
        #expect((len / 2) == 5)
    }

    @Test
    func `Dimension map`() {
        let dim: Geometry<Double>.Dimension = .init(10)
        let mapped = dim.map { $0 * 2 }
        #expect(mapped == 20)
    }

    @Test
    func `X negation and multiplication`() {
        let x: Geometry<Double>.X = .init(10)
        #expect((-x) == -10)
        #expect((x * 2.0) == 20)
        #expect((x / 2) == 5)
    }

    @Test
    func `Y negation and multiplication`() {
        let y: Geometry<Double>.Y = .init(10)
        #expect((-y) == -10)
        #expect((y * 2.0) == 20)
        #expect((y / 2) == 5)
    }
}

// MARK: - AffineTransform Generic Tests

@Suite
struct AffineTransformGenericTests {
    @Test
    func `Float AffineTransform`() {
        let transform: Geometry<Float>.AffineTransform = .identity
        let point: Geometry<Float>.Point<2> = .init(x: 10, y: 20)
        let result = transform.apply(to: point)
        #expect(result.x == 10)
        #expect(result.y.value == 20)
    }

    @Test
    func `Float rotation`() {
        let transform: Geometry<Float>.AffineTransform = .rotation(.halfPi)
        let point: Geometry<Float>.Point<2> = .init(x: 1, y: 0)
        let result = transform.apply(to: point)
        #expect(abs(result.x.value) < 0.0001)
        #expect(abs(result.y.value - 1) < 0.0001)
    }
}

// MARK: - Linear Transform Tests

@Suite
struct LinearTransformTests {
    @Test
    func `Linear identity`() {
        let identity = Linear<2>.identity
        #expect(identity.a == 1)
        #expect(identity.b == 0)
        #expect(identity.c == 0)
        #expect(identity.d == 1)
    }

    @Test
    func `Linear from Scale`() {
        let scale = Scale<2>(x: 2, y: 3)
        let linear = scale.linear
        #expect(linear.a == 2)
        #expect(linear.b == 0)
        #expect(linear.c == 0)
        #expect(linear.d == 3)
    }

    @Test
    func `Linear from Rotation`() {
        let rotation = Rotation<2>(angle: .halfPi)
        let linear = rotation.matrix
        #expect(abs(linear.a) < 1e-10)
        #expect(abs(linear.b + 1) < 1e-10)
        #expect(abs(linear.c - 1) < 1e-10)
        #expect(abs(linear.d) < 1e-10)
    }

    @Test
    func `Linear concatenation`() {
        let scale = Linear<2>.scale(2)
        let rotation = Linear<2>.rotation(.halfPi)
        let combined = rotation.concatenating(scale)
        // Scale first, then rotate
        #expect(abs(combined.a) < 1e-10)
        #expect(abs(combined.b + 2) < 1e-10)
        #expect(abs(combined.c - 2) < 1e-10)
        #expect(abs(combined.d) < 1e-10)
    }

    @Test
    func `Linear determinant`() {
        let identity = Linear<2>.identity
        #expect(identity.determinant == 1)

        let scale = Linear<2>.scale(x: 2, y: 3)
        #expect(scale.determinant == 6)
    }

    @Test
    func `Linear inversion`() {
        let scale = Linear<2>.scale(x: 2, y: 4)
        let inverted = scale.inverted!
        #expect(inverted.a == 0.5)
        #expect(inverted.d == 0.25)

        let singular = Linear<2>(a: 1, b: 1, c: 1, d: 1)
        #expect(singular.inverted == nil)
    }
}

// MARK: - Scale Tests

@Suite
struct ScaleTransformTests {
    @Test
    func `Scale identity`() {
        let identity = Scale<2>.identity
        #expect(identity.x == 1)
        #expect(identity.y == 1)
    }

    @Test
    func `Scale uniform`() {
        let uniform = Scale<2>.uniform(3)
        #expect(uniform.x == 3)
        #expect(uniform.y == 3)
    }

    @Test
    func `Scale composition`() {
        let a = Scale<2>(x: 2, y: 3)
        let b = Scale<2>(x: 4, y: 5)
        let combined = a.concatenating(b)
        #expect(combined.x == 8)
        #expect(combined.y == 15)
    }

    @Test
    func `Scale inversion`() {
        let scale = Scale<2>(x: 2, y: 4)
        let inverted = scale.inverted
        #expect(inverted.x == 0.5)
        #expect(inverted.y == 0.25)
    }
}

// MARK: - Rotation Tests

@Suite
struct RotationTransformTests {
    @Test
    func `Rotation identity`() {
        let identity = Rotation<2>.identity
        #expect(identity.angle == 0)
    }

    @Test
    func `Rotation from angle`() {
        let rotation = Rotation<2>(angle: .pi)
        #expect(abs(rotation.angle - .pi) < 1e-10)
    }

    @Test
    func `Rotation quarter turn`() {
        let rotation = Rotation<2>.quarterTurn
        #expect(abs(rotation.angle - .pi / 2) < 1e-10)
    }

    @Test
    func `Rotation composition`() {
        let a = Rotation<2>(angle: .pi(over: 4))
        let b = Rotation<2>(angle: .pi(over: 4))
        let combined = a.concatenating(b)
        #expect(abs(combined.angle - .pi / 2) < 1e-10)
    }

    @Test
    func `Rotation inversion`() {
        let rotation = Rotation<2>(angle: .pi(over: 3))
        let inverted = rotation.inverted
        #expect(abs(inverted.angle + .pi / 3) < 1e-10)
    }
}

// MARK: - Shear Tests

@Suite
struct ShearTransformTests {
    @Test
    func `Shear identity`() {
        let identity = Shear<2>.identity
        #expect(identity.x == 0)
        #expect(identity.y == 0)
    }

    @Test
    func `Shear horizontal`() {
        let shear = Shear<2>.horizontal(0.5)
        #expect(shear.x == 0.5)
        #expect(shear.y == 0)
    }

    @Test
    func `Shear vertical`() {
        let shear = Shear<2>.vertical(0.5)
        #expect(shear.x == 0)
        #expect(shear.y == 0.5)
    }

    @Test
    func `Shear to Linear`() {
        let shear = Shear<2>(x: 0.5, y: 0.25)
        let linear = shear.linear
        #expect(linear.a == 1)
        #expect(linear.b == 0.5)
        #expect(linear.c == 0.25)
        #expect(linear.d == 1)
    }
}
