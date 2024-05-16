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
        let temporaryDirectory = try await subject.makeTemporaryDirectory(prefix: "FileSystem")

        // When
        let exists = try await subject.exists(temporaryDirectory)
        XCTAssertTrue(exists)
        let firstExists = try await subject.exists(temporaryDirectory, isDirectory: true)
        XCTAssertTrue(firstExists)
        let secondExists = try await subject.exists(temporaryDirectory, isDirectory: false)
        XCTAssertFalse(secondExists)
    }

    func test_runInTemporaryDirectory_removesTheDirectoryAfterSuccessfulCompletion() async throws {
        // Given/When
        let temporaryDirectory = try await subject.runInTemporaryDirectory(prefix: "FileSystem") { temporaryDirectory in
            try await subject.touch(temporaryDirectory.appending(component: "test"))
            return temporaryDirectory
        }

        // Then
        let exists = try await subject.exists(temporaryDirectory)
        XCTAssertFalse(exists)
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

    func test_move_when_fromFileExistsAndToPathsParentDirectoryExists() async throws {
        try await subject.runInTemporaryDirectory(prefix: "FileSystem") { temporaryDirectory in
            // Given
            let fromFilePath = temporaryDirectory.appending(component: "from")
            try await subject.touch(fromFilePath)
            let toFilePath = temporaryDirectory.appending(component: "to")

            // When
            try await subject.move(from: fromFilePath, to: toFilePath)

            // Then
            let exists = try await subject.exists(toFilePath)
            XCTAssertTrue(exists)
        }
    }

    func test_move_throwsAMoveNotFoundError_when_fromFileDoesntExist() async throws {
        try await subject.runInTemporaryDirectory(prefix: "FileSystem") { temporaryDirectory in
            // Given
            let fromFilePath = temporaryDirectory.appending(component: "from")
            let toFilePath = temporaryDirectory.appending(component: "to")

            // When
            var _error: FileSystemError?
            do {
                try await subject.move(from: fromFilePath, to: toFilePath)
            } catch {
                _error = error as? FileSystemError
            }

            // Then
            XCTAssertEqual(_error, FileSystemError.moveNotFound(from: fromFilePath, to: toFilePath))
        }
    }

    func test_makeDirectory_createsTheDirectory() async throws {
        try await subject.runInTemporaryDirectory(prefix: "FileSystem") { temporaryDirectory in
            // Given
            let directoryPath = temporaryDirectory.appending(component: "to")

            // When
            try await subject.makeDirectory(at: directoryPath)

            // Then
            let exists = try await subject.exists(directoryPath)
            XCTAssertTrue(exists)
        }
    }

    func test_makeDirectory_createsTheParentDirectories() async throws {
        try await subject.runInTemporaryDirectory(prefix: "FileSystem") { temporaryDirectory in
            // Given
            let directoryPath = temporaryDirectory.appending(component: "first").appending(component: "second")

            // When
            try await subject.makeDirectory(at: directoryPath)

            // Then
            let exists = try await subject.exists(directoryPath)
            XCTAssertTrue(exists)
        }
    }

    func test_makeDirectory_throwsAnError_when_parentDirectoryDoesntExist() async throws {
        try await subject.runInTemporaryDirectory(prefix: "FileSystem") { temporaryDirectory in
            // Given
            let directoryPath = temporaryDirectory.appending(component: "first").appending(component: "second")

            // When
            var _error: FileSystemError?
            do {
                try await subject.makeDirectory(at: directoryPath, options: [])
            } catch {
                _error = error as? FileSystemError
            }

            // Then
            XCTAssertEqual(_error, FileSystemError.makeDirectoryAbsentParent(directoryPath))
        }
    }

    func test_readTextFile_returnsTheContent() async throws {
//        try await subject.runInTemporaryDirectory(prefix: "FileSystem") { temporaryDirectory in
//            // Given
//            let filePath = temporaryDirectory.appending(component: "file")
//            try await "test".write(toFileAt: .init(filePath.pathString))
//
//            // When
//            let got = try await subject.readTextFile(at: filePath)
//
//            // Then
//            XCTAssertEqual(got, "test")
//        }
    }
}
