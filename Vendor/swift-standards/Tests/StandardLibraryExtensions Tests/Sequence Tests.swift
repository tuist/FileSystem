import StandardsTestSupport
import Testing

@testable import StandardLibraryExtensions

@Suite
struct `Sequence - Extensions` {

    // MARK: - sum() (AdditiveArithmetic)

    @Test(arguments: [
        ([1, 2, 3, 4, 5], 15),
        ([10, 20, 30], 60),
        ([], 0),
        ([42], 42),
    ])
    func `sum returns correct total for integers`(testCase: ([Int], Int)) {
        let (array, expected) = testCase
        #expect(array.sum() == expected)
    }

    @Test
    func `sum works with floating point`() {
        let numbers = [1.5, 2.5, 3.0]
        #expect(numbers.sum() == 7.0)
    }

    @Test
    func `sum on empty sequence returns zero`() {
        let empty: [Int] = []
        #expect(empty.sum() == 0)
    }

    // MARK: - product() (Numeric)

    @Test(arguments: [
        ([1, 2, 3, 4, 5], 120),
        ([2, 3, 4], 24),
        ([10, 10], 100),
        ([7], 7),
    ])
    func `product returns correct result for integers`(testCase: ([Int], Int)) {
        let (array, expected) = testCase
        #expect(array.product() == expected)
    }

    @Test
    func `product on empty sequence returns one`() {
        let empty: [Int] = []
        #expect(empty.product() == 1)
    }

    @Test
    func `product with zero returns zero`() {
        let numbers = [1, 2, 0, 4, 5]
        #expect(numbers.product() == 0)
    }

    @Test
    func `product works with floating point`() {
        let numbers = [2.0, 2.5, 2.0]
        #expect(numbers.product() == 10.0)
    }

    // MARK: - mean() (BinaryInteger)

    @Test(arguments: [
        ([1, 2, 3, 4, 5], 3),
        ([10, 20, 30], 20),
        ([100], 100),
        ([2, 4, 6, 8], 5),
    ])
    func `mean returns correct average for integers`(testCase: ([Int], Int)) {
        let (array, expected) = testCase
        #expect(array.mean() == expected)
    }

    @Test
    func `mean on empty sequence returns nil`() {
        let empty: [Int] = []
        #expect(empty.mean() == nil)
    }

    // MARK: - mean() (BinaryFloatingPoint)

    @Test
    func `mean returns correct average for doubles`() {
        let numbers = [1.0, 2.0, 3.0, 4.0, 5.0]
        #expect(numbers.mean() == 3.0)
    }

    @Test
    func `mean handles fractional results`() {
        let numbers = [1.0, 2.0, 3.0]
        #expect(numbers.mean() == 2.0)
    }

    @Test
    func `mean on empty floating point sequence returns nil`() {
        let empty: [Double] = []
        #expect(empty.mean() == nil)
    }

    // MARK: - count(where:)

    @Test(arguments: [
        ([1, 2, 3, 4, 5, 6], 3),  // 3 even numbers
        ([1, 3, 5, 7], 0),  // 0 even numbers
        ([2, 4, 6, 8], 4),  // all even
        ([], 0),  // empty
    ])
    func `count where predicate counts matching elements`(testCase: ([Int], Int)) {
        let (array, expected) = testCase
        #expect(array.count(where: { $0.isMultiple(of: 2) }) == expected)
    }

    // MARK: - frequencies()

    @Test
    func `frequencies counts element occurrences`() {
        let numbers = [1, 2, 2, 3, 1, 4, 2]
        let result = numbers.frequencies()

        #expect(result[1] == 2)
        #expect(result[2] == 3)
        #expect(result[3] == 1)
        #expect(result[4] == 1)
    }

    @Test
    func `frequencies on string characters`() {
        let chars = Array("hello")
        let result = chars.frequencies()

        #expect(result["h"] == 1)
        #expect(result["e"] == 1)
        #expect(result["l"] == 2)
        #expect(result["o"] == 1)
    }

    @Test
    func `frequencies on empty sequence returns empty`() {
        let empty: [Int] = []
        #expect(empty.frequencies().isEmpty)
    }

    @Test
    func `frequencies with all unique elements`() {
        let numbers = [1, 2, 3, 4, 5]
        let result = numbers.frequencies()

        #expect(result.count == 5)
        #expect(result.values.allSatisfy { $0 == 1 })
    }

    // MARK: - isSorted()

    @Test(arguments: [
        [1, 2, 3, 4, 5],
        [1, 1, 2, 3, 3],
        [],
        [42],
    ])
    func `isSorted returns true for sorted sequences`(array: [Int]) {
        #expect(array.isSorted())
    }

    @Test(arguments: [
        [5, 4, 3, 2, 1],
        [1, 3, 2, 4],
        [1, 2, 10, 3],
    ])
    func `isSorted returns false for unsorted sequences`(array: [Int]) {
        #expect(!array.isSorted())
    }

    // MARK: - isSorted(by:)

    @Test
    func `isSorted by descending order`() {
        let numbers = [5, 4, 3, 2, 1]
        #expect(numbers.isSorted(by: >))
    }

    @Test
    func `isSorted by custom comparator`() {
        let words = ["a", "bb", "ccc", "dddd"]
        #expect(words.isSorted(by: { $0.count <= $1.count }))
    }

    @Test
    func `isSorted by fails for wrong order`() {
        let numbers = [1, 2, 3, 4, 5]
        #expect(!numbers.isSorted(by: >))
    }

    // MARK: - max(count:)

    @Test
    func `max count returns N largest elements`() {
        let numbers = [3, 1, 4, 1, 5, 9, 2]
        let result = numbers.max(count: 3)

        #expect(result == [9, 5, 4])
    }

    @Test
    func `max count with zero returns empty`() {
        let numbers = [1, 2, 3]
        #expect(numbers.max(count: 0).isEmpty)
    }

    @Test
    func `max count greater than array size returns all sorted`() {
        let numbers = [3, 1, 2]
        let result = numbers.max(count: 10)

        #expect(result.count == 3)
        #expect(result == [3, 2, 1])
    }

    @Test
    func `max count on empty returns empty`() {
        let empty: [Int] = []
        #expect(empty.max(count: 5).isEmpty)
    }

    // MARK: - min(count:)

    @Test
    func `min count returns N smallest elements`() {
        let numbers = [3, 1, 4, 1, 5, 9, 2]
        let result = numbers.min(count: 3)

        #expect(result == [1, 1, 2])
    }

    @Test
    func `min count with zero returns empty`() {
        let numbers = [1, 2, 3]
        #expect(numbers.min(count: 0).isEmpty)
    }

    @Test
    func `min count greater than array size returns all sorted`() {
        let numbers = [3, 1, 2]
        let result = numbers.min(count: 10)

        #expect(result.count == 3)
        #expect(result == [1, 2, 3])
    }
}

// MARK: - Performance Tests

extension `Performance Tests` {
    @Suite
    struct `Sequence - Performance` {

        // MARK: - Aggregation Performance

        @Test(.timed(threshold: .milliseconds(50), maxAllocations: 10_000_000))
        func `sum 100k elements`() {
            let numbers = Array(1...100_000)
            _ = numbers.sum()
        }

        @Test(.timed(threshold: .microseconds(500), maxAllocations: 1_000_000))
        func `product 20 elements`() {
            let numbers = Array(1...20)
            _ = numbers.product()
        }

        @Test(.timed(threshold: .milliseconds(50), maxAllocations: 10_000_000))
        func `mean 100k integers`() {
            let numbers = Array(1...100_000)
            _ = numbers.mean()
        }

        @Test(.timed(threshold: .milliseconds(70), maxAllocations: 10_000_000))
        func `mean 100k doubles`() {
            let numbers = Array(1...100_000).map { Double($0) }
            _ = numbers.mean()
        }

        // MARK: - Collection Operations

        @Test(.timed(threshold: .milliseconds(50), maxAllocations: 10_000_000))
        func `count where 100k elements`() {
            let numbers = Array(1...100_000)
            _ = numbers.count(where: { $0.isMultiple(of: 2) })
        }

        @Test(.timed(threshold: .milliseconds(60), maxAllocations: 10_000_000))
        func `frequencies 100k elements with duplicates`() {
            let numbers = Array(repeating: 1...100, count: 1000).flatMap { $0 }
            _ = numbers.frequencies()
        }

        @Test(.timed(threshold: .milliseconds(50), maxAllocations: 10_000_000))
        func `isSorted 100k sorted elements`() {
            let numbers = Array(1...100_000)
            _ = numbers.isSorted()
        }

        @Test(.timed(threshold: .milliseconds(40), maxAllocations: 10_000_000))
        func `isSorted 100k reversed elements`() {
            let numbers = Array((1...100_000).reversed())
            _ = numbers.isSorted()
        }

        // MARK: - max/min count Performance

        @Test(.timed(threshold: .milliseconds(120), maxAllocations: 10_000_000))
        func `max count 10 from 100k`() {
            let numbers = Array(1...100_000).shuffled()
            _ = numbers.max(count: 10)
        }

        @Test(.timed(threshold: .milliseconds(100), maxAllocations: 10_000_000))
        func `min count 10 from 100k`() {
            let numbers = Array(1...100_000).shuffled()
            _ = numbers.min(count: 10)
        }
    }
}
