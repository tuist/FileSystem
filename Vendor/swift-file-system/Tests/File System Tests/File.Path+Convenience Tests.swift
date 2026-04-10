//
//  File.Path+Convenience Tests.swift
//  swift-file-system
//
//  Created by Coen ten Thije Boonkkamp on 18/12/2025.
//

import Foundation
import Testing

@testable import File_System

extension File.System.Test.Unit {
    @Suite("File.Path+Convenience")
    struct PathConvenience {

        // MARK: - with(.extension)

        @Test("with extension sets extension")
        func withExtensionSetsExtension() {
            let path: File.Path = "/tmp/data.json"
            let result = path.with(.extension, "txt")
            #expect(result.string == "/tmp/data.txt")
        }

        @Test("with extension replaces existing extension")
        func withExtensionReplacesExtension() {
            let path: File.Path = "/tmp/file.tar.gz"
            let result = path.with(.extension, "bz2")
            #expect(result.string == "/tmp/file.tar.bz2")
        }

        @Test("with extension on file without extension")
        func withExtensionOnNoExtension() {
            let path: File.Path = "/tmp/Makefile"
            let result = path.with(.extension, "bak")
            #expect(result.string == "/tmp/Makefile.bak")
        }

        // MARK: - with(.lastComponent)

        @Test("with lastComponent replaces filename")
        func withLastComponentReplacesFilename() {
            let path: File.Path = "/tmp/data.json"
            let result = path.with(.lastComponent, "config.yaml")
            #expect(result.string == "/tmp/config.yaml")
        }

        @Test("with lastComponent on nested path")
        func withLastComponentOnNestedPath() {
            let path: File.Path = "/usr/local/bin/swift"
            let result = path.with(.lastComponent, "swiftc")
            #expect(result.string == "/usr/local/bin/swiftc")
        }

        // MARK: - removing(.extension)

        @Test("removing extension removes extension")
        func removingExtensionRemovesExtension() {
            let path: File.Path = "/tmp/data.json"
            let result = path.removing(.extension)
            #expect(result.string == "/tmp/data")
        }

        @Test("removing extension on file without extension")
        func removingExtensionOnNoExtension() {
            let path: File.Path = "/tmp/Makefile"
            let result = path.removing(.extension)
            #expect(result.string == "/tmp/Makefile")
        }

        @Test("removing extension on double extension")
        func removingExtensionOnDoubleExtension() {
            let path: File.Path = "/tmp/file.tar.gz"
            let result = path.removing(.extension)
            #expect(result.string == "/tmp/file.tar")
        }

        // MARK: - removing(.lastComponent)

        @Test("removing lastComponent returns parent")
        func removingLastComponentReturnsParent() {
            let path: File.Path = "/tmp/subdir/file.txt"
            let result = path.removing(.lastComponent)
            #expect(result.string == "/tmp/subdir")
        }

        // MARK: - components

        @Test("components returns all components")
        func componentsReturnsAllComponents() {
            let path: File.Path = "/usr/local/bin"
            let components = path.components
            #expect(components.count == 3)
            #expect(components[0].string == "usr")
            #expect(components[1].string == "local")
            #expect(components[2].string == "bin")
        }

        @Test("components on single component path")
        func componentsOnSingleComponent() {
            let path: File.Path = "/tmp"
            let components = path.components
            #expect(components.count == 1)
            #expect(components[0].string == "tmp")
        }

        // MARK: - count

        @Test("count returns component count")
        func countReturnsComponentCount() {
            let path: File.Path = "/usr/local/bin/swift"
            #expect(path.count == 4)
        }

        @Test("root path is not empty")
        func rootPathIsNotEmpty() {
            let path: File.Path = "/"
            #expect(!path.isEmpty)  // "/" contains the root component
        }

        // MARK: - hasPrefix

        @Test("hasPrefix returns true for matching prefix")
        func hasPrefixReturnsTrueForMatch() {
            let path: File.Path = "/usr/local/bin/swift"
            let prefix: File.Path = "/usr/local"
            #expect(path.hasPrefix(prefix) == true)
        }

        @Test("hasPrefix returns false for non-matching prefix")
        func hasPrefixReturnsFalseForNonMatch() {
            let path: File.Path = "/usr/local/bin"
            let prefix: File.Path = "/var"
            #expect(path.hasPrefix(prefix) == false)
        }

        @Test("hasPrefix returns true for same path")
        func hasPrefixReturnsTrueForSamePath() {
            let path: File.Path = "/usr/local"
            #expect(path.hasPrefix(path) == true)
        }

        @Test("hasPrefix returns false when prefix is longer")
        func hasPrefixReturnsFalseWhenPrefixLonger() {
            let path: File.Path = "/usr"
            let prefix: File.Path = "/usr/local/bin"
            #expect(path.hasPrefix(prefix) == false)
        }

        // MARK: - relative(to:)

        @Test("relative returns relative path")
        func relativeReturnsRelativePath() {
            let path: File.Path = "/usr/local/bin/swift"
            let base: File.Path = "/usr/local"
            let result = path.relative(to: base)
            #expect(result?.string == "bin/swift")
        }

        @Test("relative returns nil when not a prefix")
        func relativeReturnsNilWhenNotPrefix() {
            let path: File.Path = "/usr/local/bin"
            let base: File.Path = "/var"
            #expect(path.relative(to: base) == nil)
        }

        @Test("relative returns nil for same path")
        func relativeReturnsNilForSamePath() {
            let path: File.Path = "/usr/local"
            #expect(path.relative(to: path) == nil)
        }

        @Test("relative with single component result")
        func relativeWithSingleComponentResult() {
            let path: File.Path = "/usr/local"
            let base: File.Path = "/usr"
            let result = path.relative(to: base)
            #expect(result?.string == "local")
        }
    }
}
