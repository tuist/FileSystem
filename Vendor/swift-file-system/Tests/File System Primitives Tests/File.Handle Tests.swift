//
//  File.Handle Tests.swift
//  swift-file-system
//
//  Created by Coen ten Thije Boonkkamp on 18/12/2025.
//

import Foundation
import Testing

@testable import File_System_Primitives

extension File.System.Test.Unit {
    @Suite("File.Handle")
    struct Handle {

        // MARK: - Test Fixtures

        private func createTempFile(content: [UInt8] = []) throws -> String {
            let path = "/tmp/handle-test-\(UUID().uuidString).bin"
            let data = Data(content)
            try data.write(to: URL(fileURLWithPath: path))
            return path
        }

        private func cleanup(_ path: String) {
            try? FileManager.default.removeItem(atPath: path)
        }

        // MARK: - Opening

        @Test("Open file for reading")
        func openForReading() throws {
            let content: [UInt8] = [1, 2, 3, 4, 5]
            let path = try createTempFile(content: content)
            defer { cleanup(path) }

            let filePath = try File.Path(path)
            var handle = try File.Handle.open(filePath, mode: .read)
            let isValid = handle.isValid
            let mode = handle.mode
            #expect(isValid)
            #expect(mode == .read)
            try handle.close()
        }

        @Test("Open file for writing")
        func openForWriting() throws {
            let path = try createTempFile()
            defer { cleanup(path) }

            let filePath = try File.Path(path)
            var handle = try File.Handle.open(filePath, mode: .write)
            let isValid = handle.isValid
            let mode = handle.mode
            #expect(isValid)
            #expect(mode == .write)
            try handle.close()
        }

        @Test("Open file for read/write")
        func openForReadWrite() throws {
            let path = try createTempFile()
            defer { cleanup(path) }

            let filePath = try File.Path(path)
            var handle = try File.Handle.open(filePath, mode: .readWrite)
            let isValid = handle.isValid
            let mode = handle.mode
            #expect(isValid)
            #expect(mode == .readWrite)
            try handle.close()
        }

        @Test("Open file for append")
        func openForAppend() throws {
            let path = try createTempFile()
            defer { cleanup(path) }

            let filePath = try File.Path(path)
            var handle = try File.Handle.open(filePath, mode: .append)
            let isValid = handle.isValid
            let mode = handle.mode
            #expect(isValid)
            #expect(mode == .append)
            try handle.close()
        }

        @Test("Open with create option")
        func openWithCreate() throws {
            let path = "/tmp/handle-create-\(UUID().uuidString).txt"
            defer { cleanup(path) }

            let filePath = try File.Path(path)
            var handle = try File.Handle.open(filePath, mode: .write, options: [.create])
            let isValid = handle.isValid
            #expect(isValid)
            #expect(FileManager.default.fileExists(atPath: path))
            try handle.close()
        }

        @Test("Open non-existing file throws pathNotFound")
        func openNonExisting() throws {
            let path = "/tmp/non-existing-\(UUID().uuidString).txt"
            let filePath = try File.Path(path)

            #expect(throws: File.Handle.Error.self) {
                _ = try File.Handle.open(filePath, mode: .read)
            }
        }

        // MARK: - Reading

        @Test("Read bytes from file")
        func readBytes() throws {
            let content: [UInt8] = [10, 20, 30, 40, 50]
            let path = try createTempFile(content: content)
            defer { cleanup(path) }

            let filePath = try File.Path(path)
            var handle = try File.Handle.open(filePath, mode: .read)

            let readData = try handle.read(count: 5)
            #expect(readData == content)
            try handle.close()
        }

        @Test("Read partial bytes")
        func readPartialBytes() throws {
            let content: [UInt8] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
            let path = try createTempFile(content: content)
            defer { cleanup(path) }

            let filePath = try File.Path(path)
            var handle = try File.Handle.open(filePath, mode: .read)

            let firstPart = try handle.read(count: 5)
            #expect(firstPart == [1, 2, 3, 4, 5])

            let secondPart = try handle.read(count: 5)
            #expect(secondPart == [6, 7, 8, 9, 10])
            try handle.close()
        }

        @Test("Read at EOF returns empty")
        func readAtEOF() throws {
            let content: [UInt8] = [1, 2, 3]
            let path = try createTempFile(content: content)
            defer { cleanup(path) }

            let filePath = try File.Path(path)
            var handle = try File.Handle.open(filePath, mode: .read)

            _ = try handle.read(count: 3)  // Read all
            let atEOF = try handle.read(count: 10)
            #expect(atEOF.isEmpty)
            try handle.close()
        }

        @Test("Read more than available returns available")
        func readMoreThanAvailable() throws {
            let content: [UInt8] = [1, 2, 3]
            let path = try createTempFile(content: content)
            defer { cleanup(path) }

            let filePath = try File.Path(path)
            var handle = try File.Handle.open(filePath, mode: .read)

            let readData = try handle.read(count: 100)
            #expect(readData == content)
            try handle.close()
        }

        // MARK: - Writing

        @Test("Write bytes to file")
        func writeBytes() throws {
            let path = try createTempFile()
            defer { cleanup(path) }

            let filePath = try File.Path(path)
            var handle = try File.Handle.open(filePath, mode: .write, options: [.truncate])

            let data: [UInt8] = [100, 101, 102, 103, 104]
            try data.withUnsafeBufferPointer { buffer in
                let span = Span<UInt8>(_unsafeElements: buffer)
                try handle.write(span)
            }
            try handle.close()

            let readBack = try [UInt8](Data(contentsOf: URL(fileURLWithPath: path)))
            #expect(readBack == data)
        }

        @Test("Write empty data")
        func writeEmpty() throws {
            let path = try createTempFile(content: [1, 2, 3])
            defer { cleanup(path) }

            let filePath = try File.Path(path)
            var handle = try File.Handle.open(filePath, mode: .write, options: [.truncate])

            let data: [UInt8] = []
            try data.withUnsafeBufferPointer { buffer in
                let span = Span<UInt8>(_unsafeElements: buffer)
                try handle.write(span)
            }
            try handle.close()

            let readBack = try Data(contentsOf: URL(fileURLWithPath: path))
            #expect(readBack.isEmpty)
        }

        // MARK: - Seeking

        @Test("Seek from start")
        func seekFromStart() throws {
            let content: [UInt8] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
            let path = try createTempFile(content: content)
            defer { cleanup(path) }

            let filePath = try File.Path(path)
            var handle = try File.Handle.open(filePath, mode: .read)

            let newPos = try handle.seek(to: 5, from: .start)
            #expect(newPos == 5)

            let readData = try handle.read(count: 3)
            #expect(readData == [6, 7, 8])
            try handle.close()
        }

        @Test("Seek from current")
        func seekFromCurrent() throws {
            let content: [UInt8] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
            let path = try createTempFile(content: content)
            defer { cleanup(path) }

            let filePath = try File.Path(path)
            var handle = try File.Handle.open(filePath, mode: .read)

            _ = try handle.read(count: 3)  // Position at 3
            let newPos = try handle.seek(to: 2, from: .current)  // Now at 5
            #expect(newPos == 5)

            let readData = try handle.read(count: 1)
            #expect(readData == [6])
            try handle.close()
        }

        @Test("Seek from end")
        func seekFromEnd() throws {
            let content: [UInt8] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
            let path = try createTempFile(content: content)
            defer { cleanup(path) }

            let filePath = try File.Path(path)
            var handle = try File.Handle.open(filePath, mode: .read)

            let newPos = try handle.seek(to: -3, from: .end)
            #expect(newPos == 7)

            let readData = try handle.read(count: 3)
            #expect(readData == [8, 9, 10])
            try handle.close()
        }

        @Test("Get current position")
        func getCurrentPosition() throws {
            let content: [UInt8] = [1, 2, 3, 4, 5]
            let path = try createTempFile(content: content)
            defer { cleanup(path) }

            let filePath = try File.Path(path)
            var handle = try File.Handle.open(filePath, mode: .read)

            let pos1 = try handle.seek(to: 0, from: .current)
            #expect(pos1 == 0)
            _ = try handle.read(count: 3)
            let pos2 = try handle.seek(to: 0, from: .current)
            #expect(pos2 == 3)
            try handle.close()
        }

        // MARK: - Sync

        @Test("Sync flushes to disk")
        func syncToDisk() throws {
            let path = "/tmp/handle-sync-\(UUID().uuidString).txt"
            defer { cleanup(path) }

            let filePath = try File.Path(path)
            var handle = try File.Handle.open(filePath, mode: .write, options: [.create])

            let data: [UInt8] = [1, 2, 3]
            try data.withUnsafeBufferPointer { buffer in
                let span = Span<UInt8>(_unsafeElements: buffer)
                try handle.write(span)
            }
            try handle.sync()
            try handle.close()

            // File should exist and have content
            #expect(FileManager.default.fileExists(atPath: path))
        }

        // MARK: - Error descriptions

        @Test("pathNotFound error description")
        func pathNotFoundErrorDescription() throws {
            let path = try File.Path("/tmp/missing")
            let error = File.Handle.Error.pathNotFound(path)
            #expect(error.description.contains("Path not found"))
        }

        @Test("permissionDenied error description")
        func permissionDeniedErrorDescription() throws {
            let path = try File.Path("/root/secret")
            let error = File.Handle.Error.permissionDenied(path)
            #expect(error.description.contains("Permission denied"))
        }

        @Test("invalidHandle error description")
        func invalidHandleErrorDescription() {
            let error = File.Handle.Error.invalidHandle
            #expect(error.description.contains("Invalid"))
        }

        @Test("seekFailed error description")
        func seekFailedErrorDescription() {
            let error = File.Handle.Error.seekFailed(errno: 22, message: "Invalid argument")
            #expect(error.description.contains("Seek failed"))
        }

        @Test("readFailed error description")
        func readFailedErrorDescription() {
            let error = File.Handle.Error.readFailed(errno: 5, message: "I/O error")
            #expect(error.description.contains("Read failed"))
        }

        @Test("writeFailed error description")
        func writeFailedErrorDescription() {
            let error = File.Handle.Error.writeFailed(errno: 28, message: "No space left")
            #expect(error.description.contains("Write failed"))
        }
    }
}
