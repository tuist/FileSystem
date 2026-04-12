extension Range {
    /// A result builder for declaratively constructing arrays of half-open ranges.
    ///
    /// Use `Range.build` to build collections of potentially discontinuous ranges.
    ///
    /// ```swift
    /// let ranges = Range.build {
    ///     0..<5
    ///     10..<15
    ///     if includeExtra {
    ///         20..<25
    ///     }
    /// }
    /// ```
    @resultBuilder
    public enum Builder {
        // MARK: - Expression Building

        @inlinable
        public static func buildExpression(_ expression: Range<Bound>) -> [Range<Bound>] {
            [expression]
        }

        @inlinable
        public static func buildExpression(_ expression: [Range<Bound>]) -> [Range<Bound>] {
            expression
        }

        // MARK: - Partial Block Building

        @inlinable
        public static func buildPartialBlock(first: [Range<Bound>]) -> [Range<Bound>] {
            first
        }

        @inlinable
        public static func buildPartialBlock(first: Void) -> [Range<Bound>] {
            []
        }

        @inlinable
        public static func buildPartialBlock(first: Never) -> [Range<Bound>] {}

        @inlinable
        public static func buildPartialBlock(
            accumulated: [Range<Bound>],
            next: [Range<Bound>]
        ) -> [Range<Bound>] {
            accumulated + next
        }

        // MARK: - Block Building

        @inlinable
        public static func buildBlock() -> [Range<Bound>] {
            []
        }

        // MARK: - Control Flow

        @inlinable
        public static func buildOptional(_ component: [Range<Bound>]?) -> [Range<Bound>] {
            component ?? []
        }

        @inlinable
        public static func buildEither(first: [Range<Bound>]) -> [Range<Bound>] {
            first
        }

        @inlinable
        public static func buildEither(second: [Range<Bound>]) -> [Range<Bound>] {
            second
        }

        @inlinable
        public static func buildArray(_ components: [[Range<Bound>]]) -> [Range<Bound>] {
            components.flatMap { $0 }
        }

        @inlinable
        public static func buildLimitedAvailability(_ component: [Range<Bound>]) -> [Range<Bound>] {
            component
        }
    }
}

extension Range {
    @inlinable
    public static func build(
        @Range<Bound>.Builder _ builder: () -> [Range<Bound>]
    ) -> [Range<Bound>] {
        builder()
    }
}

// MARK: - ClosedRange Builder (delegates to Range.Builder pattern)

extension ClosedRange {
    /// A result builder for declaratively constructing arrays of closed ranges.
    ///
    /// Use `ClosedRange.build` to build collections of potentially discontinuous ranges.
    ///
    /// ```swift
    /// let ranges = ClosedRange.build {
    ///     1...5
    ///     10...15
    ///     if includeExtra {
    ///         20...25
    ///     }
    /// }
    /// ```
    @resultBuilder
    public enum Builder {
        // MARK: - Expression Building

        @inlinable
        public static func buildExpression(_ expression: ClosedRange<Bound>) -> [ClosedRange<Bound>]
        {
            [expression]
        }

        @inlinable
        public static func buildExpression(
            _ expression: [ClosedRange<Bound>]
        ) -> [ClosedRange<Bound>] {
            expression
        }

        /// Allows single values to be expressed as single-element closed ranges.
        @inlinable
        public static func buildExpression(_ expression: Bound) -> [ClosedRange<Bound>] {
            [expression...expression]
        }

        // MARK: - Partial Block Building

        @inlinable
        public static func buildPartialBlock(first: [ClosedRange<Bound>]) -> [ClosedRange<Bound>] {
            first
        }

        @inlinable
        public static func buildPartialBlock(first: Void) -> [ClosedRange<Bound>] {
            []
        }

        @inlinable
        public static func buildPartialBlock(first: Never) -> [ClosedRange<Bound>] {}

        @inlinable
        public static func buildPartialBlock(
            accumulated: [ClosedRange<Bound>],
            next: [ClosedRange<Bound>]
        ) -> [ClosedRange<Bound>] {
            accumulated + next
        }

        // MARK: - Block Building

        @inlinable
        public static func buildBlock() -> [ClosedRange<Bound>] {
            []
        }

        // MARK: - Control Flow

        @inlinable
        public static func buildOptional(_ component: [ClosedRange<Bound>]?) -> [ClosedRange<Bound>]
        {
            component ?? []
        }

        @inlinable
        public static func buildEither(first: [ClosedRange<Bound>]) -> [ClosedRange<Bound>] {
            first
        }

        @inlinable
        public static func buildEither(second: [ClosedRange<Bound>]) -> [ClosedRange<Bound>] {
            second
        }

        @inlinable
        public static func buildArray(_ components: [[ClosedRange<Bound>]]) -> [ClosedRange<Bound>]
        {
            components.flatMap { $0 }
        }

        @inlinable
        public static func buildLimitedAvailability(
            _ component: [ClosedRange<Bound>]
        ) -> [ClosedRange<Bound>] {
            component
        }
    }
}

extension ClosedRange {
    @inlinable
    public static func build(
        @ClosedRange<Bound>.Builder _ builder: () -> [ClosedRange<Bound>]
    ) -> [ClosedRange<Bound>] {
        builder()
    }
}
