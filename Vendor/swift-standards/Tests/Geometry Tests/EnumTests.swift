// EnumTests.swift
// Tests for Region types: Quadrant, Octant, Cardinal, Corner, Edge
// and Geometry type: Curvature

import Algebra
import Region
import Testing

@testable import Geometry

// MARK: - Quadrant Tests

@Suite
struct QuadrantTests {
    @Test
    func `Quadrant cases`() {
        #expect(Region.Quadrant.allCases.count == 4)
        #expect(Region.Quadrant.allCases.contains(.I))
        #expect(Region.Quadrant.allCases.contains(.II))
        #expect(Region.Quadrant.allCases.contains(.III))
        #expect(Region.Quadrant.allCases.contains(.IV))
    }

    @Test
    func `Quadrant opposite is 180 degree rotation`() {
        #expect(Region.Quadrant.I.opposite == .III)
        #expect(Region.Quadrant.II.opposite == .IV)
        #expect(Region.Quadrant.III.opposite == .I)
        #expect(Region.Quadrant.IV.opposite == .II)
    }

    @Test
    func `Quadrant opposite is involution`() {
        for q in Region.Quadrant.allCases {
            #expect(q.opposite.opposite == q)
        }
    }

    @Test
    func `Quadrant negation operator`() {
        #expect(!Region.Quadrant.I == .III)
        #expect(!Region.Quadrant.II == .IV)
    }

    @Test
    func `Quadrant rotation`() {
        // Next (counterclockwise)
        #expect(Region.Quadrant.I.next == .II)
        #expect(Region.Quadrant.II.next == .III)
        #expect(Region.Quadrant.III.next == .IV)
        #expect(Region.Quadrant.IV.next == .I)

        // Previous (clockwise)
        #expect(Region.Quadrant.I.previous == .IV)
        #expect(Region.Quadrant.II.previous == .I)
        #expect(Region.Quadrant.III.previous == .II)
        #expect(Region.Quadrant.IV.previous == .III)

        // Four rotations return to start
        var q = Region.Quadrant.I
        q = q.next.next.next.next
        #expect(q == .I)
    }

    @Test
    func `Quadrant sign properties`() {
        #expect(Region.Quadrant.I.hasPositiveX == true)
        #expect(Region.Quadrant.I.hasPositiveY == true)
        #expect(Region.Quadrant.II.hasPositiveX == false)
        #expect(Region.Quadrant.II.hasPositiveY == true)
        #expect(Region.Quadrant.III.hasPositiveX == false)
        #expect(Region.Quadrant.III.hasPositiveY == false)
        #expect(Region.Quadrant.IV.hasPositiveX == true)
        #expect(Region.Quadrant.IV.hasPositiveY == false)
    }

    @Test
    func `Quadrant Value typealias`() {
        let tagged: Region.Quadrant.Value<String> = .init(tag: .I, value: "first")
        #expect(tagged.tag == .I)
        #expect(tagged.value == "first")
    }
}

// MARK: - Octant Tests

@Suite
struct OctantTests {
    @Test
    func `Octant cases`() {
        #expect(Region.Octant.allCases.count == 8)
    }

    @Test
    func `Octant opposite is reflection through origin`() {
        #expect(Region.Octant.ppp.opposite == .nnn)
        #expect(Region.Octant.ppn.opposite == .nnp)
        #expect(Region.Octant.pnp.opposite == .npn)
        #expect(Region.Octant.pnn.opposite == .npp)
        #expect(Region.Octant.npp.opposite == .pnn)
        #expect(Region.Octant.npn.opposite == .pnp)
        #expect(Region.Octant.nnp.opposite == .ppn)
        #expect(Region.Octant.nnn.opposite == .ppp)
    }

    @Test
    func `Octant opposite is involution`() {
        for o in Region.Octant.allCases {
            #expect(o.opposite.opposite == o)
        }
    }

    @Test
    func `Octant negation operator`() {
        #expect(!Region.Octant.ppp == .nnn)
        #expect(!(!Region.Octant.ppp) == .ppp)
    }

    @Test
    func `Octant sign properties`() {
        // Test ppp
        #expect(Region.Octant.ppp.hasPositiveX == true)
        #expect(Region.Octant.ppp.hasPositiveY == true)
        #expect(Region.Octant.ppp.hasPositiveZ == true)

        // Test nnn
        #expect(Region.Octant.nnn.hasPositiveX == false)
        #expect(Region.Octant.nnn.hasPositiveY == false)
        #expect(Region.Octant.nnn.hasPositiveZ == false)

        // Test mixed
        #expect(Region.Octant.pnp.hasPositiveX == true)
        #expect(Region.Octant.pnp.hasPositiveY == false)
        #expect(Region.Octant.pnp.hasPositiveZ == true)
    }

    @Test
    func `Octant Value typealias`() {
        let tagged: Region.Octant.Value<Int> = .init(tag: .ppp, value: 1)
        #expect(tagged.tag == .ppp)
        #expect(tagged.value == 1)
    }
}

// MARK: - Cardinal Tests

@Suite
struct CardinalTests {
    @Test
    func `Cardinal cases`() {
        #expect(Region.Cardinal.allCases.count == 4)
        #expect(Region.Cardinal.allCases.contains(.north))
        #expect(Region.Cardinal.allCases.contains(.east))
        #expect(Region.Cardinal.allCases.contains(.south))
        #expect(Region.Cardinal.allCases.contains(.west))
    }

    @Test
    func `Cardinal opposite is 180 degree rotation`() {
        #expect(Region.Cardinal.north.opposite == .south)
        #expect(Region.Cardinal.south.opposite == .north)
        #expect(Region.Cardinal.east.opposite == .west)
        #expect(Region.Cardinal.west.opposite == .east)
    }

    @Test
    func `Cardinal opposite is involution`() {
        for c in Region.Cardinal.allCases {
            #expect(c.opposite.opposite == c)
        }
    }

    @Test
    func `Cardinal negation operator`() {
        #expect(!Region.Cardinal.north == .south)
        #expect(!Region.Cardinal.east == .west)
    }

    @Test
    func `Cardinal rotation forms Z4 group`() {
        // Clockwise rotation
        #expect(Region.Cardinal.north.clockwise == .east)
        #expect(Region.Cardinal.east.clockwise == .south)
        #expect(Region.Cardinal.south.clockwise == .west)
        #expect(Region.Cardinal.west.clockwise == .north)

        // Counterclockwise rotation
        #expect(Region.Cardinal.north.counterclockwise == .west)
        #expect(Region.Cardinal.west.counterclockwise == .south)
        #expect(Region.Cardinal.south.counterclockwise == .east)
        #expect(Region.Cardinal.east.counterclockwise == .north)

        // Four rotations return to start
        var c = Region.Cardinal.north
        c = c.clockwise.clockwise.clockwise.clockwise
        #expect(c == .north)
    }

    @Test
    func `Cardinal axis properties`() {
        #expect(Region.Cardinal.north.isVertical == true)
        #expect(Region.Cardinal.south.isVertical == true)
        #expect(Region.Cardinal.east.isHorizontal == true)
        #expect(Region.Cardinal.west.isHorizontal == true)

        #expect(Region.Cardinal.north.isHorizontal == false)
        #expect(Region.Cardinal.east.isVertical == false)
    }

    @Test
    func `Cardinal Value typealias`() {
        let tagged: Region.Cardinal.Value<Double> = .init(tag: .north, value: 100.0)
        #expect(tagged.tag == .north)
        #expect(tagged.value == 100.0)
    }
}

// MARK: - Corner Tests

@Suite
struct CornerTests {
    @Test
    func `Corner cases`() {
        #expect(Region.Corner.allCases.count == 4)
        #expect(Region.Corner.allCases.contains(.topLeft))
        #expect(Region.Corner.allCases.contains(.topRight))
        #expect(Region.Corner.allCases.contains(.bottomLeft))
        #expect(Region.Corner.allCases.contains(.bottomRight))
    }

    @Test
    func `Corner opposite is diagonal`() {
        #expect(Region.Corner.topLeft.opposite == .bottomRight)
        #expect(Region.Corner.topRight.opposite == .bottomLeft)
        #expect(Region.Corner.bottomLeft.opposite == .topRight)
        #expect(Region.Corner.bottomRight.opposite == .topLeft)
    }

    @Test
    func `Corner opposite is involution`() {
        for c in Region.Corner.allCases {
            #expect(c.opposite.opposite == c)
        }
    }

    @Test
    func `Corner negation operator`() {
        #expect(!Region.Corner.topLeft == .bottomRight)
        #expect(!(!Region.Corner.topLeft) == .topLeft)
    }

    @Test
    func `Corner position properties`() {
        #expect(Region.Corner.topLeft.isTop == true)
        #expect(Region.Corner.topRight.isTop == true)
        #expect(Region.Corner.bottomLeft.isTop == false)
        #expect(Region.Corner.bottomRight.isTop == false)

        #expect(Region.Corner.topLeft.isBottom == false)
        #expect(Region.Corner.bottomLeft.isBottom == true)

        #expect(Region.Corner.topLeft.isLeft == true)
        #expect(Region.Corner.bottomLeft.isLeft == true)
        #expect(Region.Corner.topRight.isLeft == false)

        #expect(Region.Corner.topRight.isRight == true)
        #expect(Region.Corner.bottomRight.isRight == true)
    }

    @Test
    func `Corner adjacent corners`() {
        #expect(Region.Corner.topLeft.horizontalAdjacent == .topRight)
        #expect(Region.Corner.topLeft.verticalAdjacent == .bottomLeft)
        #expect(Region.Corner.bottomRight.horizontalAdjacent == .bottomLeft)
        #expect(Region.Corner.bottomRight.verticalAdjacent == .topRight)
    }

    @Test
    func `Corner Value typealias`() {
        let tagged: Region.Corner.Value<Double> = .init(tag: .topLeft, value: 8.0)
        #expect(tagged.tag == .topLeft)
        #expect(tagged.value == 8.0)
    }
}

// MARK: - Edge Tests

@Suite
struct EdgeTests {
    @Test
    func `Edge cases`() {
        #expect(Region.Edge.allCases.count == 4)
        #expect(Region.Edge.allCases.contains(.top))
        #expect(Region.Edge.allCases.contains(.left))
        #expect(Region.Edge.allCases.contains(.bottom))
        #expect(Region.Edge.allCases.contains(.right))
    }

    @Test
    func `Edge opposite`() {
        #expect(Region.Edge.top.opposite == .bottom)
        #expect(Region.Edge.bottom.opposite == .top)
        #expect(Region.Edge.left.opposite == .right)
        #expect(Region.Edge.right.opposite == .left)
    }

    @Test
    func `Edge opposite is involution`() {
        for e in Region.Edge.allCases {
            #expect(e.opposite.opposite == e)
        }
    }

    @Test
    func `Edge negation operator`() {
        #expect(!Region.Edge.top == .bottom)
        #expect(!Region.Edge.left == .right)
    }

    @Test
    func `Edge orientation properties`() {
        #expect(Region.Edge.top.isHorizontal == true)
        #expect(Region.Edge.bottom.isHorizontal == true)
        #expect(Region.Edge.left.isHorizontal == false)
        #expect(Region.Edge.right.isHorizontal == false)

        #expect(Region.Edge.left.isVertical == true)
        #expect(Region.Edge.right.isVertical == true)
        #expect(Region.Edge.top.isVertical == false)
        #expect(Region.Edge.bottom.isVertical == false)
    }

    @Test
    func `Edge corners`() {
        let topCorners = Region.Edge.top.corners
        #expect(topCorners.0 == .topLeft)
        #expect(topCorners.1 == .topRight)

        let bottomCorners = Region.Edge.bottom.corners
        #expect(bottomCorners.0 == .bottomLeft)
        #expect(bottomCorners.1 == .bottomRight)

        let leftCorners = Region.Edge.left.corners
        #expect(leftCorners.0 == .topLeft)
        #expect(leftCorners.1 == .bottomLeft)

        let rightCorners = Region.Edge.right.corners
        #expect(rightCorners.0 == .topRight)
        #expect(rightCorners.1 == .bottomRight)
    }

    @Test
    func `Edge Value typealias`() {
        let tagged: Region.Edge.Value<Double> = .init(tag: .top, value: 20.0)
        #expect(tagged.tag == .top)
        #expect(tagged.value == 20.0)
    }
}

// MARK: - Curvature Tests

@Suite
struct CurvatureTests {
    @Test
    func `Curvature cases`() {
        #expect(Curvature.allCases.count == 2)
        #expect(Curvature.allCases.contains(.convex))
        #expect(Curvature.allCases.contains(.concave))
    }

    @Test
    func `Curvature opposite is involution`() {
        #expect(Curvature.convex.opposite == .concave)
        #expect(Curvature.concave.opposite == .convex)
        #expect(Curvature.convex.opposite.opposite == .convex)
    }

    @Test
    func `Curvature negation operator`() {
        #expect(!Curvature.convex == .concave)
        #expect(!Curvature.concave == .convex)
        #expect(!(!Curvature.convex) == .convex)
    }

    @Test
    func `Curvature Value typealias`() {
        let tagged: Curvature.Value<Double> = .init(tag: .convex, value: 0.5)
        #expect(tagged.tag == .convex)
        #expect(tagged.value == 0.5)
    }

    @Test
    func `Curvature Hashable`() {
        let set: Set<Curvature> = [.convex, .concave, .convex]
        #expect(set.count == 2)
    }
}
