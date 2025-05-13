import FileSystem
import Testing

struct FileSystemTestingTraitTests {
    @Test(.inTemporaryDirectory) func testTemporaryDirectory() async throws {
        // Given
        let temporaryDirectory = try #require(FileSystem.testTemporaryDirectory)
        let filePath = temporaryDirectory.appending(component: "test")

        // Then
        try await FileSystem().touch(filePath)
    }
}
