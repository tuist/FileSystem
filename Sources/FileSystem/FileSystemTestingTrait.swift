#if DEBUG && canImport(Testing)
    import Path
    import Testing

    extension FileSystem {
        /// It returns the temporary directory created when using the `@Test(.inTemporaryDirectory)`.
        /// Note that since the value is only propagated through Swift structured concurrency, if you use DispatchQueue,
        /// values won't be propagated so you'll have to make sure they are explicitly passed down.
        @TaskLocal public static var temporaryTestDirectory: AbsolutePath?
    }

    public struct FileSystemTestingTrait: TestTrait, SuiteTrait, TestScoping {
        public func provideScope(
            for _: Test,
            testCase _: Test.Case?,
            performing function: @Sendable () async throws -> Void
        ) async throws {
            try await FileSystem().runInTemporaryDirectory { temporaryDirectory in
                try await FileSystem.$temporaryTestDirectory.withValue(temporaryDirectory) {
                    try await function()
                }
            }
        }
    }

    extension Trait where Self == FileSystemTestingTrait {
        /// Creates a temporary directory and scopes its lifecycle to the lifecycle of the test.
        public static var inTemporaryDirectory: Self { Self() }
    }

#endif
