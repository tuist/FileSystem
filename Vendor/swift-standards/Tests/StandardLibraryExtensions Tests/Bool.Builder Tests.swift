import Testing

@testable import StandardLibraryExtensions

@Suite("Bool.Builder Tests")
struct BoolBuilderTests {

    @Suite("Bool.all (AND Semantics)")
    struct AllBuilderTests {

        @Test("All true returns true")
        func allTrueReturnsTrue() {
            let result = Bool.all {
                true
                true
                true
            }
            #expect(result == true)
        }

        @Test("Any false returns false")
        func anyFalseReturnsFalse() {
            let result = Bool.all {
                true
                false
                true
            }
            #expect(result == false)
        }

        @Test("Empty block returns true (identity)")
        func emptyBlockReturnsTrue() {
            let result = Bool.all {
            }
            #expect(result == true)
        }

        @Test("Single true")
        func singleTrue() {
            let result = Bool.all {
                true
            }
            #expect(result == true)
        }

        @Test("Single false")
        func singleFalse() {
            let result = Bool.all {
                false
            }
            #expect(result == false)
        }

        @Test("Conditional inclusion - true")
        func conditionalInclusionTrue() {
            let include = true
            let result = Bool.all {
                true
                if include {
                    true
                }
            }
            #expect(result == true)
        }

        @Test("Conditional inclusion - false condition")
        func conditionalInclusionFalseCondition() {
            let include = false
            let result = Bool.all {
                true
                if include {
                    false
                }
            }
            #expect(result == true)
        }

        @Test("For loop all true")
        func forLoopAllTrue() {
            let result = Bool.all {
                for _ in 1...3 {
                    true
                }
            }
            #expect(result == true)
        }

        @Test("For loop with false")
        func forLoopWithFalse() {
            let result = Bool.all {
                for i in 1...3 {
                    i != 2
                }
            }
            #expect(result == false)
        }
    }

    @Suite("Bool.any (OR Semantics)")
    struct AnyBuilderTests {

        @Test("All false returns false")
        func allFalseReturnsFalse() {
            let result = Bool.any {
                false
                false
                false
            }
            #expect(result == false)
        }

        @Test("Any true returns true")
        func anyTrueReturnsTrue() {
            let result = Bool.any {
                false
                true
                false
            }
            #expect(result == true)
        }

        @Test("Empty block returns false (identity)")
        func emptyBlockReturnsFalse() {
            let result = Bool.any {
            }
            #expect(result == false)
        }

        @Test("Single true")
        func singleTrue() {
            let result = Bool.any {
                true
            }
            #expect(result == true)
        }

        @Test("Single false")
        func singleFalse() {
            let result = Bool.any {
                false
            }
            #expect(result == false)
        }

        @Test("Conditional inclusion - true condition with true value")
        func conditionalInclusionTrueConditionTrueValue() {
            let include = true
            let result = Bool.any {
                false
                if include {
                    true
                }
            }
            #expect(result == true)
        }

        @Test("Conditional inclusion - false condition")
        func conditionalInclusionFalseCondition() {
            let include = false
            let result = Bool.any {
                false
                if include {
                    true
                }
            }
            #expect(result == false)
        }

        @Test("For loop all false")
        func forLoopAllFalse() {
            let result = Bool.any {
                for _ in 1...3 {
                    false
                }
            }
            #expect(result == false)
        }

        @Test("For loop with true")
        func forLoopWithTrue() {
            let result = Bool.any {
                for i in 1...3 {
                    i == 2
                }
            }
            #expect(result == true)
        }
    }

    @Suite("Bool.count")
    struct CountBuilderTests {

        @Test("Counts true values")
        func countsTrueValues() {
            let result = Bool.count {
                true
                false
                true
                true
                false
            }
            #expect(result == 3)
        }

        @Test("All false returns zero")
        func allFalseReturnsZero() {
            let result = Bool.count {
                false
                false
                false
            }
            #expect(result == 0)
        }

        @Test("All true returns count")
        func allTrueReturnsCount() {
            let result = Bool.count {
                true
                true
                true
            }
            #expect(result == 3)
        }

        @Test("Empty block returns zero")
        func emptyBlockReturnsZero() {
            let result = Bool.count {
            }
            #expect(result == 0)
        }

        @Test("For loop counting")
        func forLoopCounting() {
            let result = Bool.count {
                for i in 1...10 {
                    i % 2 == 0
                }
            }
            #expect(result == 5)
        }
    }

    @Suite("Bool.one (XOR Semantics)")
    struct OneBuilderTests {

        @Test("Exactly one true returns true")
        func exactlyOneTrueReturnsTrue() {
            let result = Bool.one {
                false
                true
                false
            }
            #expect(result == true)
        }

        @Test("Multiple true returns false")
        func multipleTrueReturnsFalse() {
            let result = Bool.one {
                true
                true
                false
            }
            #expect(result == false)
        }

        @Test("All false returns false")
        func allFalseReturnsFalse() {
            let result = Bool.one {
                false
                false
                false
            }
            #expect(result == false)
        }

        @Test("Empty block returns false")
        func emptyBlockReturnsFalse() {
            let result = Bool.one {
            }
            #expect(result == false)
        }

        @Test("Single true returns true")
        func singleTrueReturnsTrue() {
            let result = Bool.one {
                true
            }
            #expect(result == true)
        }
    }

    @Suite("Bool.none (NOR Semantics)")
    struct NoneBuilderTests {

        @Test("All false returns true")
        func allFalseReturnsTrue() {
            let result = Bool.none {
                false
                false
                false
            }
            #expect(result == true)
        }

        @Test("Any true returns false")
        func anyTrueReturnsFalse() {
            let result = Bool.none {
                false
                true
                false
            }
            #expect(result == false)
        }

        @Test("Empty block returns true")
        func emptyBlockReturnsTrue() {
            let result = Bool.none {
            }
            #expect(result == true)
        }

        @Test("Single false returns true")
        func singleFalseReturnsTrue() {
            let result = Bool.none {
                false
            }
            #expect(result == true)
        }

        @Test("Single true returns false")
        func singleTrueReturnsFalse() {
            let result = Bool.none {
                true
            }
            #expect(result == false)
        }
    }

    @Suite("Real-World Patterns")
    struct RealWorldPatternsTests {

        @Test("Validation with all")
        func validationWithAll() {
            let username = "john_doe"
            let password = "secret123"
            let age = 25

            let isValid = Bool.all {
                !username.isEmpty
                password.count >= 8
                age >= 18
            }

            #expect(isValid == true)
        }

        @Test("Permission check with any")
        func permissionCheckWithAny() {
            let isAdmin = false
            let isOwner = true
            let isPublic = false

            let canAccess = Bool.any {
                isAdmin
                isOwner
                isPublic
            }

            #expect(canAccess == true)
        }

        @Test("Mutual exclusion with one")
        func mutualExclusionWithOne() {
            let option1 = false
            let option2 = true
            let option3 = false

            let exactlyOneSelected = Bool.one {
                option1
                option2
                option3
            }

            #expect(exactlyOneSelected == true)
        }

        @Test("No errors check with none")
        func noErrorsCheckWithNone() {
            let hasNetworkError = false
            let hasValidationError = false
            let hasTimeout = false

            let noErrors = Bool.none {
                hasNetworkError
                hasValidationError
                hasTimeout
            }

            #expect(noErrors == true)
        }
    }

    @Suite("Limited Availability")
    struct LimitedAvailabilityTests {

        @Test("Limited availability passthrough - all")
        func limitedAvailabilityPassthroughAll() {
            let result = Bool.all {
                true
                if #available(macOS 26, iOS 26, *) {
                    true
                }
            }
            #expect(result == true)
        }

        @Test("Limited availability passthrough - any")
        func limitedAvailabilityPassthroughAny() {
            let result = Bool.any {
                false
                if #available(macOS 26, iOS 26, *) {
                    true
                }
            }
            #expect(result == true)
        }
    }
}
