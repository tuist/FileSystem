// MARK: - TernaryLogic Builders

extension TernaryLogic {
    /// Namespace for ternary logic result builders.
    ///
    /// These builders implement Strong Kleene three-valued logic where:
    /// - `unknown` propagates through operations
    /// - Short-circuit evaluation still applies where possible
    public enum Builder<T: TernaryLogic.`Protocol`> {
        /// A result builder that combines ternary conditions with AND semantics (Strong Kleene).
        ///
        /// Returns `false` if any condition is `false` (short-circuits),
        /// `unknown` if any condition is `unknown` and none are `false`,
        /// `true` only if all conditions are `true`.
        ///
        /// ```swift
        /// let result = TernaryLogic.all {
        ///     true
        ///     nil    // unknown
        ///     true
        /// }
        /// // result = nil (unknown)
        /// ```
        @resultBuilder
        public enum All {
            @inlinable
            public static func buildExpression(_ expression: T) -> T {
                expression
            }

            @inlinable
            public static func buildExpression(_ expression: Bool) -> T {
                T(expression)
            }

            @inlinable
            public static func buildPartialBlock(first: T) -> T {
                first
            }

            @inlinable
            public static func buildPartialBlock(first: Void) -> T {
                .true
            }

            @inlinable
            public static func buildPartialBlock(first: Never) -> T {}

            @inlinable
            public static func buildPartialBlock(accumulated: T, next: T) -> T {
                // Strong Kleene AND: false dominates, then unknown, then true
                if T.from(accumulated) == false || T.from(next) == false {
                    return .false
                }
                if T.from(accumulated) == nil || T.from(next) == nil {
                    return .unknown
                }
                return .true
            }

            @inlinable
            public static func buildBlock() -> T {
                .true
            }

            @inlinable
            public static func buildOptional(_ component: T?) -> T {
                // Missing value means unknown in ternary logic
                component ?? .unknown
            }

            @inlinable
            public static func buildEither(first: T) -> T {
                first
            }

            @inlinable
            public static func buildEither(second: T) -> T {
                second
            }

            @inlinable
            public static func buildArray(_ components: [T]) -> T {
                var hasUnknown = false
                for component in components {
                    if T.from(component) == false {
                        return .false
                    }
                    if T.from(component) == nil {
                        hasUnknown = true
                    }
                }
                return hasUnknown ? .unknown : .true
            }

            @inlinable
            public static func buildLimitedAvailability(_ component: T) -> T {
                component
            }
        }

        /// A result builder that combines ternary conditions with OR semantics (Strong Kleene).
        ///
        /// Returns `true` if any condition is `true` (short-circuits),
        /// `unknown` if any condition is `unknown` and none are `true`,
        /// `false` only if all conditions are `false`.
        ///
        /// ```swift
        /// let result = TernaryLogic.any {
        ///     false
        ///     nil    // unknown
        ///     false
        /// }
        /// // result = nil (unknown)
        /// ```
        @resultBuilder
        public enum `Any` {
            @inlinable
            public static func buildExpression(_ expression: T) -> T {
                expression
            }

            @inlinable
            public static func buildExpression(_ expression: Bool) -> T {
                T(expression)
            }

            @inlinable
            public static func buildPartialBlock(first: T) -> T {
                first
            }

            @inlinable
            public static func buildPartialBlock(first: Void) -> T {
                .false
            }

            @inlinable
            public static func buildPartialBlock(first: Never) -> T {}

            @inlinable
            public static func buildPartialBlock(accumulated: T, next: T) -> T {
                // Strong Kleene OR: true dominates, then unknown, then false
                if T.from(accumulated) == true || T.from(next) == true {
                    return .true
                }
                if T.from(accumulated) == nil || T.from(next) == nil {
                    return .unknown
                }
                return .false
            }

            @inlinable
            public static func buildBlock() -> T {
                .false
            }

            @inlinable
            public static func buildOptional(_ component: T?) -> T {
                component ?? .unknown
            }

            @inlinable
            public static func buildEither(first: T) -> T {
                first
            }

            @inlinable
            public static func buildEither(second: T) -> T {
                second
            }

            @inlinable
            public static func buildArray(_ components: [T]) -> T {
                var hasUnknown = false
                for component in components {
                    if T.from(component) == true {
                        return .true
                    }
                    if T.from(component) == nil {
                        hasUnknown = true
                    }
                }
                return hasUnknown ? .unknown : .false
            }

            @inlinable
            public static func buildLimitedAvailability(_ component: T) -> T {
                component
            }
        }

        /// A result builder that requires no conditions to be true (Strong Kleene NOR).
        ///
        /// Returns `true` if all conditions are `false`,
        /// `unknown` if any condition is `unknown` and none are `true`,
        /// `false` if any condition is `true`.
        @resultBuilder
        public enum None {
            @inlinable
            public static func buildExpression(_ expression: T) -> T {
                expression
            }

            @inlinable
            public static func buildExpression(_ expression: Bool) -> T {
                T(expression)
            }

            @inlinable
            public static func buildPartialBlock(first: T) -> T {
                first
            }

            @inlinable
            public static func buildPartialBlock(first: Void) -> T {
                .false
            }

            @inlinable
            public static func buildPartialBlock(first: Never) -> T {}

            @inlinable
            public static func buildPartialBlock(accumulated: T, next: T) -> T {
                // Collect for OR (will be negated in buildFinalResult)
                if T.from(accumulated) == true || T.from(next) == true {
                    return .true
                }
                if T.from(accumulated) == nil || T.from(next) == nil {
                    return .unknown
                }
                return .false
            }

            @inlinable
            public static func buildBlock() -> T {
                .false
            }

            @inlinable
            public static func buildOptional(_ component: T?) -> T {
                component ?? .unknown
            }

            @inlinable
            public static func buildEither(first: T) -> T {
                first
            }

            @inlinable
            public static func buildEither(second: T) -> T {
                second
            }

            @inlinable
            public static func buildArray(_ components: [T]) -> T {
                var hasUnknown = false
                for component in components {
                    if T.from(component) == true {
                        return .true
                    }
                    if T.from(component) == nil {
                        hasUnknown = true
                    }
                }
                return hasUnknown ? .unknown : .false
            }

            @inlinable
            public static func buildLimitedAvailability(_ component: T) -> T {
                component
            }

            @inlinable
            public static func buildFinalResult(_ component: T) -> T {
                // NOR: negate the OR result
                switch T.from(component) {
                case true: return .false
                case false: return .true
                case nil: return .unknown
                }
            }
        }
    }
}

// MARK: - Convenience Entry Points

extension TernaryLogic {
    /// Returns the Strong Kleene AND of all conditions in the builder.
    ///
    /// - Returns: `false` if any is false, `nil` (unknown) if any unknown and none false, `true` if all true.
    @inlinable
    public static func all<T: TernaryLogic.`Protocol`>(@Builder<T>.All _ builder: () -> T) -> T {
        builder()
    }

    /// Returns the Strong Kleene OR of all conditions in the builder.
    ///
    /// - Returns: `true` if any is true, `nil` (unknown) if any unknown and none true, `false` if all false.
    @inlinable
    public static func any<T: TernaryLogic.`Protocol`>(@Builder<T>.`Any` _ builder: () -> T) -> T {
        builder()
    }

    /// Returns true if no conditions are true (Strong Kleene NOR).
    ///
    /// - Returns: `true` if all false, `nil` (unknown) if any unknown and none true, `false` if any true.
    @inlinable
    public static func none<T: TernaryLogic.`Protocol`>(@Builder<T>.None _ builder: () -> T) -> T {
        builder()
    }
}

// MARK: - Bool? Convenience (Type-level Entry Points)

extension Optional where Wrapped == Bool {
    /// Returns the Strong Kleene AND of all conditions in the builder.
    ///
    /// - Returns: `false` if any is false, `nil` (unknown) if any unknown and none false, `true` if all true.
    @inlinable
    public static func all(@TernaryLogic.Builder<Bool?>.All _ builder: () -> Bool?) -> Bool? {
        builder()
    }

    /// Returns the Strong Kleene OR of all conditions in the builder.
    ///
    /// - Returns: `true` if any is true, `nil` (unknown) if any unknown and none true, `false` if all false.
    @inlinable
    public static func any(@TernaryLogic.Builder<Bool?>.`Any` _ builder: () -> Bool?) -> Bool? {
        builder()
    }

    /// Returns true if no conditions are true (Strong Kleene NOR).
    ///
    /// - Returns: `true` if all false, `nil` (unknown) if any unknown and none true, `false` if any true.
    @inlinable
    public static func none(@TernaryLogic.Builder<Bool?>.None _ builder: () -> Bool?) -> Bool? {
        builder()
    }
}
