extension String {
    /// A result builder for declaratively constructing strings.
    ///
    /// Joins multiple string expressions with newlines.
    ///
    /// ```swift
    /// let text = String {
    ///     "Hello"
    ///     "World"
    /// }
    /// // "Hello\nWorld"
    /// ```
    @resultBuilder
    public enum Builder {
        // MARK: - Expression Building

        @inlinable
        public static func buildExpression<S: StringProtocol>(_ expression: S) -> String {
            String(expression)
        }

        @inlinable
        public static func buildExpression<S: StringProtocol>(_ expression: S?) -> String {
            expression.map { String($0) } ?? ""
        }

        // MARK: - Partial Block Building

        @inlinable
        public static func buildPartialBlock(first: String) -> String {
            first
        }

        @inlinable
        public static func buildPartialBlock(first: Void) -> String {
            ""
        }

        @inlinable
        public static func buildPartialBlock(first: Never) -> String {}

        @inlinable
        public static func buildPartialBlock(accumulated: String, next: String) -> String {
            if accumulated.isEmpty {
                next
            } else {
                accumulated + "\n" + next
            }
        }

        // MARK: - Block Building

        @inlinable
        public static func buildBlock() -> String {
            ""
        }

        // MARK: - Control Flow

        @inlinable
        public static func buildOptional(_ component: String?) -> String {
            component ?? ""
        }

        @inlinable
        public static func buildEither(first: String) -> String {
            first
        }

        @inlinable
        public static func buildEither(second: String) -> String {
            second
        }

        @inlinable
        public static func buildArray(_ components: [String]) -> String {
            components.joined(separator: "\n")
        }

        @inlinable
        public static func buildLimitedAvailability(_ component: String) -> String {
            component
        }
    }
}

extension String {
    @inlinable
    public init(@Builder _ builder: () -> String) {
        self = builder()
    }
}

extension Substring {
    /// A result builder for declaratively constructing substrings.
    ///
    /// Uses `String.Builder` internally and converts the final result to `Substring`.
    @resultBuilder
    public enum Builder {
        // MARK: - Expression Building

        @inlinable
        public static func buildExpression<S: StringProtocol>(_ expression: S) -> String {
            String.Builder.buildExpression(expression)
        }

        @inlinable
        public static func buildExpression<S: StringProtocol>(_ expression: S?) -> String {
            String.Builder.buildExpression(expression)
        }

        // MARK: - Partial Block Building

        @inlinable
        public static func buildPartialBlock(first: String) -> String {
            String.Builder.buildPartialBlock(first: first)
        }

        @inlinable
        public static func buildPartialBlock(first: Void) -> String {
            String.Builder.buildPartialBlock(first: first)
        }

        @inlinable
        public static func buildPartialBlock(first: Never) -> String {}

        @inlinable
        public static func buildPartialBlock(accumulated: String, next: String) -> String {
            String.Builder.buildPartialBlock(accumulated: accumulated, next: next)
        }

        // MARK: - Block Building

        @inlinable
        public static func buildBlock() -> String {
            String.Builder.buildBlock()
        }

        // MARK: - Control Flow

        @inlinable
        public static func buildOptional(_ component: String?) -> String {
            String.Builder.buildOptional(component)
        }

        @inlinable
        public static func buildEither(first: String) -> String {
            String.Builder.buildEither(first: first)
        }

        @inlinable
        public static func buildEither(second: String) -> String {
            String.Builder.buildEither(second: second)
        }

        @inlinable
        public static func buildArray(_ components: [String]) -> String {
            String.Builder.buildArray(components)
        }

        @inlinable
        public static func buildLimitedAvailability(_ component: String) -> String {
            String.Builder.buildLimitedAvailability(component)
        }

        // MARK: - Final Result

        @inlinable
        public static func buildFinalResult(_ component: String) -> Substring {
            Substring(component)
        }
    }
}

extension Substring {
    @inlinable
    public init(@Builder _ builder: () -> Substring) {
        self = builder()
    }
}
