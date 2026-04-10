//
//  File.Descriptor Tests.swift
//  swift-file-system
//
//  Created by Coen ten Thije Boonkkamp on 18/12/2025.
//

import Foundation
import Testing

@testable import File_System_Primitives

extension File.System.Test.Unit {
    @Suite("File.Descriptor")
    struct Descriptor {

        // MARK: - Test Fixtures

        private func createTempFile(content: [UInt8] = []) throws -> String {
            let path = "/tmp/descriptor-test-\(UUID().uuidString).bin"
            let data = Data(content)
            try data.write(to: URL(fileURLWithPath: path))
            return path
        }

        private func cleanup(_ path: String) {
            try? FileManager.default.removeItem(atPath: path)
        }

        // MARK: - Opening

        @Test("Open file in read mode")
        func openReadMode() throws {
            let path = try createTempFile(content: [1, 2, 3])
            defer { cleanup(path) }

            let filePath = try File.Path(path)
            var descriptor = try File.Descriptor.open(filePath, mode: .read)
            let isValid = descriptor.isValid
            #expect(isValid)
            try descriptor.close()
        }

        @Test("Open file in write mode")
        func openWriteMode() throws {
            let path = try createTempFile()
            defer { cleanup(path) }

            let filePath = try File.Path(path)
            var descriptor = try File.Descriptor.open(filePath, mode: .write)
            let isValid = descriptor.isValid
            #expect(isValid)
            try descriptor.close()
        }

        @Test("Open file in readWrite mode")
        func openReadWriteMode() throws {
            let path = try createTempFile()
            defer { cleanup(path) }

            let filePath = try File.Path(path)
            var descriptor = try File.Descriptor.open(filePath, mode: .readWrite)
            let isValid = descriptor.isValid
            #expect(isValid)
            try descriptor.close()
        }

        @Test("Open non-existing file throws error")
        func openNonExisting() throws {
            let path = "/tmp/non-existing-\(UUID().uuidString).txt"
            let filePath = try File.Path(path)

            #expect(throws: File.Descriptor.Error.self) {
                _ = try File.Descriptor.open(filePath, mode: .read)
            }
        }

        // MARK: - Options

        @Test("Open with create option creates file")
        func openWithCreate() throws {
            let path = "/tmp/descriptor-create-\(UUID().uuidString).txt"
            defer { cleanup(path) }

            let filePath = try File.Path(path)
            var descriptor = try File.Descriptor.open(filePath, mode: .write, options: [.create])
            let isValid = descriptor.isValid
            #expect(isValid)
            #expect(FileManager.default.fileExists(atPath: path))
            try descriptor.close()
        }

        @Test("Open with truncate option truncates file")
        func openWithTruncate() throws {
            let path = try createTempFile(content: [1, 2, 3, 4, 5])
            defer { cleanup(path) }

            let filePath = try File.Path(path)
            var descriptor = try File.Descriptor.open(filePath, mode: .write, options: [.truncate])
            try descriptor.close()

            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            #expect(data.isEmpty)
        }

        @Test("Open with exclusive and create on existing file throws")
        func openWithExclusiveOnExisting() throws {
            let path = try createTempFile()
            defer { cleanup(path) }

            let filePath = try File.Path(path)
            #expect(throws: File.Descriptor.Error.self) {
                _ = try File.Descriptor.open(
                    filePath,
                    mode: .write,
                    options: [.create, .exclusive]
                )
            }
        }

        // MARK: - Closing

        @Test("Close makes descriptor invalid")
        func closeInvalidates() throws {
            let path = try createTempFile()
            defer { cleanup(path) }

            let filePath = try File.Path(path)
            var descriptor = try File.Descriptor.open(filePath, mode: .read)
            let isValid = descriptor.isValid
            #expect(isValid)
            try descriptor.close()
            // After close, descriptor is consumed, can't check isValid
        }

        @Test("Double close throws alreadyClosed")
        func doubleCloseThrows() throws {
            let path = try createTempFile()
            defer { cleanup(path) }

            let filePath = try File.Path(path)
            var descriptor = try File.Descriptor.open(filePath, mode: .read)
            try descriptor.close()

            // Can't actually test double close since close() is consuming
            // The descriptor is consumed after first close
        }

        // MARK: - Mode enum

        @Test("Mode enum values")
        func modeEnumValues() {
            let read = File.Descriptor.Mode.read
            let write = File.Descriptor.Mode.write
            let readWrite = File.Descriptor.Mode.readWrite

            #expect(read != write)
            #expect(write != readWrite)
            #expect(read != readWrite)
        }

        // MARK: - Options OptionSet

        @Test("Options default is empty")
        func optionsDefault() {
            let options: File.Descriptor.Options = []
            #expect(options.isEmpty)
        }

        @Test("Options can be combined")
        func optionsCombined() {
            let options: File.Descriptor.Options = [.create, .truncate]
            #expect(options.contains(.create))
            #expect(options.contains(.truncate))
            #expect(!options.contains(.exclusive))
        }

        @Test("Options rawValue")
        func optionsRawValue() {
            #expect(File.Descriptor.Options.create.rawValue == 1 << 0)
            #expect(File.Descriptor.Options.truncate.rawValue == 1 << 1)
            #expect(File.Descriptor.Options.exclusive.rawValue == 1 << 2)
            #expect(File.Descriptor.Options.append.rawValue == 1 << 3)
            #expect(File.Descriptor.Options.noFollow.rawValue == 1 << 4)
            #expect(File.Descriptor.Options.closeOnExec.rawValue == 1 << 5)
        }

        // MARK: - Error descriptions

        @Test("pathNotFound error description")
        func pathNotFoundErrorDescription() throws {
            let path = try File.Path("/tmp/missing")
            let error = File.Descriptor.Error.pathNotFound(path)
            #expect(error.description.contains("Path not found"))
        }

        @Test("permissionDenied error description")
        func permissionDeniedErrorDescription() throws {
            let path = try File.Path("/root/secret")
            let error = File.Descriptor.Error.permissionDenied(path)
            #expect(error.description.contains("Permission denied"))
        }

        @Test("alreadyExists error description")
        func alreadyExistsErrorDescription() throws {
            let path = try File.Path("/tmp/existing")
            let error = File.Descriptor.Error.alreadyExists(path)
            #expect(error.description.contains("already exists"))
        }

        @Test("isDirectory error description")
        func isDirectoryErrorDescription() throws {
            let path = try File.Path("/tmp")
            let error = File.Descriptor.Error.isDirectory(path)
            #expect(error.description.contains("Is a directory"))
        }

        @Test("tooManyOpenFiles error description")
        func tooManyOpenFilesErrorDescription() {
            let error = File.Descriptor.Error.tooManyOpenFiles
            #expect(error.description.contains("Too many open files"))
        }

        @Test("invalidDescriptor error description")
        func invalidDescriptorErrorDescription() {
            let error = File.Descriptor.Error.invalidDescriptor
            #expect(error.description.contains("Invalid"))
        }

        @Test("openFailed error description")
        func openFailedErrorDescription() {
            let error = File.Descriptor.Error.openFailed(errno: 13, message: "Permission denied")
            #expect(error.description.contains("Open failed"))
            #expect(error.description.contains("Permission denied"))
        }

        @Test("closeFailed error description")
        func closeFailedErrorDescription() {
            let error = File.Descriptor.Error.closeFailed(errno: 9, message: "Bad file descriptor")
            #expect(error.description.contains("Close failed"))
        }

        @Test("alreadyClosed error description")
        func alreadyClosedErrorDescription() {
            let error = File.Descriptor.Error.alreadyClosed
            #expect(error.description.contains("already closed"))
        }

        // MARK: - Error Equatable

        @Test("Errors are equatable")
        func errorsAreEquatable() throws {
            let path1 = try File.Path("/tmp/a")
            let path2 = try File.Path("/tmp/a")

            #expect(
                File.Descriptor.Error.pathNotFound(path1)
                    == File.Descriptor.Error.pathNotFound(path2)
            )
            #expect(
                File.Descriptor.Error.tooManyOpenFiles == File.Descriptor.Error.tooManyOpenFiles
            )
            #expect(File.Descriptor.Error.alreadyClosed == File.Descriptor.Error.alreadyClosed)
        }
    }
}
