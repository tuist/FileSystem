import Testing
@testable import StandardLibraryExtensions

@Suite struct StringProtocolRangeOfTests {
    @Test func emptyPatternReturnsEmptyRangeAtStart() {
        let s = "hello"
        #expect(s.range(of: "") == s.startIndex ..< s.startIndex)
    }

    @Test func patternLongerThanReceiverReturnsNil() {
        #expect("hi".range(of: "hello") == nil)
    }

    @Test func simpleMatchAtStart() throws {
        let s = "warning: something happened"
        let r = try #require(s.range(of: "warning: "))
        #expect(String(s[r]) == "warning: ")
        #expect(r.lowerBound == s.startIndex)
    }

    @Test func simpleMatchInMiddle() throws {
        let s = "foo warning: bar"
        let r = try #require(s.range(of: "warning: "))
        #expect(String(s[r]) == "warning: ")
    }

    @Test func noMatchReturnsNil() {
        #expect("foo bar".range(of: "baz") == nil)
    }

    @Test func matchAtEnd() throws {
        let s = "trailing ^~"
        let r = try #require(s.range(of: " ^~"))
        #expect(String(s[r]) == " ^~")
        #expect(r.upperBound == s.endIndex)
    }

    @Test func overlappingCandidateFirstDoesNotMatchThenSecondDoes() throws {
        let s = "aaab"
        let r = try #require(s.range(of: "aab"))
        #expect(String(s[r]) == "aab")
    }

    @Test func worksOnSubstring() throws {
        let full = "xxwarning: yy"
        let sub = full[full.index(after: full.startIndex)...]
        let r = try #require(sub.range(of: "warning: "))
        #expect(String(sub[r]) == "warning: ")
    }

    @Test func unicodePatternMatches() throws {
        let s = "café au lait"
        let r = try #require(s.range(of: "café"))
        #expect(String(s[r]) == "café")
    }

    @Test func unicodeHaystackAsciiPattern() throws {
        let s = "日本語 warning: thing"
        let r = try #require(s.range(of: "warning: "))
        #expect(String(s[r]) == "warning: ")
    }

    // MARK: - Benchmark (mirrors XCActivityLog extractIssues hotspot)

    @Test func benchmarkManyIssueMessages() {
        let messageCount = 6000

        // A padding paragraph that simulates the surrounding code context diagnostics ship with.
        let padding = String(
            repeating: "    let something = doSomethingInteresting(x, y, z) // trailing note\n",
            count: 8
        )

        let templates: [String] = [
            "/path/to/Sources/File.swift:42:17: \(padding)warning: something is deprecated\n    let x = 1\n    ^~~~~~~~~~~~~~~\n",
            "/path/to/Sources/Other.swift:108:3: \(padding)error: cannot find 'bar' in scope\n    bar()\n    ^~~\n",
            "plain build output line with \(padding) no diagnostic marker at all, padding padding padding\n",
        ]
        var messages: [String] = []
        messages.reserveCapacity(messageCount)
        for i in 0 ..< messageCount {
            messages.append(templates[i % templates.count])
        }

        let start = ContinuousClock.now
        var hits = 0
        for detail in messages {
            if detail.range(of: "warning: ") != nil { hits += 1 }
            if detail.range(of: "error: ") != nil { hits += 1 }
            if detail.range(of: " ^~") != nil { hits += 1 }
        }
        let elapsed = ContinuousClock.now - start

        // Sanity: warning+^~ template hits 2, error+^~ template hits 2, plain hits 0 ⇒ 4 * (6000/3) = 8000.
        #expect(hits == 8000)

        print("[benchmark] range(of:) x3 over \(messageCount) messages took \(elapsed)")
    }
}
