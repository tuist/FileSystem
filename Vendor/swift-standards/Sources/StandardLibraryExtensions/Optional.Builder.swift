extension Optional {
    /// A result builder that returns the first non-nil value from a sequence of expressions.
    ///
    /// Use `Optional.first` to coalesce multiple optional values, returning the first
    /// one that is non-nil. This is similar to the `??` operator but works with multiple
    /// values in a declarative block syntax.
    ///
    /// ```swift
    /// let value = Optional.first {
    ///     cachedValue
    ///     computeExpensiveValue()
    ///     fallbackValue
    /// }
    /// ```
    ///
    /// The builder short-circuits: once a non-nil value is found, subsequent expressions
    /// are not evaluated.
    @resultBuilder
    public enum Builder {
        // MARK: - Expression Building

        @inlinable
        public static func buildExpression(_ expression: Wrapped) -> Wrapped? {
            expression
        }

        @inlinable
        public static func buildExpression(_ expression: Wrapped?) -> Wrapped? {
            expression
        }

        // MARK: - Partial Block Building

        @inlinable
        public static func buildPartialBlock(first: Wrapped?) -> Wrapped? {
            first
        }

        @inlinable
        public static func buildPartialBlock(first: Void) -> Wrapped? {
            nil
        }

        @inlinable
        public static func buildPartialBlock(first: Never) -> Wrapped? {}

        @inlinable
        public static func buildPartialBlock(accumulated: Wrapped?, next: Wrapped?) -> Wrapped? {
            accumulated ?? next
        }

        // MARK: - Block Building

        @inlinable
        public static func buildBlock() -> Wrapped? {
            nil
        }

        // MARK: - Control Flow

        @inlinable
        public static func buildOptional(_ component: Wrapped??) -> Wrapped? {
            component ?? nil
        }

        @inlinable
        public static func buildEither(first: Wrapped?) -> Wrapped? {
            first
        }

        @inlinable
        public static func buildEither(second: Wrapped?) -> Wrapped? {
            second
        }

        @inlinable
        public static func buildArray(_ components: [Wrapped?]) -> Wrapped? {
            for component in components {
                if let value = component {
                    return value
                }
            }
            return nil
        }

        @inlinable
        public static func buildLimitedAvailability(_ component: Wrapped?) -> Wrapped? {
            component
        }
    }
}

extension Optional {
    /// Builds an optional by returning the first non-nil value from the builder block.
    ///
    /// ```swift
    /// let value = Optional.first {
    ///     cachedValue
    ///     computeExpensiveValue()
    ///     fallbackValue
    /// }
    /// ```
    @inlinable
    public static func first(@Optional<Wrapped>.Builder _ builder: () -> Wrapped?) -> Wrapped? {
        builder()
    }
}
