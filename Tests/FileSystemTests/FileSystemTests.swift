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

    func test_writeTextFile_and_readTextFile_returnsTheContent_when_whenOverwritingFile() async throws {
        try await subject.runInTemporaryDirectory(prefix: "FileSystem") { temporaryDirectory in
            // Given
            let filePath = temporaryDirectory.appending(component: "file")
            try await subject.writeText("test", at: filePath, options: Set([.overwrite]))
            try await subject.writeText("test", at: filePath, options: Set([.overwrite]))

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

    func test_writeAsJSON_and_readJSONFile_returnsTheContent_when_whenOverwritingFile() async throws {
        struct CodableStruct: Codable, Equatable { let name: String }

        try await subject.runInTemporaryDirectory(prefix: "FileSystem") { temporaryDirectory in
            // Given
            let item = CodableStruct(name: "tuist")
            let filePath = temporaryDirectory.appending(component: "file")
            try await subject.writeAsJSON(item, at: filePath, options: Set([.overwrite]))
            try await subject.writeAsJSON(item, at: filePath, options: Set([.overwrite]))

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

    func test_writeAsPlist_and_readPlistFile_returnsTheContent_when_overridingFile() async throws {
        struct CodableStruct: Codable, Equatable { let name: String }

        try await subject.runInTemporaryDirectory(prefix: "FileSystem") { temporaryDirectory in
            // Given
            let item = CodableStruct(name: "tuist")
            let filePath = temporaryDirectory.appending(component: "file")
            try await subject.writeAsPlist(item, at: filePath, options: Set([.overwrite]))
            try await subject.writeAsPlist(item, at: filePath, options: Set([.overwrite]))

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

    func test_fileMetadata_when_fileAbsent() async throws {
        try await subject.runInTemporaryDirectory(prefix: "FileSystem") { temporaryDirectory in
            // Given
            let path = temporaryDirectory.appending(component: "file")

            // When
            let modificationDate = try await subject.fileMetadata(at: path)

            // Then
            XCTAssertNil(modificationDate)
        }
    }

    func test_fileMetadata_when_filePresent() async throws {
        try await subject.runInTemporaryDirectory(prefix: "FileSystem") { temporaryDirectory in
            // Given
            let path = temporaryDirectory.appending(component: "file")
            try await subject.touch(path)

            // When
            let metadata = try await subject.fileMetadata(at: path)

            // Then
            XCTAssertNotNil(metadata?.lastModificationDate)
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

    func test_resolveSymbolicLink_whenTheDestinationIsRelative() async throws {
        try await subject.runInTemporaryDirectory(prefix: "FileSystem") { temporaryDirectory in
            // Given
            let symbolicPath = temporaryDirectory.appending(component: "symbolic")
            let destinationPath = temporaryDirectory.appending(component: "destination")
            try await subject.touch(destinationPath)
            try await subject.createSymbolicLink(from: symbolicPath, to: RelativePath(validating: "destination"))

            // When
            let got = try await subject.resolveSymbolicLink(symbolicPath)

            // Then
            XCTAssertEqual(got, destinationPath)
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

    func test_glob_with_file_with_a_special_character_and_only_a_directory_wildcard() async throws {
        try await subject.runInTemporaryDirectory(prefix: "FileSystem") { temporaryDirectory in
            // Given
            let sourceFile = temporaryDirectory.appending(component: "firstµplus.swift")
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

    func test_glob_with_file_extension_wildcard() async throws {
        try await subject.runInTemporaryDirectory(prefix: "FileSystem") { temporaryDirectory in
            // Given
            let directory = temporaryDirectory.appending(component: "directory")
            let sourceFile = directory.appending(component: "first.swift")
            try await subject.makeDirectory(at: directory)
            try await subject.touch(sourceFile)

            // When
            let got = try await subject.glob(
                directory: directory,
                include: ["first.*"]
            )
            .collect()
            .sorted()

            // Then
            XCTAssertEqual(got, [sourceFile])
        }
    }

    func test_glob_with_hidden_file_and_extension_wildcard() async throws {
        try await subject.runInTemporaryDirectory(prefix: "FileSystem") { temporaryDirectory in
            // Given
            let directory = temporaryDirectory.appending(component: "directory")
            let sourceFile = directory.appending(component: ".hidden.swift")
            try await subject.makeDirectory(at: directory)
            try await subject.touch(sourceFile)

            // When
            let got = try await subject.glob(
                directory: directory,
                include: [".*.swift"]
            )
            .collect()
            .sorted()

            // Then
            XCTAssertEqual(got, [sourceFile])
        }
    }

    func test_glob_with_constant_file() async throws {
        try await subject.runInTemporaryDirectory(prefix: "FileSystem") { temporaryDirectory in
            // Given
            let directory = temporaryDirectory.appending(component: "directory")
            let sourceFile = directory.appending(component: "first.swift")
            try await subject.makeDirectory(at: directory)
            try await subject.touch(sourceFile)

            // When
            let got = try await subject.glob(
                directory: directory,
                include: ["first.swift"]
            )
            .collect()
            .sorted()

            // Then
            XCTAssertEqual(got, [sourceFile])
        }
    }

    func test_glob_with_path_wildcard() async throws {
        try await subject.runInTemporaryDirectory(prefix: "FileSystem") { temporaryDirectory in
            // Given
            let directory = temporaryDirectory.appending(component: "directory")
            let sourceFile = directory.appending(component: "first.swift")
            try await subject.makeDirectory(at: directory)
            try await subject.touch(sourceFile)

            // When
            let got = try await subject.glob(
                directory: directory,
                include: ["**/first.swift"]
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

    func test_glob_with_nested_files_and_only_a_directory_wildcard_when_ds_store_is_present() async throws {
        try await subject.runInTemporaryDirectory(prefix: "FileSystem") { temporaryDirectory in
            // Given
            let firstDirectory = temporaryDirectory.appending(component: "first")
            let secondDirectory = firstDirectory.appending(component: "second")
            let sourceFile = firstDirectory.appending(component: "file.swift")
            try await subject.makeDirectory(at: secondDirectory)
            try await subject.touch(sourceFile)
            try await subject.touch(firstDirectory.appending(component: ".DS_Store"))
            try await subject.touch(secondDirectory.appending(component: ".DS_Store"))

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

    func test_glob_with_nested_files_and_only_a_directory_wildcard_when_git_keep_is_present() async throws {
        try await subject.runInTemporaryDirectory(prefix: "FileSystem") { temporaryDirectory in
            // Given
            let firstDirectory = temporaryDirectory.appending(component: "first")
            let secondDirectory = firstDirectory.appending(component: "second")
            let sourceFile = firstDirectory.appending(component: "file.swift")
            try await subject.makeDirectory(at: secondDirectory)
            try await subject.touch(sourceFile)
            try await subject.touch(firstDirectory.appending(component: ".gitkeep"))
            try await subject.touch(secondDirectory.appending(component: ".gitkeep"))

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

    func test_glob_with_symlink_and_only_a_directory_wildcard() async throws {
        try await subject.runInTemporaryDirectory(prefix: "FileSystem") { temporaryDirectory in
            // Given
            let firstDirectory = temporaryDirectory.appending(component: "first")
            let symlink = firstDirectory.appending(component: "symlink")
            let secondDirectory = temporaryDirectory.appending(component: "second")
            let sourceFile = secondDirectory.appending(component: "file.swift")
            let symlinkSourceFilePath = symlink.appending(component: "file.swift")
            try await subject.makeDirectory(at: firstDirectory)
            try await subject.makeDirectory(at: secondDirectory)
            try await subject.touch(sourceFile)
            try await subject.createSymbolicLink(from: symlink, to: secondDirectory)

            // When
            let got = try await subject.glob(
                directory: firstDirectory,
                include: ["**/*.swift"]
            )
            .collect()
            .sorted()

            // Then
            XCTAssertEqual(got, [symlinkSourceFilePath])
        }
    }

    func test_glob_with_symlink_as_base_url() async throws {
        try await subject.runInTemporaryDirectory(prefix: "FileSystem") { temporaryDirectory in
            // Given
            let symlink = temporaryDirectory.appending(component: "symlink")
            let firstDirectory = temporaryDirectory.appending(component: "first")
            let sourceFile = firstDirectory.appending(component: "file.swift")
            let symlinkSourceFilePath = symlink.appending(component: "file.swift")
            try await subject.makeDirectory(at: firstDirectory)
            try await subject.touch(sourceFile)
            try await subject.createSymbolicLink(from: symlink, to: firstDirectory)

            // When
            let got = try await subject.glob(
                directory: symlink,
                include: ["*.swift"]
            )
            .collect()
            .sorted()

            // Then
            XCTAssertEqual(got, [symlinkSourceFilePath])
        }
    }

    func test_glob_with_relative_symlink() async throws {
        try await subject.runInTemporaryDirectory(prefix: "FileSystem") { temporaryDirectory in
            // Given
            let frameworkDir = temporaryDirectory.appending(component: "Framework")
            let sourceDir = frameworkDir.appending(component: "Source")
            let spmResourcesDir = sourceDir.appending(component: "SwiftPackageResources")
            let modelSymLinkPath = spmResourcesDir.appending(component: "MyModel.xcdatamodeld")

            let actualResourcesDir = frameworkDir.appending(component: "Resources")
            let actualModelPath = actualResourcesDir.appending(component: "MyModel.xcdatamodeld")
            let versionPath = actualModelPath.appending(component: "MyModel_0.xcdatamodel")

            try await subject.makeDirectory(at: spmResourcesDir)
            try await subject.makeDirectory(at: actualResourcesDir)
            try await subject.makeDirectory(at: actualModelPath)
            try await subject.touch(versionPath)

            let relativeActualModelPath = try RelativePath(validating: "../../Resources/MyModel.xcdatamodeld")
            try await subject.createSymbolicLink(from: modelSymLinkPath, to: relativeActualModelPath)

            // When
            let got = try await subject.glob(
                directory: modelSymLinkPath,
                include: ["*.xcdatamodel"]
            )
            .collect()
            .sorted()

            // Then
            XCTAssertEqual(got.count, 1)
            XCTAssertEqual(got.map(\.basename), [versionPath.basename])
        }
    }

    func test_glob_with_relative_directory_symlink() async throws {
        try await subject.runInTemporaryDirectory(prefix: "FileSystem") { temporaryDirectory in
            // Given
            let frameworkDir = temporaryDirectory.appending(component: "MyFramework")
            let testsDir = temporaryDirectory.appending(component: "Tests")
            let customSQLiteDir = testsDir.appending(component: "CustomSQLite")

            let myStructPath = frameworkDir.appending(component: "MyStruct.swift")

            try await subject.makeDirectory(at: frameworkDir)
            try await subject.makeDirectory(at: customSQLiteDir)
            try await subject.touch(myStructPath)

            let rootDirSymLinkPath = customSQLiteDir.appending(component: "MyFramework")
            let relativeRootDirPath = try RelativePath(validating: "../..")
            try await subject.createSymbolicLink(from: rootDirSymLinkPath, to: relativeRootDirPath)

            // When
            let got = try await subject.glob(
                directory: temporaryDirectory,
                include: ["**/*.swift"]
            )
            .collect()
            .sorted()

            // Then
            XCTAssertEqual(got.count, 1)
            XCTAssertEqual(got.map(\.basename), [myStructPath.basename])
        }
    }

    func test_glob_with_double_directory_wildcard() async throws {
        try await subject.runInTemporaryDirectory(prefix: "FileSystem") { temporaryDirectory in
            // Given
            let firstDirectory = temporaryDirectory.appending(component: "first")
            let firstSourceFile = firstDirectory.appending(component: "first.swift")
            let secondDirectory = firstDirectory.appending(component: "second")
            let secondSourceFile = secondDirectory.appending(component: "second.swift")
            let thirdDirectory = secondDirectory.appending(component: "third")
            let thirdSourceFile = thirdDirectory.appending(component: "third.swift")
            let fourthDirectory = thirdDirectory.appending(component: "fourth")
            let fourthSourceFile = fourthDirectory.appending(component: "fourth.swift")

            try await subject.makeDirectory(at: fourthDirectory)
            try await subject.touch(firstSourceFile)
            try await subject.touch(secondSourceFile)
            try await subject.touch(thirdSourceFile)
            try await subject.touch(fourthSourceFile)

            // When
            let got = try await subject.glob(
                directory: temporaryDirectory,
                include: ["first/**/third/**/*.swift"]
            )
            .collect()
            .sorted()

            // Then
            XCTAssertEqual(got, [fourthSourceFile, thirdSourceFile])
        }
    }

    func test_glob_with_extension_group() async throws {
        try await subject.runInTemporaryDirectory(prefix: "FileSystem") { temporaryDirectory in
            // Given
            let swiftSourceFile = temporaryDirectory.appending(component: "file.swift")
            let cppSourceFile = temporaryDirectory.appending(component: "file.cpp")
            let jsSourceFile = temporaryDirectory.appending(component: "file.js")
            try await subject.touch(swiftSourceFile)
            try await subject.touch(cppSourceFile)
            try await subject.touch(jsSourceFile)

            // When
            let got = try await subject.glob(directory: temporaryDirectory, include: ["*.{swift,cpp}"])
                .collect()
                .sorted()

            // Then
            XCTAssertEqual(
                got,
                [
                    cppSourceFile,
                    swiftSourceFile,
                ]
            )
        }
    }

    func test_remove_file() async throws {
        try await subject.runInTemporaryDirectory(prefix: "FileSystem") { temporaryDirectory in
            // Given
            let file = temporaryDirectory.appending(component: "test")
            try await subject.touch(file)

            // When
            try await subject.remove(file)

            // Then
            let exists = try await subject.exists(file)
            XCTAssertFalse(exists)
        }
    }

    func test_remove_non_existing_file() async throws {
        try await subject.runInTemporaryDirectory(prefix: "FileSystem") { temporaryDirectory in
            // Given
            let file = temporaryDirectory.appending(component: "test")

            // When / Then
            try await subject.remove(file)
        }
    }

    func test_remove_directory_with_files() async throws {
        try await subject.runInTemporaryDirectory(prefix: "FileSystem") { temporaryDirectory in
            // Given
            let directory = temporaryDirectory.appending(component: "directory")
            let nestedDirectory = directory.appending(component: "nested")
            let file = nestedDirectory.appending(component: "test")
            try await subject.makeDirectory(at: nestedDirectory)
            try await subject.touch(file)

            // When
            try await subject.remove(directory)

            // Then
            let directoryExists = try await subject.exists(directory)
            let nestedDirectoryExists = try await subject.exists(nestedDirectory)
            let fileExists = try await subject.exists(file)
            XCTAssertFalse(directoryExists)
            XCTAssertFalse(nestedDirectoryExists)
            XCTAssertFalse(fileExists)
        }
    }

    func test_get_contents_of_directory() async throws {
        try await subject.runInTemporaryDirectory(prefix: "FileSystem") { temporaryDirectory in
            // Given
            let file1 = temporaryDirectory.appending(component: "README.md")
            let file2 = temporaryDirectory.appending(component: "Foo")
            let nestedDirectory = temporaryDirectory.appending(component: "nested")
            let nestedFile = nestedDirectory.appending(component: "test")
            try await subject.touch(file1)
            try await subject.touch(file2)
            try await subject.makeDirectory(at: nestedDirectory)
            try await subject.touch(nestedFile)

            // When
            let contents = try await subject.contentsOfDirectory(temporaryDirectory)

            // Then
            let fileNames = contents.map(\.basename)
            XCTAssertEqual(fileNames.sorted(using: .localized), ["Foo", "nested", "README.md"])
        }
    }
}
