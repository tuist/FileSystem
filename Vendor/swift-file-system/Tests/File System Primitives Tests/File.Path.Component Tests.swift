//
//  File.Path.Component Tests.swift
//  swift-file-system
//
//  Created by Coen ten Thije Boonkkamp on 18/12/2025.
//

import SystemPackage
import Testing

@testable import File_System_Primitives

extension File.System.Test.Unit {
    @Suite("File.Path.Component")
    struct PathComponent {

        // MARK: - Initialization

        @Test("Valid component initialization")
        func validComponent() throws {
            let component = try File.Path.Component("file.txt")
            #expect(component.string == "file.txt")
        }

        @Test("Component with special characters")
        func componentWithSpecialCharacters() throws {
            let component = try File.Path.Component("file-name_v2.0.txt")
            #expect(component.string == "file-name_v2.0.txt")
        }

        @Test("Component with spaces")
        func componentWithSpaces() throws {
            let component = try File.Path.Component("my file.txt")
            #expect(component.string == "my file.txt")
        }

        @Test("Empty component throws error")
        func emptyComponent() {
            let emptyString = ""
            #expect(throws: File.Path.Component.Error.empty) {
                try File.Path.Component(emptyString)
            }
        }

        @Test("Component with path separator throws error")
        func componentWithPathSeparator() {
            let componentWithSep = "foo/bar"
            #expect(throws: File.Path.Component.Error.containsPathSeparator) {
                try File.Path.Component(componentWithSep)
            }
        }

        // MARK: - Properties

        @Test("String property")
        func stringProperty() throws {
            let component = try File.Path.Component("file.txt")
            #expect(component.string == "file.txt")
        }

        @Test("Extension of component with extension")
        func extensionOfComponent() throws {
            let component = try File.Path.Component("file.txt")
            #expect(component.extension == "txt")
        }

        @Test("Extension of component without extension")
        func extensionOfComponentWithoutExtension() throws {
            let component = try File.Path.Component("Makefile")
            #expect(component.extension == nil)
        }

        @Test("Extension of component with multiple dots")
        func extensionOfComponentWithMultipleDots() throws {
            let component = try File.Path.Component("file.tar.gz")
            #expect(component.extension == "gz")
        }

        @Test("Stem of component with extension")
        func stemOfComponent() throws {
            let component = try File.Path.Component("file.txt")
            #expect(component.stem == "file")
        }

        @Test("Stem of component without extension")
        func stemOfComponentWithoutExtension() throws {
            let component = try File.Path.Component("Makefile")
            #expect(component.stem == "Makefile")
        }

        @Test("Stem of component with multiple dots")
        func stemOfComponentWithMultipleDots() throws {
            let component = try File.Path.Component("file.tar.gz")
            #expect(component.stem == "file.tar")
        }

        @Test("FilePathComponent conversion")
        func filePathComponentConversion() throws {
            let component = try File.Path.Component("file.txt")
            #expect(component.filePathComponent == FilePath.Component("file.txt"))
        }

        // MARK: - Protocols

        @Test("Hashable conformance")
        func hashableConformance() throws {
            let comp1 = try File.Path.Component("file.txt")
            let comp2 = try File.Path.Component("file.txt")
            let comp3 = try File.Path.Component("other.txt")

            #expect(comp1.hashValue == comp2.hashValue)
            #expect(comp1.hashValue != comp3.hashValue)
        }

        @Test("Equatable conformance")
        func equatableConformance() throws {
            let comp1 = try File.Path.Component("file.txt")
            let comp2 = try File.Path.Component("file.txt")
            let comp3 = try File.Path.Component("other.txt")

            #expect(comp1 == comp2)
            #expect(comp1 != comp3)
        }

        @Test("CustomStringConvertible")
        func customStringConvertible() throws {
            let component = try File.Path.Component("file.txt")
            #expect(component.description == "file.txt")
        }

        @Test("CustomDebugStringConvertible")
        func customDebugStringConvertible() throws {
            let component = try File.Path.Component("file.txt")
            #expect(component.debugDescription.contains("File.Path.Component"))
            #expect(component.debugDescription.contains("file.txt"))
        }

        @Test("ExpressibleByStringLiteral")
        func expressibleByStringLiteral() {
            let component: File.Path.Component = "file.txt"
            #expect(component.string == "file.txt")
        }

        @Test("Use in Set")
        func useInSet() throws {
            let comp1 = try File.Path.Component("file.txt")
            let comp2 = try File.Path.Component("file.txt")
            let comp3 = try File.Path.Component("other.txt")

            let set: Set<File.Path.Component> = [comp1, comp2, comp3]
            #expect(set.count == 2)
        }

        @Test("Use as Dictionary key")
        func useAsDictionaryKey() throws {
            let comp1 = try File.Path.Component("file.txt")
            let comp2 = try File.Path.Component("other.txt")

            var dict: [File.Path.Component: Int] = [:]
            dict[comp1] = 1
            dict[comp2] = 2

            #expect(dict[comp1] == 1)
            #expect(dict[comp2] == 2)
        }

        // MARK: - Integration with File.Path

        @Test("Component can be appended to path")
        func componentAppendedToPath() throws {
            let path = try File.Path("/usr/local")
            let component = try File.Path.Component("bin")
            let newPath = path.appending(component)
            #expect(newPath.string == "/usr/local/bin")
        }

        @Test("Path lastComponent returns component")
        func pathLastComponentReturnsComponent() throws {
            let path = try File.Path("/usr/local/bin")
            let lastComp = path.lastComponent
            #expect(lastComp?.string == "bin")
        }
    }
}
