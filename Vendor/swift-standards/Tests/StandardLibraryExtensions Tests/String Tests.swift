import Testing

@testable import StandardLibraryExtensions

// Tests for non-ASCII string functionality that remains in swift-standards
// (Percent encoding, CaseInsensitive, LineEnding, Base64, Hex encoding)

// MARK: - String.CaseInsensitive

@Suite
struct `String.CaseInsensitive - Equality` {

    @Test
    func `Same strings are equal`() {
        let a = "hello".caseInsensitive
        let b = "hello".caseInsensitive
        #expect(a == b)
    }

    @Test
    func `Different case strings are equal`() {
        let a = "hello".caseInsensitive
        let b = "HELLO".caseInsensitive
        #expect(a == b)
    }

    @Test
    func `Mixed case strings are equal`() {
        let a = "HeLLo".caseInsensitive
        let b = "hEllO".caseInsensitive
        #expect(a == b)
    }
}

@Suite
struct `String.CaseInsensitive - Hashing` {

    @Test
    func `Same case strings have same hash`() {
        let a = "hello".caseInsensitive
        let b = "hello".caseInsensitive
        #expect(a.hashValue == b.hashValue)
    }

    @Test
    func `Different case strings have same hash`() {
        let a = "hello".caseInsensitive
        let b = "HELLO".caseInsensitive
        #expect(a.hashValue == b.hashValue)
    }
}

// String.ASCII.LineEnding tests have been moved to swift-incits-4-1986
// Percent encoding tests have been moved to swift-rfc-3986
// Hex encoding tests have been moved to swift-rfc-4648
// Base64 encoding tests have been moved to swift-rfc-4648

// MARK: - StringProtocol.range(of:)

@Suite
struct `StringProtocol.range(of:) - Basic Matching` {

    @Test
    func `Find substring in middle`() {
        let result = "Hello World".range(of: "World")
        #expect(result != nil)
        if let range = result {
            #expect("Hello World"[range] == "World")
        }
    }

    @Test
    func `Find substring at start`() {
        let result = "Hello World".range(of: "Hello")
        #expect(result != nil)
        if let range = result {
            #expect("Hello World"[range] == "Hello")
        }
    }

    @Test
    func `Find substring at end`() {
        let result = "Hello World".range(of: "World")
        #expect(result != nil)
        if let range = result {
            #expect("Hello World"[range] == "World")
        }
    }

    @Test
    func `Find single character`() {
        let result = "test".range(of: "s")
        #expect(result != nil)
        if let range = result {
            #expect("test"[range] == "s")
        }
    }

    @Test
    func `Not found returns nil`() {
        #expect("Hello World".range(of: "xyz") == nil)
    }
}

@Suite
struct `StringProtocol.range(of:) - Edge Cases` {

    @Test
    func `Empty search string returns empty range at start`() {
        let result = "test".range(of: "")
        #expect(result != nil)
        if let range = result {
            #expect(range.isEmpty)
            #expect(range.lowerBound == "test".startIndex)
        }
    }

    @Test
    func `Empty source string returns nil for non-empty search`() {
        #expect("".range(of: "test") == nil)
    }

    @Test
    func `Search string longer than source returns nil`() {
        #expect("abc".range(of: "abcdef") == nil)
    }

    @Test
    func `Exact match returns full range`() {
        let result = "test".range(of: "test")
        #expect(result != nil)
        if let range = result {
            #expect("test"[range] == "test")
        }
    }
}

@Suite
struct `StringProtocol.range(of:) - Multiple Occurrences` {

    @Test
    func `Returns first occurrence`() {
        let result = "test test test".range(of: "test")
        #expect(result != nil)
        if let range = result {
            // Should be the first occurrence
            #expect(range.lowerBound == "test test test".startIndex)
        }
    }

    @Test
    func `Find repeated pattern`() {
        let result = "aaabbbaaaccc".range(of: "aaa")
        #expect(result != nil)
        if let range = result {
            #expect("aaabbbaaaccc"[range] == "aaa")
            #expect(range.lowerBound == "aaabbbaaaccc".startIndex)
        }
    }
}

@Suite
struct `StringProtocol.range(of:) - Substring Support` {

    @Test
    func `Works with Substring as source`() {
        let string = "Hello World Test"
        let substring = string[string.startIndex..<string.index(string.startIndex, offsetBy: 11)]

        let result = substring.range(of: "World")
        #expect(result != nil)
        if let range = result {
            #expect(substring[range] == "World")
        }
    }

    @Test
    func `Works with Substring as search pattern`() {
        let pattern = "World Test"
        let subPattern = pattern[
            pattern.startIndex..<pattern.index(pattern.startIndex, offsetBy: 5)
        ]

        let result = "Hello World".range(of: subPattern)
        #expect(result != nil)
        if let range = result {
            #expect("Hello World"[range] == "World")
        }
    }

    @Test
    func `Zero-copy Substring search`() {
        let large = "prefix_Hello World_suffix"
        let start = large.index(large.startIndex, offsetBy: 7)
        let end = large.index(start, offsetBy: 11)
        let sub = large[start..<end]

        // Substring type is preserved
        #expect(type(of: sub) == Substring.self)

        let result = sub.range(of: "World")
        #expect(result != nil)
        if let range = result {
            #expect(sub[range] == "World")
        }
    }
}

@Suite
struct `StringProtocol.range(of:) - Special Characters` {

    @Test
    func `Find unicode characters`() {
        let result = "Hello 🌍 World".range(of: "🌍")
        #expect(result != nil)
        if let range = result {
            #expect("Hello 🌍 World"[range] == "🌍")
        }
    }

    @Test
    func `Find string with spaces`() {
        let result = "This is a test".range(of: "is a")
        #expect(result != nil)
        if let range = result {
            #expect("This is a test"[range] == "is a")
        }
    }

    @Test
    func `Find punctuation`() {
        let result = "Hello, World!".range(of: ", ")
        #expect(result != nil)
        if let range = result {
            #expect("Hello, World!"[range] == ", ")
        }
    }

    @Test
    func `Find newline`() {
        let result = "Line1\nLine2".range(of: "\n")
        #expect(result != nil)
        if let range = result {
            #expect("Line1\nLine2"[range] == "\n")
        }
    }
}

@Suite
struct `StringProtocol.range(of:) - Case Sensitivity` {

    @Test
    func `Case sensitive search`() {
        #expect("Hello World".range(of: "world") == nil)
        #expect("Hello World".range(of: "World") != nil)
    }

    @Test
    func `Exact case required`() {
        #expect("TEST".range(of: "test") == nil)
        #expect("TEST".range(of: "TEST") != nil)
    }
}
