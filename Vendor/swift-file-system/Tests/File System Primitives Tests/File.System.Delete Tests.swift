//
//  File.System.Delete Tests.swift
//  swift-file-system
//
//  Created by Coen ten Thije Boonkkamp on 18/12/2025.
//

import Foundation
import Testing

@testable import File_System_Primitives

extension File.System.Test.Unit {
    @Suite("File.System.Delete")
    struct Delete {

        // MARK: - Test Fixtures

        private func createTempFile(content: String = "test") throws -> String {
            let path = "/tmp/delete-test-\(UUID().uuidString).txt"
            try content.write(toFile: path, atomically: true, encoding: .utf8)
            return path
        }

        private func createTempDirectory() throws -> String {
            let path = "/tmp/delete-test-dir-\(UUID().uuidString)"
            try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true)
            return path
        }

        private func createNestedDirectory() throws -> String {
            let basePath = "/tmp/delete-test-nested-\(UUID().uuidString)"
            let nestedPath = "\(basePath)/a/b/c"
            try FileManager.default.createDirectory(
                atPath: nestedPath,
                withIntermediateDirectories: true
            )
            // Add some files
            try "file1".write(toFile: "\(basePath)/file1.txt", atomically: true, encoding: .utf8)
            try "file2".write(toFile: "\(basePath)/a/file2.txt", atomically: true, encoding: .utf8)
            try "file3".write(
                toFile: "\(basePath)/a/b/file3.txt",
                atomically: true,
                encoding: .utf8
            )
            return basePath
        }

        private func cleanup(_ path: String) {
            try? FileManager.default.removeItem(atPath: path)
        }

        // MARK: - Delete file

        @Test("Delete existing file")
        func deleteExistingFile() throws {
            let path = try createTempFile()

            let filePath = try File.Path(path)
            try File.System.Delete.delete(at: filePath)

            #expect(!FileManager.default.fileExists(atPath: path))
        }

        @Test("Delete non-existing file throws pathNotFound")
        func deleteNonExistingFile() throws {
            let path = "/tmp/non-existing-\(UUID().uuidString).txt"
            let filePath = try File.Path(path)

            #expect(throws: File.System.Delete.Error.self) {
                try File.System.Delete.delete(at: filePath)
            }
        }

        // MARK: - Delete directory

        @Test("Delete empty directory")
        func deleteEmptyDirectory() throws {
            let path = try createTempDirectory()

            let filePath = try File.Path(path)
            try File.System.Delete.delete(at: filePath)

            #expect(!FileManager.default.fileExists(atPath: path))
        }

        @Test("Delete non-empty directory without recursive throws")
        func deleteNonEmptyDirectoryWithoutRecursive() throws {
            let basePath = try createNestedDirectory()
            defer { cleanup(basePath) }

            let filePath = try File.Path(basePath)

            #expect(throws: File.System.Delete.Error.self) {
                try File.System.Delete.delete(at: filePath)
            }

            // Directory should still exist
            #expect(FileManager.default.fileExists(atPath: basePath))
        }

        @Test("Delete non-empty directory with recursive option")
        func deleteNonEmptyDirectoryWithRecursive() throws {
            let basePath = try createNestedDirectory()

            let filePath = try File.Path(basePath)
            let options = File.System.Delete.Options(recursive: true)
            try File.System.Delete.delete(at: filePath, options: options)

            #expect(!FileManager.default.fileExists(atPath: basePath))
        }

        // MARK: - Options

        @Test("Options default values")
        func optionsDefaultValues() {
            let options = File.System.Delete.Options()
            #expect(options.recursive == false)
        }

        @Test("Options recursive true")
        func optionsRecursiveTrue() {
            let options = File.System.Delete.Options(recursive: true)
            #expect(options.recursive == true)
        }

        // MARK: - Async variants

        @Test("Async delete file")
        func asyncDeleteFile() async throws {
            let path = try createTempFile()

            let filePath = try File.Path(path)
            try await File.System.Delete.delete(at: filePath)

            #expect(!FileManager.default.fileExists(atPath: path))
        }

        @Test("Async delete directory with options")
        func asyncDeleteDirectoryWithOptions() async throws {
            let basePath = try createNestedDirectory()

            let filePath = try File.Path(basePath)
            let options = File.System.Delete.Options(recursive: true)
            try await File.System.Delete.delete(at: filePath, options: options)

            #expect(!FileManager.default.fileExists(atPath: basePath))
        }

        // MARK: - Error descriptions

        @Test("pathNotFound error description")
        func pathNotFoundErrorDescription() throws {
            let path = try File.Path("/tmp/missing.txt")
            let error = File.System.Delete.Error.pathNotFound(path)
            #expect(error.description.contains("Path not found"))
            #expect(error.description.contains("/tmp/missing.txt"))
        }

        @Test("permissionDenied error description")
        func permissionDeniedErrorDescription() throws {
            let path = try File.Path("/root/protected")
            let error = File.System.Delete.Error.permissionDenied(path)
            #expect(error.description.contains("Permission denied"))
        }

        @Test("isDirectory error description")
        func isDirectoryErrorDescription() throws {
            let path = try File.Path("/tmp/somedir")
            let error = File.System.Delete.Error.isDirectory(path)
            #expect(error.description.contains("Is a directory"))
            #expect(error.description.contains("recursive"))
        }

        @Test("directoryNotEmpty error description")
        func directoryNotEmptyErrorDescription() throws {
            let path = try File.Path("/tmp/nonempty")
            let error = File.System.Delete.Error.directoryNotEmpty(path)
            #expect(error.description.contains("Directory not empty"))
            #expect(error.description.contains("recursive"))
        }

        @Test("deleteFailed error description")
        func deleteFailedErrorDescription() {
            let error = File.System.Delete.Error.deleteFailed(
                errno: 16,
                message: "Device or resource busy"
            )
            #expect(error.description.contains("Delete failed"))
            #expect(error.description.contains("Device or resource busy"))
            #expect(error.description.contains("16"))
        }

        // MARK: - Error Equatable

        @Test("Errors are equatable")
        func errorsAreEquatable() throws {
            let path1 = try File.Path("/tmp/a")
            let path2 = try File.Path("/tmp/a")
            let path3 = try File.Path("/tmp/b")

            #expect(
                File.System.Delete.Error.pathNotFound(path1)
                    == File.System.Delete.Error.pathNotFound(path2)
            )
            #expect(
                File.System.Delete.Error.pathNotFound(path1)
                    != File.System.Delete.Error.pathNotFound(path3)
            )
            #expect(
                File.System.Delete.Error.pathNotFound(path1)
                    != File.System.Delete.Error.permissionDenied(path1)
            )
        }
    }
}
