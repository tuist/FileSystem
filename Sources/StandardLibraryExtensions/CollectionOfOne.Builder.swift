extension CollectionOfOne {
    /// A result builder that ensures exactly one element is provided.
    ///
    /// Use `CollectionOfOne.Builder` when you need to guarantee at compile time
    /// that exactly one element is present. This is useful for APIs that require
    /// a single value but benefit from builder syntax for conditional logic.
    ///
    /// ```swift
    /// let single: CollectionOfOne<Int> = CollectionOfOne {
    ///     if useDefault {
    ///         42
    ///     } else {
    ///         computedValue
    ///     }
    /// }
    /// ```
    ///
    /// Note: The builder enforces single-element semantics. If control flow could
    /// result in zero or multiple elements, it will not compile.
    @resultBuilder
    public enum Builder {
        // MARK: - Expression Building

        @inlinable
        public static func buildExpression(_ expression: Element) -> Element {
            expression
        }

        // MARK: - Block Building

        @inlinable
        public static func buildBlock(_ component: Element) -> Element {
            component
        }

        // MARK: - Control Flow

        @inlinable
        public static func buildEither(first: Element) -> Element {
            first
        }

        @inlinable
        public static func buildEither(second: Element) -> Element {
            second
        }

        @inlinable
        public static func buildLimitedAvailability(_ component: Element) -> Element {
            component
        }

        // MARK: - Final Result

        @inlinable
        public static func buildFinalResult(_ component: Element) -> CollectionOfOne<Element> {
            CollectionOfOne(component)
        }
    }
}

extension CollectionOfOne {
    @inlinable
    public init(@CollectionOfOne.Builder _ builder: () -> CollectionOfOne<Element>) {
        self = builder()
    }
}
