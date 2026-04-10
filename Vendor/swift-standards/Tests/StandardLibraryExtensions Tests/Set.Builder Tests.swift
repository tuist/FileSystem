import Testing

@testable import StandardLibraryExtensions

@Suite("Set.Builder Tests")
struct SetBuilderTests {

    @Suite("Expression Building")
    struct ExpressionBuildingTests {

        @Test("Single element expression")
        func singleElementExpression() {
            let result = Set<String>.Builder.buildExpression("hello")
            #expect(result == ["hello"])
        }

        @Test("Set expression")
        func setExpression() {
            let inputSet: Set<Int> = [1, 2, 3]
            let result = Set<Int>.Builder.buildExpression(inputSet)
            #expect(result == inputSet)
        }

        @Test("Array expression")
        func arrayExpression() {
            let result = Set<Int>.Builder.buildExpression([1, 2, 3, 2, 1])
            #expect(result == [1, 2, 3])
        }

        @Test("Optional element expression - some")
        func optionalElementExpressionSome() {
            let value: String? = "hello"
            let result = Set<String>.Builder.buildExpression(value)
            #expect(result == ["hello"])
        }

        @Test("Optional element expression - none")
        func optionalElementExpressionNone() {
            let value: String? = nil
            let result = Set<String>.Builder.buildExpression(value)
            #expect(result == [])
        }
    }

    @Suite("Partial Block Building")
    struct PartialBlockBuildingTests {

        @Test("First set")
        func firstSet() {
            let inputSet: Set<Int> = [1, 2, 3]
            let result = Set<Int>.Builder.buildPartialBlock(first: inputSet)
            #expect(result == inputSet)
        }

        @Test("First void")
        func firstVoid() {
            let result = Set<String>.Builder.buildPartialBlock(first: ())
            #expect(result.isEmpty)
        }

        @Test("Accumulated set and next set")
        func accumulatedSetAndNextSet() {
            let accumulated: Set<Int> = [1, 2]
            let next: Set<Int> = [3, 4]
            let result = Set<Int>.Builder.buildPartialBlock(accumulated: accumulated, next: next)
            #expect(result == [1, 2, 3, 4])
        }

        @Test("Overlapping sets merge correctly")
        func overlappingSetsMergeCorrectly() {
            let accumulated: Set<Int> = [1, 2, 3]
            let next: Set<Int> = [3, 4, 5]
            let result = Set<Int>.Builder.buildPartialBlock(accumulated: accumulated, next: next)
            #expect(result == [1, 2, 3, 4, 5])
            #expect(result.count == 5)
        }
    }

    @Suite("Control Flow")
    struct ControlFlowTests {

        @Test("buildOptional with some set")
        func buildOptionalWithSomeSet() {
            let inputSet: Set<String>? = ["conditional"]
            let result = Set<String>.Builder.buildOptional(inputSet)
            #expect(result == ["conditional"])
        }

        @Test("buildOptional with nil set")
        func buildOptionalWithNilSet() {
            let inputSet: Set<String>? = nil
            let result = Set<String>.Builder.buildOptional(inputSet)
            #expect(result.isEmpty)
        }

        @Test("buildEither first branch")
        func buildEitherFirstBranch() {
            let inputSet: Set<String> = ["first", "option"]
            let result = Set<String>.Builder.buildEither(first: inputSet)
            #expect(result == inputSet)
        }

        @Test("buildEither second branch")
        func buildEitherSecondBranch() {
            let inputSet: Set<String> = ["second", "option"]
            let result = Set<String>.Builder.buildEither(second: inputSet)
            #expect(result == inputSet)
        }

        @Test("buildArray merges all sets")
        func buildArrayMergesAllSets() {
            let components: [Set<Int>] = [
                [1, 2],
                [3, 4],
                [2, 5],
            ]
            let result = Set<Int>.Builder.buildArray(components)
            #expect(result == [1, 2, 3, 4, 5])
            #expect(result.count == 5)
        }

        @Test("buildLimitedAvailability")
        func buildLimitedAvailability() {
            let inputSet: Set<Int> = [1, 2, 3]
            let result = Set<Int>.Builder.buildLimitedAvailability(inputSet)
            #expect(result == inputSet)
        }
    }

    @Suite("Set Extension Initialization")
    struct SetExtensionInitializationTests {

        @Test("Set initialization with elements")
        func setInitializationWithElements() {
            let set = Set {
                "hello"
                "world"
                "hello"
            }
            #expect(set == ["hello", "world"])
            #expect(set.count == 2)
        }

        @Test("Set initialization with mixed elements and sets")
        func setInitializationWithMixedElementsAndSets() {
            let existingSet: Set<Int> = [2, 3]
            let set = Set {
                1
                existingSet
                4
                existingSet
            }
            #expect(set == [1, 2, 3, 4])
            #expect(set.count == 4)
        }

        @Test("Empty set initialization")
        func emptySetInitialization() {
            let set = Set<String> {
            }
            #expect(set.isEmpty)
        }

        @Test("Set initialization with conditionals")
        func setInitializationWithConditionals() {
            let includeExtra = true
            let set = Set {
                "always"
                if includeExtra {
                    "extra"
                }
            }
            #expect(set == ["always", "extra"])
        }

        @Test("Set initialization with for loop")
        func setInitializationWithForLoop() {
            let set = Set {
                for i in 1...5 {
                    i
                }
            }
            #expect(set == [1, 2, 3, 4, 5])
        }
    }

    @Suite("Hashable Types Compatibility")
    struct HashableTypesCompatibilityTests {

        @Test("String sets")
        func stringSets() {
            let set = Set {
                "apple"
                "banana"
                "apple"
            }
            #expect(set == ["apple", "banana"])
        }

        @Test("Integer sets")
        func integerSets() {
            let set = Set {
                1
                2
                3
                1
            }
            #expect(set == [1, 2, 3])
        }

        @Test("Custom hashable type")
        func customHashableType() {
            struct Person: Hashable {
                let name: String
                let age: Int
            }

            let alice = Person(name: "Alice", age: 30)
            let bob = Person(name: "Bob", age: 25)
            let aliceDuplicate = Person(name: "Alice", age: 30)

            let set = Set {
                alice
                bob
                aliceDuplicate
            }

            #expect(set.count == 2)
            #expect(set.contains(alice))
            #expect(set.contains(bob))
        }

        @Test("Enum sets")
        func enumSets() {
            enum Color: String, Hashable, CaseIterable {
                case red, green, blue
            }

            let set = Set {
                Color.red
                Color.green
                Color.blue
                Color.red
            }

            #expect(set == Set(Color.allCases))
            #expect(set.count == 3)
        }
    }

    @Suite("Edge Cases")
    struct EdgeCasesTests {

        @Test("Large set construction")
        func largeSetConstruction() {
            let components: [Set<Int>] = (0..<100).map { i in
                Set([i, i + 1000])
            }

            let result = Set<Int>.Builder.buildArray(components)

            #expect(result.count == 200)
            #expect(result.contains(0))
            #expect(result.contains(99))
            #expect(result.contains(1000))
            #expect(result.contains(1099))
        }

        @Test("Empty sets in array")
        func emptySetsInArray() {
            let components: [Set<String>] = [
                ["a"],
                [],
                ["b"],
                [],
                ["c"],
            ]

            let result = Set<String>.Builder.buildArray(components)
            #expect(result == ["a", "b", "c"])
        }

        @Test("All empty sets")
        func allEmptySets() {
            let components: [Set<Int>] = [[], [], []]
            let result = Set<Int>.Builder.buildArray(components)
            #expect(result.isEmpty)
        }

        @Test("Single element repeated")
        func singleElementRepeated() {
            let components: [Set<String>] = [
                ["same"],
                ["same"],
                ["same"],
            ]

            let result = Set<String>.Builder.buildArray(components)
            #expect(result == ["same"])
            #expect(result.count == 1)
        }

        @Test("Deeply nested conditionals")
        func deeplyNestedConditionals() {
            let a = true
            let b = false
            let c = true

            let set = Set {
                "start"
                if a {
                    "a"
                    if b {
                        "b"
                    } else {
                        "not-b"
                        if c {
                            "c"
                        }
                    }
                }
                "end"
            }

            #expect(set == ["start", "a", "not-b", "c", "end"])
        }
    }

    @Suite("Limited Availability")
    struct LimitedAvailabilityTests {

        @Test("Limited availability passthrough")
        func limitedAvailabilityPassthrough() {
            let set = Set {
                "always"
                if #available(macOS 26, iOS 26, *) {
                    "newer"
                }
            }
            #expect(set.contains("always"))
            #expect(set.contains("newer"))
        }
    }
}
