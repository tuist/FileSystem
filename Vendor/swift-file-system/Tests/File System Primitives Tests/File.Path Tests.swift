//
//  File.Path Tests.swift
//  swift-file-system
//
//  Created by Coen ten Thije Boonkkamp on 18/12/2025.
//

import SystemPackage
import Testing

@testable import File_System_Primitives

extension File.System.Test.Unit {
    @Suite("File.Path")
    struct Path {

        // MARK: - Initialization

        @Test("Valid absolute path initialization")
        func validAbsolutePath() throws {
            let path = try File.Path("/usr/local/bin")
            #expect(path.string == "/usr/local/bin")
        }

        @Test("Valid relative path initialization")
        func validRelativePath() throws {
            let path = try File.Path("foo/bar/baz")
            #expect(path.string == "foo/bar/baz")
        }

        @Test("Single component path")
        func singleComponentPath() throws {
            let path = try File.Path("file.txt")
            #expect(path.string == "file.txt")
        }

        @Test("Root path")
        func rootPath() throws {
            let path = try File.Path("/")
            #expect(path.string == "/")
            #expect(path.isAbsolute)
        }

        @Test("Empty path throws error")
        func emptyPath() {
            let emptyString = ""
            #expect(throws: File.Path.Error.empty) {
                try File.Path(emptyString)
            }
        }

        @Test("Path with null character throws error")
        func pathWithNullCharacter() {
            let pathWithNull = "/tmp/test\0file.txt"
            #expect(throws: File.Path.Error.containsControlCharacters) {
                try File.Path(pathWithNull)
            }
        }

        @Test("Path with control characters throws error")
        func pathWithControlCharacters() {
            let pathWithControl = "/tmp/test\u{01}file.txt"
            #expect(throws: File.Path.Error.containsControlCharacters) {
                try File.Path(pathWithControl)
            }
        }

        @Test("FilePath initializer - valid")
        func filePathInitValid() throws {
            let filePath = FilePath("/usr/bin")
            let path = try File.Path(filePath)
            #expect(path.string == "/usr/bin")
        }

        @Test("FilePath initializer - empty throws")
        func filePathInitEmpty() {
            let filePath = FilePath("")
            #expect(throws: File.Path.Error.empty) {
                try File.Path(filePath)
            }
        }

        // MARK: - Navigation

        @Test("Parent of nested path")
        func parentOfNestedPath() throws {
            let path = try File.Path("/usr/local/bin")
            let parent = path.parent
            #expect(parent?.string == "/usr/local")
        }

        @Test("Parent of root path is nil")
        func parentOfRootPathIsNil() throws {
            let path = try File.Path("/")
            #expect(path.parent == nil)
        }

        @Test("Parent chain")
        func parentChain() throws {
            let path = try File.Path("/a/b/c")
            #expect(path.parent?.string == "/a/b")
            #expect(path.parent?.parent?.string == "/a")
            #expect(path.parent?.parent?.parent?.string == "/")
            #expect(path.parent?.parent?.parent?.parent == nil)
        }

        @Test("Appending string component")
        func appendingString() throws {
            let path = try File.Path("/usr/local")
            let newPath = path.appending("bin")
            #expect(newPath.string == "/usr/local/bin")
        }

        @Test("Appending Component")
        func appendingComponent() throws {
            let path = try File.Path("/usr/local")
            let component = try File.Path.Component("bin")
            let newPath = path.appending(component)
            #expect(newPath.string == "/usr/local/bin")
        }

        @Test("Appending another path")
        func appendingPath() throws {
            let base = try File.Path("/usr")
            let suffix = try File.Path("local/bin")
            let newPath = base.appending(suffix)
            #expect(newPath.string == "/usr/local/bin")
        }

        // MARK: - Introspection

        @Test("Last component of path")
        func lastComponent() throws {
            let path = try File.Path("/usr/local/bin")
            #expect(path.lastComponent?.string == "bin")
        }

        @Test("Last component of single component")
        func lastComponentOfSingle() throws {
            let path = try File.Path("file.txt")
            #expect(path.lastComponent?.string == "file.txt")
        }

        @Test("Extension of file")
        func extensionOfFile() throws {
            let path = try File.Path("/tmp/file.txt")
            #expect(path.extension == "txt")
        }

        @Test("Extension of file with multiple dots")
        func extensionOfFileWithMultipleDots() throws {
            let path = try File.Path("/tmp/file.tar.gz")
            #expect(path.extension == "gz")
        }

        @Test("Extension of directory (none)")
        func extensionOfDirectory() throws {
            let path = try File.Path("/usr/local/bin")
            #expect(path.extension == nil)
        }

        @Test("Stem of file")
        func stemOfFile() throws {
            let path = try File.Path("/tmp/file.txt")
            #expect(path.stem == "file")
        }

        @Test("Stem of file with multiple dots")
        func stemOfFileWithMultipleDots() throws {
            let path = try File.Path("/tmp/file.tar.gz")
            #expect(path.stem == "file.tar")
        }

        @Test("isAbsolute for absolute path")
        func isAbsoluteForAbsolutePath() throws {
            let path = try File.Path("/usr/bin")
            #expect(path.isAbsolute == true)
            #expect(path.isRelative == false)
        }

        @Test("isAbsolute for relative path")
        func isAbsoluteForRelativePath() throws {
            let path = try File.Path("usr/bin")
            #expect(path.isAbsolute == false)
            #expect(path.isRelative == true)
        }

        // MARK: - Conversion

        @Test("String conversion")
        func stringConversion() throws {
            let path = try File.Path("/usr/local/bin")
            #expect(path.string == "/usr/local/bin")
        }

        @Test("FilePath conversion")
        func filePathConversion() throws {
            let path = try File.Path("/usr/local/bin")
            #expect(path.filePath == FilePath("/usr/local/bin"))
        }

        // MARK: - Operators

        @Test("Slash operator with string")
        func slashOperatorWithString() throws {
            let path = try File.Path("/usr")
            let newPath = path / "local" / "bin"
            #expect(newPath.string == "/usr/local/bin")
        }

        @Test("Slash operator with Component")
        func slashOperatorWithComponent() throws {
            let path = try File.Path("/usr")
            let component = try File.Path.Component("local")
            let newPath = path / component
            #expect(newPath.string == "/usr/local")
        }

        @Test("Slash operator with Path")
        func slashOperatorWithPath() throws {
            let base = try File.Path("/usr")
            let suffix = try File.Path("local/bin")
            let newPath = base / suffix
            #expect(newPath.string == "/usr/local/bin")
        }

        // MARK: - Protocols

        @Test("Hashable conformance")
        func hashableConformance() throws {
            let path1 = try File.Path("/usr/local")
            let path2 = try File.Path("/usr/local")
            let path3 = try File.Path("/usr/bin")

            #expect(path1.hashValue == path2.hashValue)
            #expect(path1.hashValue != path3.hashValue)
        }

        @Test("Equatable conformance")
        func equatableConformance() throws {
            let path1 = try File.Path("/usr/local")
            let path2 = try File.Path("/usr/local")
            let path3 = try File.Path("/usr/bin")

            #expect(path1 == path2)
            #expect(path1 != path3)
        }

        @Test("CustomStringConvertible")
        func customStringConvertible() throws {
            let path = try File.Path("/usr/local/bin")
            #expect(path.description == "/usr/local/bin")
        }

        @Test("CustomDebugStringConvertible")
        func customDebugStringConvertible() throws {
            let path = try File.Path("/usr/local")
            #expect(path.debugDescription.contains("File.Path"))
            #expect(path.debugDescription.contains("/usr/local"))
        }

        @Test("ExpressibleByStringLiteral")
        func expressibleByStringLiteral() {
            let path: File.Path = "/usr/local/bin"
            #expect(path.string == "/usr/local/bin")
        }

        @Test("Use in Set")
        func useInSet() throws {
            let path1 = try File.Path("/usr/local")
            let path2 = try File.Path("/usr/local")
            let path3 = try File.Path("/usr/bin")

            let set: Set<File.Path> = [path1, path2, path3]
            #expect(set.count == 2)
        }

        @Test("Use as Dictionary key")
        func useAsDictionaryKey() throws {
            let path1 = try File.Path("/usr/local")
            let path2 = try File.Path("/usr/bin")

            var dict: [File.Path: Int] = [:]
            dict[path1] = 1
            dict[path2] = 2

            #expect(dict[path1] == 1)
            #expect(dict[path2] == 2)
        }
    }
}
