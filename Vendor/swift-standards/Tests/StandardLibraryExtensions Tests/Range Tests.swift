import Testing

@testable import StandardLibraryExtensions

@Suite
struct `Range - Extensions` {

    // MARK: - Range.overlap

    @Test
    func `overlap with intersecting ranges returns intersection`() {
        let a = 0..<10
        let b = 5..<15
        let result = a.overlap(b)

        #expect(result == 5..<10)
    }

    @Test(arguments: [
        (0..<5, 5..<10),
        (0..<5, 10..<15),
        (10..<20, 0..<5),
    ])
    func `overlap with non-overlapping ranges returns nil`(ranges: (Range<Int>, Range<Int>)) {
        let result = ranges.0.overlap(ranges.1)
        #expect(result == nil)
    }

    @Test
    func `overlap with subset returns subset`() {
        let outer = 0..<20
        let inner = 5..<15
        let result = outer.overlap(inner)

        #expect(result == inner)
    }

    @Test
    func `overlap with superset returns self`() {
        let inner = 5..<15
        let outer = 0..<20
        let result = inner.overlap(outer)

        #expect(result == inner)
    }

    @Test
    func `overlap with identical range returns same range`() {
        let range = 5..<15
        let result = range.overlap(range)

        #expect(result == range)
    }

    @Test
    func `overlap is commutative`() {
        let a = 3..<12
        let b = 7..<20

        #expect(a.overlap(b) == b.overlap(a))
    }

    // MARK: - Range.clamped

    @Test
    func `clamped to larger range returns self`() {
        let range = 5..<15
        let bounds = 0..<20
        let result = range.clamped(to: bounds)

        #expect(result == range)
    }

    @Test
    func `clamped to smaller range returns bounds`() {
        let range = 0..<20
        let bounds = 5..<15
        let result = range.clamped(to: bounds)

        #expect(result == bounds)
    }

    @Test
    func `clamped with partial overlap clamps correctly`() {
        let range = 0..<10
        let bounds = 5..<20
        let result = range.clamped(to: bounds)

        #expect(result == 5..<10)
    }

    @Test
    func `clamped to non-overlapping returns nil`() {
        let range = 0..<5
        let bounds = 10..<20
        let result = range.clamped(to: bounds)

        #expect(result == nil)
    }

    // MARK: - Range.split

    @Test(arguments: [
        (0..<10, 5, (0..<5, 5..<10)),
        (0..<100, 50, (0..<50, 50..<100)),
        (10..<20, 15, (10..<15, 15..<20)),
    ])
    func `split at midpoint creates two ranges`(
        testCase: (Range<Int>, Int, (Range<Int>, Range<Int>))
    ) {
        let (range, point, expected) = testCase
        let result = range.split(at: point)

        #expect(result?.lower == expected.0)
        #expect(result?.upper == expected.1)
    }

    @Test
    func `split at lower bound returns nil`() {
        let range = 5..<15
        let result = range.split(at: 5)

        #expect(result == nil)
    }

    @Test
    func `split at upper bound returns nil`() {
        let range = 5..<15
        let result = range.split(at: 15)

        #expect(result == nil)
    }

    @Test
    func `split outside range returns nil`() {
        let range = 5..<15
        #expect(range.split(at: 0) == nil)
        #expect(range.split(at: 20) == nil)
    }

    @Test
    func `split creates contiguous non-overlapping ranges`() {
        let range = 0..<100
        let result = range.split(at: 42)!

        // Lower ends where upper begins
        #expect(result.lower.upperBound == result.upper.lowerBound)

        // No overlap
        #expect(result.lower.upperBound <= result.upper.lowerBound)

        // Union would cover original (if we could union ranges)
        #expect(result.lower.lowerBound == range.lowerBound)
        #expect(result.upper.upperBound == range.upperBound)
    }
}
