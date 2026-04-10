//
//  File.Directory.Contents Tests.swift
//  swift-file-system
//
//  Created by Coen ten Thije Boonkkamp on 18/12/2025.
//

import Foundation
import Testing

@testable import File_System_Primitives

extension File.System.Test.Unit {
    @Suite("File.Directory.Contents")
    struct DirectoryContents {

        // MARK: - Test Fixtures

        private func createTempDir() throws -> String {
            let path = "/tmp/contents-test-\(UUID().uuidString)"
            try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true)
            return path
        }

        private func cleanup(_ path: String) {
            try? FileManager.default.removeItem(atPath: path)
        }

        // MARK: - Listing

        @Test("List empty directory")
        func listEmptyDirectory() throws {
            let dirPath = try createTempDir()
            defer { cleanup(dirPath) }

            let path = try File.Path(dirPath)
            let entries = try File.Directory.Contents.list(at: path)
            #expect(entries.isEmpty)
        }

        @Test("List directory with files")
        func listDirectoryWithFiles() throws {
            let dirPath = try createTempDir()
            defer { cleanup(dirPath) }

            // Create some files
            FileManager.default.createFile(atPath: "\(dirPath)/file1.txt", contents: nil)
            FileManager.default.createFile(atPath: "\(dirPath)/file2.txt", contents: nil)
            FileManager.default.createFile(atPath: "\(dirPath)/file3.txt", contents: nil)

            let path = try File.Path(dirPath)
            let entries = try File.Directory.Contents.list(at: path)
            #expect(entries.count == 3)

            let names = entries.map { $0.name }.sorted()
            #expect(names == ["file1.txt", "file2.txt", "file3.txt"])
        }

        @Test("List directory with subdirectories")
        func listDirectoryWithSubdirectories() throws {
            let dirPath = try createTempDir()
            defer { cleanup(dirPath) }

            // Create subdirectories
            try FileManager.default.createDirectory(
                atPath: "\(dirPath)/subdir1",
                withIntermediateDirectories: true
            )
            try FileManager.default.createDirectory(
                atPath: "\(dirPath)/subdir2",
                withIntermediateDirectories: true
            )

            let path = try File.Path(dirPath)
            let entries = try File.Directory.Contents.list(at: path)
            #expect(entries.count == 2)

            for entry in entries {
                #expect(entry.type == .directory)
            }
        }

        @Test("List directory with mixed content")
        func listDirectoryWithMixedContent() throws {
            let dirPath = try createTempDir()
            defer { cleanup(dirPath) }

            // Create file
            FileManager.default.createFile(atPath: "\(dirPath)/file.txt", contents: nil)

            // Create subdirectory
            try FileManager.default.createDirectory(
                atPath: "\(dirPath)/subdir",
                withIntermediateDirectories: true
            )

            let path = try File.Path(dirPath)
            let entries = try File.Directory.Contents.list(at: path)
            #expect(entries.count == 2)

            let fileEntry = entries.first { $0.name == "file.txt" }
            #expect(fileEntry?.type == .file)

            let dirEntry = entries.first { $0.name == "subdir" }
            #expect(dirEntry?.type == .directory)
        }

        @Test("List directory excludes . and ..")
        func listDirectoryExcludesDotEntries() throws {
            let dirPath = try createTempDir()
            defer { cleanup(dirPath) }

            FileManager.default.createFile(atPath: "\(dirPath)/regular.txt", contents: nil)

            let path = try File.Path(dirPath)
            let entries = try File.Directory.Contents.list(at: path)

            let names = entries.map { $0.name }
            #expect(!names.contains("."))
            #expect(!names.contains(".."))
        }

        @Test("List directory with symlink")
        func listDirectoryWithSymlink() throws {
            let dirPath = try createTempDir()
            defer { cleanup(dirPath) }

            // Create a regular file
            FileManager.default.createFile(atPath: "\(dirPath)/target.txt", contents: nil)

            // Create a symlink
            try FileManager.default.createSymbolicLink(
                atPath: "\(dirPath)/link.txt",
                withDestinationPath: "\(dirPath)/target.txt"
            )

            let path = try File.Path(dirPath)
            let entries = try File.Directory.Contents.list(at: path)
            #expect(entries.count == 2)

            let linkEntry = entries.first { $0.name == "link.txt" }
            #expect(linkEntry?.type == .symbolicLink)
        }

        // MARK: - Entry Properties

        @Test("Entry has correct path")
        func entryHasCorrectPath() throws {
            let dirPath = try createTempDir()
            defer { cleanup(dirPath) }

            FileManager.default.createFile(atPath: "\(dirPath)/test.txt", contents: nil)

            let path = try File.Path(dirPath)
            let entries = try File.Directory.Contents.list(at: path)
            #expect(entries.count == 1)

            let entry = entries[0]
            #expect(entry.name == "test.txt")
            #expect(entry.path.string.hasSuffix("/test.txt"))
        }

        // MARK: - Error Cases

        @Test("List non-existent directory throws pathNotFound")
        func listNonExistentDirectoryThrows() throws {
            let nonExistent = "/tmp/non-existent-\(UUID().uuidString)"
            let path = try File.Path(nonExistent)

            #expect(throws: File.Directory.Contents.Error.self) {
                _ = try File.Directory.Contents.list(at: path)
            }
        }

        @Test("List file throws notADirectory")
        func listFileThrowsNotADirectory() throws {
            let filePath = "/tmp/contents-file-\(UUID().uuidString).txt"
            defer { try? FileManager.default.removeItem(atPath: filePath) }

            FileManager.default.createFile(atPath: filePath, contents: nil)

            let path = try File.Path(filePath)

            #expect(throws: File.Directory.Contents.Error.notADirectory(path)) {
                _ = try File.Directory.Contents.list(at: path)
            }
        }

        // MARK: - Error Descriptions

        @Test("pathNotFound error description")
        func pathNotFoundErrorDescription() throws {
            let path = try File.Path("/tmp/missing")
            let error = File.Directory.Contents.Error.pathNotFound(path)
            #expect(error.description.contains("Path not found"))
        }

        @Test("permissionDenied error description")
        func permissionDeniedErrorDescription() throws {
            let path = try File.Path("/root")
            let error = File.Directory.Contents.Error.permissionDenied(path)
            #expect(error.description.contains("Permission denied"))
        }

        @Test("notADirectory error description")
        func notADirectoryErrorDescription() throws {
            let path = try File.Path("/tmp/file.txt")
            let error = File.Directory.Contents.Error.notADirectory(path)
            #expect(error.description.contains("Not a directory"))
        }

        @Test("readFailed error description")
        func readFailedErrorDescription() {
            let error = File.Directory.Contents.Error.readFailed(errno: 5, message: "I/O error")
            #expect(error.description.contains("Read failed"))
            #expect(error.description.contains("I/O error"))
        }

        // MARK: - Entry Type

        @Test("EntryType file case")
        func entryTypeFile() {
            let type: File.Directory.EntryType = .file
            #expect(type == .file)
        }

        @Test("EntryType directory case")
        func entryTypeDirectory() {
            let type: File.Directory.EntryType = .directory
            #expect(type == .directory)
        }

        @Test("EntryType symbolicLink case")
        func entryTypeSymbolicLink() {
            let type: File.Directory.EntryType = .symbolicLink
            #expect(type == .symbolicLink)
        }

        @Test("EntryType other case")
        func entryTypeOther() {
            let type: File.Directory.EntryType = .other
            #expect(type == .other)
        }
    }
}
