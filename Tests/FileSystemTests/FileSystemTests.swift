import Path
import XCTest
@testable import FileSystem

private struct TestError: Error, Equatable {}

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

    func test_runInTemporaryDirectory_removesTheDirectoryAfterSuccessfulCompletion() async throws {
        // Given/When
        let temporaryDirectory = try await subject.runInTemporaryDirectory(prefix: "FileSystem") { temporaryDirectory in
            try subject.touch(temporaryDirectory.appending(component: "test"))
            return temporaryDirectory
        }

        // Then
        XCTAssertFalse(subject.exists(temporaryDirectory))
    }

    func test_runInTemporaryDirectory_rethrowsErrors() async throws {
        // Given/When
        var caughtError: Error?
        do {
            try await subject.runInTemporaryDirectory(prefix: "FileSystem") { _ in
                throw TestError()
            }
        } catch {
            caughtError = error
        }

        // Then
        XCTAssertEqual(caughtError as? TestError, TestError())
    }
}
