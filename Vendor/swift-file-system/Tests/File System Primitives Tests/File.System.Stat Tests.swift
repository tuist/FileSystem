//
//  File.System.Stat Tests.swift
//  swift-file-system
//
//  Created by Coen ten Thije Boonkkamp on 18/12/2025.
//

import Foundation
import Testing

@testable import File_System_Primitives

extension File.System.Test.Unit {
    @Suite("File.System.Stat")
    struct Stat {

        // MARK: - Test Fixtures

        private func createTempFile(content: String = "test") throws -> String {
            let path = "/tmp/stat-test-\(UUID().uuidString).txt"
            try content.write(toFile: path, atomically: true, encoding: .utf8)
            return path
        }

        private func createTempDirectory() throws -> String {
            let path = "/tmp/stat-test-dir-\(UUID().uuidString)"
            try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true)
            return path
        }

        private func cleanup(_ path: String) {
            try? FileManager.default.removeItem(atPath: path)
        }

        // MARK: - exists()

        @Test("exists returns true for existing file")
        func existsReturnsTrueForFile() throws {
            let path = try createTempFile()
            defer { cleanup(path) }

            let filePath = try File.Path(path)
            #expect(File.System.Stat.exists(at: filePath) == true)
        }

        @Test("exists returns true for existing directory")
        func existsReturnsTrueForDirectory() throws {
            let path = try createTempDirectory()
            defer { cleanup(path) }

            let filePath = try File.Path(path)
            #expect(File.System.Stat.exists(at: filePath) == true)
        }

        @Test("exists returns false for non-existing path")
        func existsReturnsFalseForNonExisting() throws {
            let filePath = try File.Path("/tmp/non-existing-\(UUID().uuidString)")
            #expect(File.System.Stat.exists(at: filePath) == false)
        }

        // MARK: - Type checks via info()

        @Test("info returns regular type for file")
        func infoReturnsRegularForFile() throws {
            let path = try createTempFile()
            defer { cleanup(path) }

            let filePath = try File.Path(path)
            let info = try File.System.Stat.info(at: filePath)
            #expect(info.type == .regular)
        }

        @Test("info returns directory type for directory")
        func infoReturnsDirectoryForDirectory() throws {
            let path = try createTempDirectory()
            defer { cleanup(path) }

            let filePath = try File.Path(path)
            let info = try File.System.Stat.info(at: filePath)
            #expect(info.type == .directory)
        }

        @Test("info throws for non-existing path")
        func infoThrowsForNonExisting() throws {
            let filePath = try File.Path("/tmp/non-existing-\(UUID().uuidString)")
            #expect(throws: File.System.Stat.Error.self) {
                _ = try File.System.Stat.info(at: filePath)
            }
        }

        @Test("lstatInfo returns symbolicLink type for symlink")
        func lstatInfoReturnsSymlinkForSymlink() throws {
            let targetPath = try createTempFile()
            let linkPath = "/tmp/stat-test-link-\(UUID().uuidString)"
            defer {
                cleanup(targetPath)
                cleanup(linkPath)
            }

            try FileManager.default.createSymbolicLink(
                atPath: linkPath,
                withDestinationPath: targetPath
            )

            let filePath = try File.Path(linkPath)
            let info = try File.System.Stat.lstatInfo(at: filePath)
            #expect(info.type == .symbolicLink)
        }

        @Test("lstatInfo returns regular type for file (not symlink)")
        func lstatInfoReturnsRegularForFile() throws {
            let path = try createTempFile()
            defer { cleanup(path) }

            let filePath = try File.Path(path)
            let info = try File.System.Stat.lstatInfo(at: filePath)
            #expect(info.type == .regular)
        }

        @Test("lstatInfo returns directory type for directory (not symlink)")
        func lstatInfoReturnsDirectoryForDirectory() throws {
            let path = try createTempDirectory()
            defer { cleanup(path) }

            let filePath = try File.Path(path)
            let info = try File.System.Stat.lstatInfo(at: filePath)
            #expect(info.type == .directory)
        }

        // MARK: - info()

        @Test("info returns correct type for file")
        func infoReturnsCorrectTypeForFile() throws {
            let path = try createTempFile(content: "Hello, World!")
            defer { cleanup(path) }

            let filePath = try File.Path(path)
            let info = try File.System.Stat.info(at: filePath)

            #expect(info.type == .regular)
            #expect(info.size == 13)  // "Hello, World!" is 13 bytes
        }

        @Test("info returns correct type for directory")
        func infoReturnsCorrectTypeForDirectory() throws {
            let path = try createTempDirectory()
            defer { cleanup(path) }

            let filePath = try File.Path(path)
            let info = try File.System.Stat.info(at: filePath)

            #expect(info.type == .directory)
        }

        @Test("info returns correct type for symlink")
        func infoReturnsCorrectTypeForSymlink() throws {
            let targetPath = try createTempFile()
            let linkPath = "/tmp/stat-test-link-\(UUID().uuidString)"
            defer {
                cleanup(targetPath)
                cleanup(linkPath)
            }

            try FileManager.default.createSymbolicLink(
                atPath: linkPath,
                withDestinationPath: targetPath
            )

            let filePath = try File.Path(linkPath)
            let info = try File.System.Stat.info(at: filePath)

            // info() follows symlinks by default, so it should return the target type
            #expect(info.type == .regular)
        }

        // MARK: - Async variants

        @Test("async exists works")
        func asyncExists() async throws {
            let path = try createTempFile()
            defer { cleanup(path) }

            let filePath = try File.Path(path)
            let exists = await File.System.Stat.exists(at: filePath)
            #expect(exists == true)
        }

        @Test("async info returns regular type for file")
        func asyncInfo() async throws {
            let path = try createTempFile()
            defer { cleanup(path) }

            let filePath = try File.Path(path)
            let info = try await File.System.Stat.info(at: filePath)
            #expect(info.type == .regular)
        }

        // MARK: - Error cases

        @Test("pathNotFound error description")
        func pathNotFoundErrorDescription() throws {
            let path = try File.Path("/tmp/non-existing")
            let error = File.System.Stat.Error.pathNotFound(path)
            #expect(error.description.contains("Path not found"))
        }

        @Test("permissionDenied error description")
        func permissionDeniedErrorDescription() throws {
            let path = try File.Path("/root/restricted")
            let error = File.System.Stat.Error.permissionDenied(path)
            #expect(error.description.contains("Permission denied"))
        }

        @Test("statFailed error description")
        func statFailedErrorDescription() {
            let error = File.System.Stat.Error.statFailed(errno: 22, message: "Invalid argument")
            #expect(error.description.contains("Stat failed"))
            #expect(error.description.contains("Invalid argument"))
        }

        // MARK: - lstatInfo() tests

        @Test("lstatInfo returns symbolicLink type for symlink")
        func lstatInfoReturnsSymlinkType() throws {
            let targetPath = try File.Path("/tmp/stat-lstat-target-\(UUID().uuidString).txt")
            let linkPath = try File.Path("/tmp/stat-lstat-test-\(UUID().uuidString)")
            defer {
                try? File.System.Delete.delete(at: targetPath)
                try? File.System.Delete.delete(at: linkPath)
            }

            // Create target file using our API
            var handle = try File.Handle.open(
                targetPath,
                mode: .write,
                options: [.create, .closeOnExec]
            )
            try Array("test".utf8).withUnsafeBufferPointer { buffer in
                try handle.write(Span<UInt8>(_unsafeElements: buffer))
            }
            try handle.close()

            // Create symlink using our API
            try File.System.Link.Symbolic.create(at: linkPath, pointingTo: targetPath)

            // lstatInfo should return symbolicLink type (doesn't follow)
            let lstatInfo = try File.System.Stat.lstatInfo(at: linkPath)
            #expect(lstatInfo.type == .symbolicLink)

            // info should return regular type (follows symlink)
            let statInfo = try File.System.Stat.info(at: linkPath)
            #expect(statInfo.type == .regular)
        }

        @Test("lstatInfo returns different inode than info for symlink")
        func lstatInfoReturnsDifferentInodeForSymlink() throws {
            let targetPath = try File.Path("/tmp/stat-inode-target-\(UUID().uuidString).txt")
            let linkPath = try File.Path("/tmp/stat-inode-test-\(UUID().uuidString)")
            defer {
                try? File.System.Delete.delete(at: targetPath)
                try? File.System.Delete.delete(at: linkPath)
            }

            // Create target file using our API
            var handle = try File.Handle.open(
                targetPath,
                mode: .write,
                options: [.create, .closeOnExec]
            )
            try Array("test".utf8).withUnsafeBufferPointer { buffer in
                try handle.write(Span<UInt8>(_unsafeElements: buffer))
            }
            try handle.close()

            // Create symlink using our API
            try File.System.Link.Symbolic.create(at: linkPath, pointingTo: targetPath)

            // lstatInfo returns the symlink's own inode
            let lstatInfo = try File.System.Stat.lstatInfo(at: linkPath)

            // info on symlink follows to target, should have same inode as target
            let statInfo = try File.System.Stat.info(at: linkPath)
            let targetInfo = try File.System.Stat.info(at: targetPath)

            // The symlink has its own inode, different from the target
            #expect(lstatInfo.inode != targetInfo.inode)

            // info() on symlink should return the target's inode
            #expect(statInfo.inode == targetInfo.inode)
        }

        @Test("lstatInfo same as info for regular file")
        func lstatInfoSameAsInfoForRegularFile() throws {
            let filePath = try File.Path("/tmp/stat-lstat-regular-\(UUID().uuidString).txt")
            defer { try? File.System.Delete.delete(at: filePath) }

            // Create file using our API
            var handle = try File.Handle.open(
                filePath,
                mode: .write,
                options: [.create, .closeOnExec]
            )
            try Array("test content".utf8).withUnsafeBufferPointer { buffer in
                try handle.write(Span<UInt8>(_unsafeElements: buffer))
            }
            try handle.close()

            let lstatInfo = try File.System.Stat.lstatInfo(at: filePath)
            let statInfo = try File.System.Stat.info(at: filePath)

            // For regular files, both should return the same info
            #expect(lstatInfo.type == statInfo.type)
            #expect(lstatInfo.inode == statInfo.inode)
            #expect(lstatInfo.size == statInfo.size)
        }
    }
}
