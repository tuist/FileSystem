extension Result {
    /// Namespace for Result builders.
    public enum Builder {
        /// A result builder that chains fallible operations, returning the first success.
        ///
        /// Use `Result.first` to try multiple operations in sequence, returning the first
        /// successful result. If all operations fail, returns the last failure.
        ///
        /// ```swift
        /// let result: Result<Data, Error> = Result.first {
        ///     try loadFromCache()
        ///     try loadFromDisk()
        ///     try loadFromNetwork()
        /// }
        /// ```
        ///
        /// The builder short-circuits: once a success is found, subsequent operations
        /// are not evaluated.
        @resultBuilder
        public enum First {
            // MARK: - Expression Building

            @inlinable
            public static func buildExpression(_ expression: Success) -> Result<Success, Failure> {
                .success(expression)
            }

            @inlinable
            public static func buildExpression(
                _ expression: Result<Success, Failure>
            ) -> Result<Success, Failure> {
                expression
            }

            // MARK: - Partial Block Building

            @inlinable
            public static func buildPartialBlock(
                first: Result<Success, Failure>
            ) -> Result<Success, Failure> {
                first
            }

            @inlinable
            public static func buildPartialBlock(
                first: Result<Success, Failure>?
            ) -> Result<Success, Failure>? {
                first
            }

            @inlinable
            public static func buildPartialBlock(first: Void) -> Result<Success, Failure>? {
                nil
            }

            @inlinable
            public static func buildPartialBlock(first: Never) -> Result<Success, Failure> {}

            @inlinable
            public static func buildPartialBlock(
                accumulated: Result<Success, Failure>,
                next: Result<Success, Failure>
            ) -> Result<Success, Failure> {
                switch accumulated {
                case .success:
                    accumulated
                case .failure:
                    next
                }
            }

            @inlinable
            public static func buildPartialBlock(
                accumulated: Result<Success, Failure>,
                next: Result<Success, Failure>?
            ) -> Result<Success, Failure> {
                switch accumulated {
                case .success:
                    accumulated
                case .failure:
                    next ?? accumulated
                }
            }

            // MARK: - Control Flow

            @inlinable
            public static func buildOptional(
                _ component: Result<Success, Failure>?
            ) -> Result<Success, Failure>? {
                component
            }

            @inlinable
            public static func buildEither(
                first: Result<Success, Failure>
            ) -> Result<Success, Failure> {
                first
            }

            @inlinable
            public static func buildEither(
                second: Result<Success, Failure>
            ) -> Result<Success, Failure> {
                second
            }

            @inlinable
            public static func buildArray(
                _ components: [Result<Success, Failure>]
            ) -> Result<Success, Failure>? {
                var lastFailure: Result<Success, Failure>?
                for component in components {
                    switch component {
                    case .success:
                        return component
                    case .failure:
                        lastFailure = component
                    }
                }
                return lastFailure
            }

            @inlinable
            public static func buildLimitedAvailability(
                _ component: Result<Success, Failure>
            ) -> Result<Success, Failure> {
                component
            }
        }

        /// A result builder that collects all successes into an array.
        ///
        /// Use `Result.all` to collect all successful results. If any operation fails,
        /// returns the first failure encountered.
        ///
        /// ```swift
        /// let results: Result<[User], Error> = Result.all {
        ///     try fetchUser(id: 1)
        ///     try fetchUser(id: 2)
        ///     try fetchUser(id: 3)
        /// }
        /// ```
        @resultBuilder
        public enum All {
            // MARK: - Expression Building

            @inlinable
            public static func buildExpression(_ expression: Success) -> Result<[Success], Failure>
            {
                .success([expression])
            }

            @inlinable
            public static func buildExpression(
                _ expression: Result<Success, Failure>
            ) -> Result<[Success], Failure> {
                expression.map { [$0] }
            }

            // MARK: - Partial Block Building

            @inlinable
            public static func buildPartialBlock(
                first: Result<[Success], Failure>
            ) -> Result<[Success], Failure> {
                first
            }

            @inlinable
            public static func buildPartialBlock(first: Void) -> Result<[Success], Failure> {
                .success([])
            }

            @inlinable
            public static func buildPartialBlock(first: Never) -> Result<[Success], Failure> {}

            @inlinable
            public static func buildPartialBlock(
                accumulated: Result<[Success], Failure>,
                next: Result<[Success], Failure>
            ) -> Result<[Success], Failure> {
                switch (accumulated, next) {
                case (.success(let accValues), .success(let nextValues)):
                    .success(accValues + nextValues)
                case (.failure(let error), _):
                    .failure(error)
                case (_, .failure(let error)):
                    .failure(error)
                }
            }

            // MARK: - Block Building

            @inlinable
            public static func buildBlock() -> Result<[Success], Failure> {
                .success([])
            }

            // MARK: - Control Flow

            @inlinable
            public static func buildOptional(
                _ component: Result<[Success], Failure>?
            ) -> Result<[Success], Failure> {
                component ?? .success([])
            }

            @inlinable
            public static func buildEither(
                first: Result<[Success], Failure>
            ) -> Result<[Success], Failure> {
                first
            }

            @inlinable
            public static func buildEither(
                second: Result<[Success], Failure>
            ) -> Result<[Success], Failure> {
                second
            }

            @inlinable
            public static func buildArray(
                _ components: [Result<[Success], Failure>]
            ) -> Result<[Success], Failure> {
                var collected: [Success] = []
                for component in components {
                    switch component {
                    case .success(let values):
                        collected.append(contentsOf: values)
                    case .failure(let error):
                        return .failure(error)
                    }
                }
                return .success(collected)
            }

            @inlinable
            public static func buildLimitedAvailability(
                _ component: Result<[Success], Failure>
            ) -> Result<[Success], Failure> {
                component
            }
        }
    }
}

// MARK: - Convenience Entry Points

extension Result {
    @inlinable
    public static func first(
        @Builder.First _ builder: () -> Result<Success, Failure>
    ) -> Result<Success, Failure> {
        builder()
    }

    @inlinable
    public static func first(
        @Builder.First _ builder: () -> Result<Success, Failure>?
    ) -> Result<Success, Failure>? {
        builder()
    }

    @inlinable
    public static func all(
        @Builder.All _ builder: () -> Result<[Success], Failure>
    ) -> Result<[Success], Failure> {
        builder()
    }
}
