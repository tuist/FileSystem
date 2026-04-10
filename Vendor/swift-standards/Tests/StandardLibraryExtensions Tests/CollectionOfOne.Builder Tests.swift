import Testing

@testable import StandardLibraryExtensions

@Suite("CollectionOfOne.Builder Tests")
struct CollectionOfOneBuilderTests {

    @Suite("Basic Construction")
    struct BasicConstructionTests {

        @Test("Single element")
        func singleElement() {
            let collection: CollectionOfOne<Int> = CollectionOfOne {
                42
            }
            #expect(collection.first == 42)
            #expect(collection.count == 1)
        }

        @Test("Single string element")
        func singleStringElement() {
            let collection: CollectionOfOne<String> = CollectionOfOne {
                "Hello"
            }
            #expect(collection.first == "Hello")
        }
    }

    @Suite("Control Flow")
    struct ControlFlowTests {

        @Test("If-else first branch")
        func ifElseFirstBranch() {
            let condition = true
            let collection: CollectionOfOne<String> = CollectionOfOne {
                if condition {
                    "first"
                } else {
                    "second"
                }
            }
            #expect(collection.first == "first")
        }

        @Test("If-else second branch")
        func ifElseSecondBranch() {
            let condition = false
            let collection: CollectionOfOne<String> = CollectionOfOne {
                if condition {
                    "first"
                } else {
                    "second"
                }
            }
            #expect(collection.first == "second")
        }

        @Test("Nested if-else")
        func nestedIfElse() {
            let a = false
            let b = true

            let collection: CollectionOfOne<String> = CollectionOfOne {
                if a {
                    "a"
                } else {
                    if b {
                        "b"
                    } else {
                        "c"
                    }
                }
            }
            #expect(collection.first == "b")
        }
    }

    @Suite("Static Method Tests")
    struct StaticMethodTests {

        @Test("buildExpression")
        func buildExpression() {
            let result = CollectionOfOne<Int>.Builder.buildExpression(42)
            #expect(result == 42)
        }

        @Test("buildBlock")
        func buildBlock() {
            let result = CollectionOfOne<Int>.Builder.buildBlock(42)
            #expect(result == 42)
        }

        @Test("buildEither first")
        func buildEitherFirst() {
            let result = CollectionOfOne<Int>.Builder.buildEither(first: 42)
            #expect(result == 42)
        }

        @Test("buildEither second")
        func buildEitherSecond() {
            let result = CollectionOfOne<Int>.Builder.buildEither(second: 100)
            #expect(result == 100)
        }

        @Test("buildFinalResult")
        func buildFinalResult() {
            let result = CollectionOfOne<Int>.Builder.buildFinalResult(42)
            #expect(result.first == 42)
            #expect(result.count == 1)
        }
    }

    @Suite("Collection Conformance")
    struct CollectionConformanceTests {

        @Test("Iteration")
        func iteration() {
            let collection: CollectionOfOne<Int> = CollectionOfOne {
                42
            }

            var values: [Int] = []
            for value in collection {
                values.append(value)
            }

            #expect(values == [42])
        }

        @Test("Count is always one")
        func countIsAlwaysOne() {
            let collection: CollectionOfOne<String> = CollectionOfOne {
                "value"
            }
            #expect(collection.count == 1)
        }

        @Test("isEmpty is always false")
        func isEmptyIsAlwaysFalse() {
            let collection: CollectionOfOne<Int> = CollectionOfOne {
                0
            }
            #expect(collection.isEmpty == false)
        }

        @Test("First and last are same")
        func firstAndLastAreSame() {
            let collection: CollectionOfOne<Int> = CollectionOfOne {
                42
            }
            #expect(collection.first == collection.last)
        }
    }

    @Suite("Real-World Patterns")
    struct RealWorldPatternsTests {

        @Test("Configuration value selection")
        func configurationValueSelection() {
            let isDebug = false

            let config: CollectionOfOne<String> = CollectionOfOne {
                if isDebug {
                    "debug-endpoint"
                } else {
                    "production-endpoint"
                }
            }

            #expect(config.first == "production-endpoint")
        }

        @Test("Default value selection")
        func defaultValueSelection() {
            let hasCustomValue = true
            let customValue = 100

            let value: CollectionOfOne<Int> = CollectionOfOne {
                if hasCustomValue {
                    customValue
                } else {
                    42
                }
            }

            #expect(value.first == 100)
        }
    }

    @Suite("Limited Availability")
    struct LimitedAvailabilityTests {

        @Test("Limited availability passthrough")
        func limitedAvailabilityPassthrough() {
            let collection: CollectionOfOne<Int> = CollectionOfOne {
                if #available(macOS 26, iOS 26, *) {
                    42
                } else {
                    0
                }
            }
            #expect(collection.first == 42)
        }
    }
}
