import Path
import XCTest
@testable import FileSystem

private struct TestError: Error, Equatable {}

final class FileSystemTests: XCTestCase, @unchecked Sendable {
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

    func test_currentWorkingDirectory() async throws {
        // When
        let got = try await subject.currentWorkingDirectory()

        // Then
        let isDirectory = try await subject.exists(got, isDirectory: true)
        XCTAssertTrue(isDirectory)
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

    func test_writeTextFile_and_readTextFile_returnsTheContent() async throws {
        try await subject.runInTemporaryDirectory(prefix: "FileSystem") { temporaryDirectory in
            // Given
            let filePath = temporaryDirectory.appending(component: "file")
            try await subject.writeText("test", at: filePath)

            // When
            let got = try await subject.readTextFile(at: filePath)

            // Then
            XCTAssertEqual(got, "test")
        }
    }

    func test_writeAsJSON_and_readJSONFile_returnsTheContent() async throws {
        struct CodableStruct: Codable, Equatable { let name: String }

        try await subject.runInTemporaryDirectory(prefix: "FileSystem") { temporaryDirectory in
            // Given
            let item = CodableStruct(name: "tuist")
            let filePath = temporaryDirectory.appending(component: "file")
            try await subject.writeAsJSON(item, at: filePath)

            // When
            let got: CodableStruct = try await subject.readJSONFile(at: filePath)

            // Then
            XCTAssertEqual(got, item)
        }
    }

    func test_writeAsPlist_and_readPlistFile_returnsTheContent() async throws {
        struct CodableStruct: Codable, Equatable { let name: String }

        try await subject.runInTemporaryDirectory(prefix: "FileSystem") { temporaryDirectory in
            // Given
            let item = CodableStruct(name: "tuist")
            let filePath = temporaryDirectory.appending(component: "file")
            try await subject.writeAsPlist(item, at: filePath)

            // When
            let got: CodableStruct = try await subject.readPlistFile(at: filePath)

            // Then
            XCTAssertEqual(got, item)
        }
    }

    func test_fileSizeInBytes_returnsTheFileSize_when_itExists() async throws {
        try await subject.runInTemporaryDirectory(prefix: "FileSystem") { temporaryDirectory in
            // Given
            let path = temporaryDirectory.appending(component: "file")
            try await subject.writeText("tuist", at: path)

            // When
            let size = try await subject.fileSizeInBytes(at: path)

            // Then
            XCTAssertEqual(size, 5)
        }
    }

    func test_fileSizeInBytes_returnsNil_when_theFileDoesntExist() async throws {
        try await subject.runInTemporaryDirectory(prefix: "FileSystem") { temporaryDirectory in
            // Given
            let path = temporaryDirectory.appending(component: "file")

            // When
            let size = try await subject.fileSizeInBytes(at: path)

            // Then
            XCTAssertNil(size)
        }
    }

    func test_replace_replaces_when_replacingPathIsADirectory_and_targetDirectoryIsAbsent() async throws {
        try await subject.runInTemporaryDirectory(prefix: "FileSystem") { temporaryDirectory in
            // Given
            let replacedPath = temporaryDirectory.appending(component: "replaced")
            let replacingPath = temporaryDirectory.appending(component: "replacing")
            try await subject.makeDirectory(at: replacingPath)
            let replacingFilePath = replacingPath.appending(component: "file")
            try await subject.touch(replacingFilePath)

            // When
            try await subject.replace(replacedPath, with: replacingPath)

            // Then
            let exists = try await subject.exists(replacedPath.appending(component: "file"))
            XCTAssertTrue(exists)
        }
    }

    func test_replace_replaces_when_replacingPathIsADirectory_and_targetDirectoryIsPresent() async throws {
        try await subject.runInTemporaryDirectory(prefix: "FileSystem") { temporaryDirectory in
            // Given
            let replacedPath = temporaryDirectory.appending(component: "replaced")
            let replacingPath = temporaryDirectory.appending(component: "replacing")
            try await subject.makeDirectory(at: replacedPath)
            try await subject.makeDirectory(at: replacingPath)
            let replacingFilePath = replacingPath.appending(component: "file")
            try await subject.touch(replacingFilePath)

            // When
            try await subject.replace(replacedPath, with: replacingPath)

            // Then
            let exists = try await subject.exists(replacedPath.appending(component: "file"))
            XCTAssertTrue(exists)
        }
    }

    func test_replace_replaces_when_replacingPathDoesntExist() async throws {
        try await subject.runInTemporaryDirectory(prefix: "FileSystem") { temporaryDirectory in
            // Given
            let replacedPath = temporaryDirectory.appending(component: "replaced")
            let replacingPath = temporaryDirectory.appending(component: "replacing")
            try await subject.makeDirectory(at: replacedPath)
            try await subject.makeDirectory(at: replacingPath)
            let replacingFilePath = replacingPath.appending(component: "file")
            let replacedFilePath = replacedPath.appending(component: "file")

            // When
            var _error: FileSystemError?
            do {
                try await subject.replace(replacedFilePath, with: replacingFilePath)
            } catch {
                _error = error as? FileSystemError
            }

            // Then
            XCTAssertEqual(
                _error,
                FileSystemError.replacingItemAbsent(replacingPath: replacingFilePath, replacedPath: replacedFilePath)
            )
        }
    }

    func test_replace_createsTheReplacedPathParentDirectoryIfAbsent() async throws {
        try await subject.runInTemporaryDirectory(prefix: "FileSystem") { temporaryDirectory in
            // Given
            let replacedPath = temporaryDirectory.appending(component: "replaced")
            let replacingPath = temporaryDirectory.appending(component: "replacing")
            try await subject.makeDirectory(at: replacingPath)
            let replacingFilePath = replacingPath.appending(component: "file")
            let replacedFilePath = replacedPath.appending(component: "file")
            try await subject.touch(replacingFilePath)

            // When
            try await subject.replace(replacedFilePath, with: replacingFilePath)

            // Then
            let exists = try await subject.exists(replacedFilePath)
            XCTAssertTrue(exists)
        }
    }

    func test_copy_copiesASourceItemToATargetPath() async throws {
        try await subject.runInTemporaryDirectory(prefix: "FileSystem") { temporaryDirectory in
            // Given
            let fromPath = temporaryDirectory.appending(component: "from")
            let toPath = temporaryDirectory.appending(component: "to")
            try await subject.touch(fromPath)

            // When
            try await subject.copy(fromPath, to: toPath)

            // Then
            let exists = try await subject.exists(toPath)
            XCTAssertTrue(exists)
        }
    }

    func test_copy_createsTargetParentDirectoriesIfNeeded() async throws {
        try await subject.runInTemporaryDirectory(prefix: "FileSystem") { temporaryDirectory in
            // Given
            let fromPath = temporaryDirectory.appending(component: "from")
            let toPath = temporaryDirectory.appending(components: ["directory", "to"])
            try await subject.touch(fromPath)

            // When
            try await subject.copy(fromPath, to: toPath)

            // Then
            let exists = try await subject.exists(toPath)
            XCTAssertTrue(exists)
        }
    }

    func test_copy_errorsIfTheSourceItemDoesntExist() async throws {
        try await subject.runInTemporaryDirectory(prefix: "FileSystem") { temporaryDirectory in
            // Given
            let fromPath = temporaryDirectory.appending(component: "from")
            let toPath = temporaryDirectory.appending(component: "to")

            // When
            var _error: FileSystemError?
            do {
                try await subject.copy(fromPath, to: toPath)
            } catch {
                _error = error as? FileSystemError
            }

            // Then
            XCTAssertEqual(_error, FileSystemError.copiedItemAbsent(copiedPath: fromPath, intoPath: toPath))
        }
    }

    func test_locateTraversingUp_whenAnItemIsFound() async throws {
        try await subject.runInTemporaryDirectory(prefix: "FileSystem") { temporaryDirectory in
            // Given
            let fileToLookUp = temporaryDirectory.appending(component: "FileSystem.swift")
            try await self.subject.touch(fileToLookUp)
            let veryNestedDirectory = temporaryDirectory.appending(components: ["first", "second", "third"])

            // When
            let got = try await subject.locateTraversingUp(
                from: veryNestedDirectory,
                relativePath: try RelativePath(validating: "FileSystem.swift")
            )

            // Then
            XCTAssertEqual(got, fileToLookUp)
        }
    }

    func test_locateTraversingUp_whenAnItemIsNotFound() async throws {
        try await subject.runInTemporaryDirectory(prefix: "FileSystem") { temporaryDirectory in
            // Given
            let veryNestedDirectory = temporaryDirectory.appending(components: ["first", "second", "third"])

            // When
            let got = try await subject.locateTraversingUp(
                from: veryNestedDirectory,
                relativePath: try RelativePath(validating: "FileSystem.swift")
            )

            // Then
            XCTAssertNil(got)
        }
    }

    func test_createSymbolicLink() async throws {
        try await subject.runInTemporaryDirectory(prefix: "FileSystem") { temporaryDirectory in
            // Given
            let filePath = temporaryDirectory.appending(component: "file")
            let symbolicLinkPath = temporaryDirectory.appending(component: "symbolic")
            try await subject.touch(filePath)

            // When
            try await subject.createSymbolicLink(from: symbolicLinkPath, to: filePath)
            let got = try await subject.resolveSymbolicLink(symbolicLinkPath)

            // Then
            XCTAssertEqual(got, filePath)
        }
    }

    func test_createSymbolicLink_whenTheSymbolicLinkDoesntExist() async throws {
        try await subject.runInTemporaryDirectory(prefix: "FileSystem") { temporaryDirectory in
            // Given
            let filePath = temporaryDirectory.appending(component: "file")
            let symbolicLinkPath = temporaryDirectory.appending(component: "symbolic")
            try await subject.touch(filePath)

            // When
            var _error: FileSystemError?
            do {
                _ = try await subject.resolveSymbolicLink(symbolicLinkPath)
            } catch {
                _error = error as? FileSystemError
            }

            // Then
            XCTAssertEqual(_error, FileSystemError.absentSymbolicLink(symbolicLinkPath))
        }
    }

    func test_resolveSymbolicLink_whenThePathIsNotASymbolicLink() async throws {
        try await subject.runInTemporaryDirectory(prefix: "FileSystem") { temporaryDirectory in
            // Given
            let directoryPath = temporaryDirectory.appending(component: "symbolic")
            try await subject.makeDirectory(at: directoryPath)

            // When
            let got = try await subject.resolveSymbolicLink(directoryPath)

            // Then
            XCTAssertEqual(got, directoryPath)
        }
    }

    func test_zipping() async throws {
        try await subject.runInTemporaryDirectory(prefix: "FileSystem") { temporaryDirectory in
            // Given
            let filePath = temporaryDirectory.appending(component: "file")
            let zipPath = temporaryDirectory.appending(component: "file.zip")
            let unzippedPath = temporaryDirectory.appending(component: "unzipped")
            try await subject.makeDirectory(at: unzippedPath)
            try await subject.touch(filePath)

            // When
            try await subject.zipFileOrDirectoryContent(at: filePath, to: zipPath)
            try await subject.unzip(zipPath, to: unzippedPath)

            // Then
            let exists = try await subject.exists(unzippedPath.appending(component: "file"))
            XCTAssertTrue(exists)
        }
    }

    func test_glob_component_wildcard() async throws {
        try await subject.runInTemporaryDirectory(prefix: "FileSystem") { temporaryDirectory in
            // Given
            let firstDirectory = temporaryDirectory.appending(component: "first")
            let firstSourceFile = firstDirectory.appending(component: "first.swift")

            try await subject.makeDirectory(at: firstDirectory)
            try await subject.touch(firstSourceFile)

            // When
            let got = try await subject.glob(
                directory: temporaryDirectory,
                include: ["first/*.swift"]
            )
            .collect()
            .sorted()

            // Then
            XCTAssertEqual(got, [firstSourceFile])
        }
    }

    func test_glob_nested_component_wildcard() async throws {
        try await subject.runInTemporaryDirectory(prefix: "FileSystem") { temporaryDirectory in
            // Given
            let firstSourceFile = temporaryDirectory.appending(component: "first.swift")

            try await subject.touch(firstSourceFile)

            // When
            let got = try await subject.glob(
                directory: temporaryDirectory,
                include: ["*.swift"]
            )
            .collect()
            .sorted()

            // Then
            XCTAssertEqual(got, [firstSourceFile])
        }
    }

    // The following behavior works correctly only on Apple environments due to discrepancies in the `Foundation` implementation.
    #if !os(Linux)
        func test_glob_when_recursive_glob_with_file_being_in_the_base_directory() async throws {
            try await subject.runInTemporaryDirectory(prefix: "FileSystem") { temporaryDirectory in
                // Given
                let temporaryDirectory = try AbsolutePath(validating: temporaryDirectory.pathString.replacingOccurrences(
                    of: "/private",
                    with: ""
                ))
                let firstSourceFile = temporaryDirectory.appending(component: "first.swift")

                try await subject.touch(firstSourceFile)

                // When
                let got = try await subject.glob(
                    directory: temporaryDirectory,
                    include: ["*.swift"]
                )
                .collect()
                .sorted()

                // Then
                XCTAssertEqual(got, [firstSourceFile])
            }
        }
    #endif

    func test_glob_with_nested_directories() async throws {
        try await subject.runInTemporaryDirectory(prefix: "FileSystem") { temporaryDirectory in
            // Given
            let topFile = temporaryDirectory.appending(component: "top.swift")
            let firstDirectory = temporaryDirectory.appending(component: "first")
            let firstSourceFile = firstDirectory.appending(component: "first.swift")
            let secondDirectory = firstDirectory.appending(component: "second")
            let secondSourceFile = firstDirectory.appending(component: "second.swift")

            try await subject.touch(topFile)
            try await subject.makeDirectory(at: secondDirectory)
            try await subject.touch(firstSourceFile)
            try await subject.touch(secondSourceFile)

            // When
            let got = try await subject.glob(
                directory: temporaryDirectory,
                include: ["**/*.swift"]
            )
            .collect()
            .sorted()

            // Then
            XCTAssertEqual(got, [firstSourceFile, secondSourceFile, topFile])
        }
    }
    
    func test_glob_with_file_in_a_nested_directory_with_a_component_wildcard() async throws {
        try await subject.runInTemporaryDirectory(prefix: "FileSystem") { temporaryDirectory in
            // Given
            let firstDirectory = temporaryDirectory.appending(component: "first")
            let firstSourceFile = firstDirectory.appending(component: "first.swift")

            try await subject.makeDirectory(at: firstDirectory)
            try await subject.touch(firstSourceFile)

            // When
            let got = try await subject.glob(
                directory: temporaryDirectory,
                include: ["*/*.swift"]
            )
            .collect()
            .sorted()

            // Then
            XCTAssertEqual(got, [firstSourceFile])
        }
    }

    func test_glob_with_file_and_only_a_directory_wildcard() async throws {
        try await subject.runInTemporaryDirectory(prefix: "FileSystem") { temporaryDirectory in
            // Given
            let firstSourceFile = temporaryDirectory.appending(component: "first.swift")
            try await subject.touch(firstSourceFile)

            // When
            let got = try await subject.glob(
                directory: temporaryDirectory,
                include: ["**"]
            )
            .collect()
            .sorted()

            // Then
            XCTAssertEqual(got, [firstSourceFile])
        }
    }

    func test_glob_with_file_with_a_space_and_only_a_directory_wildcard() async throws {
        try await subject.runInTemporaryDirectory(prefix: "FileSystem") { temporaryDirectory in
            // Given
            let sourceFile = temporaryDirectory.appending(component: "first plus.swift")
            try await subject.touch(sourceFile)

            // When
            let got = try await subject.glob(
                directory: temporaryDirectory,
                include: ["**"]
            )
            .collect()
            .sorted()

            // Then
            XCTAssertEqual(got, [sourceFile])
        }
    }
    
    func test_glob_with_path_wildcard_and_a_constant_file_name() async throws {
        try await subject.runInTemporaryDirectory(prefix: "FileSystem") { temporaryDirectory in
            // Given
            let directory = temporaryDirectory.appending(component: "first")
            let sourceFile = directory.appending(component: "first.swift")

            try await subject.makeDirectory(at: directory)
            try await subject.touch(sourceFile)

            // When
            let got = try await subject.glob(
                directory: temporaryDirectory,
                include: ["**/first.swift"]
            )
            .collect()
            .sorted()

            // Then
            XCTAssertEqual(got, [sourceFile])
        }
    }

    func test_glob_with_file_in_a_directory_with_a_space() async throws {
        try await subject.runInTemporaryDirectory(prefix: "FileSystem") { temporaryDirectory in
            // Given
            let directory = temporaryDirectory.appending(component: "directory with a space")
            let sourceFile = directory.appending(component: "first.swift")
            try await subject.makeDirectory(at: directory)
            try await subject.touch(sourceFile)

            // When
            let got = try await subject.glob(
                directory: directory,
                include: ["*.swift"]
            )
            .collect()
            .sorted()

            // Then
            XCTAssertEqual(got, [sourceFile])
        }
    }

    func test_glob_with_nested_files_and_only_a_directory_wildcard() async throws {
        try await subject.runInTemporaryDirectory(prefix: "FileSystem") { temporaryDirectory in
            // Given
            let firstDirectory = temporaryDirectory.appending(component: "first")
            let secondDirectory = firstDirectory.appending(component: "second")
            let sourceFile = firstDirectory.appending(component: "file.swift")
            try await subject.makeDirectory(at: secondDirectory)
            try await subject.touch(sourceFile)

            // When
            let got = try await subject.glob(
                directory: temporaryDirectory,
                include: ["**"]
            )
            .collect()
            .sorted()

            // Then
            XCTAssertEqual(got, [firstDirectory, sourceFile, secondDirectory])
        }
    }
}
