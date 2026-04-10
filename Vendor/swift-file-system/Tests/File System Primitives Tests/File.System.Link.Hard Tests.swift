//
//  File.System.Link.Hard Tests.swift
//  swift-file-system
//
//  Created by Coen ten Thije Boonkkamp on 18/12/2025.
//

import Foundation
import Testing

@testable import File_System_Primitives

extension File.System.Test.Unit {
    @Suite("File.System.Link.Hard")
    struct LinkHard {

        // MARK: - Test Fixtures

        private func createTempFile(content: [UInt8] = [1, 2, 3]) throws -> String {
            let path = "/tmp/hardlink-test-\(UUID().uuidString).bin"
            let data = Data(content)
            try data.write(to: URL(fileURLWithPath: path))
            return path
        }

        private func cleanup(_ path: String) {
            try? FileManager.default.removeItem(atPath: path)
        }

        // MARK: - Create Hard Link

        @Test("Create hard link to file")
        func createHardLinkToFile() throws {
            let existingPath = try createTempFile(content: [1, 2, 3])
            let linkPath = "/tmp/hardlink-\(UUID().uuidString)"
            defer {
                cleanup(existingPath)
                cleanup(linkPath)
            }

            let existing = try File.Path(existingPath)
            let link = try File.Path(linkPath)

            try File.System.Link.Hard.create(at: link, to: existing)

            #expect(FileManager.default.fileExists(atPath: linkPath))

            // Both files should have same content
            let existingData = try Data(contentsOf: URL(fileURLWithPath: existingPath))
            let linkData = try Data(contentsOf: URL(fileURLWithPath: linkPath))
            #expect(existingData == linkData)
        }

        @Test("Hard link shares inode with original")
        func hardLinkSharesInode() throws {
            let existingPath = try createTempFile(content: [1, 2, 3])
            let linkPath = "/tmp/hardlink-\(UUID().uuidString)"
            defer {
                cleanup(existingPath)
                cleanup(linkPath)
            }

            let existing = try File.Path(existingPath)
            let link = try File.Path(linkPath)

            try File.System.Link.Hard.create(at: link, to: existing)

            // Get inode numbers
            let existingAttrs = try FileManager.default.attributesOfItem(atPath: existingPath)
            let linkAttrs = try FileManager.default.attributesOfItem(atPath: linkPath)

            let existingInode = existingAttrs[.systemFileNumber] as? UInt64
            let linkInode = linkAttrs[.systemFileNumber] as? UInt64

            #expect(existingInode == linkInode)
        }

        @Test("Modifying hard link modifies original")
        func modifyingHardLinkModifiesOriginal() throws {
            let existingPath = try createTempFile(content: [1, 2, 3])
            let linkPath = "/tmp/hardlink-\(UUID().uuidString)"
            defer {
                cleanup(existingPath)
                cleanup(linkPath)
            }

            let existing = try File.Path(existingPath)
            let link = try File.Path(linkPath)

            try File.System.Link.Hard.create(at: link, to: existing)

            // Modify through the link
            try Data([10, 20, 30]).write(to: URL(fileURLWithPath: linkPath))

            // Original should also be modified
            let originalData = try [UInt8](Data(contentsOf: URL(fileURLWithPath: existingPath)))
            #expect(originalData == [10, 20, 30])
        }

        @Test("Deleting original does not delete hard link")
        func deletingOriginalDoesNotDeleteHardLink() throws {
            let existingPath = try createTempFile(content: [1, 2, 3])
            let linkPath = "/tmp/hardlink-\(UUID().uuidString)"
            defer {
                cleanup(linkPath)
            }

            let existing = try File.Path(existingPath)
            let link = try File.Path(linkPath)

            try File.System.Link.Hard.create(at: link, to: existing)

            // Delete original
            try FileManager.default.removeItem(atPath: existingPath)

            // Hard link should still exist and have the data
            #expect(FileManager.default.fileExists(atPath: linkPath))
            let data = try [UInt8](Data(contentsOf: URL(fileURLWithPath: linkPath)))
            #expect(data == [1, 2, 3])
        }

        // MARK: - Error Cases

        @Test("Create hard link to non-existent file throws sourceNotFound")
        func createHardLinkToNonExistentThrows() throws {
            let existingPath = "/tmp/non-existent-\(UUID().uuidString)"
            let linkPath = "/tmp/hardlink-\(UUID().uuidString)"

            let existing = try File.Path(existingPath)
            let link = try File.Path(linkPath)

            #expect(throws: File.System.Link.Hard.Error.sourceNotFound(existing)) {
                try File.System.Link.Hard.create(at: link, to: existing)
            }
        }

        @Test("Create hard link at existing path throws alreadyExists")
        func createHardLinkAtExistingPathThrows() throws {
            let existingPath = try createTempFile()
            let linkPath = try createTempFile()
            defer {
                cleanup(existingPath)
                cleanup(linkPath)
            }

            let existing = try File.Path(existingPath)
            let link = try File.Path(linkPath)

            #expect(throws: File.System.Link.Hard.Error.alreadyExists(link)) {
                try File.System.Link.Hard.create(at: link, to: existing)
            }
        }

        // MARK: - Error Descriptions

        @Test("sourceNotFound error description")
        func sourceNotFoundErrorDescription() throws {
            let path = try File.Path("/tmp/missing")
            let error = File.System.Link.Hard.Error.sourceNotFound(path)
            #expect(error.description.contains("Source not found"))
        }

        @Test("permissionDenied error description")
        func permissionDeniedErrorDescription() throws {
            let path = try File.Path("/root/secret")
            let error = File.System.Link.Hard.Error.permissionDenied(path)
            #expect(error.description.contains("Permission denied"))
        }

        @Test("alreadyExists error description")
        func alreadyExistsErrorDescription() throws {
            let path = try File.Path("/tmp/existing")
            let error = File.System.Link.Hard.Error.alreadyExists(path)
            #expect(error.description.contains("already exists"))
        }

        @Test("crossDevice error description")
        func crossDeviceErrorDescription() throws {
            let source = try File.Path("/tmp/source")
            let dest = try File.Path("/var/dest")
            let error = File.System.Link.Hard.Error.crossDevice(source: source, destination: dest)
            #expect(error.description.contains("Cross-device"))
        }

        @Test("isDirectory error description")
        func isDirectoryErrorDescription() throws {
            let path = try File.Path("/tmp")
            let error = File.System.Link.Hard.Error.isDirectory(path)
            #expect(error.description.contains("Cannot create hard link to directory"))
        }

        @Test("linkFailed error description")
        func linkFailedErrorDescription() {
            let error = File.System.Link.Hard.Error.linkFailed(
                errno: 22,
                message: "Invalid argument"
            )
            #expect(error.description.contains("Hard link creation failed"))
        }

        // MARK: - Error Equatable

        @Test("Errors are equatable")
        func errorsAreEquatable() throws {
            let path1 = try File.Path("/tmp/a")
            let path2 = try File.Path("/tmp/a")

            #expect(
                File.System.Link.Hard.Error.sourceNotFound(path1)
                    == File.System.Link.Hard.Error.sourceNotFound(path2)
            )
            #expect(
                File.System.Link.Hard.Error.alreadyExists(path1)
                    == File.System.Link.Hard.Error.alreadyExists(path2)
            )
        }
    }
}
