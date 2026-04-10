import Testing

@testable import StandardLibraryExtensions

@Suite("ArraySlice.Builder Tests")
struct ArraySliceBuilderTests {

    @Suite("Basic Construction")
    struct BasicConstructionTests {

        @Test("Single element")
        func singleElement() {
            let slice: ArraySlice<Int> = ArraySlice {
                42
            }
            #expect(Array(slice) == [42])
        }

        @Test("Multiple elements")
        func multipleElements() {
            let slice: ArraySlice<Int> = ArraySlice {
                1
                2
                3
            }
            #expect(Array(slice) == [1, 2, 3])
        }

        @Test("Empty block")
        func emptyBlock() {
            let slice: ArraySlice<Int> = ArraySlice {
            }
            #expect(slice.isEmpty)
        }

        @Test("Mixed elements and arrays")
        func mixedElementsAndArrays() {
            let slice: ArraySlice<Int> = ArraySlice {
                1
                [2, 3]
                4
            }
            #expect(Array(slice) == [1, 2, 3, 4])
        }

        @Test("Nested slices")
        func nestedSlices() {
            let nested: ArraySlice<Int> = [10, 20]
            let slice: ArraySlice<Int> = ArraySlice {
                1
                nested
                2
            }
            #expect(Array(slice) == [1, 10, 20, 2])
        }
    }

    @Suite("Control Flow")
    struct ControlFlowTests {

        @Test("Conditional inclusion - true")
        func conditionalInclusionTrue() {
            let include = true
            let slice: ArraySlice<Int> = ArraySlice {
                1
                if include {
                    2
                }
                3
            }
            #expect(Array(slice) == [1, 2, 3])
        }

        @Test("Conditional inclusion - false")
        func conditionalInclusionFalse() {
            let include = false
            let slice: ArraySlice<Int> = ArraySlice {
                1
                if include {
                    2
                }
                3
            }
            #expect(Array(slice) == [1, 3])
        }

        @Test("If-else first branch")
        func ifElseFirstBranch() {
            let condition = true
            let slice: ArraySlice<String> = ArraySlice {
                if condition {
                    "first"
                } else {
                    "second"
                }
            }
            #expect(Array(slice) == ["first"])
        }

        @Test("If-else second branch")
        func ifElseSecondBranch() {
            let condition = false
            let slice: ArraySlice<String> = ArraySlice {
                if condition {
                    "first"
                } else {
                    "second"
                }
            }
            #expect(Array(slice) == ["second"])
        }

        @Test("For loop")
        func forLoop() {
            let slice: ArraySlice<Int> = ArraySlice {
                for i in 1...3 {
                    i * 10
                }
            }
            #expect(Array(slice) == [10, 20, 30])
        }
    }

    @Suite("Expression Building")
    struct ExpressionBuildingTests {

        @Test("Optional element - some")
        func optionalElementSome() {
            let value: Int? = 42
            let slice: ArraySlice<Int> = ArraySlice {
                value
            }
            #expect(Array(slice) == [42])
        }

        @Test("Optional element - none")
        func optionalElementNone() {
            let value: Int? = nil
            let slice: ArraySlice<Int> = ArraySlice {
                value
            }
            #expect(slice.isEmpty)
        }

        @Test("Regular array expression")
        func regularArrayExpression() {
            let slice: ArraySlice<Int> = ArraySlice {
                [1, 2, 3]
            }
            #expect(Array(slice) == [1, 2, 3])
        }
    }

    @Suite("Static Method Tests")
    struct StaticMethodTests {

        @Test("buildExpression single element")
        func buildExpressionSingleElement() {
            let result = ArraySlice<Int>.Builder.buildExpression(42)
            #expect(result == [42])
        }

        @Test("buildExpression array")
        func buildExpressionArray() {
            let result = ArraySlice<Int>.Builder.buildExpression([1, 2, 3])
            #expect(result == [1, 2, 3])
        }

        @Test("buildPartialBlock first")
        func buildPartialBlockFirst() {
            let result = ArraySlice<Int>.Builder.buildPartialBlock(first: [1, 2, 3])
            #expect(result == [1, 2, 3])
        }

        @Test("buildPartialBlock first void")
        func buildPartialBlockFirstVoid() {
            let result = ArraySlice<Int>.Builder.buildPartialBlock(first: ())
            #expect(result.isEmpty)
        }

        @Test("buildPartialBlock accumulated")
        func buildPartialBlockAccumulated() {
            let result = ArraySlice<Int>.Builder.buildPartialBlock(
                accumulated: [1, 2],
                next: [3, 4]
            )
            #expect(result == [1, 2, 3, 4])
        }

        @Test("buildOptional some")
        func buildOptionalSome() {
            let result = ArraySlice<Int>.Builder.buildOptional([1, 2, 3])
            #expect(result == [1, 2, 3])
        }

        @Test("buildOptional none")
        func buildOptionalNone() {
            let result = ArraySlice<Int>.Builder.buildOptional(nil)
            #expect(result.isEmpty)
        }

        @Test("buildArray")
        func buildArray() {
            let result = ArraySlice<Int>.Builder.buildArray([[1, 2], [3, 4]])
            #expect(result == [1, 2, 3, 4])
        }

        @Test("buildFinalResult")
        func buildFinalResult() {
            let result = ArraySlice<Int>.Builder.buildFinalResult([1, 2, 3])
            #expect(Array(result) == [1, 2, 3])
            #expect(type(of: result) == ArraySlice<Int>.self)
        }
    }

    @Suite("Limited Availability")
    struct LimitedAvailabilityTests {

        @Test("Limited availability passthrough")
        func limitedAvailabilityPassthrough() {
            let slice: ArraySlice<Int> = ArraySlice {
                1
                if #available(macOS 26, iOS 26, *) {
                    2
                }
            }
            #expect(Array(slice) == [1, 2])
        }
    }
}
