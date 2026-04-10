import Testing

@testable import StandardLibraryExtensions

@Suite("Dictionary.Builder Tests")
struct DictionaryBuilderTests {

    @Suite("Expression Building")
    struct ExpressionBuildingTests {

        @Test("Tuple expression")
        func tupleExpression() {
            let dict: [String: Int] = Dictionary {
                ("key", 42)
            }
            #expect(dict == ["key": 42])
        }

        @Test("Dictionary expression")
        func dictionaryExpression() {
            let dict: [String: Int] = Dictionary {
                ["a": 1, "b": 2]
            }
            #expect(dict == ["a": 1, "b": 2])
        }

        @Test("Array of tuples expression")
        func arrayOfTuplesExpression() {
            let dict: [String: Int] = Dictionary {
                [("a", 1), ("b", 2), ("c", 3)]
            }
            #expect(dict == ["a": 1, "b": 2, "c": 3])
        }

        @Test("Optional tuple expression - some")
        func optionalTupleExpressionSome() {
            let pair: (String, Int)? = ("key", 42)
            let dict: [String: Int] = Dictionary {
                pair
            }
            #expect(dict == ["key": 42])
        }

        @Test("Optional tuple expression - none")
        func optionalTupleExpressionNone() {
            let pair: (String, Int)? = nil
            let dict: [String: Int] = Dictionary {
                pair
            }
            #expect(dict == [:])
        }
    }

    @Suite("Basic Construction")
    struct BasicConstructionTests {

        @Test("Basic tuple construction")
        func basicTupleConstruction() {
            let dict: [String: String] = Dictionary {
                ("key", "value")
            }
            #expect(dict == ["key": "value"])
        }

        @Test("Multiple tuples")
        func multipleTuples() {
            let dict: [String: Int] = Dictionary {
                ("a", 1)
                ("b", 2)
            }
            #expect(dict == ["a": 1, "b": 2])
        }

        @Test("Dictionary literal construction")
        func dictionaryLiteralConstruction() {
            let dict: [String: String] = Dictionary {
                ["host": "localhost"]
            }
            #expect(dict == ["host": "localhost"])
        }

        @Test("Dictionary merging")
        func dictionaryMerging() {
            let existing = ["a": 1, "b": 2]
            let dict: [String: Int] = Dictionary {
                existing
                ("c", 3)
            }
            #expect(dict == ["a": 1, "b": 2, "c": 3])
        }

        @Test("Empty dictionary")
        func emptyDictionary() {
            let dict: [String: Int] = Dictionary {
            }
            #expect(dict == [:])
        }
    }

    @Suite("Control Flow")
    struct ControlFlowTests {

        @Test("Conditional elements - included")
        func conditionalElementsIncluded() {
            let includePort = true
            let dict: [String: String] = Dictionary {
                ("host", "localhost")
                if includePort {
                    ("port", "8080")
                }
            }
            #expect(dict == ["host": "localhost", "port": "8080"])
        }

        @Test("Conditional elements - excluded")
        func conditionalElementsExcluded() {
            let includePort = false
            let dict: [String: String] = Dictionary {
                ("host", "localhost")
                if includePort {
                    ("port", "8080")
                }
            }
            #expect(dict == ["host": "localhost"])
        }

        @Test("If-else first branch")
        func ifElseFirstBranch() {
            let useProduction = true
            let dict: [String: String] = Dictionary {
                if useProduction {
                    ("env", "production")
                } else {
                    ("env", "development")
                }
            }
            #expect(dict == ["env": "production"])
        }

        @Test("If-else second branch")
        func ifElseSecondBranch() {
            let useProduction = false
            let dict: [String: String] = Dictionary {
                if useProduction {
                    ("env", "production")
                } else {
                    ("env", "development")
                }
            }
            #expect(dict == ["env": "development"])
        }

        @Test("For loop")
        func forLoop() {
            let dict: [String: Int] = Dictionary {
                for i in 1...3 {
                    ("key\(i)", i)
                }
            }
            #expect(dict == ["key1": 1, "key2": 2, "key3": 3])
        }
    }

    @Suite("Key Override Behavior")
    struct KeyOverrideBehaviorTests {

        @Test("Later values override earlier")
        func laterValuesOverride() {
            let dict: [String: String] = Dictionary {
                ("key", "first")
                ("key", "second")
            }
            #expect(dict == ["key": "second"])
        }

        @Test("Merged dictionaries override")
        func mergedDictionariesOverride() {
            let dict: [String: Int] = Dictionary {
                ["a": 1, "b": 2]
                ["b": 20, "c": 3]
            }
            #expect(dict == ["a": 1, "b": 20, "c": 3])
        }
    }

    @Suite("Limited Availability")
    struct LimitedAvailabilityTests {

        @Test("Limited availability passthrough")
        func limitedAvailabilityPassthrough() {
            let dict: [String: String] = Dictionary {
                ("always", "present")
                if #available(macOS 26, iOS 26, *) {
                    ("newer", "feature")
                }
            }
            #expect(dict["always"] == "present")
            #expect(dict["newer"] == "feature")
        }
    }

    @Suite("Static Method Tests")
    struct StaticMethodTests {

        @Test("buildExpression tuple")
        func buildExpressionTuple() {
            let result = [String: Int].Builder.buildExpression(("key", 42))
            #expect(result == ["key": 42])
        }

        @Test("buildExpression dictionary")
        func buildExpressionDictionary() {
            let result = [String: Int].Builder.buildExpression(["a": 1, "b": 2])
            #expect(result == ["a": 1, "b": 2])
        }

        @Test("buildExpression array of tuples")
        func buildExpressionArrayOfTuples() {
            let result = [String: Int].Builder.buildExpression([("a", 1), ("b", 2)])
            #expect(result == ["a": 1, "b": 2])
        }

        @Test("buildExpression optional tuple some")
        func buildExpressionOptionalTupleSome() {
            let pair: (String, Int)? = ("key", 42)
            let result = [String: Int].Builder.buildExpression(pair)
            #expect(result == ["key": 42])
        }

        @Test("buildExpression optional tuple none")
        func buildExpressionOptionalTupleNone() {
            let pair: (String, Int)? = nil
            let result = [String: Int].Builder.buildExpression(pair)
            #expect(result == [:])
        }

        @Test("buildPartialBlock first")
        func buildPartialBlockFirst() {
            let result = [String: Int].Builder.buildPartialBlock(first: ["a": 1])
            #expect(result == ["a": 1])
        }

        @Test("buildPartialBlock first void")
        func buildPartialBlockFirstVoid() {
            let result = [String: Int].Builder.buildPartialBlock(first: ())
            #expect(result == [:])
        }

        @Test("buildPartialBlock accumulated")
        func buildPartialBlockAccumulated() {
            let result = [String: Int].Builder.buildPartialBlock(
                accumulated: ["a": 1],
                next: ["b": 2]
            )
            #expect(result == ["a": 1, "b": 2])
        }

        @Test("buildOptional some")
        func buildOptionalSome() {
            let result = [String: Int].Builder.buildOptional(["a": 1])
            #expect(result == ["a": 1])
        }

        @Test("buildOptional none")
        func buildOptionalNone() {
            let result = [String: Int].Builder.buildOptional(nil)
            #expect(result == [:])
        }

        @Test("buildEither first")
        func buildEitherFirst() {
            let result = [String: Int].Builder.buildEither(first: ["a": 1])
            #expect(result == ["a": 1])
        }

        @Test("buildEither second")
        func buildEitherSecond() {
            let result = [String: Int].Builder.buildEither(second: ["b": 2])
            #expect(result == ["b": 2])
        }

        @Test("buildArray")
        func buildArray() {
            let result = [String: Int].Builder.buildArray([
                ["a": 1],
                ["b": 2],
                ["c": 3],
            ])
            #expect(result == ["a": 1, "b": 2, "c": 3])
        }

        @Test("buildLimitedAvailability")
        func buildLimitedAvailability() {
            let result = [String: Int].Builder.buildLimitedAvailability(["a": 1])
            #expect(result == ["a": 1])
        }
    }

    @Suite("Edge Cases")
    struct EdgeCasesTests {

        @Test("Large dictionary construction")
        func largeDictionaryConstruction() {
            let dict: [String: Int] = Dictionary {
                for i in 1...100 {
                    ("key\(i)", i)
                }
            }
            #expect(dict.count == 100)
            #expect(dict["key1"] == 1)
            #expect(dict["key100"] == 100)
        }

        @Test("Mixed types as values")
        func mixedTypesAsValues() {
            let dict: [String: Any] = Dictionary {
                ("string", "value" as Any)
                ("int", 42 as Any)
                ("bool", true as Any)
            }
            #expect(dict.count == 3)
        }

        @Test("Nested conditionals")
        func nestedConditionals() {
            let a = true
            let b = false

            let dict: [String: String] = Dictionary {
                ("base", "value")
                if a {
                    ("a", "true")
                    if b {
                        ("b", "true")
                    } else {
                        ("b", "false")
                    }
                }
            }
            #expect(dict == ["base": "value", "a": "true", "b": "false"])
        }
    }
}
