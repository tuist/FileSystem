//
//  File.System.Create.Directory Tests.swift
//  swift-file-system
//
//  Created by Coen ten Thije Boonkkamp on 18/12/2025.
//

import Foundation
import Testing

@testable import File_System_Primitives

extension File.System.Test.Unit {
    @Suite("File.System.Create.Directory")
    struct CreateDirectory {

        // MARK: - Test Fixtures

        private func uniquePath() -> String {
            "/tmp/create-dir-test-\(UUID().uuidString)"
        }

        private func cleanup(_ path: String) {
            try? FileManager.default.removeItem(atPath: path)
        }

        // MARK: - create() basic

        @Test("Create directory at path")
        func createDirectory() throws {
            let path = uniquePath()
            defer { cleanup(path) }

            let filePath = try File.Path(path)
            try File.System.Create.Directory.create(at: filePath)

            #expect(FileManager.default.fileExists(atPath: path))
            var isDir: ObjCBool = false
            _ = FileManager.default.fileExists(atPath: path, isDirectory: &isDir)
            #expect(isDir.boolValue == true)
        }

        @Test("Create directory throws if already exists")
        func createDirectoryAlreadyExists() throws {
            let path = uniquePath()
            defer { cleanup(path) }

            try FileManager.default.createDirectory(
                atPath: path,
                withIntermediateDirectories: false
            )

            let filePath = try File.Path(path)
            #expect(throws: File.System.Create.Directory.Error.self) {
                try File.System.Create.Directory.create(at: filePath)
            }
        }

        @Test("Create directory throws if parent doesn't exist")
        func createDirectoryParentNotFound() throws {
            let nonExistentParent = uniquePath()
            let path = "\(nonExistentParent)/child"

            let filePath = try File.Path(path)
            #expect(throws: File.System.Create.Directory.Error.self) {
                try File.System.Create.Directory.create(at: filePath)
            }
        }

        // MARK: - create() with options

        @Test("Create directory with createIntermediates")
        func createDirectoryWithIntermediates() throws {
            let basePath = uniquePath()
            let path = "\(basePath)/a/b/c"
            defer { cleanup(basePath) }

            let filePath = try File.Path(path)
            let options = File.System.Create.Directory.Options(createIntermediates: true)
            try File.System.Create.Directory.create(at: filePath, options: options)

            #expect(FileManager.default.fileExists(atPath: path))
            #expect(FileManager.default.fileExists(atPath: "\(basePath)/a"))
            #expect(FileManager.default.fileExists(atPath: "\(basePath)/a/b"))
        }

        @Test("Create directory without createIntermediates fails for nested path")
        func createDirectoryWithoutIntermediatesFails() throws {
            let basePath = uniquePath()
            let path = "\(basePath)/a/b/c"

            let filePath = try File.Path(path)
            let options = File.System.Create.Directory.Options(createIntermediates: false)

            #expect(throws: File.System.Create.Directory.Error.self) {
                try File.System.Create.Directory.create(at: filePath, options: options)
            }
        }

        @Test("Create directory with custom permissions")
        func createDirectoryWithPermissions() throws {
            let path = uniquePath()
            defer { cleanup(path) }

            let filePath = try File.Path(path)
            let permissions: File.System.Metadata.Permissions = [
                .ownerRead, .ownerWrite, .ownerExecute,
            ]
            let options = File.System.Create.Directory.Options(permissions: permissions)
            try File.System.Create.Directory.create(at: filePath, options: options)

            #expect(FileManager.default.fileExists(atPath: path))
            // Directory should exist (permission verification is platform-specific)
        }

        // MARK: - Options

        @Test("Options default values")
        func optionsDefaultValues() {
            let options = File.System.Create.Directory.Options()
            #expect(options.createIntermediates == false)
            #expect(options.permissions == nil)
        }

        @Test("Options custom values")
        func optionsCustomValues() {
            let permissions: File.System.Metadata.Permissions = [.ownerRead, .ownerWrite]
            let options = File.System.Create.Directory.Options(
                createIntermediates: true,
                permissions: permissions
            )
            #expect(options.createIntermediates == true)
            #expect(options.permissions == permissions)
        }

        // MARK: - Async variants

        @Test("Async create directory")
        func asyncCreateDirectory() async throws {
            let path = uniquePath()
            defer { cleanup(path) }

            let filePath = try File.Path(path)
            try await File.System.Create.Directory.create(at: filePath)

            #expect(FileManager.default.fileExists(atPath: path))
        }

        @Test("Async create directory with options")
        func asyncCreateDirectoryWithOptions() async throws {
            let basePath = uniquePath()
            let path = "\(basePath)/nested/dir"
            defer { cleanup(basePath) }

            let filePath = try File.Path(path)
            let options = File.System.Create.Directory.Options(createIntermediates: true)
            try await File.System.Create.Directory.create(at: filePath, options: options)

            #expect(FileManager.default.fileExists(atPath: path))
        }

        // MARK: - Error descriptions

        @Test("alreadyExists error description")
        func alreadyExistsErrorDescription() throws {
            let path = try File.Path("/tmp/existing")
            let error = File.System.Create.Directory.Error.alreadyExists(path)
            #expect(error.description.contains("Directory already exists"))
            #expect(error.description.contains("/tmp/existing"))
        }

        @Test("permissionDenied error description")
        func permissionDeniedErrorDescription() throws {
            let path = try File.Path("/root/forbidden")
            let error = File.System.Create.Directory.Error.permissionDenied(path)
            #expect(error.description.contains("Permission denied"))
        }

        @Test("parentDirectoryNotFound error description")
        func parentDirectoryNotFoundErrorDescription() throws {
            let path = try File.Path("/nonexistent/dir")
            let error = File.System.Create.Directory.Error.parentDirectoryNotFound(path)
            #expect(error.description.contains("Parent directory not found"))
        }

        @Test("createFailed error description")
        func createFailedErrorDescription() {
            let error = File.System.Create.Directory.Error.createFailed(
                errno: 22,
                message: "Invalid argument"
            )
            #expect(error.description.contains("Create failed"))
            #expect(error.description.contains("Invalid argument"))
            #expect(error.description.contains("22"))
        }

        // MARK: - Error Equatable

        @Test("Errors are equatable")
        func errorsAreEquatable() throws {
            let path1 = try File.Path("/tmp/a")
            let path2 = try File.Path("/tmp/a")
            let path3 = try File.Path("/tmp/b")

            #expect(
                File.System.Create.Directory.Error.alreadyExists(path1)
                    == File.System.Create.Directory.Error.alreadyExists(path2)
            )
            #expect(
                File.System.Create.Directory.Error.alreadyExists(path1)
                    != File.System.Create.Directory.Error.alreadyExists(path3)
            )
            #expect(
                File.System.Create.Directory.Error.alreadyExists(path1)
                    != File.System.Create.Directory.Error.permissionDenied(path1)
            )
        }
    }
}
