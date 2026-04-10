//
//  File.System.Move Tests.swift
//  swift-file-system
//
//  Created by Coen ten Thije Boonkkamp on 18/12/2025.
//

import Foundation
import Testing

@testable import File_System_Primitives

extension File.System.Test.Unit {
    @Suite("File.System.Move")
    struct Move {

        // MARK: - Test Fixtures

        private func createTempFile(content: [UInt8] = [1, 2, 3]) throws -> String {
            let path = "/tmp/move-test-\(UUID().uuidString).bin"
            let data = Data(content)
            try data.write(to: URL(fileURLWithPath: path))
            return path
        }

        private func cleanup(_ path: String) {
            try? FileManager.default.removeItem(atPath: path)
        }

        // MARK: - Basic Move

        @Test("Move file to new location")
        func moveFileToNewLocation() throws {
            let sourcePath = try createTempFile(content: [10, 20, 30, 40])
            let destPath = "/tmp/move-dest-\(UUID().uuidString).bin"
            defer {
                cleanup(sourcePath)
                cleanup(destPath)
            }

            let originalData = try Data(contentsOf: URL(fileURLWithPath: sourcePath))

            let source = try File.Path(sourcePath)
            let dest = try File.Path(destPath)

            try File.System.Move.move(from: source, to: dest)

            #expect(FileManager.default.fileExists(atPath: destPath))

            let destData = try Data(contentsOf: URL(fileURLWithPath: destPath))
            #expect(originalData == destData)
        }

        @Test("Move removes source file")
        func moveRemovesSourceFile() throws {
            let sourcePath = try createTempFile(content: [1, 2, 3])
            let destPath = "/tmp/move-dest-\(UUID().uuidString).bin"
            defer {
                cleanup(sourcePath)
                cleanup(destPath)
            }

            let source = try File.Path(sourcePath)
            let dest = try File.Path(destPath)

            try File.System.Move.move(from: source, to: dest)

            // Source should no longer exist
            #expect(!FileManager.default.fileExists(atPath: sourcePath))
        }

        @Test("Move empty file")
        func moveEmptyFile() throws {
            let sourcePath = try createTempFile(content: [])
            let destPath = "/tmp/move-dest-\(UUID().uuidString).bin"
            defer {
                cleanup(sourcePath)
                cleanup(destPath)
            }

            let source = try File.Path(sourcePath)
            let dest = try File.Path(destPath)

            try File.System.Move.move(from: source, to: dest)

            let destData = try Data(contentsOf: URL(fileURLWithPath: destPath))
            #expect(destData.isEmpty)
        }

        @Test("Rename file in same directory")
        func renameFileInSameDirectory() throws {
            let sourcePath = try createTempFile(content: [1, 2, 3])
            let destPath = "/tmp/renamed-\(UUID().uuidString).bin"
            defer {
                cleanup(sourcePath)
                cleanup(destPath)
            }

            let source = try File.Path(sourcePath)
            let dest = try File.Path(destPath)

            try File.System.Move.move(from: source, to: dest)

            #expect(!FileManager.default.fileExists(atPath: sourcePath))
            #expect(FileManager.default.fileExists(atPath: destPath))
        }

        // MARK: - Options

        @Test("Move with overwrite option")
        func moveWithOverwriteOption() throws {
            let sourcePath = try createTempFile(content: [1, 2, 3])
            let destPath = try createTempFile(content: [99, 99])
            defer {
                cleanup(sourcePath)
                cleanup(destPath)
            }

            let source = try File.Path(sourcePath)
            let dest = try File.Path(destPath)

            let options = File.System.Move.Options(overwrite: true)
            try File.System.Move.move(from: source, to: dest, options: options)

            let destData = try [UInt8](Data(contentsOf: URL(fileURLWithPath: destPath)))
            #expect(destData == [1, 2, 3])
        }

        @Test("Move without overwrite throws when destination exists")
        func moveWithoutOverwriteThrows() throws {
            let sourcePath = try createTempFile(content: [1, 2, 3])
            let destPath = try createTempFile(content: [99, 99])
            defer {
                cleanup(sourcePath)
                cleanup(destPath)
            }

            let source = try File.Path(sourcePath)
            let dest = try File.Path(destPath)

            let options = File.System.Move.Options(overwrite: false)
            #expect(throws: File.System.Move.Error.self) {
                try File.System.Move.move(from: source, to: dest, options: options)
            }
        }

        @Test("Options default values")
        func optionsDefaultValues() {
            let options = File.System.Move.Options()
            #expect(options.overwrite == false)
        }

        @Test("Options custom values")
        func optionsCustomValues() {
            let options = File.System.Move.Options(overwrite: true)
            #expect(options.overwrite == true)
        }

        // MARK: - Error Cases

        @Test("Move non-existent source throws sourceNotFound")
        func moveNonExistentSourceThrows() throws {
            let sourcePath = "/tmp/non-existent-\(UUID().uuidString).bin"
            let destPath = "/tmp/move-dest-\(UUID().uuidString).bin"
            defer { cleanup(destPath) }

            let source = try File.Path(sourcePath)
            let dest = try File.Path(destPath)

            #expect(throws: File.System.Move.Error.self) {
                try File.System.Move.move(from: source, to: dest)
            }
        }

        @Test("Move to existing file without overwrite throws destinationExists")
        func moveToExistingFileThrows() throws {
            let sourcePath = try createTempFile(content: [1, 2, 3])
            let destPath = try createTempFile(content: [99])
            defer {
                cleanup(sourcePath)
                cleanup(destPath)
            }

            let source = try File.Path(sourcePath)
            let dest = try File.Path(destPath)

            #expect(throws: File.System.Move.Error.destinationExists(dest)) {
                try File.System.Move.move(from: source, to: dest)
            }
        }

        // MARK: - Error Descriptions

        @Test("sourceNotFound error description")
        func sourceNotFoundErrorDescription() throws {
            let path = try File.Path("/tmp/missing")
            let error = File.System.Move.Error.sourceNotFound(path)
            #expect(error.description.contains("Source not found"))
        }

        @Test("destinationExists error description")
        func destinationExistsErrorDescription() throws {
            let path = try File.Path("/tmp/existing")
            let error = File.System.Move.Error.destinationExists(path)
            #expect(error.description.contains("already exists"))
        }

        @Test("permissionDenied error description")
        func permissionDeniedErrorDescription() throws {
            let path = try File.Path("/root/secret")
            let error = File.System.Move.Error.permissionDenied(path)
            #expect(error.description.contains("Permission denied"))
        }

        @Test("moveFailed error description")
        func moveFailedErrorDescription() {
            let error = File.System.Move.Error.moveFailed(errno: 5, message: "I/O error")
            #expect(error.description.contains("Move failed"))
            #expect(error.description.contains("I/O error"))
        }

        // MARK: - Error Equatable

        @Test("Errors are equatable")
        func errorsAreEquatable() throws {
            let path1 = try File.Path("/tmp/a")
            let path2 = try File.Path("/tmp/a")

            #expect(
                File.System.Move.Error.sourceNotFound(path1)
                    == File.System.Move.Error.sourceNotFound(path2)
            )
            #expect(
                File.System.Move.Error.destinationExists(path1)
                    == File.System.Move.Error.destinationExists(path2)
            )
        }
    }
}
