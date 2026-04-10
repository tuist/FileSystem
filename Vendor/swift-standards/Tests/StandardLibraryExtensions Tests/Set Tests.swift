import StandardsTestSupport
import Testing

@testable import StandardLibraryExtensions

@Suite
struct `Set - Extensions` {

    // MARK: - partition(where:)

    @Test
    func `partition splits set correctly`() {
        let numbers: Set = [1, 2, 3, 4, 5, 6]
        let (evens, odds) = numbers.partition(where: { $0.isMultiple(of: 2) })

        #expect(evens == [2, 4, 6])
        #expect(odds == [1, 3, 5])
    }

    @Test
    func `partition on empty set returns empty sets`() {
        let empty: Set<Int> = []
        let (satisfying, failing) = empty.partition(where: { $0 > 0 })

        #expect(satisfying.isEmpty)
        #expect(failing.isEmpty)
    }

    @Test
    func `partition where all satisfy returns full and empty`() {
        let numbers: Set = [2, 4, 6, 8]
        let (evens, odds) = numbers.partition(where: { $0.isMultiple(of: 2) })

        #expect(evens == numbers)
        #expect(odds.isEmpty)
    }

    @Test
    func `partition where none satisfy returns empty and full`() {
        let numbers: Set = [1, 3, 5, 7]
        let (evens, odds) = numbers.partition(where: { $0.isMultiple(of: 2) })

        #expect(evens.isEmpty)
        #expect(odds == numbers)
    }

    @Test
    func `partition creates disjoint sets`() {
        let numbers: Set = [1, 2, 3, 4, 5]
        let (satisfying, failing) = numbers.partition(where: { $0 > 3 })

        // Disjoint: intersection is empty
        #expect(satisfying.isDisjoint(with: failing))

        // Union equals original
        #expect(satisfying.union(failing) == numbers)
    }

    // MARK: - subsets(ofSize:)

    @Test
    func `subsets of size 0 returns empty set`() {
        let set: Set = [1, 2, 3]
        let result = set.subsets(ofSize: 0)

        #expect(result == [[]])
    }

    @Test
    func `subsets of size equal to count returns original set`() {
        let set: Set = [1, 2, 3]
        let result = set.subsets(ofSize: 3)

        #expect(result == [set])
    }

    @Test
    func `subsets of size 2 from 3 elements returns 3 subsets`() {
        let set: Set = [1, 2, 3]
        let result = set.subsets(ofSize: 2)

        #expect(result.count == 3)
        #expect(result.contains([1, 2]))
        #expect(result.contains([1, 3]))
        #expect(result.contains([2, 3]))
    }

    @Test
    func `subsets of size 1 returns all singleton sets`() {
        let set: Set = [1, 2, 3]
        let result = set.subsets(ofSize: 1)

        #expect(result.count == 3)
        #expect(result.contains([1]))
        #expect(result.contains([2]))
        #expect(result.contains([3]))
    }

    @Test
    func `subsets with negative size returns empty`() {
        let set: Set = [1, 2, 3]
        let result = set.subsets(ofSize: -1)

        #expect(result.isEmpty)
    }

    @Test
    func `subsets with size greater than count returns empty`() {
        let set: Set = [1, 2, 3]
        let result = set.subsets(ofSize: 5)

        #expect(result.isEmpty)
    }

    @Test
    func `subsets count matches binomial coefficient`() {
        let set: Set = [1, 2, 3, 4]

        // C(4,2) = 6
        let result = set.subsets(ofSize: 2)
        #expect(result.count == 6)
    }

    // MARK: - cartesianProduct

    @Test
    func `cartesianProduct produces all pairs`() {
        let a: Set = [1, 2]
        let b: Set = ["x", "y"]
        let result = a.cartesianProduct(b)

        #expect(result.count == 4)
        #expect(result.contains(where: { $0 == (1, "x") }))
        #expect(result.contains(where: { $0 == (1, "y") }))
        #expect(result.contains(where: { $0 == (2, "x") }))
        #expect(result.contains(where: { $0 == (2, "y") }))
    }

    @Test
    func `cartesianProduct with empty set returns empty`() {
        let a: Set = [1, 2]
        let b: Set<String> = []
        let result = a.cartesianProduct(b)

        #expect(result.isEmpty)
    }

    @Test
    func `cartesianProduct count equals product of cardinalities`() {
        let a: Set = [1, 2, 3]
        let b: Set = ["a", "b", "c", "d"]
        let result = a.cartesianProduct(b)

        #expect(result.count == a.count * b.count)
    }

    // MARK: - cartesianSquare

    @Test
    func `cartesianSquare includes all pairs from same set`() {
        let set: Set = [1, 2, 3]
        let result = set.cartesianSquare()

        #expect(result.count == 9)
        #expect(result.contains(where: { $0 == (1, 1) }))
        #expect(result.contains(where: { $0 == (1, 2) }))
        #expect(result.contains(where: { $0 == (2, 3) }))
        #expect(result.contains(where: { $0 == (3, 3) }))
    }

    @Test
    func `cartesianSquare count equals n squared`() {
        let set: Set = [1, 2, 3, 4]
        let result = set.cartesianSquare()

        #expect(result.count == set.count * set.count)
    }
}

// MARK: - Performance Tests

extension `Performance Tests` {
    @Suite
    struct `Set - Performance` {

        @Test(.timed(threshold: .milliseconds(15), maxAllocations: 10_000_000))
        func `partition 10k elements`() {
            let numbers: Set = Set(1...10_000)
            _ = numbers.partition(where: { $0.isMultiple(of: 2) })
        }

        @Test(.timed(threshold: .milliseconds(2), maxAllocations: 2_000_000))
        func `subsets of size 2 from 20 elements`() {
            let set: Set = Set(1...20)
            _ = set.subsets(ofSize: 2)
        }

        @Test(.timed(threshold: .milliseconds(100), maxAllocations: 2_000_000))
        func `subsets of size 5 from 15 elements`() {
            let set: Set = Set(1...15)
            _ = set.subsets(ofSize: 5)
        }

        @Test(.timed(threshold: .milliseconds(50), maxAllocations: 500_000))
        func `cartesianProduct 100x100`() {
            let a: Set = Set(1...100)
            let b: Set = Set(1...100)
            _ = a.cartesianProduct(b)
        }

        @Test(.timed(threshold: .milliseconds(20), maxAllocations: 2_000_000))
        func `cartesianSquare 100 elements`() {
            let set: Set = Set(1...100)
            _ = set.cartesianSquare()
        }
    }
}
