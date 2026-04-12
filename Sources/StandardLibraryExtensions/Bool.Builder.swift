extension Bool {
    /// Namespace for boolean result builders.
    public enum Builder {
        /// A result builder that combines boolean conditions with AND semantics.
        ///
        /// Use `Bool.all` to check that all conditions are true.
        /// Short-circuits on the first false value.
        ///
        /// ```swift
        /// let isValid = Bool.all {
        ///     user.isAuthenticated
        ///     user.hasPermission
        ///     !resource.isLocked
        /// }
        /// ```
        @resultBuilder
        public enum All {
            // MARK: - Expression Building

            @inlinable
            public static func buildExpression(_ expression: Bool) -> Bool {
                expression
            }

            // MARK: - Partial Block Building

            @inlinable
            public static func buildPartialBlock(first: Bool) -> Bool {
                first
            }

            @inlinable
            public static func buildPartialBlock(first: Void) -> Bool {
                true
            }

            @inlinable
            public static func buildPartialBlock(first: Never) -> Bool {}

            @inlinable
            public static func buildPartialBlock(accumulated: Bool, next: Bool) -> Bool {
                accumulated && next
            }

            // MARK: - Block Building

            @inlinable
            public static func buildBlock() -> Bool {
                true
            }

            // MARK: - Control Flow

            @inlinable
            public static func buildOptional(_ component: Bool?) -> Bool {
                component ?? true
            }

            @inlinable
            public static func buildEither(first: Bool) -> Bool {
                first
            }

            @inlinable
            public static func buildEither(second: Bool) -> Bool {
                second
            }

            @inlinable
            public static func buildArray(_ components: [Bool]) -> Bool {
                components.allSatisfy { $0 }
            }

            @inlinable
            public static func buildLimitedAvailability(_ component: Bool) -> Bool {
                component
            }
        }

        /// A result builder that combines boolean conditions with OR semantics.
        ///
        /// Use `Bool.any` to check that at least one condition is true.
        /// Short-circuits on the first true value.
        ///
        /// ```swift
        /// let canAccess = Bool.any {
        ///     user.isAdmin
        ///     user.isOwner
        ///     resource.isPublic
        /// }
        /// ```
        @resultBuilder
        public enum `Any` {
            // MARK: - Expression Building

            @inlinable
            public static func buildExpression(_ expression: Bool) -> Bool {
                expression
            }

            // MARK: - Partial Block Building

            @inlinable
            public static func buildPartialBlock(first: Bool) -> Bool {
                first
            }

            @inlinable
            public static func buildPartialBlock(first: Void) -> Bool {
                false
            }

            @inlinable
            public static func buildPartialBlock(first: Never) -> Bool {}

            @inlinable
            public static func buildPartialBlock(accumulated: Bool, next: Bool) -> Bool {
                accumulated || next
            }

            // MARK: - Block Building

            @inlinable
            public static func buildBlock() -> Bool {
                false
            }

            // MARK: - Control Flow

            @inlinable
            public static func buildOptional(_ component: Bool?) -> Bool {
                component ?? false
            }

            @inlinable
            public static func buildEither(first: Bool) -> Bool {
                first
            }

            @inlinable
            public static func buildEither(second: Bool) -> Bool {
                second
            }

            @inlinable
            public static func buildArray(_ components: [Bool]) -> Bool {
                components.contains(true)
            }

            @inlinable
            public static func buildLimitedAvailability(_ component: Bool) -> Bool {
                component
            }
        }

        /// A result builder that counts how many conditions are true.
        ///
        /// Use `Bool.count` to count true conditions.
        ///
        /// ```swift
        /// let trueCount = Bool.count {
        ///     condition1
        ///     condition2
        ///     condition3
        /// }
        /// ```
        @resultBuilder
        public enum Count {
            // MARK: - Expression Building

            @inlinable
            public static func buildExpression(_ expression: Bool) -> Int {
                expression ? 1 : 0
            }

            // MARK: - Partial Block Building

            @inlinable
            public static func buildPartialBlock(first: Int) -> Int {
                first
            }

            @inlinable
            public static func buildPartialBlock(first: Void) -> Int {
                0
            }

            @inlinable
            public static func buildPartialBlock(first: Never) -> Int {}

            @inlinable
            public static func buildPartialBlock(accumulated: Int, next: Int) -> Int {
                accumulated + next
            }

            // MARK: - Block Building

            @inlinable
            public static func buildBlock() -> Int {
                0
            }

            // MARK: - Control Flow

            @inlinable
            public static func buildOptional(_ component: Int?) -> Int {
                component ?? 0
            }

            @inlinable
            public static func buildEither(first: Int) -> Int {
                first
            }

            @inlinable
            public static func buildEither(second: Int) -> Int {
                second
            }

            @inlinable
            public static func buildArray(_ components: [Int]) -> Int {
                components.reduce(0, +)
            }

            @inlinable
            public static func buildLimitedAvailability(_ component: Int) -> Int {
                component
            }
        }

        /// A result builder that requires exactly one condition to be true.
        ///
        /// Use `Bool.one` for XOR-like semantics.
        ///
        /// ```swift
        /// let exactlyOne = Bool.one {
        ///     option1Selected
        ///     option2Selected
        ///     option3Selected
        /// }
        /// ```
        @resultBuilder
        public enum One {
            // MARK: - Expression Building

            @inlinable
            public static func buildExpression(_ expression: Bool) -> Int {
                expression ? 1 : 0
            }

            // MARK: - Partial Block Building

            @inlinable
            public static func buildPartialBlock(first: Int) -> Int {
                first
            }

            @inlinable
            public static func buildPartialBlock(first: Void) -> Int {
                0
            }

            @inlinable
            public static func buildPartialBlock(first: Never) -> Int {}

            @inlinable
            public static func buildPartialBlock(accumulated: Int, next: Int) -> Int {
                accumulated + next
            }

            // MARK: - Block Building

            @inlinable
            public static func buildBlock() -> Int {
                0
            }

            // MARK: - Control Flow

            @inlinable
            public static func buildOptional(_ component: Int?) -> Int {
                component ?? 0
            }

            @inlinable
            public static func buildEither(first: Int) -> Int {
                first
            }

            @inlinable
            public static func buildEither(second: Int) -> Int {
                second
            }

            @inlinable
            public static func buildArray(_ components: [Int]) -> Int {
                components.reduce(0, +)
            }

            @inlinable
            public static func buildLimitedAvailability(_ component: Int) -> Int {
                component
            }

            @inlinable
            public static func buildFinalResult(_ component: Int) -> Bool {
                component == 1
            }
        }

        /// A result builder that requires no conditions to be true.
        ///
        /// Use `Bool.none` to ensure all conditions are false.
        ///
        /// ```swift
        /// let noneSelected = Bool.none {
        ///     option1
        ///     option2
        ///     option3
        /// }
        /// ```
        @resultBuilder
        public enum None {
            // MARK: - Expression Building

            @inlinable
            public static func buildExpression(_ expression: Bool) -> Bool {
                !expression
            }

            // MARK: - Partial Block Building

            @inlinable
            public static func buildPartialBlock(first: Bool) -> Bool {
                first
            }

            @inlinable
            public static func buildPartialBlock(first: Void) -> Bool {
                true
            }

            @inlinable
            public static func buildPartialBlock(first: Never) -> Bool {}

            @inlinable
            public static func buildPartialBlock(accumulated: Bool, next: Bool) -> Bool {
                accumulated && next
            }

            // MARK: - Block Building

            @inlinable
            public static func buildBlock() -> Bool {
                true
            }

            // MARK: - Control Flow

            @inlinable
            public static func buildOptional(_ component: Bool?) -> Bool {
                component ?? true
            }

            @inlinable
            public static func buildEither(first: Bool) -> Bool {
                first
            }

            @inlinable
            public static func buildEither(second: Bool) -> Bool {
                second
            }

            @inlinable
            public static func buildArray(_ components: [Bool]) -> Bool {
                components.allSatisfy { $0 }
            }

            @inlinable
            public static func buildLimitedAvailability(_ component: Bool) -> Bool {
                component
            }
        }
    }
}

// MARK: - Convenience Entry Points

extension Bool {
    /// Returns true if all conditions in the builder are true (AND semantics).
    @inlinable
    public static func all(@Builder.All _ builder: () -> Bool) -> Bool {
        builder()
    }

    /// Returns true if any condition in the builder is true (OR semantics).
    @inlinable
    public static func any(@Builder.`Any` _ builder: () -> Bool) -> Bool {
        builder()
    }

    /// Returns the count of true conditions in the builder.
    @inlinable
    public static func count(@Builder.Count _ builder: () -> Int) -> Int {
        builder()
    }

    /// Returns true if exactly one condition in the builder is true (XOR semantics).
    @inlinable
    public static func one(@Builder.One _ builder: () -> Bool) -> Bool {
        builder()
    }

    /// Returns true if no conditions in the builder are true (NOR semantics).
    @inlinable
    public static func none(@Builder.None _ builder: () -> Bool) -> Bool {
        builder()
    }
}
