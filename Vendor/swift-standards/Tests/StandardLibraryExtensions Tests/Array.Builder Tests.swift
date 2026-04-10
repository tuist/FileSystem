import Testing

@testable import StandardLibraryExtensions

@Suite("Array.Builder Tests")
struct ArrayBuilderTests {

    @Suite("Expression Building")
    struct ExpressionBuildingTests {

        @Test("Single element expression")
        func singleElementExpression() {
            let array: [Int] = Array {
                42
            }
            #expect(array == [42])
        }

        @Test("Array expression")
        func arrayExpression() {
            let array: [Int] = Array {
                [1, 2, 3]
            }
            #expect(array == [1, 2, 3])
        }

        @Test("Mixed expressions")
        func mixedExpressions() {
            let array: [Int] = Array {
                1
                [2, 3]
                4
            }
            #expect(array == [1, 2, 3, 4])
        }

        @Test("Optional element expression - some")
        func optionalElementExpressionSome() {
            let value: Int? = 42
            let array: [Int] = Array {
                value
            }
            #expect(array == [42])
        }

        @Test("Optional element expression - none")
        func optionalElementExpressionNone() {
            let value: Int? = nil
            let array: [Int] = Array {
                value
            }
            #expect(array == [])
        }
    }

    @Suite("Block Building")
    struct BlockBuildingTests {

        @Test("Empty block")
        func emptyBlock() {
            let array: [Int] = Array {
            }
            #expect(array.isEmpty)
        }

        @Test("Single component block")
        func singleComponentBlock() {
            let array: [String] = Array {
                "hello"
            }
            #expect(array == ["hello"])
        }

        @Test("Multiple component block")
        func multipleComponentBlock() {
            let array: [String] = Array {
                "hello"
                "world"
                "test"
            }
            #expect(array == ["hello", "world", "test"])
        }

        @Test("Nested arrays in block")
        func nestedArraysInBlock() {
            let array: [Int] = Array {
                [1, 2]
                [3, 4]
                [5, 6]
            }
            #expect(array == [1, 2, 3, 4, 5, 6])
        }
    }

    @Suite("Control Flow")
    struct ControlFlowTests {

        @Test("Optional elements - some")
        func optionalElementsSome() {
            let shouldInclude = true
            let array: [String] = Array {
                "always"
                if shouldInclude {
                    "conditional"
                }
                "end"
            }
            #expect(array == ["always", "conditional", "end"])
        }

        @Test("Optional elements - none")
        func optionalElementsNone() {
            let shouldInclude = false
            let array: [String] = Array {
                "always"
                if shouldInclude {
                    "conditional"
                }
                "end"
            }
            #expect(array == ["always", "end"])
        }

        @Test("If-else first branch")
        func ifElseFirstBranch() {
            let condition = true
            let array: [String] = Array {
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
            let array: [String] = Array {
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
            let array: [Int] = Array {
                for i in 1...3 {
                    i * 2
                }
            }
            #expect(array == [2, 4, 6])
        }

        @Test("Complex for loop with nested arrays")
        func complexForLoopWithNestedArrays() {
            let array: [Int] = Array {
                0
                for i in 1...2 {
                    [i, i + 10]
                }
                100
            }
            #expect(array == [0, 1, 11, 2, 12, 100])
        }
    }

    @Suite("Limited Availability")
    struct LimitedAvailabilityTests {

        @Test("Limited availability passthrough")
        func limitedAvailabilityPassthrough() {
            let array: [String] = Array {
                "available"
                if #available(macOS 26, iOS 26, *) {
                    "newer"
                }
            }
            #expect(array.contains("available"))
            #expect(array.contains("newer"))
        }
    }

    @Suite("Type Inference")
    struct TypeInferenceTests {

        @Test("String type inference")
        func stringTypeInference() {
            let array = Array {
                "hello"
                "world"
            }
            #expect(array == ["hello", "world"])
        }

        @Test("Int type inference")
        func intTypeInference() {
            let array = Array {
                1
                2
                3
            }
            #expect(array == [1, 2, 3])
        }

        @Test("Mixed numeric types promote to common type")
        func mixedNumericTypes() {
            let array: [Double] = Array {
                1.0
                2.5
                3
            }
            #expect(array == [1.0, 2.5, 3.0])
        }
    }

    @Suite("Edge Cases")
    struct EdgeCasesTests {

        @Test("Deeply nested conditionals")
        func deeplyNestedConditionals() {
            let a = true
            let b = false
            let c = true

            let array: [String] = Array {
                "start"
                if a {
                    "a-true"
                    if b {
                        "b-true"
                    } else {
                        "b-false"
                        if c {
                            "c-true"
                        }
                    }
                }
                "end"
            }
            #expect(array == ["start", "a-true", "b-false", "c-true", "end"])
        }

        @Test("Empty arrays in builder")
        func emptyArraysInBuilder() {
            let array: [Int] = Array {
                [1, 2]
                []
                [3, 4]
                []
            }
            #expect(array == [1, 2, 3, 4])
        }

        @Test("Large array construction")
        func largeArrayConstruction() {
            let array: [Int] = Array {
                for i in 1...100 {
                    i
                }
            }
            #expect(array.count == 100)
            #expect(array.first == 1)
            #expect(array.last == 100)
        }

        @Test("Alternating types with Optional")
        func alternatingTypesWithOptional() {
            let array: [Int?] = Array {
                1
                nil
                2
                nil
                3
            }
            #expect(array == [1, nil, 2, nil, 3])
        }
    }

    @Suite("Static Method Tests")
    struct StaticMethodTests {

        @Test("buildExpression single element")
        func buildExpressionSingleElement() {
            let result = [Int].Builder.buildExpression(42)
            #expect(result == [42])
        }

        @Test("buildExpression array")
        func buildExpressionArray() {
            let result = [Int].Builder.buildExpression([1, 2, 3])
            #expect(result == [1, 2, 3])
        }

        @Test("buildExpression optional some")
        func buildExpressionOptionalSome() {
            let value: Int? = 42
            let result = [Int].Builder.buildExpression(value)
            #expect(result == [42])
        }

        @Test("buildExpression optional none")
        func buildExpressionOptionalNone() {
            let value: Int? = nil
            let result = [Int].Builder.buildExpression(value)
            #expect(result == [])
        }

        @Test("buildPartialBlock first")
        func buildPartialBlockFirst() {
            let result = [Int].Builder.buildPartialBlock(first: [1, 2, 3])
            #expect(result == [1, 2, 3])
        }

        @Test("buildPartialBlock first void")
        func buildPartialBlockFirstVoid() {
            let result = [Int].Builder.buildPartialBlock(first: ())
            #expect(result == [])
        }

        @Test("buildPartialBlock accumulated")
        func buildPartialBlockAccumulated() {
            let result = [Int].Builder.buildPartialBlock(accumulated: [1, 2], next: [3, 4])
            #expect(result == [1, 2, 3, 4])
        }

        @Test("buildOptional some")
        func buildOptionalSome() {
            let result = [Int].Builder.buildOptional([1, 2, 3])
            #expect(result == [1, 2, 3])
        }

        @Test("buildOptional none")
        func buildOptionalNone() {
            let result = [Int].Builder.buildOptional(nil)
            #expect(result == [])
        }

        @Test("buildEither first")
        func buildEitherFirst() {
            let result = [Int].Builder.buildEither(first: [1, 2])
            #expect(result == [1, 2])
        }

        @Test("buildEither second")
        func buildEitherSecond() {
            let result = [Int].Builder.buildEither(second: [3, 4])
            #expect(result == [3, 4])
        }

        @Test("buildArray")
        func buildArray() {
            let result = [Int].Builder.buildArray([[1, 2], [3, 4], [5, 6]])
            #expect(result == [1, 2, 3, 4, 5, 6])
        }

        @Test("buildLimitedAvailability")
        func buildLimitedAvailability() {
            let result = [Int].Builder.buildLimitedAvailability([1, 2, 3])
            #expect(result == [1, 2, 3])
        }
    }
}
