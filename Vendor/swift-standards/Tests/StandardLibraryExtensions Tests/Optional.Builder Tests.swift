import Testing

@testable import StandardLibraryExtensions

@Suite("Optional.Builder Tests")
struct OptionalBuilderTests {

    @Suite("Basic Coalescing")
    struct BasicCoalescingTests {

        @Test("First non-nil value is returned")
        func firstNonNilValueIsReturned() {
            let a: Int? = nil
            let b: Int? = 42
            let c: Int? = 100

            let result = Optional.first {
                a
                b
                c
            }

            #expect(result == 42)
        }

        @Test("Returns nil when all values are nil")
        func returnsNilWhenAllValuesAreNil() {
            let a: Int? = nil
            let b: Int? = nil
            let c: Int? = nil

            let result = Optional.first {
                a
                b
                c
            }

            #expect(result == nil)
        }

        @Test("Single non-nil value")
        func singleNonNilValue() {
            let result = Optional.first {
                42
            }

            #expect(result == 42)
        }

        @Test("Single nil value")
        func singleNilValue() {
            let value: String? = nil
            let result = Optional.first {
                value
            }

            #expect(result == nil)
        }

        @Test("Empty block returns nil")
        func emptyBlockReturnsNil() {
            let result: Int? = Optional.first {
            }

            #expect(result == nil)
        }
    }

    @Suite("Control Flow")
    struct ControlFlowTests {

        @Test("Conditional inclusion - true branch")
        func conditionalInclusionTrueBranch() {
            let useFirst = true
            let result = Optional.first {
                if useFirst {
                    42
                }
            }

            #expect(result == 42)
        }

        @Test("Conditional inclusion - false branch")
        func conditionalInclusionFalseBranch() {
            let useFirst = false
            let result: Int? = Optional.first {
                if useFirst {
                    42
                }
            }

            #expect(result == nil)
        }

        @Test("If-else first branch")
        func ifElseFirstBranch() {
            let condition = true
            let result = Optional.first {
                if condition {
                    "first"
                } else {
                    "second"
                }
            }

            #expect(result == "first")
        }

        @Test("If-else second branch")
        func ifElseSecondBranch() {
            let condition = false
            let result = Optional.first {
                if condition {
                    "first"
                } else {
                    "second"
                }
            }

            #expect(result == "second")
        }

        @Test("For loop - first match wins")
        func forLoopFirstMatchWins() {
            let values: [Int?] = [nil, nil, 42, 100]
            let result = Optional.first {
                for value in values {
                    value
                }
            }

            #expect(result == 42)
        }

        @Test("For loop - all nil")
        func forLoopAllNil() {
            let values: [Int?] = [nil, nil, nil]
            let result = Optional.first {
                for value in values {
                    value
                }
            }

            #expect(result == nil)
        }
    }

    @Suite("Expression Building")
    struct ExpressionBuildingTests {

        @Test("Non-optional expression is wrapped")
        func nonOptionalExpressionIsWrapped() {
            let result = Optional.first {
                42
            }

            #expect(result == 42)
        }

        @Test("Optional expression passes through")
        func optionalExpressionPassesThrough() {
            let value: Int? = 42
            let result = Optional.first {
                value
            }

            #expect(result == 42)
        }
    }

    @Suite("Static Method Tests")
    struct StaticMethodTests {

        @Test("buildPartialBlock first")
        func buildPartialBlockFirst() {
            let result = Int?.Builder.buildPartialBlock(first: 42)
            #expect(result == 42)
        }

        @Test("buildPartialBlock first void")
        func buildPartialBlockFirstVoid() {
            let result = Int?.Builder.buildPartialBlock(first: ())
            #expect(result == nil)
        }

        @Test("buildPartialBlock accumulated with first non-nil")
        func buildPartialBlockAccumulatedWithFirstNonNil() {
            let result = Int?.Builder.buildPartialBlock(accumulated: 42, next: 100)
            #expect(result == 42)
        }

        @Test("buildPartialBlock accumulated with first nil")
        func buildPartialBlockAccumulatedWithFirstNil() {
            let result = Int?.Builder.buildPartialBlock(accumulated: nil, next: 100)
            #expect(result == 100)
        }

        @Test("buildOptional some")
        func buildOptionalSome() {
            let inner: Int? = 42
            let result = Int?.Builder.buildOptional(inner)
            #expect(result == 42)
        }

        @Test("buildOptional none")
        func buildOptionalNone() {
            let result = Int?.Builder.buildOptional(nil)
            #expect(result == nil)
        }

        @Test("buildArray first non-nil")
        func buildArrayFirstNonNil() {
            let components: [Int?] = [nil, 42, 100]
            let result = Int?.Builder.buildArray(components)
            #expect(result == 42)
        }

        @Test("buildArray all nil")
        func buildArrayAllNil() {
            let components: [Int?] = [nil, nil, nil]
            let result = Int?.Builder.buildArray(components)
            #expect(result == nil)
        }
    }

    @Suite("Real-World Patterns")
    struct RealWorldPatternsTests {

        @Test("Fallback chain pattern")
        func fallbackChainPattern() {
            let cached: String? = nil
            let computed: String? = nil
            let defaultValue = "default"

            let result = Optional.first {
                cached
                computed
                defaultValue
            }

            #expect(result == "default")
        }

        @Test("Configuration lookup pattern")
        func configurationLookupPattern() {
            let envVar: String? = nil
            let configFile: String? = "from-config"
            let hardcoded = "hardcoded"

            let result = Optional.first {
                envVar
                configFile
                hardcoded
            }

            #expect(result == "from-config")
        }
    }

    @Suite("Limited Availability")
    struct LimitedAvailabilityTests {

        @Test("Limited availability passthrough")
        func limitedAvailabilityPassthrough() {
            let result = Optional.first {
                if #available(macOS 26, iOS 26, *) {
                    42
                }
            }
            #expect(result == 42)
        }
    }
}
