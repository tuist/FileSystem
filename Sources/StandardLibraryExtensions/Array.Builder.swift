extension Array {
    /// A result builder for declaratively constructing arrays.
    ///
    /// ```swift
    /// let array = Array {
    ///     1
    ///     2
    ///     if condition {
    ///         3
    ///     }
    /// }
    /// ```
    @resultBuilder
    public enum Builder {
        // MARK: - Expression Building

        @inlinable
        public static func buildExpression(_ expression: Element) -> [Element] {
            [expression]
        }

        @inlinable
        public static func buildExpression(_ expression: [Element]) -> [Element] {
            expression
        }

        @inlinable
        public static func buildExpression(_ expression: Element?) -> [Element] {
            expression.map { [$0] } ?? []
        }

        // MARK: - Partial Block Building

        @inlinable
        public static func buildPartialBlock(first: [Element]) -> [Element] {
            first
        }

        @inlinable
        public static func buildPartialBlock(first: Void) -> [Element] {
            []
        }

        @inlinable
        public static func buildPartialBlock(first: Never) -> [Element] {}

        @inlinable
        public static func buildPartialBlock(accumulated: [Element], next: [Element]) -> [Element] {
            accumulated + next
        }

        // MARK: - Block Building

        @inlinable
        public static func buildBlock() -> [Element] {
            []
        }

        // MARK: - Control Flow

        @inlinable
        public static func buildOptional(_ component: [Element]?) -> [Element] {
            component ?? []
        }

        @inlinable
        public static func buildEither(first: [Element]) -> [Element] {
            first
        }

        @inlinable
        public static func buildEither(second: [Element]) -> [Element] {
            second
        }

        @inlinable
        public static func buildArray(_ components: [[Element]]) -> [Element] {
            components.flatMap { $0 }
        }

        @inlinable
        public static func buildLimitedAvailability(_ component: [Element]) -> [Element] {
            component
        }
    }
}

extension Array {
    @inlinable
    public init(@Array.Builder _ builder: () -> [Element]) {
        self = builder()
    }
}

// MARK: - ArraySlice Builder (delegates to Array.Builder)

extension ArraySlice {
    /// A result builder for declaratively constructing array slices.
    ///
    /// Uses `Array.Builder` internally and converts the final result to `ArraySlice`.
    @resultBuilder
    public enum Builder {
        @inlinable
        public static func buildExpression(_ expression: Element) -> [Element] {
            [Element].Builder.buildExpression(expression)
        }

        @inlinable
        public static func buildExpression(_ expression: [Element]) -> [Element] {
            [Element].Builder.buildExpression(expression)
        }

        @inlinable
        public static func buildExpression(_ expression: ArraySlice<Element>) -> [Element] {
            Array(expression)
        }

        @inlinable
        public static func buildExpression(_ expression: Element?) -> [Element] {
            [Element].Builder.buildExpression(expression)
        }

        @inlinable
        public static func buildPartialBlock(first: [Element]) -> [Element] {
            [Element].Builder.buildPartialBlock(first: first)
        }

        @inlinable
        public static func buildPartialBlock(first: Void) -> [Element] {
            [Element].Builder.buildPartialBlock(first: first)
        }

        @inlinable
        public static func buildPartialBlock(first: Never) -> [Element] {}

        @inlinable
        public static func buildPartialBlock(accumulated: [Element], next: [Element]) -> [Element] {
            [Element].Builder.buildPartialBlock(accumulated: accumulated, next: next)
        }

        @inlinable
        public static func buildBlock() -> [Element] {
            [Element].Builder.buildBlock()
        }

        @inlinable
        public static func buildOptional(_ component: [Element]?) -> [Element] {
            [Element].Builder.buildOptional(component)
        }

        @inlinable
        public static func buildEither(first: [Element]) -> [Element] {
            [Element].Builder.buildEither(first: first)
        }

        @inlinable
        public static func buildEither(second: [Element]) -> [Element] {
            [Element].Builder.buildEither(second: second)
        }

        @inlinable
        public static func buildArray(_ components: [[Element]]) -> [Element] {
            [Element].Builder.buildArray(components)
        }

        @inlinable
        public static func buildLimitedAvailability(_ component: [Element]) -> [Element] {
            [Element].Builder.buildLimitedAvailability(component)
        }

        @inlinable
        public static func buildFinalResult(_ component: [Element]) -> ArraySlice<Element> {
            ArraySlice(component)
        }
    }
}

extension ArraySlice {
    @inlinable
    public init(@ArraySlice.Builder _ builder: () -> ArraySlice<Element>) {
        self = builder()
    }
}

// MARK: - ContiguousArray Builder (delegates to Array.Builder)

extension ContiguousArray {
    /// A result builder for declaratively constructing contiguous arrays.
    ///
    /// Uses `Array.Builder` internally and converts the final result to `ContiguousArray`.
    @resultBuilder
    public enum Builder {
        @inlinable
        public static func buildExpression(_ expression: Element) -> [Element] {
            [Element].Builder.buildExpression(expression)
        }

        @inlinable
        public static func buildExpression(_ expression: [Element]) -> [Element] {
            [Element].Builder.buildExpression(expression)
        }

        @inlinable
        public static func buildExpression(_ expression: ContiguousArray<Element>) -> [Element] {
            Array(expression)
        }

        @inlinable
        public static func buildExpression(_ expression: Element?) -> [Element] {
            [Element].Builder.buildExpression(expression)
        }

        @inlinable
        public static func buildPartialBlock(first: [Element]) -> [Element] {
            [Element].Builder.buildPartialBlock(first: first)
        }

        @inlinable
        public static func buildPartialBlock(first: Void) -> [Element] {
            [Element].Builder.buildPartialBlock(first: first)
        }

        @inlinable
        public static func buildPartialBlock(first: Never) -> [Element] {}

        @inlinable
        public static func buildPartialBlock(accumulated: [Element], next: [Element]) -> [Element] {
            [Element].Builder.buildPartialBlock(accumulated: accumulated, next: next)
        }

        @inlinable
        public static func buildBlock() -> [Element] {
            [Element].Builder.buildBlock()
        }

        @inlinable
        public static func buildOptional(_ component: [Element]?) -> [Element] {
            [Element].Builder.buildOptional(component)
        }

        @inlinable
        public static func buildEither(first: [Element]) -> [Element] {
            [Element].Builder.buildEither(first: first)
        }

        @inlinable
        public static func buildEither(second: [Element]) -> [Element] {
            [Element].Builder.buildEither(second: second)
        }

        @inlinable
        public static func buildArray(_ components: [[Element]]) -> [Element] {
            [Element].Builder.buildArray(components)
        }

        @inlinable
        public static func buildLimitedAvailability(_ component: [Element]) -> [Element] {
            [Element].Builder.buildLimitedAvailability(component)
        }

        @inlinable
        public static func buildFinalResult(_ component: [Element]) -> ContiguousArray<Element> {
            ContiguousArray(component)
        }
    }
}

extension ContiguousArray {
    @inlinable
    public init(@ContiguousArray.Builder _ builder: () -> ContiguousArray<Element>) {
        self = builder()
    }
}
