// String.swift
// swift-standards
//
// Pure Swift string manipulation utilities

// String trimming has been moved to swift-incits-4-1986

extension String {
    /// Case-insensitive string wrapper for use as dictionary keys and comparisons
    ///
    /// Provides case-insensitive hashing and equality checking, enabling
    /// case-insensitive lookups in dictionaries and sets.
    ///
    /// Example:
    /// ```swift
    /// var headers: [String.CaseInsensitive: String] = [:]
    /// headers["Content-Type".caseInsensitive] = "text/html"
    /// headers["content-type".caseInsensitive]  // "text/html"
    /// ```
    public struct CaseInsensitive: Hashable, Comparable, Sendable {
        public let value: String

        public init(_ value: some StringProtocol) {
            self.value = String(value)
        }

        public func hash(into hasher: inout Hasher) {
            value.lowercased().hash(into: &hasher)
        }

        public static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.value.lowercased() == rhs.value.lowercased()
        }

        public static func < (lhs: Self, rhs: Self) -> Bool {
            lhs.value.lowercased() < rhs.value.lowercased()
        }
    }

    /// Returns a case-insensitive wrapper for this string
    public var caseInsensitive: CaseInsensitive {
        CaseInsensitive(self)
    }
}

// ASCII validation methods have been moved to swift-incits-4-1986

extension String {
    /// String case style for formatting
    ///
    /// This struct allows for extensible case transformations. Third parties can
    /// create custom case formats by providing a closure that transforms strings.
    ///
    /// Example:
    /// ```swift
    /// let customCase = String.Case { string in
    ///     // Custom transformation logic
    ///     return string.map { $0.isLetter ? $0.uppercased() : $0.lowercased() }.joined()
    /// }
    /// let result = "hello world".formatted(as: customCase)
    /// ```
    public struct Case: Sendable {
        let transform: @Sendable (String) -> String

        public init(transform: @escaping @Sendable (String) -> String) {
            self.transform = transform
        }

        /// Convert to uppercase (HELLO WORLD)
        public static let upper = Case { $0.uppercased() }

        /// Convert to lowercase (hello world)
        public static let lower = Case { $0.lowercased() }

        /// Convert to title case (Hello World)
        public static let title = Case { string in
            string.split(separator: " ")
                .map { word in
                    guard let first = word.first else { return "" }
                    return first.uppercased() + word.dropFirst().lowercased()
                }
                .joined(separator: " ")
        }

        /// Convert to sentence case (Hello world)
        public static let sentence = Case { string in
            guard let first = string.first else { return string }
            return first.uppercased() + string.dropFirst().lowercased()
        }
    }

}

// StringProtocol extensions have been moved to StringProtocol.swift

extension String {
    /// Splits string into lines
    ///
    /// Homomorphism respecting line structure.
    /// Decomposes text into line-separated components.
    ///
    /// Category theory: List homomorphism decomposing concatenated structure
    /// lines: String → [String] where concat ∘ lines ≈ id (modulo separators)
    ///
    /// Example:
    /// ```swift
    /// "hello\nworld\ntest".lines  // ["hello", "world", "test"]
    /// ```
    public var lines: [String] {
        split(whereSeparator: \.isNewline).map(String.init)
    }

    /// Splits string into words
    ///
    /// Tokenization via whitespace separation.
    /// Decomposes text into word tokens.
    ///
    /// Category theory: List homomorphism via whitespace quotient
    /// words: String → [String] factoring through String/~
    ///
    /// Example:
    /// ```swift
    /// "hello world test".words  // ["hello", "world", "test"]
    /// ```
    public var words: [String] {
        split(whereSeparator: \.isWhitespace).map(String.init)
    }
}
