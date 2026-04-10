import Path
import XCTest
@testable import FileSystem

#if !os(Windows)
    final class SwiftFileSystemBackendTests: XCTestCase, @unchecked Sendable {
        private var subject: FileSystem!

        override func setUp() async throws {
            try await super.setUp()
            subject = FileSystem(
                environmentVariables: ["TUIST_FILESYSTEM_BACKEND": "swift-file-system"]
            )
        }

        override func tearDown() async throws {
            subject = nil
            try await super.tearDown()
        }

        func test_roundTripsTextAndMetadata() async throws {
            try await subject.runInTemporaryDirectory(prefix: "SwiftFileSystemBackend") { temporaryDirectory in
                let filePath = temporaryDirectory.appending(component: "file.txt")

                try await subject.writeText("hello", at: filePath)

                let text = try await subject.readTextFile(at: filePath)
                let metadata = try await subject.fileMetadata(at: filePath)

                XCTAssertEqual(text, "hello")
                XCTAssertEqual(metadata?.size, 5)
            }
        }

        func test_listsCopiesMovesAndRemovesFiles() async throws {
            try await subject.runInTemporaryDirectory(prefix: "SwiftFileSystemBackend") { temporaryDirectory in
                let sourceDirectory = temporaryDirectory.appending(component: "source")
                let copiedDirectory = temporaryDirectory.appending(component: "copied")
                let movedFile = temporaryDirectory.appending(component: "moved.txt")
                let sourceFile = sourceDirectory.appending(component: "file.txt")
                let copiedFile = copiedDirectory.appending(component: "file.txt")

                try await subject.makeDirectory(at: sourceDirectory)
                try await subject.writeText("hello", at: sourceFile)

                let contents = try await subject.contentsOfDirectory(sourceDirectory)
                XCTAssertEqual(contents, [sourceFile])

                try await subject.copy(sourceDirectory, to: copiedDirectory)
                let copiedFileExists = try await subject.exists(copiedFile)
                XCTAssertTrue(copiedFileExists)

                try await subject.move(from: copiedFile, to: movedFile)
                let movedFileExists = try await subject.exists(movedFile)
                XCTAssertTrue(movedFileExists)

                try await subject.remove(movedFile)
                let removedFileExists = try await subject.exists(movedFile)
                XCTAssertFalse(removedFileExists)
            }
        }

        func test_createsAndResolvesRelativeSymbolicLinks() async throws {
            try await subject.runInTemporaryDirectory(prefix: "SwiftFileSystemBackend") { temporaryDirectory in
                let targetDirectory = temporaryDirectory.appending(component: "target")
                let targetFile = targetDirectory.appending(component: "file.txt")
                let symbolicLink = temporaryDirectory.appending(component: "link")

                try await subject.makeDirectory(at: targetDirectory)
                try await subject.writeText("hello", at: targetFile)

                try await subject.createSymbolicLink(
                    from: symbolicLink,
                    to: try RelativePath(validating: "target/file.txt")
                )

                let resolved = try await subject.resolveSymbolicLink(symbolicLink)
                XCTAssertEqual(resolved, targetFile)
            }
        }
    }
#endif
