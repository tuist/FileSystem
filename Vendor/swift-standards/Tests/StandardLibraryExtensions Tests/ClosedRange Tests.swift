import Testing

@testable import StandardLibraryExtensions

@Suite
struct `ClosedRange - Extensions` {

    // MARK: - ClosedRange.overlap

    @Test
    func `overlap with intersecting ranges returns intersection`() {
        let a = 0...10
        let b = 5...15
        let result = a.overlap(b)

        #expect(result == 5...10)
    }

    @Test(arguments: [
        (0...4, 5...10),
        (0...5, 10...15),
        (10...20, 0...4),
    ])
    func `overlap with non-overlapping ranges returns nil`(
        ranges: (ClosedRange<Int>, ClosedRange<Int>)
    ) {
        let result = ranges.0.overlap(ranges.1)
        #expect(result == nil)
    }

    @Test
    func `overlap at boundary point returns single point range`() {
        let a = 0...5
        let b = 5...10
        let result = a.overlap(b)

        #expect(result == 5...5)
    }

    @Test
    func `overlap is commutative`() {
        let a = 3...12
        let b = 7...20

        #expect(a.overlap(b) == b.overlap(a))
    }

    // MARK: - ClosedRange.clamped

    @Test
    func `clamped to larger range returns self`() {
        let range = 5...15
        let bounds = 0...20
        let result = range.clamped(to: bounds)

        #expect(result == range)
    }

    @Test
    func `clamped to smaller range returns bounds`() {
        let range = 0...20
        let bounds = 5...15
        let result = range.clamped(to: bounds)

        #expect(result == bounds)
    }

    @Test
    func `clamped with partial overlap clamps correctly`() {
        let range = 0...10
        let bounds = 5...20
        let result = range.clamped(to: bounds)

        #expect(result == 5...10)
    }

    @Test
    func `clamped to non-overlapping returns nil`() {
        let range = 0...4
        let bounds = 10...20
        let result = range.clamped(to: bounds)

        #expect(result == nil)
    }
}
