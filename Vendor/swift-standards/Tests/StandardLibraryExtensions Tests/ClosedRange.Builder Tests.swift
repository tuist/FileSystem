import Testing

@testable import StandardLibraryExtensions

@Suite("ClosedRange.Builder Tests")
struct ClosedRangeBuilderTests {

    @Suite("Basic Construction")
    struct BasicConstructionTests {

        @Test("Single range")
        func singleRange() {
            let ranges = ClosedRange.build {
                1...5
            }
            #expect(ranges == [1...5])
        }

        @Test("Multiple ranges")
        func multipleRanges() {
            let ranges = ClosedRange.build {
                1...5
                10...15
                20...25
            }
            #expect(ranges == [1...5, 10...15, 20...25])
        }

        @Test("Empty block")
        func emptyBlock() {
            let ranges: [ClosedRange<Int>] = ClosedRange.build {
            }
            #expect(ranges.isEmpty)
        }

        @Test("Single value becomes single-element range")
        func singleValueBecomesSingleElementRange() {
            let ranges = ClosedRange.build {
                5
            }
            #expect(ranges == [5...5])
        }

        @Test("Mixed values and ranges")
        func mixedValuesAndRanges() {
            let ranges = ClosedRange.build {
                1
                3...5
                10
            }
            #expect(ranges == [1...1, 3...5, 10...10])
        }
    }

    @Suite("Control Flow")
    struct ControlFlowTests {

        @Test("Conditional inclusion - true")
        func conditionalInclusionTrue() {
            let include = true
            let ranges = ClosedRange.build {
                1...5
                if include {
                    10...15
                }
            }
            #expect(ranges == [1...5, 10...15])
        }

        @Test("Conditional inclusion - false")
        func conditionalInclusionFalse() {
            let include = false
            let ranges = ClosedRange.build {
                1...5
                if include {
                    10...15
                }
            }
            #expect(ranges == [1...5])
        }

        @Test("If-else first branch")
        func ifElseFirstBranch() {
            let condition = true
            let ranges = ClosedRange.build {
                if condition {
                    1...5
                } else {
                    10...15
                }
            }
            #expect(ranges == [1...5])
        }

        @Test("If-else second branch")
        func ifElseSecondBranch() {
            let condition = false
            let ranges = ClosedRange.build {
                if condition {
                    1...5
                } else {
                    10...15
                }
            }
            #expect(ranges == [10...15])
        }

        @Test("For loop")
        func forLoop() {
            let ranges = ClosedRange.build {
                for i in 0..<3 {
                    (i * 10)...(i * 10 + 5)
                }
            }
            #expect(ranges == [0...5, 10...15, 20...25])
        }
    }

    @Suite("Expression Building")
    struct ExpressionBuildingTests {

        @Test("Array of ranges")
        func arrayOfRanges() {
            let existing = [1...5, 10...15]
            let ranges = ClosedRange.build {
                existing
                20...25
            }
            #expect(ranges == [1...5, 10...15, 20...25])
        }
    }

    @Suite("Static Method Tests")
    struct StaticMethodTests {

        @Test("buildExpression range")
        func buildExpressionRange() {
            let result = ClosedRange<Int>.Builder.buildExpression(1...5)
            #expect(result == [1...5])
        }

        @Test("buildExpression single value")
        func buildExpressionSingleValue() {
            let result = ClosedRange<Int>.Builder.buildExpression(5)
            #expect(result == [5...5])
        }

        @Test("buildPartialBlock first")
        func buildPartialBlockFirst() {
            let result = ClosedRange<Int>.Builder.buildPartialBlock(first: [1...5])
            #expect(result == [1...5])
        }

        @Test("buildPartialBlock first void")
        func buildPartialBlockFirstVoid() {
            let result = ClosedRange<Int>.Builder.buildPartialBlock(first: ())
            #expect(result.isEmpty)
        }

        @Test("buildPartialBlock accumulated")
        func buildPartialBlockAccumulated() {
            let result = ClosedRange<Int>.Builder.buildPartialBlock(
                accumulated: [1...5],
                next: [10...15]
            )
            #expect(result == [1...5, 10...15])
        }

        @Test("buildOptional some")
        func buildOptionalSome() {
            let result = ClosedRange<Int>.Builder.buildOptional([1...5])
            #expect(result == [1...5])
        }

        @Test("buildOptional none")
        func buildOptionalNone() {
            let result = ClosedRange<Int>.Builder.buildOptional(nil)
            #expect(result.isEmpty)
        }

        @Test("buildArray")
        func buildArray() {
            let result = ClosedRange<Int>.Builder.buildArray([[1...5], [10...15]])
            #expect(result == [1...5, 10...15])
        }
    }

    @Suite("Different Bound Types")
    struct DifferentBoundTypesTests {

        @Test("Double ranges")
        func doubleRanges() {
            let ranges = ClosedRange.build {
                0.0...1.0
                2.0...3.0
            }
            #expect(ranges == [0.0...1.0, 2.0...3.0])
        }

        @Test("Character ranges")
        func characterRanges() {
            let ranges = ClosedRange.build {
                Character("a")...Character("z")
                Character("A")...Character("Z")
            }
            #expect(ranges.count == 2)
            #expect(ranges[0] == Character("a")...Character("z"))
            #expect(ranges[1] == Character("A")...Character("Z"))
        }
    }

    @Suite("Limited Availability")
    struct LimitedAvailabilityTests {

        @Test("Limited availability passthrough")
        func limitedAvailabilityPassthrough() {
            let ranges = ClosedRange.build {
                1...5
                if #available(macOS 26, iOS 26, *) {
                    10...15
                }
            }
            #expect(ranges == [1...5, 10...15])
        }
    }
}
