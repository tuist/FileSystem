import Testing

@testable import StandardLibraryExtensions

@Suite("Result.Builder Tests")
struct ResultBuilderTests {

    enum TestError: Error, Equatable {
        case first
        case second
        case third
    }

    @Suite("Result.Builder (First Success)")
    struct FirstSuccessTests {

        @Test("Returns first success")
        func returnsFirstSuccess() {
            let result: Result<Int, TestError> = Result.first {
                Result<Int, TestError>.failure(.first)
                Result<Int, TestError>.success(42)
                Result<Int, TestError>.success(100)
            }

            #expect(result == .success(42))
        }

        @Test("Returns last failure when all fail")
        func returnsLastFailureWhenAllFail() {
            let result: Result<Int, TestError> = Result.first {
                Result<Int, TestError>.failure(.first)
                Result<Int, TestError>.failure(.second)
                Result<Int, TestError>.failure(.third)
            }

            #expect(result == .failure(.third))
        }

        @Test("Direct success value")
        func directSuccessValue() {
            let result: Result<Int, TestError> = Result.first {
                42
            }

            #expect(result == .success(42))
        }

        @Test("If-else first branch")
        func ifElseFirstBranch() {
            let condition = true
            let result: Result<String, TestError> = Result.first {
                if condition {
                    Result<String, TestError>.success("first")
                } else {
                    Result<String, TestError>.success("second")
                }
            }

            #expect(result == .success("first"))
        }

        @Test("If-else second branch")
        func ifElseSecondBranch() {
            let condition = false
            let result: Result<String, TestError> = Result.first {
                if condition {
                    Result<String, TestError>.success("first")
                } else {
                    Result<String, TestError>.success("second")
                }
            }

            #expect(result == .success("second"))
        }
    }

    @Suite("Result.AllBuilder (Collect All)")
    struct CollectAllTests {

        @Test("Collects all successes")
        func collectsAllSuccesses() {
            let result: Result<[Int], TestError> = Result.all {
                Result<Int, TestError>.success(1)
                Result<Int, TestError>.success(2)
                Result<Int, TestError>.success(3)
            }

            #expect(result == .success([1, 2, 3]))
        }

        @Test("Fails on first error")
        func failsOnFirstError() {
            let result: Result<[Int], TestError> = Result.all {
                Result<Int, TestError>.success(1)
                Result<Int, TestError>.failure(.second)
                Result<Int, TestError>.success(3)
            }

            #expect(result == .failure(.second))
        }

        @Test("Empty block returns empty array")
        func emptyBlockReturnsEmptyArray() {
            let result: Result<[Int], TestError> = Result.all {
            }

            #expect(result == .success([]))
        }

        @Test("Direct values are wrapped")
        func directValuesAreWrapped() {
            let result: Result<[Int], TestError> = Result.all {
                1
                2
                3
            }

            #expect(result == .success([1, 2, 3]))
        }

        @Test("For loop collects all")
        func forLoopCollectsAll() {
            let result: Result<[Int], TestError> = Result.all {
                for i in 1...3 {
                    Result<Int, TestError>.success(i * 10)
                }
            }

            #expect(result == .success([10, 20, 30]))
        }

        @Test("For loop fails on error")
        func forLoopFailsOnError() {
            let result: Result<[Int], TestError> = Result.all {
                for i in 1...3 {
                    if i == 2 {
                        Result<Int, TestError>.failure(.second)
                    } else {
                        Result<Int, TestError>.success(i * 10)
                    }
                }
            }

            #expect(result == .failure(.second))
        }

        @Test("Conditional inclusion - some")
        func conditionalInclusionSome() {
            let include = true
            let result: Result<[Int], TestError> = Result.all {
                Result<Int, TestError>.success(1)
                if include {
                    Result<Int, TestError>.success(2)
                }
                Result<Int, TestError>.success(3)
            }

            #expect(result == .success([1, 2, 3]))
        }

        @Test("Conditional inclusion - none")
        func conditionalInclusionNone() {
            let include = false
            let result: Result<[Int], TestError> = Result.all {
                Result<Int, TestError>.success(1)
                if include {
                    Result<Int, TestError>.success(2)
                }
                Result<Int, TestError>.success(3)
            }

            #expect(result == .success([1, 3]))
        }
    }

    @Suite("Static Method Tests")
    struct StaticMethodTests {

        @Test("buildExpression success value")
        func buildExpressionSuccessValue() {
            let result = Result<Int, TestError>.Builder.First.buildExpression(42)
            #expect(result == .success(42))
        }

        @Test("buildExpression result passthrough")
        func buildExpressionResultPassthrough() {
            let input = Result<Int, TestError>.failure(.first)
            let result = Result<Int, TestError>.Builder.First.buildExpression(input)
            #expect(result == .failure(.first))
        }

        @Test("buildPartialBlock accumulated success keeps success")
        func buildPartialBlockAccumulatedSuccessKeepsSuccess() {
            let result = Result<Int, TestError>.Builder.First.buildPartialBlock(
                accumulated: .success(42),
                next: .success(100)
            )
            #expect(result == .success(42))
        }

        @Test("buildPartialBlock accumulated failure tries next")
        func buildPartialBlockAccumulatedFailureTriesNext() {
            let result = Result<Int, TestError>.Builder.First.buildPartialBlock(
                accumulated: .failure(.first),
                next: .success(100)
            )
            #expect(result == .success(100))
        }

        @Test("buildEither first")
        func buildEitherFirst() {
            let result = Result<Int, TestError>.Builder.First.buildEither(first: .success(42))
            #expect(result == .success(42))
        }

        @Test("buildEither second")
        func buildEitherSecond() {
            let result = Result<Int, TestError>.Builder.First.buildEither(second: .failure(.second))
            #expect(result == .failure(.second))
        }
    }

    @Suite("Limited Availability")
    struct LimitedAvailabilityTests {

        @Test("Limited availability passthrough - first")
        func limitedAvailabilityPassthroughFirst() {
            let result: Result<Int, TestError> = Result.first {
                Result<Int, TestError>.failure(.first)
                if #available(macOS 26, iOS 26, *) {
                    Result<Int, TestError>.success(42)
                }
            }
            #expect(result == .success(42))
        }

        @Test("Limited availability passthrough - all")
        func limitedAvailabilityPassthroughAll() {
            let result: Result<[Int], TestError> = Result.all {
                Result<Int, TestError>.success(1)
                if #available(macOS 26, iOS 26, *) {
                    Result<Int, TestError>.success(2)
                }
            }
            #expect(result == .success([1, 2]))
        }
    }
}
