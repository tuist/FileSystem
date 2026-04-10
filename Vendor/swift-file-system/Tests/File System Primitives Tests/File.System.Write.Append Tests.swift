//
//  File.System.Write.Append Tests.swift
//  swift-file-system
//
//  Created by Coen ten Thije Boonkkamp on 18/12/2025.
//

import Foundation
import Testing

@testable import File_System_Primitives

extension File.System.Test.Unit {
    @Suite("File.System.Write.Append")
    struct WriteAppend {

        // MARK: - Test Fixtures

        private func createTempFile(content: [UInt8] = []) throws -> String {
            let path = "/tmp/append-test-\(UUID().uuidString).bin"
            let data = Data(content)
            try data.write(to: URL(fileURLWithPath: path))
            return path
        }

        private func cleanup(_ path: String) {
            try? FileManager.default.removeItem(atPath: path)
        }

        private func appendBytes(_ bytes: [UInt8], to pathString: String) throws {
            let filePath = try File.Path(pathString)
            var bytes = bytes
            try bytes.withUnsafeMutableBufferPointer { buffer in
                let span = Span<UInt8>(_unsafeElements: buffer)
                try File.System.Write.Append.append(span, to: filePath)
            }
        }

        // MARK: - Basic Append

        @Test("Append to existing file")
        func appendToExistingFile() throws {
            let path = try createTempFile(content: [1, 2, 3])
            defer { cleanup(path) }

            try appendBytes([4, 5, 6], to: path)

            let data = try [UInt8](Data(contentsOf: URL(fileURLWithPath: path)))
            #expect(data == [1, 2, 3, 4, 5, 6])
        }

        @Test("Append creates file if not exists")
        func appendCreatesFileIfNotExists() throws {
            let path = "/tmp/append-new-\(UUID().uuidString).bin"
            defer { cleanup(path) }

            try appendBytes([10, 20, 30], to: path)

            #expect(FileManager.default.fileExists(atPath: path))

            let data = try [UInt8](Data(contentsOf: URL(fileURLWithPath: path)))
            #expect(data == [10, 20, 30])
        }

        @Test("Append empty data")
        func appendEmptyData() throws {
            let path = try createTempFile(content: [1, 2, 3])
            defer { cleanup(path) }

            try appendBytes([], to: path)

            let data = try [UInt8](Data(contentsOf: URL(fileURLWithPath: path)))
            #expect(data == [1, 2, 3])
        }

        @Test("Multiple appends")
        func multipleAppends() throws {
            let path = try createTempFile(content: [])
            defer { cleanup(path) }

            try appendBytes([1, 2], to: path)
            try appendBytes([3, 4], to: path)
            try appendBytes([5, 6], to: path)

            let data = try [UInt8](Data(contentsOf: URL(fileURLWithPath: path)))
            #expect(data == [1, 2, 3, 4, 5, 6])
        }

        @Test("Append to empty file")
        func appendToEmptyFile() throws {
            let path = try createTempFile(content: [])
            defer { cleanup(path) }

            try appendBytes([1, 2, 3], to: path)

            let data = try [UInt8](Data(contentsOf: URL(fileURLWithPath: path)))
            #expect(data == [1, 2, 3])
        }

        @Test("Append large data")
        func appendLargeData() throws {
            let path = try createTempFile(content: [])
            defer { cleanup(path) }

            let largeData = [UInt8](repeating: 42, count: 100_000)
            try appendBytes(largeData, to: path)

            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            #expect(data.count == 100_000)
        }

        // MARK: - Error Cases

        @Test("Append to directory throws isDirectory")
        func appendToDirectoryThrows() throws {
            let dirPath = "/tmp/append-dir-\(UUID().uuidString)"
            try FileManager.default.createDirectory(
                atPath: dirPath,
                withIntermediateDirectories: true
            )
            defer { cleanup(dirPath) }

            let path = try File.Path(dirPath)

            #expect(throws: File.System.Write.Append.Error.isDirectory(path)) {
                var bytes: [UInt8] = [1, 2, 3]
                try bytes.withUnsafeMutableBufferPointer { buffer in
                    let span = Span<UInt8>(_unsafeElements: buffer)
                    try File.System.Write.Append.append(span, to: path)
                }
            }
        }

        // MARK: - Error Descriptions

        @Test("pathNotFound error description")
        func pathNotFoundErrorDescription() throws {
            let path = try File.Path("/tmp/missing/nested/file.txt")
            let error = File.System.Write.Append.Error.pathNotFound(path)
            #expect(error.description.contains("Path not found"))
        }

        @Test("permissionDenied error description")
        func permissionDeniedErrorDescription() throws {
            let path = try File.Path("/root/secret.txt")
            let error = File.System.Write.Append.Error.permissionDenied(path)
            #expect(error.description.contains("Permission denied"))
        }

        @Test("isDirectory error description")
        func isDirectoryErrorDescription() throws {
            let path = try File.Path("/tmp")
            let error = File.System.Write.Append.Error.isDirectory(path)
            #expect(error.description.contains("Is a directory"))
        }

        @Test("writeFailed error description")
        func writeFailedErrorDescription() {
            let error = File.System.Write.Append.Error.writeFailed(
                errno: 28,
                message: "No space left"
            )
            #expect(error.description.contains("Write failed"))
            #expect(error.description.contains("No space left"))
        }

        // MARK: - Error Equatable

        @Test("Errors are equatable")
        func errorsAreEquatable() throws {
            let path1 = try File.Path("/tmp/a")
            let path2 = try File.Path("/tmp/a")

            #expect(
                File.System.Write.Append.Error.pathNotFound(path1)
                    == File.System.Write.Append.Error.pathNotFound(path2)
            )
            #expect(
                File.System.Write.Append.Error.isDirectory(path1)
                    == File.System.Write.Append.Error.isDirectory(path2)
            )
        }
    }
}
