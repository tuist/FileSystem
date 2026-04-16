// MARK: - Case Formatting

extension StringProtocol {
    /// Formats the string using the specified case transformation
    /// - Parameter case: The case format to apply
    /// - Returns: Formatted string
    ///
    /// Example:
    /// ```swift
    /// "hello world".formatted(as: .upper)  // "HELLO WORLD"
    /// "hello world".formatted(as: .title)  // "Hello World"
    /// let sub = "hello world"[...]; sub.formatted(as: .upper)  // Works on Substring too
    /// ```
    public func formatted(as case: String.Case) -> String {
        `case`.transform(String(self))
    }
}

// MARK: - String Search Operations

extension StringProtocol {
    /// Finds the range of the first occurrence of a given string
    ///
    /// Foundation-free implementation for finding substrings.
    /// Works with both String and Substring for zero-copy operations.
    ///
    /// - Parameter string: The string to search for
    /// - Returns: Range of the first occurrence, or nil if not found
    ///
    /// Example:
    /// ```swift
    /// "Hello World".range(of: "World")  // Range at position 6
    /// "test".range(of: "xyz")           // nil
    ///
    /// // Works with Substring (zero-copy)
    /// let sub = "Hello World"[...]
    /// sub.range(of: "World")            // Range in Substring
    /// ```
    public func range(of string: some StringProtocol) -> Range<Index>? {
        guard !string.isEmpty else { return startIndex ..< startIndex }

        // Search on the UTF-8 byte view. UTF-8 is self-synchronizing, so any
        // byte-level match is also Unicode-scalar-aligned, and `String.Index`
        // values from `utf8` are interchangeable with the receiver's own
        // indices. This avoids per-Character grapheme-cluster comparisons
        // and the O(n) `distance(from:to:)` calls the previous naive scan
        // performed once per outer iteration.
        let haystack = utf8
        let needle = string.utf8
        let nCount = needle.count
        let hCount = haystack.count
        guard nCount <= hCount else { return nil }

        let needleStart = needle.startIndex
        let needleEnd = needle.endIndex
        let firstByte = needle[needleStart]
        let secondNeedle = needle.index(after: needleStart)

        let hEnd = haystack.endIndex
        let lastPossibleStart = haystack.index(hEnd, offsetBy: -nCount)

        var i = haystack.startIndex
        while i <= lastPossibleStart {
            if haystack[i] == firstByte {
                var h = haystack.index(after: i)
                var n = secondNeedle
                while n < needleEnd, haystack[h] == needle[n] {
                    h = haystack.index(after: h)
                    n = needle.index(after: n)
                }
                if n == needleEnd {
                    let end = haystack.index(i, offsetBy: nCount)
                    return i ..< end
                }
            }
            i = haystack.index(after: i)
        }

        return nil
    }
}

// MARK: - String Trimming

extension StringProtocol {
    /// Trims characters from both ends of a string (authoritative implementation)
    ///
    /// - Parameters:
    ///   - string: The string to trim
    ///   - predicate: A closure that returns `true` for characters to trim
    /// - Returns: A substring view with matching characters trimmed from both ends
    ///
    /// This method returns a zero-copy view (SubSequence) of the original string.
    /// If you need an owned String, explicitly convert the result: `String(result)`.
    ///
    /// Example:
    /// ```swift
    /// String.trimming("  hello  ", where: { $0.isWhitespace })  // "hello"
    /// String.trimming("123hello456", where: \.isNumber)         // "hello"
    /// ```
    public static func trimming(
        _ string: Self,
        where predicate: (Character) -> Bool
    ) -> SubSequence {
        var start = string.startIndex
        var end = string.endIndex

        // Trim from start
        while start < end, predicate(string[start]) {
            start = string.index(after: start)
        }

        // Trim from end
        while end > start, predicate(string[string.index(before: end)]) {
            end = string.index(before: end)
        }

        return string[start ..< end]
    }

    /// Trims characters from both ends of a string
    ///
    /// Convenience overload that delegates to `trimming(_:where:)`.
    ///
    /// - Parameters:
    ///   - string: The string to trim
    ///   - characterSet: The set of characters to trim
    /// - Returns: A substring view with the specified characters trimmed from both ends
    ///
    /// Example:
    /// ```swift
    /// String.trimming("  hello  ", of: [" "])  // "hello"
    /// ```
    public static func trimming(
        _ string: Self,
        of characterSet: Set<Character>
    ) -> SubSequence {
        trimming(string, where: characterSet.contains)
    }

    /// Trims characters matching a predicate from both ends of the string
    ///
    /// Delegates to the authoritative `Self.trimming(_:where:)` implementation.
    ///
    /// - Parameter predicate: A closure that returns `true` for characters to trim
    /// - Returns: A substring view with matching characters trimmed from both ends
    ///
    /// Example:
    /// ```swift
    /// "  hello  ".trimming(where: { $0.isWhitespace })  // "hello"
    /// "123hello456".trimming(where: \.isNumber)         // "hello"
    /// ```
    public func trimming(where predicate: (Character) -> Bool) -> SubSequence {
        Self.trimming(self, where: predicate)
    }

    /// Trims characters from both ends of the string
    ///
    /// Delegates to the authoritative `Self.trimming(_:where:)` implementation.
    ///
    /// - Parameter characterSet: The set of characters to trim
    /// - Returns: A substring view with the specified characters trimmed from both ends
    ///
    /// Example:
    /// ```swift
    /// "  hello  ".trimming([" "])           // "hello"
    /// "\t\nhello\n\t".trimming(["\t", "\n"]) // "hello"
    /// "🎉hello🎉".trimming(["🎉"])          // "hello"
    /// ```
    @_disfavoredOverload
    public func trimming(_ characterSet: Set<Character>) -> SubSequence {
        Self.trimming(self, of: characterSet)
    }

    public func trimming(_ characterSet: Set<Character>) -> String {
        String(Self.trimming(self, of: characterSet))
    }
}
