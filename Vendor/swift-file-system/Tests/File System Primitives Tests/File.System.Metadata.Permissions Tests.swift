//
//  File.System.Metadata.Permissions Tests.swift
//  swift-file-system
//
//  Created by Coen ten Thije Boonkkamp on 18/12/2025.
//

import Foundation
import Testing

@testable import File_System_Primitives

extension File.System.Test.Unit {
    @Suite("File.System.Metadata.Permissions")
    struct MetadataPermissions {

        // MARK: - Test Fixtures

        private func createTempFile() throws -> String {
            let path = "/tmp/perms-test-\(UUID().uuidString).txt"
            FileManager.default.createFile(atPath: path, contents: nil)
            return path
        }

        private func cleanup(_ path: String) {
            try? FileManager.default.removeItem(atPath: path)
        }

        // MARK: - OptionSet Values

        @Test("Owner permission values")
        func ownerPermissionValues() {
            #expect(File.System.Metadata.Permissions.ownerRead.rawValue == 0o400)
            #expect(File.System.Metadata.Permissions.ownerWrite.rawValue == 0o200)
            #expect(File.System.Metadata.Permissions.ownerExecute.rawValue == 0o100)
        }

        @Test("Group permission values")
        func groupPermissionValues() {
            #expect(File.System.Metadata.Permissions.groupRead.rawValue == 0o040)
            #expect(File.System.Metadata.Permissions.groupWrite.rawValue == 0o020)
            #expect(File.System.Metadata.Permissions.groupExecute.rawValue == 0o010)
        }

        @Test("Other permission values")
        func otherPermissionValues() {
            #expect(File.System.Metadata.Permissions.otherRead.rawValue == 0o004)
            #expect(File.System.Metadata.Permissions.otherWrite.rawValue == 0o002)
            #expect(File.System.Metadata.Permissions.otherExecute.rawValue == 0o001)
        }

        @Test("Special bit values")
        func specialBitValues() {
            #expect(File.System.Metadata.Permissions.setuid.rawValue == 0o4000)
            #expect(File.System.Metadata.Permissions.setgid.rawValue == 0o2000)
            #expect(File.System.Metadata.Permissions.sticky.rawValue == 0o1000)
        }

        @Test("Combined permission values")
        func combinedPermissionValues() {
            let ownerAll = File.System.Metadata.Permissions.ownerAll
            #expect(ownerAll.contains(.ownerRead))
            #expect(ownerAll.contains(.ownerWrite))
            #expect(ownerAll.contains(.ownerExecute))

            let groupAll = File.System.Metadata.Permissions.groupAll
            #expect(groupAll.contains(.groupRead))
            #expect(groupAll.contains(.groupWrite))
            #expect(groupAll.contains(.groupExecute))

            let otherAll = File.System.Metadata.Permissions.otherAll
            #expect(otherAll.contains(.otherRead))
            #expect(otherAll.contains(.otherWrite))
            #expect(otherAll.contains(.otherExecute))
        }

        @Test("Default file permissions (644)")
        func defaultFilePermissions() {
            let defaultFile = File.System.Metadata.Permissions.defaultFile
            #expect(defaultFile.contains(.ownerRead))
            #expect(defaultFile.contains(.ownerWrite))
            #expect(!defaultFile.contains(.ownerExecute))
            #expect(defaultFile.contains(.groupRead))
            #expect(!defaultFile.contains(.groupWrite))
            #expect(defaultFile.contains(.otherRead))
            #expect(!defaultFile.contains(.otherWrite))
        }

        @Test("Default directory permissions (755)")
        func defaultDirectoryPermissions() {
            let defaultDir = File.System.Metadata.Permissions.defaultDirectory
            #expect(defaultDir.contains(.ownerRead))
            #expect(defaultDir.contains(.ownerWrite))
            #expect(defaultDir.contains(.ownerExecute))
            #expect(defaultDir.contains(.groupRead))
            #expect(defaultDir.contains(.groupExecute))
            #expect(defaultDir.contains(.otherRead))
            #expect(defaultDir.contains(.otherExecute))
        }

        // MARK: - Get/Set

        @Test("Get permissions of file")
        func getPermissionsOfFile() throws {
            let path = try createTempFile()
            defer { cleanup(path) }

            let filePath = try File.Path(path)
            let perms = try File.System.Metadata.Permissions.get(at: filePath)

            // File should have some permissions
            #expect(perms.rawValue != 0)
        }

        @Test("Set permissions of file")
        func setPermissionsOfFile() throws {
            let path = try createTempFile()
            defer { cleanup(path) }

            let filePath = try File.Path(path)
            let newPerms: File.System.Metadata.Permissions = [.ownerRead, .ownerWrite, .groupRead]

            try File.System.Metadata.Permissions.set(newPerms, at: filePath)

            let readBack = try File.System.Metadata.Permissions.get(at: filePath)
            #expect(readBack.contains(.ownerRead))
            #expect(readBack.contains(.ownerWrite))
            #expect(readBack.contains(.groupRead))
            #expect(!readBack.contains(.groupWrite))
            #expect(!readBack.contains(.otherRead))
        }

        @Test("Permissions roundtrip")
        func permissionsRoundtrip() throws {
            let path = try createTempFile()
            defer { cleanup(path) }

            let filePath = try File.Path(path)
            let testPerms: File.System.Metadata.Permissions = [
                .ownerRead, .ownerWrite, .ownerExecute,
                .groupRead,
                .otherRead,
            ]

            try File.System.Metadata.Permissions.set(testPerms, at: filePath)
            let readBack = try File.System.Metadata.Permissions.get(at: filePath)

            // Check the permission bits we set
            #expect(readBack.contains(.ownerRead))
            #expect(readBack.contains(.ownerWrite))
            #expect(readBack.contains(.ownerExecute))
            #expect(readBack.contains(.groupRead))
            #expect(!readBack.contains(.groupWrite))
            #expect(readBack.contains(.otherRead))
            #expect(!readBack.contains(.otherWrite))
        }

        // MARK: - Error Cases

        @Test("Get permissions of non-existent file throws pathNotFound")
        func getPermissionsOfNonExistentFileThrows() throws {
            let nonExistent = "/tmp/non-existent-\(UUID().uuidString)"
            let path = try File.Path(nonExistent)

            #expect(throws: File.System.Metadata.Permissions.Error.pathNotFound(path)) {
                _ = try File.System.Metadata.Permissions.get(at: path)
            }
        }

        @Test("Set permissions of non-existent file throws pathNotFound")
        func setPermissionsOfNonExistentFileThrows() throws {
            let nonExistent = "/tmp/non-existent-\(UUID().uuidString)"
            let path = try File.Path(nonExistent)

            #expect(throws: File.System.Metadata.Permissions.Error.pathNotFound(path)) {
                try File.System.Metadata.Permissions.set(.defaultFile, at: path)
            }
        }

        // MARK: - Error Descriptions

        @Test("pathNotFound error description")
        func pathNotFoundErrorDescription() throws {
            let path = try File.Path("/tmp/missing")
            let error = File.System.Metadata.Permissions.Error.pathNotFound(path)
            #expect(error.description.contains("Path not found"))
        }

        @Test("permissionDenied error description")
        func permissionDeniedErrorDescription() throws {
            let path = try File.Path("/root/secret")
            let error = File.System.Metadata.Permissions.Error.permissionDenied(path)
            #expect(error.description.contains("Permission denied"))
        }

        @Test("operationFailed error description")
        func operationFailedErrorDescription() {
            let error = File.System.Metadata.Permissions.Error.operationFailed(
                errno: 22,
                message: "Invalid argument"
            )
            #expect(error.description.contains("Operation failed"))
        }

        // MARK: - OptionSet Operations

        @Test("Permissions OptionSet union")
        func permissionsUnion() {
            let perms1: File.System.Metadata.Permissions = [.ownerRead]
            let perms2: File.System.Metadata.Permissions = [.ownerWrite]
            let union = perms1.union(perms2)

            #expect(union.contains(.ownerRead))
            #expect(union.contains(.ownerWrite))
        }

        @Test("Permissions OptionSet intersection")
        func permissionsIntersection() {
            let perms1: File.System.Metadata.Permissions = [.ownerRead, .ownerWrite]
            let perms2: File.System.Metadata.Permissions = [.ownerWrite, .ownerExecute]
            let intersection = perms1.intersection(perms2)

            #expect(!intersection.contains(.ownerRead))
            #expect(intersection.contains(.ownerWrite))
            #expect(!intersection.contains(.ownerExecute))
        }

        @Test("Permissions isEmpty")
        func permissionsIsEmpty() {
            let empty: File.System.Metadata.Permissions = []
            let notEmpty: File.System.Metadata.Permissions = [.ownerRead]

            #expect(empty.isEmpty)
            #expect(!notEmpty.isEmpty)
        }
    }
}
