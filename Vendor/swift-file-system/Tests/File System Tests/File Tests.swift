//
//  File Tests.swift
//  swift-file-system
//
//  Created by Coen ten Thije Boonkkamp on 18/12/2025.
//

import Testing

@testable import File_System

extension File.System.Test.Unit {
    @Suite("File")
    struct FileTests {

        // MARK: - Test Fixtures

        private func uniqueId() -> String {
            let characters = "abcdefghijklmnopqrstuvwxyz0123456789"
            return String((0..<16).map { _ in characters.randomElement()! })
        }

        private func createTempFile(content: [UInt8] = []) throws -> File {
            let pathString = "/tmp/file-test-\(uniqueId()).bin"
            let file = try File(pathString)
            try file.write(content)
            return file
        }

        private func cleanup(_ file: File) {
            try? file.delete()
        }

        // MARK: - Initializers

        @Test("init from path")
        func initFromPath() throws {
            let path = try File.Path("/tmp/test.txt")
            let file = File(path)
            #expect(file.path == path)
        }

        @Test("init from string")
        func initFromString() throws {
            let file = try File("/tmp/test.txt")
            #expect(file.path.string == "/tmp/test.txt")
        }

        @Test("init from string literal")
        func initFromStringLiteral() {
            let file: File = "/tmp/test.txt"
            #expect(file.path.string == "/tmp/test.txt")
        }

        // MARK: - Read Operations

        @Test("read returns file contents")
        func readReturnsContents() throws {
            let content: [UInt8] = [1, 2, 3, 4, 5]
            let file = try createTempFile(content: content)
            defer { cleanup(file) }

            let result = try file.read()
            #expect(result == content)
        }

        @Test("read async returns file contents")
        func readAsyncReturnsContents() async throws {
            let content: [UInt8] = [10, 20, 30]
            let file = try createTempFile(content: content)
            defer { cleanup(file) }

            let result = try await file.read()
            #expect(result == content)
        }

        @Test("readString returns string contents")
        func readStringReturnsContents() throws {
            let text = "Hello, File!"
            let file = try createTempFile(content: Array(text.utf8))
            defer { cleanup(file) }

            let result = try file.readString()
            #expect(result == text)
        }

        @Test("readString async returns string contents")
        func readStringAsyncReturnsContents() async throws {
            let text = "Async Hello!"
            let file = try createTempFile(content: Array(text.utf8))
            defer { cleanup(file) }

            let result = try await file.readString()
            #expect(result == text)
        }

        // MARK: - Write Operations

        @Test("write bytes to file")
        func writeBytesToFile() throws {
            let pathString = "/tmp/file-write-\(uniqueId()).bin"
            let file = try File(pathString)
            defer { cleanup(file) }

            let content: [UInt8] = [1, 2, 3, 4, 5]
            try file.write(content)

            let readBack = try file.read()
            #expect(readBack == content)
        }

        @Test("write string to file")
        func writeStringToFile() throws {
            let pathString = "/tmp/file-write-string-\(uniqueId()).txt"
            let file = try File(pathString)
            defer { cleanup(file) }

            let text = "Hello, World!"
            try file.write(text)

            let readBack = try file.readString()
            #expect(readBack == text)
        }

        @Test("write async bytes to file")
        func writeAsyncBytesToFile() async throws {
            let pathString = "/tmp/file-write-async-\(uniqueId()).bin"
            let file = try File(pathString)
            defer { cleanup(file) }

            let content: [UInt8] = [10, 20, 30]
            try await file.write(content)

            let readBack = try await file.read()
            #expect(readBack == content)
        }

        // MARK: - Stat Operations

        @Test("exists returns true for existing file")
        func existsReturnsTrueForFile() throws {
            let file = try createTempFile(content: [1, 2, 3])
            defer { cleanup(file) }

            #expect(file.exists == true)
        }

        @Test("exists returns false for non-existing file")
        func existsReturnsFalseForNonExisting() throws {
            let file = try File("/tmp/non-existing-\(uniqueId())")
            #expect(file.exists == false)
        }

        @Test("isFile returns true for file")
        func isFileReturnsTrueForFile() throws {
            let file = try createTempFile(content: [1])
            defer { cleanup(file) }

            #expect(file.isFile == true)
        }

        @Test("isDirectory returns false for file")
        func isDirectoryReturnsFalseForFile() throws {
            let file = try createTempFile(content: [1])
            defer { cleanup(file) }

            #expect(file.isDirectory == false)
        }

        @Test("isSymlink returns false for regular file")
        func isSymlinkReturnsFalseForFile() throws {
            let file = try createTempFile(content: [1])
            defer { cleanup(file) }

            #expect(file.isSymlink == false)
        }

        // MARK: - Metadata

        @Test("info returns file metadata")
        func infoReturnsMetadata() throws {
            let content: [UInt8] = [1, 2, 3, 4, 5]
            let file = try createTempFile(content: content)
            defer { cleanup(file) }

            let info = try file.info
            #expect(info.size == Int64(content.count))
            #expect(info.type == .regular)
        }

        @Test("size returns file size")
        func sizeReturnsFileSize() throws {
            let content: [UInt8] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
            let file = try createTempFile(content: content)
            defer { cleanup(file) }

            let size = try file.size
            #expect(size == 10)
        }

        @Test("permissions returns file permissions")
        func permissionsReturnsPermissions() throws {
            let file = try createTempFile(content: [1, 2, 3])
            defer { cleanup(file) }

            let permissions = try file.permissions
            // File should be readable by owner at minimum
            #expect(permissions.contains(.ownerRead) == true)
        }

        // MARK: - File Operations

        @Test("delete removes file")
        func deleteRemovesFile() throws {
            let file = try createTempFile(content: [1, 2, 3])

            #expect(file.exists == true)
            try file.delete()
            #expect(file.exists == false)
        }

        @Test("delete async removes file")
        func deleteAsyncRemovesFile() async throws {
            let file = try createTempFile(content: [1, 2, 3])

            #expect(file.exists == true)
            try await file.delete()
            #expect(file.exists == false)
        }

        @Test("copy to path copies file")
        func copyToPathCopiesFile() throws {
            let content: [UInt8] = [1, 2, 3]
            let source = try createTempFile(content: content)
            let destPath = try File.Path("/tmp/file-copy-\(uniqueId()).bin")
            let dest = File(destPath)
            defer {
                cleanup(source)
                cleanup(dest)
            }

            try source.copy(to: destPath)

            let readBack = try dest.read()
            #expect(readBack == content)
        }

        @Test("copy to file copies file")
        func copyToFileCopiesFile() throws {
            let content: [UInt8] = [1, 2, 3]
            let source = try createTempFile(content: content)
            let dest = try File("/tmp/file-copy-\(uniqueId()).bin")
            defer {
                cleanup(source)
                cleanup(dest)
            }

            try source.copy(to: dest)

            let readBack = try dest.read()
            #expect(readBack == content)
        }

        @Test("move to path moves file")
        func moveToPathMovesFile() throws {
            let content: [UInt8] = [1, 2, 3]
            let source = try createTempFile(content: content)
            let destPath = try File.Path("/tmp/file-move-\(uniqueId()).bin")
            let dest = File(destPath)
            defer {
                cleanup(source)
                cleanup(dest)
            }

            try source.move(to: destPath)

            #expect(source.exists == false)
            #expect(dest.exists == true)
            let readBack = try dest.read()
            #expect(readBack == content)
        }

        @Test("move to file moves file")
        func moveToFileMovesFile() throws {
            let content: [UInt8] = [1, 2, 3]
            let source = try createTempFile(content: content)
            let dest = try File("/tmp/file-move-\(uniqueId()).bin")
            defer {
                cleanup(source)
                cleanup(dest)
            }

            try source.move(to: dest)

            #expect(source.exists == false)
            #expect(dest.exists == true)
        }

        // MARK: - Path Navigation

        @Test("parent returns parent directory")
        func parentReturnsParent() {
            let file: File = "/tmp/subdir/file.txt"
            let parent = file.parent

            #expect(parent != nil)
            #expect(parent?.path.string == "/tmp/subdir")
        }

        @Test("name returns filename")
        func nameReturnsFilename() {
            let file: File = "/tmp/test.txt"
            #expect(file.name == "test.txt")
        }

        @Test("extension returns file extension")
        func extensionReturnsExtension() {
            let file: File = "/tmp/test.txt"
            #expect(file.extension == "txt")
        }

        @Test("extension returns nil for no extension")
        func extensionReturnsNilForNoExtension() {
            let file: File = "/tmp/Makefile"
            #expect(file.extension == nil)
        }

        @Test("stem returns filename without extension")
        func stemReturnsStem() {
            let file: File = "/tmp/test.txt"
            #expect(file.stem == "test")
        }

        @Test("appending returns new file with appended path")
        func appendingReturnsNewFile() {
            let file: File = "/tmp"
            let result = file.appending("subdir")
            #expect(result.path.string == "/tmp/subdir")
        }

        @Test("/ operator appends path")
        func slashOperatorAppendsPath() {
            let file: File = "/tmp"
            let result = file / "subdir" / "file.txt"
            #expect(result.path.string == "/tmp/subdir/file.txt")
        }

        // MARK: - Hashable & Equatable

        @Test("File is equatable")
        func fileIsEquatable() throws {
            let file1 = try File("/tmp/test.txt")
            let file2 = try File("/tmp/test.txt")
            let file3 = try File("/tmp/other.txt")

            #expect(file1 == file2)
            #expect(file1 != file3)
        }

        @Test("File is hashable")
        func fileIsHashable() throws {
            let file1 = try File("/tmp/test.txt")
            let file2 = try File("/tmp/test.txt")

            var set = Set<File>()
            set.insert(file1)
            set.insert(file2)

            #expect(set.count == 1)
        }

        // MARK: - CustomStringConvertible

        @Test("description returns path string")
        func descriptionReturnsPathString() {
            let file: File = "/tmp/test.txt"
            #expect(file.description == "/tmp/test.txt")
        }

        @Test("debugDescription returns formatted string")
        func debugDescriptionReturnsFormatted() {
            let file: File = "/tmp/test.txt"
            #expect(file.debugDescription == "File(\"/tmp/test.txt\")")
        }
    }
}
