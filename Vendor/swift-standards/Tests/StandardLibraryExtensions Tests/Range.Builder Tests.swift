import Testing

@testable import StandardLibraryExtensions

@Suite("Range.Builder Tests")
struct RangeBuilderTests {

    @Suite("Basic Construction")
    struct BasicConstructionTests {

        @Test("Single range")
        func singleRange() {
            let ranges = Range.build {
                0..<5
            }
            #expect(ranges == [0..<5])
        }

        @Test("Multiple ranges")
        func multipleRanges() {
            let ranges = Range.build {
                0..<5
                10..<15
                20..<25
            }
            #expect(ranges == [0..<5, 10..<15, 20..<25])
        }

        @Test("Empty block")
        func emptyBlock() {
            let ranges: [Range<Int>] = Range.build {
            }
            #expect(ranges.isEmpty)
        }
    }

    @Suite("Control Flow")
    struct ControlFlowTests {

        @Test("Conditional inclusion - true")
        func conditionalInclusionTrue() {
            let include = true
            let ranges = Range.build {
                0..<5
                if include {
                    10..<15
                }
            }
            #expect(ranges == [0..<5, 10..<15])
        }

        @Test("Conditional inclusion - false")
        func conditionalInclusionFalse() {
            let include = false
            let ranges = Range.build {
                0..<5
                if include {
                    10..<15
                }
            }
            #expect(ranges == [0..<5])
        }

        @Test("If-else first branch")
        func ifElseFirstBranch() {
            let condition = true
            let ranges = Range.build {
                if condition {
                    0..<5
                } else {
                    10..<15
                }
            }
            #expect(ranges == [0..<5])
        }

        @Test("If-else second branch")
        func ifElseSecondBranch() {
            let condition = false
            let ranges = Range.build {
                if condition {
                    0..<5
                } else {
                    10..<15
                }
            }
            #expect(ranges == [10..<15])
        }

        @Test("For loop")
        func forLoop() {
            let ranges = Range.build {
                for i in 0..<3 {
                    (i * 10)..<(i * 10 + 5)
                }
            }
            #expect(ranges == [0..<5, 10..<15, 20..<25])
        }
    }

    @Suite("Expression Building")
    struct ExpressionBuildingTests {

        @Test("Array of ranges")
        func arrayOfRanges() {
            let existing = [0..<5, 10..<15]
            let ranges = Range.build {
                existing
                20..<25
            }
            #expect(ranges == [0..<5, 10..<15, 20..<25])
        }
    }

    @Suite("Static Method Tests")
    struct StaticMethodTests {

        @Test("buildExpression range")
        func buildExpressionRange() {
            let result = Range<Int>.Builder.buildExpression(0..<5)
            #expect(result == [0..<5])
        }

        @Test("buildPartialBlock first")
        func buildPartialBlockFirst() {
            let result = Range<Int>.Builder.buildPartialBlock(first: [0..<5])
            #expect(result == [0..<5])
        }

        @Test("buildPartialBlock first void")
        func buildPartialBlockFirstVoid() {
            let result = Range<Int>.Builder.buildPartialBlock(first: ())
            #expect(result.isEmpty)
        }

        @Test("buildPartialBlock accumulated")
        func buildPartialBlockAccumulated() {
            let result = Range<Int>.Builder.buildPartialBlock(accumulated: [0..<5], next: [10..<15])
            #expect(result == [0..<5, 10..<15])
        }

        @Test("buildOptional some")
        func buildOptionalSome() {
            let result = Range<Int>.Builder.buildOptional([0..<5])
            #expect(result == [0..<5])
        }

        @Test("buildOptional none")
        func buildOptionalNone() {
            let result = Range<Int>.Builder.buildOptional(nil)
            #expect(result.isEmpty)
        }

        @Test("buildArray")
        func buildArray() {
            let result = Range<Int>.Builder.buildArray([[0..<5], [10..<15]])
            #expect(result == [0..<5, 10..<15])
        }
    }

    @Suite("Different Bound Types")
    struct DifferentBoundTypesTests {

        @Test("Double ranges")
        func doubleRanges() {
            let ranges = Range.build {
                0.0..<1.0
                2.0..<3.0
            }
            #expect(ranges == [0.0..<1.0, 2.0..<3.0])
        }

        @Test("String Index ranges")
        func stringIndexRanges() {
            let str = "Hello, World!"
            let ranges = Range.build {
                str.startIndex..<str.index(str.startIndex, offsetBy: 5)
            }
            #expect(ranges.count == 1)
        }
    }

    @Suite("Limited Availability")
    struct LimitedAvailabilityTests {

        @Test("Limited availability passthrough")
        func limitedAvailabilityPassthrough() {
            let ranges = Range.build {
                0..<5
                if #available(macOS 26, iOS 26, *) {
                    10..<15
                }
            }
            #expect(ranges == [0..<5, 10..<15])
        }
    }
}
