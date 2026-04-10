import Testing

@testable import StandardLibraryExtensions

@Suite("ContiguousArray.Builder Tests")
struct ContiguousArrayBuilderTests {

    @Suite("Basic Construction")
    struct BasicConstructionTests {

        @Test("Single element")
        func singleElement() {
            let array: ContiguousArray<Int> = ContiguousArray {
                42
            }
            #expect(array == [42])
        }

        @Test("Multiple elements")
        func multipleElements() {
            let array: ContiguousArray<Int> = ContiguousArray {
                1
                2
                3
            }
            #expect(array == [1, 2, 3])
        }

        @Test("Empty block")
        func emptyBlock() {
            let array: ContiguousArray<Int> = ContiguousArray {
            }
            #expect(array.isEmpty)
        }

        @Test("Mixed elements and arrays")
        func mixedElementsAndArrays() {
            let array: ContiguousArray<Int> = ContiguousArray {
                1
                [2, 3]
                4
            }
            #expect(array == [1, 2, 3, 4])
        }

        @Test("Nested contiguous arrays")
        func nestedContiguousArrays() {
            let nested: ContiguousArray<Int> = [10, 20]
            let array: ContiguousArray<Int> = ContiguousArray {
                1
                nested
                2
            }
            #expect(array == [1, 10, 20, 2])
        }
    }

    @Suite("Control Flow")
    struct ControlFlowTests {

        @Test("Conditional inclusion - true")
        func conditionalInclusionTrue() {
            let include = true
            let array: ContiguousArray<Int> = ContiguousArray {
                1
                if include {
                    2
                }
                3
            }
            #expect(array == [1, 2, 3])
        }

        @Test("Conditional inclusion - false")
        func conditionalInclusionFalse() {
            let include = false
            let array: ContiguousArray<Int> = ContiguousArray {
                1
                if include {
                    2
                }
                3
            }
            #expect(array == [1, 3])
        }

        @Test("If-else first branch")
        func ifElseFirstBranch() {
            let condition = true
            let array: ContiguousArray<String> = ContiguousArray {
                if condition {
                    "first"
                } else {
                    "second"
                }
            }
            #expect(array == ["first"])
        }

        @Test("If-else second branch")
        func ifElseSecondBranch() {
            let condition = false
            let array: ContiguousArray<String> = ContiguousArray {
                if condition {
                    "first"
                } else {
                    "second"
                }
            }
            #expect(array == ["second"])
        }

        @Test("For loop")
        func forLoop() {
            let array: ContiguousArray<Int> = ContiguousArray {
                for i in 1...3 {
                    i * 10
                }
            }
            #expect(array == [10, 20, 30])
        }
    }

    @Suite("Expression Building")
    struct ExpressionBuildingTests {

        @Test("Optional element - some")
        func optionalElementSome() {
            let value: Int? = 42
            let array: ContiguousArray<Int> = ContiguousArray {
                value
            }
            #expect(array == [42])
        }

        @Test("Optional element - none")
        func optionalElementNone() {
            let value: Int? = nil
            let array: ContiguousArray<Int> = ContiguousArray {
                value
            }
            #expect(array.isEmpty)
        }

        @Test("Regular array expression")
        func regularArrayExpression() {
            let array: ContiguousArray<Int> = ContiguousArray {
                [1, 2, 3]
            }
            #expect(array == [1, 2, 3])
        }
    }

    @Suite("Static Method Tests")
    struct StaticMethodTests {

        @Test("buildExpression single element")
        func buildExpressionSingleElement() {
            let result = ContiguousArray<Int>.Builder.buildExpression(42)
            #expect(result == [42])
        }

        @Test("buildExpression array")
        func buildExpressionArray() {
            let result = ContiguousArray<Int>.Builder.buildExpression([1, 2, 3])
            #expect(result == [1, 2, 3])
        }

        @Test("buildPartialBlock first")
        func buildPartialBlockFirst() {
            let result = ContiguousArray<Int>.Builder.buildPartialBlock(first: [1, 2, 3])
            #expect(result == [1, 2, 3])
        }

        @Test("buildPartialBlock first void")
        func buildPartialBlockFirstVoid() {
            let result = ContiguousArray<Int>.Builder.buildPartialBlock(first: ())
            #expect(result.isEmpty)
        }

        @Test("buildPartialBlock accumulated")
        func buildPartialBlockAccumulated() {
            let result = ContiguousArray<Int>.Builder.buildPartialBlock(
                accumulated: [1, 2],
                next: [3, 4]
            )
            #expect(result == [1, 2, 3, 4])
        }

        @Test("buildOptional some")
        func buildOptionalSome() {
            let result = ContiguousArray<Int>.Builder.buildOptional([1, 2, 3])
            #expect(result == [1, 2, 3])
        }

        @Test("buildOptional none")
        func buildOptionalNone() {
            let result = ContiguousArray<Int>.Builder.buildOptional(nil)
            #expect(result.isEmpty)
        }

        @Test("buildArray")
        func buildArray() {
            let result = ContiguousArray<Int>.Builder.buildArray([[1, 2], [3, 4]])
            #expect(result == [1, 2, 3, 4])
        }
    }

    @Suite("Limited Availability")
    struct LimitedAvailabilityTests {

        @Test("Limited availability passthrough")
        func limitedAvailabilityPassthrough() {
            let array: ContiguousArray<Int> = ContiguousArray {
                1
                if #available(macOS 26, iOS 26, *) {
                    2
                }
            }
            #expect(array == [1, 2])
        }
    }
}
