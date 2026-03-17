import Testing

@testable import Glob

struct PatternTests {
    @Test
    func test_pathWildcard_matchesSingleNestedFolders() throws {
        #expect(try Pattern("**/*.generated.swift").match("Target/AutoMockable.generated.swift"))
    }

    @Test
    func test_pathWildcard_with_constant_component() throws {
        #expect(try Pattern("**/file.swift").match("file.swift"))
    }

    @Test
    func test_pathWildcard_matchesDirectFile() throws {
        #expect(try Pattern("**/*.generated.swift").match("AutoMockable.generated.swift"))
    }

    @Test
    func test_pathWildcard_does_not_match() throws {
        #expect(!(try Pattern("**/*.generated.swift").match("AutoMockable.non-generated.swift")))
    }

    @Test
    func test_double_pathWildcard_matchesDirectFileInNestedDirectory() throws {
        #expect(try Pattern("**/Pivot/**/*.generated.swift").match("Target/Pivot/AutoMockable.generated.swift"))
    }

    @Test
    func test_double_pathWildcard_does_not_match_when_pivot_does_not_match() throws {
        #expect(!(try Pattern("**/Pivot/**/*.generated.swift").match("Target/NonMatchingPivot/AutoMockable.generated.swift")))
    }

    @Test
    func test_double_pathWildcard_with_prefix_constants_matchesDirectFileInNestedDirectory() throws {
        #expect(try Pattern("Target/**/Pivot/**/*.generated.swift").match("Target/Extra/Pivot/AutoMockable.generated.swift"))
    }

    @Test
    func test_pathWildcard_matchesMultipleNestedFolders() throws {
        #expect(try Pattern("**/*.generated.swift").match("Target/Generated/AutoMockable.generated.swift"))
    }

    @Test
    func test_componentWildcard_matchesNonNestedFiles() throws {
        #expect(try Pattern("*.generated.swift").match("AutoMockable.generated.swift"))
    }

    @Test
    func test_componentWildcard_doesNotMatchNestedPaths() throws {
        #expect(!(try Pattern("*.generated.swift").match("Target/AutoMockable.generated.swift")))
    }

    @Test
    func test_multipleWildcards_matchesWithMultipleConstants() throws {
        // this can be tricky for some implementations because as they are parsing the first wildcard,
        // it will see a match and move on and the remaining pattern and content will not match
        #expect(try Pattern("**/AutoMockable*.swift").match("Target/AutoMockable/Sources/AutoMockable.generated.swift"))
    }

    @Test
    func test_matchingLongStrings_onSecondaryThread_doesNotCrash() async throws {
        // In Debug when using async methods, long strings would cause crashes with recursion for strings approaching ~90
        // characters.
        // Test that our implementation can handle long strings in async cases.
        try await Task {
            try await runStressTest()
        }.value
    }

    func runStressTest() async throws {
        #expect(try Pattern("base/**/Tests/**/*Tests.swift").match(
            "base/Shared/Tests/Objects/Utilities/PathsMoreAbitraryStringLengthSomeVeryLongTypeNameThat+SomeLongExtensionNameTests.swift"
        ))
    }

    @Test
    func test_pathWildcard_pathComponentsOnly_doesNotMatchPath() throws {
        var options = Pattern.Options.default
        options.supportsPathLevelWildcards = false
        #expect(!(try Pattern("**/.build", options: options).match("Target/Other/.build")))
    }

    @Test
    func test_componentWildcard_pathComponentsOnly_doesMatchSingleComponent() throws {
        var options = Pattern.Options.default
        options.supportsPathLevelWildcards = false
        #expect(try Pattern("*/.build", options: options).match("Target/.build"))
    }

    @Test
    func test_constant() throws {
        #expect(try Pattern("abc").match("abc"))
    }

    @Test
    func test_ranges() throws {
        #expect(try Pattern("[a-c]").match("b"))
        #expect(try Pattern("[A-C]").match("B"))
        #expect(!(try Pattern("[a-c]").match("n")))
    }

    @Test
    func test_multipleRanges() throws {
        #expect(try Pattern("[a-cA-C]").match("b"))
        #expect(try Pattern("[a-cA-C]").match("B"))
        #expect(!(try Pattern("[a-cA-C]").match("n")))
        #expect(!(try Pattern("[a-cA-C]").match("N")))
        #expect(!(try Pattern("[a-cA-Z]").match("n")))
        #expect(try Pattern("[a-cA-Z]").match("N"))
    }

    @Test
    func test_negateRange() throws {
        #expect(!(try Pattern("ab[^c]", options: .go).match("abc")))
    }

    @Test
    func test_singleCharacter_doesNotMatchSeparator() throws {
        #expect(!(try Pattern("a?b").match("a/b")))
    }

    @Test
    func test_namedCharacterClasses_alpha() throws {
        #expect(try Pattern("[[:alpha:]]").match("b"))
        #expect(try Pattern("[[:alpha:]]").match("B"))
        #expect(try Pattern("[[:alpha:]]").match("ē"))
        #expect(try Pattern("[[:alpha:]]").match("ž"))
        #expect(!(try Pattern("[[:alpha:]]").match("9")))
        #expect(!(try Pattern("[[:alpha:]]").match("&")))
    }
}
