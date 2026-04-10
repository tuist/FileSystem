//
//  File.System.Link.Symbolic Tests.swift
//  swift-file-system
//
//  Created by Coen ten Thije Boonkkamp on 18/12/2025.
//

import Foundation
import Testing

@testable import File_System_Primitives

extension File.System.Test.Unit {
    @Suite("File.System.Link.Symbolic")
    struct LinkSymbolic {

        // MARK: - Test Fixtures

        private func createTempFile(content: [UInt8] = [1, 2, 3]) throws -> String {
            let path = "/tmp/symlink-test-\(UUID().uuidString).bin"
            let data = Data(content)
            try data.write(to: URL(fileURLWithPath: path))
            return path
        }

        private func createTempDir() throws -> String {
            let path = "/tmp/symlink-dir-\(UUID().uuidString)"
            try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true)
            return path
        }

        private func cleanup(_ path: String) {
            try? FileManager.default.removeItem(atPath: path)
        }

        // MARK: - Create Symlink

        @Test("Create symlink to file")
        func createSymlinkToFile() throws {
            let targetPath = try createTempFile(content: [1, 2, 3])
            let linkPath = "/tmp/link-\(UUID().uuidString)"
            defer {
                cleanup(targetPath)
                cleanup(linkPath)
            }

            let target = try File.Path(targetPath)
            let link = try File.Path(linkPath)

            try File.System.Link.Symbolic.create(at: link, pointingTo: target)

            // Verify symlink exists
            var isDir: ObjCBool = false
            #expect(FileManager.default.fileExists(atPath: linkPath, isDirectory: &isDir))

            // Verify it's a symlink
            let attrs = try FileManager.default.attributesOfItem(atPath: linkPath)
            #expect(attrs[.type] as? FileAttributeType == .typeSymbolicLink)
        }

        @Test("Create symlink to directory")
        func createSymlinkToDirectory() throws {
            let targetPath = try createTempDir()
            let linkPath = "/tmp/link-\(UUID().uuidString)"
            defer {
                cleanup(targetPath)
                cleanup(linkPath)
            }

            let target = try File.Path(targetPath)
            let link = try File.Path(linkPath)

            try File.System.Link.Symbolic.create(at: link, pointingTo: target)

            let attrs = try FileManager.default.attributesOfItem(atPath: linkPath)
            #expect(attrs[.type] as? FileAttributeType == .typeSymbolicLink)
        }

        @Test("Symlink points to correct target")
        func symlinkPointsToCorrectTarget() throws {
            let targetPath = try createTempFile(content: [10, 20, 30])
            let linkPath = "/tmp/link-\(UUID().uuidString)"
            defer {
                cleanup(targetPath)
                cleanup(linkPath)
            }

            let target = try File.Path(targetPath)
            let link = try File.Path(linkPath)

            try File.System.Link.Symbolic.create(at: link, pointingTo: target)

            // Read through symlink
            let data = try Data(contentsOf: URL(fileURLWithPath: linkPath))
            #expect([UInt8](data) == [10, 20, 30])
        }

        @Test("Create symlink to non-existent target succeeds")
        func createSymlinkToNonExistentTarget() throws {
            let targetPath = "/tmp/non-existent-target-\(UUID().uuidString)"
            let linkPath = "/tmp/link-\(UUID().uuidString)"
            defer {
                cleanup(linkPath)
            }

            let target = try File.Path(targetPath)
            let link = try File.Path(linkPath)

            // Creating symlink to non-existent target should succeed
            // (it's a dangling symlink, but that's allowed)
            try File.System.Link.Symbolic.create(at: link, pointingTo: target)

            let attrs = try FileManager.default.attributesOfItem(atPath: linkPath)
            #expect(attrs[.type] as? FileAttributeType == .typeSymbolicLink)
        }

        // MARK: - Error Cases

        @Test("Create symlink at existing path throws alreadyExists")
        func createSymlinkAtExistingPathThrows() throws {
            let targetPath = try createTempFile()
            let linkPath = try createTempFile()
            defer {
                cleanup(targetPath)
                cleanup(linkPath)
            }

            let target = try File.Path(targetPath)
            let link = try File.Path(linkPath)

            #expect(throws: File.System.Link.Symbolic.Error.alreadyExists(link)) {
                try File.System.Link.Symbolic.create(at: link, pointingTo: target)
            }
        }

        // MARK: - Error Descriptions

        @Test("targetNotFound error description")
        func targetNotFoundErrorDescription() throws {
            let path = try File.Path("/tmp/missing")
            let error = File.System.Link.Symbolic.Error.targetNotFound(path)
            #expect(error.description.contains("Target not found"))
        }

        @Test("permissionDenied error description")
        func permissionDeniedErrorDescription() throws {
            let path = try File.Path("/root/secret")
            let error = File.System.Link.Symbolic.Error.permissionDenied(path)
            #expect(error.description.contains("Permission denied"))
        }

        @Test("alreadyExists error description")
        func alreadyExistsErrorDescription() throws {
            let path = try File.Path("/tmp/existing")
            let error = File.System.Link.Symbolic.Error.alreadyExists(path)
            #expect(error.description.contains("already exists"))
        }

        @Test("linkFailed error description")
        func linkFailedErrorDescription() {
            let error = File.System.Link.Symbolic.Error.linkFailed(
                errno: 22,
                message: "Invalid argument"
            )
            #expect(error.description.contains("Symlink creation failed"))
        }

        // MARK: - Error Equatable

        @Test("Errors are equatable")
        func errorsAreEquatable() throws {
            let path1 = try File.Path("/tmp/a")
            let path2 = try File.Path("/tmp/a")

            #expect(
                File.System.Link.Symbolic.Error.alreadyExists(path1)
                    == File.System.Link.Symbolic.Error.alreadyExists(path2)
            )
            #expect(
                File.System.Link.Symbolic.Error.targetNotFound(path1)
                    == File.System.Link.Symbolic.Error.targetNotFound(path2)
            )
        }
    }
}
