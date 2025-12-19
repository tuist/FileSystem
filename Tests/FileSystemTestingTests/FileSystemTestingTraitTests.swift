#if !os(Windows)
    import FileSystem
    import FileSystemTesting
    import Testing

    struct FileSystemTestingTraitTests {
        @Test(.inTemporaryDirectory) func testTemporaryDirectory() async throws {
            // Given
            let temporaryDirectory = try #require(FileSystem.temporaryTestDirectory)
            let filePath = temporaryDirectory.appending(component: "test")

            // Then
            try await FileSystem().touch(filePath)
        }
    }
#endif
