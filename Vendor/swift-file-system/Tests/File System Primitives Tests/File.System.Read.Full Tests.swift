//
//  File.System.Read.Full Tests.swift
//  swift-file-system
//
//  Created by Coen ten Thije Boonkkamp on 18/12/2025.
//

import Foundation
import Testing

@testable import File_System_Primitives

extension File.System.Test.Unit {
    @Suite("File.System.Read.Full")
    struct ReadFull {

        // MARK: - Test Fixtures

        private func createTempFile(content: [UInt8]) throws -> String {
            let path = "/tmp/read-test-\(UUID().uuidString).bin"
            let data = Data(content)
            try data.write(to: URL(fileURLWithPath: path))
            return path
        }

        private func createTempFile(string: String) throws -> String {
            let path = "/tmp/read-test-\(UUID().uuidString).txt"
            try string.write(toFile: path, atomically: true, encoding: .utf8)
            return path
        }

        private func createTempDirectory() throws -> String {
            let path = "/tmp/read-test-dir-\(UUID().uuidString)"
            try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true)
            return path
        }

        private func cleanup(_ path: String) {
            try? FileManager.default.removeItem(atPath: path)
        }

        // MARK: - Basic read

        @Test("Read small file")
        func readSmallFile() throws {
            let content: [UInt8] = [72, 101, 108, 108, 111]  // "Hello"
            let path = try createTempFile(content: content)
            defer { cleanup(path) }

            let filePath = try File.Path(path)
            let readContent = try File.System.Read.Full.read(from: filePath)

            #expect(readContent == content)
        }

        @Test("Read empty file")
        func readEmptyFile() throws {
            let path = try createTempFile(content: [])
            defer { cleanup(path) }

            let filePath = try File.Path(path)
            let readContent = try File.System.Read.Full.read(from: filePath)

            #expect(readContent.isEmpty)
        }

        @Test("Read file with text content")
        func readFileWithTextContent() throws {
            let text = "Hello, World!"
            let path = try createTempFile(string: text)
            defer { cleanup(path) }

            let filePath = try File.Path(path)
            let readContent = try File.System.Read.Full.read(from: filePath)
            let readString = String(decoding: readContent, as: UTF8.self)

            #expect(readString == text)
        }

        @Test("Read binary data")
        func readBinaryData() throws {
            // Binary content including null bytes and non-printable characters
            let content: [UInt8] = [0x00, 0x01, 0xFF, 0xFE, 0x7F, 0x80]
            let path = try createTempFile(content: content)
            defer { cleanup(path) }

            let filePath = try File.Path(path)
            let readContent = try File.System.Read.Full.read(from: filePath)

            #expect(readContent == content)
        }

        @Test("Read larger file")
        func readLargerFile() throws {
            // Create a 64KB file
            let content = [UInt8](repeating: 0xAB, count: 64 * 1024)
            let path = try createTempFile(content: content)
            defer { cleanup(path) }

            let filePath = try File.Path(path)
            let readContent = try File.System.Read.Full.read(from: filePath)

            #expect(readContent.count == 64 * 1024)
            #expect(readContent == content)
        }

        @Test("Read file with various byte values")
        func readFileWithVariousByteValues() throws {
            // All possible byte values
            let content = (0...255).map { UInt8($0) }
            let path = try createTempFile(content: content)
            defer { cleanup(path) }

            let filePath = try File.Path(path)
            let readContent = try File.System.Read.Full.read(from: filePath)

            #expect(readContent == content)
        }

        // MARK: - Error cases

        @Test("Read non-existing file throws pathNotFound")
        func readNonExistingFile() throws {
            let path = "/tmp/non-existing-\(UUID().uuidString).txt"
            let filePath = try File.Path(path)

            #expect(throws: File.System.Read.Full.Error.self) {
                try File.System.Read.Full.read(from: filePath)
            }
        }

        @Test("Read directory throws isDirectory")
        func readDirectory() throws {
            let path = try createTempDirectory()
            defer { cleanup(path) }

            let filePath = try File.Path(path)

            #expect(throws: File.System.Read.Full.Error.self) {
                try File.System.Read.Full.read(from: filePath)
            }
        }

        // MARK: - Async variants

        @Test("Async read file")
        func asyncReadFile() async throws {
            let content: [UInt8] = [1, 2, 3, 4, 5]
            let path = try createTempFile(content: content)
            defer { cleanup(path) }

            let filePath = try File.Path(path)
            let readContent = try await File.System.Read.Full.read(from: filePath)

            #expect(readContent == content)
        }

        @Test("Async read empty file")
        func asyncReadEmptyFile() async throws {
            let path = try createTempFile(content: [])
            defer { cleanup(path) }

            let filePath = try File.Path(path)
            let readContent = try await File.System.Read.Full.read(from: filePath)

            #expect(readContent.isEmpty)
        }

        // MARK: - Error descriptions

        @Test("pathNotFound error description")
        func pathNotFoundErrorDescription() throws {
            let path = try File.Path("/tmp/missing.txt")
            let error = File.System.Read.Full.Error.pathNotFound(path)
            #expect(error.description.contains("Path not found"))
            #expect(error.description.contains("/tmp/missing.txt"))
        }

        @Test("permissionDenied error description")
        func permissionDeniedErrorDescription() throws {
            let path = try File.Path("/root/secret.txt")
            let error = File.System.Read.Full.Error.permissionDenied(path)
            #expect(error.description.contains("Permission denied"))
        }

        @Test("isDirectory error description")
        func isDirectoryErrorDescription() throws {
            let path = try File.Path("/tmp")
            let error = File.System.Read.Full.Error.isDirectory(path)
            #expect(error.description.contains("Is a directory"))
        }

        @Test("readFailed error description")
        func readFailedErrorDescription() {
            let error = File.System.Read.Full.Error.readFailed(errno: 5, message: "I/O error")
            #expect(error.description.contains("Read failed"))
            #expect(error.description.contains("I/O error"))
            #expect(error.description.contains("5"))
        }

        @Test("tooManyOpenFiles error description")
        func tooManyOpenFilesErrorDescription() {
            let error = File.System.Read.Full.Error.tooManyOpenFiles
            #expect(error.description.contains("Too many open files"))
        }

        // MARK: - Error Equatable

        @Test("Errors are equatable")
        func errorsAreEquatable() throws {
            let path1 = try File.Path("/tmp/a")
            let path2 = try File.Path("/tmp/a")
            let path3 = try File.Path("/tmp/b")

            #expect(
                File.System.Read.Full.Error.pathNotFound(path1)
                    == File.System.Read.Full.Error.pathNotFound(path2)
            )
            #expect(
                File.System.Read.Full.Error.pathNotFound(path1)
                    != File.System.Read.Full.Error.pathNotFound(path3)
            )
            #expect(
                File.System.Read.Full.Error.pathNotFound(path1)
                    != File.System.Read.Full.Error.permissionDenied(path1)
            )
            #expect(
                File.System.Read.Full.Error.tooManyOpenFiles
                    == File.System.Read.Full.Error.tooManyOpenFiles
            )
        }
    }
}
