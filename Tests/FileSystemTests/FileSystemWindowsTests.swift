#if os(Windows)
import Path
import XCTest
@testable import FileSystem

final class FileSystemWindowsTests: XCTestCase, @unchecked Sendable {
    var subject: FileSystem!

    override func setUp() async throws {
        try await super.setUp()
        subject = FileSystem()
    }

    override func tearDown() async throws {
        subject = nil
        try await super.tearDown()
    }

    func test_exists_returnsTrueForDirectoryAndFalseForFileFlag() async throws {
        let temporaryDirectory = try await subject.makeTemporaryDirectory(prefix: "FileSystem")

        let exists = try await subject.exists(temporaryDirectory)
        XCTAssertTrue(exists)
        let isDirectory = try await subject.exists(temporaryDirectory, isDirectory: true)
        XCTAssertTrue(isDirectory)
        let isFile = try await subject.exists(temporaryDirectory, isDirectory: false)
        XCTAssertFalse(isFile)
    }

    func test_exists_returnsTrueForFile() async throws {
        let temporaryDirectory = try await subject.makeTemporaryDirectory(prefix: "FileSystem")
        let file = temporaryDirectory.appending(component: "file.txt")
        try await subject.touch(file)

        let exists = try await subject.exists(file)
        XCTAssertTrue(exists)
        let isFile = try await subject.exists(file, isDirectory: false)
        XCTAssertTrue(isFile)
        let isDirectory = try await subject.exists(file, isDirectory: true)
        XCTAssertFalse(isDirectory)
    }

    func test_exists_returnsFalseForMissingPath() async throws {
        let temporaryDirectory = try await subject.makeTemporaryDirectory(prefix: "FileSystem")
        let missing = temporaryDirectory.appending(component: "missing")

        let exists = try await subject.exists(missing)
        XCTAssertFalse(exists)
    }
}
#endif
