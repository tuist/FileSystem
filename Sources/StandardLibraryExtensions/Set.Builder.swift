extension Set {
    @resultBuilder
    public enum Builder {
        // MARK: - Expression Building

        @inlinable
        public static func buildExpression(_ expression: Element) -> Set<Element> {
            [expression]
        }

        @inlinable
        public static func buildExpression(_ expression: Set<Element>) -> Set<Element> {
            expression
        }

        @inlinable
        public static func buildExpression(_ expression: [Element]) -> Set<Element> {
            Set(expression)
        }

        @inlinable
        public static func buildExpression(_ expression: Element?) -> Set<Element> {
            expression.map { [$0] } ?? []
        }

        // MARK: - Partial Block Building

        @inlinable
        public static func buildPartialBlock(first: Set<Element>) -> Set<Element> {
            first
        }

        @inlinable
        public static func buildPartialBlock(first: Void) -> Set<Element> {
            []
        }

        @inlinable
        public static func buildPartialBlock(first: Never) -> Set<Element> {}

        @inlinable
        public static func buildPartialBlock(
            accumulated: Set<Element>,
            next: Set<Element>
        ) -> Set<Element> {
            accumulated.union(next)
        }

        // MARK: - Block Building

        @inlinable
        public static func buildBlock() -> Set<Element> {
            []
        }

        // MARK: - Control Flow

        @inlinable
        public static func buildOptional(_ component: Set<Element>?) -> Set<Element> {
            component ?? []
        }

        @inlinable
        public static func buildEither(first: Set<Element>) -> Set<Element> {
            first
        }

        @inlinable
        public static func buildEither(second: Set<Element>) -> Set<Element> {
            second
        }

        @inlinable
        public static func buildArray(_ components: [Set<Element>]) -> Set<Element> {
            components.reduce(into: []) { result, set in
                result.formUnion(set)
            }
        }

        @inlinable
        public static func buildLimitedAvailability(_ component: Set<Element>) -> Set<Element> {
            component
        }
    }
}

extension Set {
    @inlinable
    public init(@Set.Builder _ builder: () -> Set<Element>) {
        self = builder()
    }
}
