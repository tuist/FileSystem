import StandardLibraryExtensions
import Testing

@testable import TernaryLogic

@Suite("TernaryLogic.Builder Tests")
struct TernaryLogicBuilderTests {

    @Suite("TernaryLogic.all (Strong Kleene AND)")
    struct AllTests {

        @Test("All true returns true")
        func allTrueReturnsTrue() {
            let result = Bool?.all {
                true
                true
                true
            }
            #expect(result == true)
        }

        @Test("Any false returns false")
        func anyFalseReturnsFalse() {
            let result = Bool?.all {
                true
                false
                true
            }
            #expect(result == false)
        }

        @Test("Unknown with no false returns unknown")
        func unknownWithNoFalseReturnsUnknown() {
            let result = Bool?.all {
                true
                nil as Bool?
                true
            }
            #expect(result == nil)
        }

        @Test("False dominates unknown")
        func falseDominatesUnknown() {
            let result = Bool?.all {
                nil as Bool?
                false
                nil as Bool?
            }
            #expect(result == false)
        }

        @Test("Empty block returns true")
        func emptyBlockReturnsTrue() {
            let result: Bool? = Bool?.all {
            }
            #expect(result == true)
        }

        @Test("Single true")
        func singleTrue() {
            let result = Bool?.all {
                true
            }
            #expect(result == true)
        }

        @Test("Single false")
        func singleFalse() {
            let result = Bool?.all {
                false
            }
            #expect(result == false)
        }

        @Test("Single unknown")
        func singleUnknown() {
            let result = Bool?.all {
                nil as Bool?
            }
            #expect(result == nil)
        }

        @Test("Conditional inclusion - true branch")
        func conditionalInclusionTrueBranch() {
            let condition = true
            let result = Bool?.all {
                true
                if condition {
                    true
                }
            }
            #expect(result == true)
        }

        @Test("Conditional inclusion - false branch yields unknown")
        func conditionalInclusionFalseBranchYieldsUnknown() {
            let condition = false
            let result = Bool?.all {
                true
                if condition {
                    true
                }
            }
            // In ternary logic, missing value = unknown
            #expect(result == nil)
        }

        @Test("If-else first branch")
        func ifElseFirstBranch() {
            let condition = true
            let result = Bool?.all {
                if condition {
                    true
                } else {
                    false
                }
            }
            #expect(result == true)
        }

        @Test("If-else second branch")
        func ifElseSecondBranch() {
            let condition = false
            let result = Bool?.all {
                if condition {
                    true
                } else {
                    false
                }
            }
            #expect(result == false)
        }

        @Test("For loop all true")
        func forLoopAllTrue() {
            let result = Bool?.all {
                for _ in 1...3 {
                    true
                }
            }
            #expect(result == true)
        }

        @Test("For loop with false")
        func forLoopWithFalse() {
            let values: [Bool?] = [true, false, true]
            let result = Bool?.all {
                for v in values {
                    v
                }
            }
            #expect(result == false)
        }

        @Test("For loop with unknown")
        func forLoopWithUnknown() {
            let values: [Bool?] = [true, nil, true]
            let result = Bool?.all {
                for v in values {
                    v
                }
            }
            #expect(result == nil)
        }
    }

    @Suite("TernaryLogic.any (Strong Kleene OR)")
    struct AnyTests {

        @Test("All false returns false")
        func allFalseReturnsFalse() {
            let result = Bool?.any {
                false
                false
                false
            }
            #expect(result == false)
        }

        @Test("Any true returns true")
        func anyTrueReturnsTrue() {
            let result = Bool?.any {
                false
                true
                false
            }
            #expect(result == true)
        }

        @Test("Unknown with no true returns unknown")
        func unknownWithNoTrueReturnsUnknown() {
            let result = Bool?.any {
                false
                nil as Bool?
                false
            }
            #expect(result == nil)
        }

        @Test("True dominates unknown")
        func trueDominatesUnknown() {
            let result = Bool?.any {
                nil as Bool?
                true
                nil as Bool?
            }
            #expect(result == true)
        }

        @Test("Empty block returns false")
        func emptyBlockReturnsFalse() {
            let result: Bool? = Bool?.any {
            }
            #expect(result == false)
        }

        @Test("Single true")
        func singleTrue() {
            let result = Bool?.any {
                true
            }
            #expect(result == true)
        }

        @Test("Single false")
        func singleFalse() {
            let result = Bool?.any {
                false
            }
            #expect(result == false)
        }

        @Test("Single unknown")
        func singleUnknown() {
            let result = Bool?.any {
                nil as Bool?
            }
            #expect(result == nil)
        }

        @Test("Conditional inclusion - false branch yields unknown")
        func conditionalInclusionFalseBranchYieldsUnknown() {
            let condition = false
            let result = Bool?.any {
                false
                if condition {
                    true
                }
            }
            // In ternary logic, missing value = unknown
            #expect(result == nil)
        }
    }

    @Suite("TernaryLogic.none (Strong Kleene NOR)")
    struct NoneTests {

        @Test("All false returns true")
        func allFalseReturnsTrue() {
            let result = Bool?.none {
                false
                false
                false
            }
            #expect(result == true)
        }

        @Test("Any true returns false")
        func anyTrueReturnsFalse() {
            let result = Bool?.none {
                false
                true
                false
            }
            #expect(result == false)
        }

        @Test("Unknown with no true returns unknown")
        func unknownWithNoTrueReturnsUnknown() {
            let result = Bool?.none {
                false
                nil as Bool?
                false
            }
            #expect(result == nil)
        }

        @Test("True dominates unknown for NOR")
        func trueDominatesUnknownForNor() {
            let result = Bool?.none {
                nil as Bool?
                true
                nil as Bool?
            }
            // NOR of (unknown OR true OR unknown) = NOR of true = false
            #expect(result == false)
        }

        @Test("Empty block returns true")
        func emptyBlockReturnsTrue() {
            let result: Bool? = Bool?.none {
            }
            // NOR of empty = NOT(false) = true
            #expect(result == true)
        }

        @Test("Single true returns false")
        func singleTrueReturnsFalse() {
            let result = Bool?.none {
                true
            }
            #expect(result == false)
        }

        @Test("Single false returns true")
        func singleFalseReturnsTrue() {
            let result = Bool?.none {
                false
            }
            #expect(result == true)
        }

        @Test("Single unknown returns unknown")
        func singleUnknownReturnsUnknown() {
            let result = Bool?.none {
                nil as Bool?
            }
            #expect(result == nil)
        }
    }

    @Suite("Static Method Tests")
    struct StaticMethodTests {

        @Test("All.buildExpression Bool?")
        func allBuildExpressionOptionalBool() {
            let result = TernaryLogic.Builder<Bool?>.All.buildExpression(true as Bool?)
            #expect(result == true)
        }

        @Test("All.buildExpression Bool")
        func allBuildExpressionBool() {
            let result = TernaryLogic.Builder<Bool?>.All.buildExpression(true)
            #expect(result == true)
        }

        @Test("All.buildPartialBlock accumulated")
        func allBuildPartialBlockAccumulated() {
            // true AND true = true
            let r1 = TernaryLogic.Builder<Bool?>.All.buildPartialBlock(
                accumulated: true,
                next: true
            )
            #expect(r1 == true)

            // true AND false = false
            let r2 = TernaryLogic.Builder<Bool?>.All.buildPartialBlock(
                accumulated: true,
                next: false
            )
            #expect(r2 == false)

            // true AND unknown = unknown
            let r3 = TernaryLogic.Builder<Bool?>.All.buildPartialBlock(accumulated: true, next: nil)
            #expect(r3 == nil)

            // unknown AND false = false (false dominates)
            let r4 = TernaryLogic.Builder<Bool?>.All.buildPartialBlock(
                accumulated: nil,
                next: false
            )
            #expect(r4 == false)
        }

        @Test("Any.buildPartialBlock accumulated")
        func anyBuildPartialBlockAccumulated() {
            // false OR false = false
            let r1 = TernaryLogic.Builder<Bool?>.`Any`.buildPartialBlock(
                accumulated: false,
                next: false
            )
            #expect(r1 == false)

            // false OR true = true
            let r2 = TernaryLogic.Builder<Bool?>.`Any`.buildPartialBlock(
                accumulated: false,
                next: true
            )
            #expect(r2 == true)

            // false OR unknown = unknown
            let r3 = TernaryLogic.Builder<Bool?>.`Any`.buildPartialBlock(
                accumulated: false,
                next: nil
            )
            #expect(r3 == nil)

            // unknown OR true = true (true dominates)
            let r4 = TernaryLogic.Builder<Bool?>.`Any`.buildPartialBlock(
                accumulated: nil,
                next: true
            )
            #expect(r4 == true)
        }

        @Test("None.buildFinalResult")
        func noneBuildFinalResult() {
            // NOR of true = false
            let r1 = TernaryLogic.Builder<Bool?>.None.buildFinalResult(true)
            #expect(r1 == false)

            // NOR of false = true
            let r2 = TernaryLogic.Builder<Bool?>.None.buildFinalResult(false)
            #expect(r2 == true)

            // NOR of unknown = unknown
            let r3 = TernaryLogic.Builder<Bool?>.None.buildFinalResult(nil)
            #expect(r3 == nil)
        }
    }

    @Suite("Comparison with Bool.Builder")
    struct ComparisonTests {

        @Test("Bool.all vs Bool?.all - no unknowns")
        func boolAllVsBoolOptionalAllNoUnknowns() {
            // With no unknowns, they should behave the same
            let boolResult = Bool.all {
                true
                true
            }
            let ternaryResult: Bool? = Bool?.all {
                true
                true
            }
            #expect(boolResult == true)
            #expect(ternaryResult == true)
        }

        @Test("Bool.all vs Bool?.all - with conditional")
        func boolAllVsBoolOptionalAllWithConditional() {
            let condition = false

            // Bool.all: missing value treated as identity (true for AND)
            let boolResult = Bool.all {
                true
                if condition {
                    true
                }
            }
            // Bool?.all: missing value treated as unknown
            let ternaryResult: Bool? = Bool?.all {
                true
                if condition {
                    true
                }
            }

            #expect(boolResult == true)  // Bool treats missing as true (identity for AND)
            #expect(ternaryResult == nil)  // Bool? treats missing as unknown
        }
    }
}
