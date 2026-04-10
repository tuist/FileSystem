//
//  File.System.Link.ReadTarget Tests.swift
//  swift-file-system
//
//  Created by Coen ten Thije Boonkkamp on 18/12/2025.
//

import Foundation
import Testing

@testable import File_System_Primitives

extension File.System.Test.Unit {
    @Suite("File.System.Link.ReadTarget")
    struct LinkReadTarget {

        // MARK: - Test Fixtures

        private func createTempFile(content: [UInt8] = [1, 2, 3]) throws -> String {
            let path = "/tmp/readtarget-test-\(UUID().uuidString).bin"
            let data = Data(content)
            try data.write(to: URL(fileURLWithPath: path))
            return path
        }

        private func createTempDir() throws -> String {
            let path = "/tmp/readtarget-dir-\(UUID().uuidString)"
            try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true)
            return path
        }

        private func cleanup(_ path: String) {
            try? FileManager.default.removeItem(atPath: path)
        }

        // MARK: - Read Target

        @Test("Read target of symlink to file")
        func readTargetOfSymlinkToFile() throws {
            let targetPath = try createTempFile()
            let linkPath = "/tmp/link-\(UUID().uuidString)"
            defer {
                cleanup(targetPath)
                cleanup(linkPath)
            }

            try FileManager.default.createSymbolicLink(
                atPath: linkPath,
                withDestinationPath: targetPath
            )

            let link = try File.Path(linkPath)
            let target = try File.System.Link.ReadTarget.target(of: link)

            #expect(target.string == targetPath)
        }

        @Test("Read target of symlink to directory")
        func readTargetOfSymlinkToDirectory() throws {
            let targetPath = try createTempDir()
            let linkPath = "/tmp/link-\(UUID().uuidString)"
            defer {
                cleanup(targetPath)
                cleanup(linkPath)
            }

            try FileManager.default.createSymbolicLink(
                atPath: linkPath,
                withDestinationPath: targetPath
            )

            let link = try File.Path(linkPath)
            let target = try File.System.Link.ReadTarget.target(of: link)

            #expect(target.string == targetPath)
        }

        @Test("Read target of dangling symlink")
        func readTargetOfDanglingSymlink() throws {
            let targetPath = "/tmp/non-existent-\(UUID().uuidString)"
            let linkPath = "/tmp/link-\(UUID().uuidString)"
            defer {
                cleanup(linkPath)
            }

            try FileManager.default.createSymbolicLink(
                atPath: linkPath,
                withDestinationPath: targetPath
            )

            let link = try File.Path(linkPath)
            let target = try File.System.Link.ReadTarget.target(of: link)

            #expect(target.string == targetPath)
        }

        @Test("Read target of relative symlink")
        func readTargetOfRelativeSymlink() throws {
            let dirPath = try createTempDir()
            let targetPath = "\(dirPath)/target.txt"
            let linkPath = "\(dirPath)/link.txt"
            defer {
                cleanup(dirPath)
            }

            // Create target file
            FileManager.default.createFile(atPath: targetPath, contents: nil)

            // Create relative symlink
            try FileManager.default.createSymbolicLink(
                atPath: linkPath,
                withDestinationPath: "target.txt"
            )

            let link = try File.Path(linkPath)
            let target = try File.System.Link.ReadTarget.target(of: link)

            #expect(target.string == "target.txt")
        }

        // MARK: - Error Cases

        @Test("Read target of regular file throws notASymlink")
        func readTargetOfRegularFileThrows() throws {
            let filePath = try createTempFile()
            defer { cleanup(filePath) }

            let path = try File.Path(filePath)

            #expect(throws: File.System.Link.ReadTarget.Error.notASymlink(path)) {
                _ = try File.System.Link.ReadTarget.target(of: path)
            }
        }

        @Test("Read target of directory throws notASymlink")
        func readTargetOfDirectoryThrows() throws {
            let dirPath = try createTempDir()
            defer { cleanup(dirPath) }

            let path = try File.Path(dirPath)

            #expect(throws: File.System.Link.ReadTarget.Error.notASymlink(path)) {
                _ = try File.System.Link.ReadTarget.target(of: path)
            }
        }

        @Test("Read target of non-existent path throws pathNotFound")
        func readTargetOfNonExistentPathThrows() throws {
            let nonExistent = "/tmp/non-existent-\(UUID().uuidString)"
            let path = try File.Path(nonExistent)

            #expect(throws: File.System.Link.ReadTarget.Error.pathNotFound(path)) {
                _ = try File.System.Link.ReadTarget.target(of: path)
            }
        }

        // MARK: - Error Descriptions

        @Test("notASymlink error description")
        func notASymlinkErrorDescription() throws {
            let path = try File.Path("/tmp/regular")
            let error = File.System.Link.ReadTarget.Error.notASymlink(path)
            #expect(error.description.contains("Not a symbolic link"))
        }

        @Test("pathNotFound error description")
        func pathNotFoundErrorDescription() throws {
            let path = try File.Path("/tmp/missing")
            let error = File.System.Link.ReadTarget.Error.pathNotFound(path)
            #expect(error.description.contains("Path not found"))
        }

        @Test("permissionDenied error description")
        func permissionDeniedErrorDescription() throws {
            let path = try File.Path("/root/secret")
            let error = File.System.Link.ReadTarget.Error.permissionDenied(path)
            #expect(error.description.contains("Permission denied"))
        }

        @Test("readFailed error description")
        func readFailedErrorDescription() {
            let error = File.System.Link.ReadTarget.Error.readFailed(errno: 5, message: "I/O error")
            #expect(error.description.contains("Read link target failed"))
            #expect(error.description.contains("I/O error"))
        }

        // MARK: - Error Equatable

        @Test("Errors are equatable")
        func errorsAreEquatable() throws {
            let path1 = try File.Path("/tmp/a")
            let path2 = try File.Path("/tmp/a")

            #expect(
                File.System.Link.ReadTarget.Error.notASymlink(path1)
                    == File.System.Link.ReadTarget.Error.notASymlink(path2)
            )
            #expect(
                File.System.Link.ReadTarget.Error.pathNotFound(path1)
                    == File.System.Link.ReadTarget.Error.pathNotFound(path2)
            )
        }
    }
}
