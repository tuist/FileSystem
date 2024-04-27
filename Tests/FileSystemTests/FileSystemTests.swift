import XCTest
@testable import FileSystem

final class FileSystemTests: XCTestCase {
    var subject: FileSystem!

    override func setUp() async throws {
        try await super.setUp()
        subject = FileSystem()
    }

    override func tearDown() async throws {
        subject = nil
        try await super.tearDown()
    }

    func test_createTemporaryDirectory_returnsAValidDirectory() async throws {
        // Given
        let temporaryDirectory = try subject.createTemporaryDirectory(prefix: "FileSystem")

        // When
        XCTAssertTrue(subject.exists(temporaryDirectory))
        XCTAssertTrue(subject.exists(temporaryDirectory, isDirectory: true))
        XCTAssertFalse(subject.exists(temporaryDirectory, isDirectory: false))
    }
}
