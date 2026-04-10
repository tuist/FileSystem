// Region Tests.swift

import Testing

@testable import Region

@Suite
struct RegionTests {
    @Test
    func cardinalOpposite() {
        #expect(Region.Cardinal.north.opposite == .south)
        #expect(Region.Cardinal.east.opposite == .west)
    }

    @Test
    func quadrantRotation() {
        #expect(Region.Quadrant.I.next == .II)
        #expect(Region.Quadrant.II.next == .III)
    }

    @Test
    func edgeOpposite() {
        #expect(Region.Edge.top.opposite == .bottom)
        #expect(Region.Edge.left.opposite == .right)
    }

    @Test
    func cornerOpposite() {
        #expect(Region.Corner.topLeft.opposite == .bottomRight)
    }
}
