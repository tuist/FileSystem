import Testing

@testable import StandardLibraryExtensions

@Suite("Substring.Builder Tests")
struct SubstringBuilderTests {

    @Suite("Basic Construction")
    struct BasicConstructionTests {

        @Test("Single substring")
        func singleSubstring() {
            let result: Substring = Substring {
                "Hello"
            }
            #expect(result == "Hello")
        }

        @Test("Multiple substrings joined with newlines")
        func multipleSubstringsJoinedWithNewlines() {
            let result: Substring = Substring {
                "First"
                "Second"
                "Third"
            }
            #expect(result == "First\nSecond\nThird")
        }

        @Test("Empty block")
        func emptyBlock() {
            let result: Substring = Substring {
            }
            #expect(result.isEmpty)
        }

        @Test("Empty string")
        func emptyString() {
            let result: Substring = Substring {
                ""
            }
            #expect(result.isEmpty)
        }

        @Test("Mixed String and Substring")
        func mixedStringAndSubstring() {
            let sub: Substring = "World"
            let result: Substring = Substring {
                "Hello"
                sub
            }
            #expect(result == "Hello\nWorld")
        }
    }

    @Suite("Control Flow")
    struct ControlFlowTests {

        @Test("Conditional inclusion - true")
        func conditionalInclusionTrue() {
            let include = true
            let result: Substring = Substring {
                "Start"
                if include {
                    "Middle"
                }
                "End"
            }
            #expect(result == "Start\nMiddle\nEnd")
        }

        @Test("Conditional inclusion - false")
        func conditionalInclusionFalse() {
            let include = false
            let result: Substring = Substring {
                "Start"
                if include {
                    "Middle"
                }
                "End"
            }
            #expect(result == "Start\n\nEnd")
        }

        @Test("If-else first branch")
        func ifElseFirstBranch() {
            let condition = true
            let result: Substring = Substring {
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
            let result: Substring = Substring {
                if condition {
                    "first"
                } else {
                    "second"
                }
            }
            #expect(result == "second")
        }

        @Test("For loop")
        func forLoop() {
            let result: Substring = Substring {
                for i in 1...3 {
                    "Line \(i)"
                }
            }
            #expect(result == "Line 1\nLine 2\nLine 3")
        }
    }

    @Suite("Expression Building")
    struct ExpressionBuildingTests {

        @Test("Optional Substring - some")
        func optionalSubstringSome() {
            let value: Substring? = "Hello"
            let result: Substring = Substring {
                value
            }
            #expect(result == "Hello")
        }

        @Test("Optional Substring - none")
        func optionalSubstringNone() {
            let value: Substring? = nil
            let result: Substring = Substring {
                value
            }
            #expect(result.isEmpty)
        }

        @Test("Optional String - some")
        func optionalStringSome() {
            let value: String? = "Hello"
            let result: Substring = Substring {
                value
            }
            #expect(result == "Hello")
        }

        @Test("Optional String - none")
        func optionalStringNone() {
            let value: String? = nil
            let result: Substring = Substring {
                value
            }
            #expect(result.isEmpty)
        }
    }

    @Suite("Static Method Tests")
    struct StaticMethodTests {

        @Test("buildExpression Substring")
        func buildExpressionSubstring() {
            let result = Substring.Builder.buildExpression(Substring("Hello"))
            #expect(result == "Hello")
        }

        @Test("buildExpression String")
        func buildExpressionString() {
            let result = Substring.Builder.buildExpression("Hello")
            #expect(result == "Hello")
        }

        @Test("buildPartialBlock first")
        func buildPartialBlockFirst() {
            let result = Substring.Builder.buildPartialBlock(first: "Hello")
            #expect(result == "Hello")
        }

        @Test("buildPartialBlock first void")
        func buildPartialBlockFirstVoid() {
            let result = Substring.Builder.buildPartialBlock(first: ())
            #expect(result.isEmpty)
        }

        @Test("buildPartialBlock accumulated")
        func buildPartialBlockAccumulated() {
            let result = Substring.Builder.buildPartialBlock(accumulated: "First", next: "Second")
            #expect(result == "First\nSecond")
        }

        @Test("buildPartialBlock accumulated empty")
        func buildPartialBlockAccumulatedEmpty() {
            let result = Substring.Builder.buildPartialBlock(accumulated: "", next: "Second")
            #expect(result == "Second")
        }

        @Test("buildOptional some")
        func buildOptionalSome() {
            let result = Substring.Builder.buildOptional("Hello")
            #expect(result == "Hello")
        }

        @Test("buildOptional none")
        func buildOptionalNone() {
            let result = Substring.Builder.buildOptional(nil)
            #expect(result.isEmpty)
        }

        @Test("buildArray")
        func buildArray() {
            let result = Substring.Builder.buildArray(["First", "Second", "Third"])
            #expect(result == "First\nSecond\nThird")
        }

        @Test("buildFinalResult")
        func buildFinalResult() {
            let result = Substring.Builder.buildFinalResult("Hello")
            #expect(result == "Hello")
            #expect(type(of: result) == Substring.self)
        }
    }

    @Suite("Limited Availability")
    struct LimitedAvailabilityTests {

        @Test("Limited availability passthrough")
        func limitedAvailabilityPassthrough() {
            let result: Substring = Substring {
                "Always"
                if #available(macOS 26, iOS 26, *) {
                    "Newer"
                }
            }
            #expect(result.contains("Always"))
            #expect(result.contains("Newer"))
        }
    }
}
