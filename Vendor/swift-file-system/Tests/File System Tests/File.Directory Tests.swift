//
//  File.Directory Tests.swift
//  swift-file-system
//
//  Created by Coen ten Thije Boonkkamp on 18/12/2025.
//

import Testing

@testable import File_System

extension File.System.Test.Unit {
    @Suite("File.Directory")
    struct DirectoryTests {

        // MARK: - Test Fixtures

        private func createTempDir() throws -> File.Directory {
            let pathString = "/tmp/directory-instance-test-\(uniqueId())"
            let dir = try File.Directory(pathString)
            try dir.create(withIntermediates: true)
            return dir
        }

        private func cleanup(_ dir: File.Directory) {
            try? dir.delete(recursive: true)
        }

        private func uniqueId() -> String {
            let characters = "abcdefghijklmnopqrstuvwxyz0123456789"
            return String((0..<16).map { _ in characters.randomElement()! })
        }

        // MARK: - Initializers

        @Test("init from path")
        func initFromPath() throws {
            let path = try File.Path("/tmp/test")
            let dir = File.Directory(path)
            #expect(dir.path == path)
        }

        @Test("init from string")
        func initFromString() throws {
            let dir = try File.Directory("/tmp/test")
            #expect(dir.path.string == "/tmp/test")
        }

        @Test("init from string literal")
        func initFromStringLiteral() {
            let dir: File.Directory = "/tmp/test"
            #expect(dir.path.string == "/tmp/test")
        }

        // MARK: - Directory Operations

        @Test("create creates directory")
        func createCreatesDirectory() throws {
            let pathString = "/tmp/directory-instance-create-\(uniqueId())"
            let dir = try File.Directory(pathString)
            defer { cleanup(dir) }

            #expect(dir.exists == false)
            try dir.create()
            #expect(dir.exists == true)
            #expect(dir.isDirectory == true)
        }

        @Test("create with intermediates")
        func createWithIntermediates() throws {
            let id = uniqueId()
            let pathString = "/tmp/directory-instance-create-\(id)/nested/path"
            let dir = try File.Directory(pathString)
            let root = try File.Directory("/tmp/directory-instance-create-\(id)")
            defer { cleanup(root) }

            #expect(dir.exists == false)
            try dir.create(withIntermediates: true)
            #expect(dir.exists == true)
        }

        @Test("create async creates directory")
        func createAsyncCreatesDirectory() async throws {
            let pathString = "/tmp/directory-instance-create-async-\(uniqueId())"
            let dir = try File.Directory(pathString)
            defer { cleanup(dir) }

            try await dir.create()
            #expect(dir.isDirectory == true)
        }

        @Test("delete removes empty directory")
        func deleteRemovesEmptyDirectory() throws {
            let dir = try createTempDir()

            #expect(dir.exists == true)
            try dir.delete()
            #expect(dir.exists == false)
        }

        @Test("delete recursive removes directory with contents")
        func deleteRecursiveRemovesContents() throws {
            let dir = try createTempDir()
            let file = dir["test.txt"]
            try file.write("test")

            #expect(dir.exists == true)
            try dir.delete(recursive: true)
            #expect(dir.exists == false)
        }

        @Test("delete async removes directory")
        func deleteAsyncRemovesDirectory() async throws {
            let dir = try createTempDir()

            #expect(dir.exists == true)
            try await dir.delete()
            #expect(dir.exists == false)
        }

        // MARK: - Stat Operations

        @Test("exists returns true for existing directory")
        func existsReturnsTrueForDirectory() throws {
            let dir = try createTempDir()
            defer { cleanup(dir) }

            #expect(dir.exists == true)
        }

        @Test("exists returns false for non-existing directory")
        func existsReturnsFalseForNonExisting() throws {
            let dir = try File.Directory("/tmp/non-existing-\(uniqueId())")
            #expect(dir.exists == false)
        }

        @Test("isDirectory returns true for directory")
        func isDirectoryReturnsTrueForDirectory() throws {
            let dir = try createTempDir()
            defer { cleanup(dir) }

            #expect(dir.isDirectory == true)
        }

        // MARK: - Contents

        @Test("contents returns directory entries")
        func contentsReturnsEntries() throws {
            let dir = try createTempDir()
            defer { cleanup(dir) }

            // Create some files
            try dir["file1.txt"].write("content1")
            try dir["file2.txt"].write("content2")

            let contents = try dir.contents()
            let names = contents.map(\.name).sorted()

            #expect(names == ["file1.txt", "file2.txt"])
        }

        @Test("contents async returns directory entries")
        func contentsAsyncReturnsEntries() async throws {
            let dir = try createTempDir()
            defer { cleanup(dir) }

            try await dir["test.txt"].write("test")

            let contents = try await dir.contents()
            #expect(contents.count == 1)
            #expect(contents[0].name == "test.txt")
        }

        @Test("files returns only files")
        func filesReturnsOnlyFiles() throws {
            let dir = try createTempDir()
            defer { cleanup(dir) }

            // Create file and subdirectory
            try dir["file.txt"].write("content")
            try dir.subdirectory("subdir").create()

            let files = try dir.files()
            #expect(files.count == 1)
            #expect(files[0].name == "file.txt")
        }

        @Test("subdirectories returns only directories")
        func subdirectoriesReturnsOnlyDirs() throws {
            let dir = try createTempDir()
            defer { cleanup(dir) }

            // Create file and subdirectory
            try dir["file.txt"].write("content")
            try dir.subdirectory("subdir").create()

            let subdirs = try dir.subdirectories()
            #expect(subdirs.count == 1)
            #expect(subdirs[0].name == "subdir")
        }

        // MARK: - Subscript Access

        @Test("subscript returns File")
        func subscriptReturnsFile() {
            let dir: File.Directory = "/tmp/mydir"
            let file = dir["readme.txt"]

            #expect(file.path.string == "/tmp/mydir/readme.txt")
        }

        @Test("subscript chain works")
        func subscriptChainWorks() throws {
            let dir = try createTempDir()
            defer { cleanup(dir) }

            let file = dir["test.txt"]
            try file.write("Hello")

            let readBack = try dir["test.txt"].readString()
            #expect(readBack == "Hello")
        }

        @Test("subdirectory returns Directory.Instance")
        func subdirectoryReturnsDirectoryInstance() {
            let dir: File.Directory = "/tmp/mydir"
            let subdir = dir.subdirectory("nested")

            #expect(subdir.path.string == "/tmp/mydir/nested")
        }

        // MARK: - Path Navigation

        @Test("parent returns parent directory")
        func parentReturnsParent() {
            let dir: File.Directory = "/tmp/parent/child"
            let parent = dir.parent

            #expect(parent != nil)
            #expect(parent?.path.string == "/tmp/parent")
        }

        @Test("name returns directory name")
        func nameReturnsDirectoryName() {
            let dir: File.Directory = "/tmp/mydir"
            #expect(dir.name == "mydir")
        }

        @Test("appending returns new instance")
        func appendingReturnsNewInstance() {
            let dir: File.Directory = "/tmp"
            let result = dir.appending("subdir")
            #expect(result.path.string == "/tmp/subdir")
        }

        @Test("/ operator appends path")
        func slashOperatorAppendsPath() {
            let dir: File.Directory = "/tmp"
            let result = dir / "subdir" / "nested"
            #expect(result.path.string == "/tmp/subdir/nested")
        }

        // MARK: - Hashable & Equatable

        @Test("File.Directory is equatable")
        func directoryIsEquatable() {
            let dir1: File.Directory = "/tmp/test"
            let dir2: File.Directory = "/tmp/test"
            let dir3: File.Directory = "/tmp/other"

            #expect(dir1 == dir2)
            #expect(dir1 != dir3)
        }

        @Test("File.Directory is hashable")
        func directoryIsHashable() {
            let dir1: File.Directory = "/tmp/test"
            let dir2: File.Directory = "/tmp/test"

            var set = Set<File.Directory>()
            set.insert(dir1)
            set.insert(dir2)

            #expect(set.count == 1)
        }

        // MARK: - CustomStringConvertible

        @Test("description returns path string")
        func descriptionReturnsPathString() {
            let dir: File.Directory = "/tmp/test"
            #expect(dir.description == "/tmp/test")
        }

        @Test("debugDescription returns formatted string")
        func debugDescriptionReturnsFormatted() {
            let dir: File.Directory = "/tmp/test"
            #expect(dir.debugDescription == #"File.Directory("/tmp/test")"#)
        }
    }
}
