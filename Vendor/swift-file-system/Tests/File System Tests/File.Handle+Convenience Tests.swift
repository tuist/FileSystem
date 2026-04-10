//
//  File.Handle+Convenience Tests.swift
//  swift-file-system
//
//  Created by Coen ten Thije Boonkkamp on 18/12/2025.
//

import Foundation
import Testing

@testable import File_System

extension File.System.Test.Unit {
    @Suite("File.Handle+Convenience")
    struct HandleConvenience {

        // MARK: - Test Fixtures

        private func createTempFile(content: [UInt8] = []) throws -> String {
            let path = "/tmp/handle-convenience-test-\(UUID().uuidString).bin"
            let data = Data(content)
            try data.write(to: URL(fileURLWithPath: path))
            return path
        }

        private func cleanup(_ path: String) {
            try? FileManager.default.removeItem(atPath: path)
        }

        // MARK: - withOpen

        @Test("withOpen reads file content")
        func withOpenReadsContent() throws {
            let content: [UInt8] = [1, 2, 3, 4, 5]
            let path = try createTempFile(content: content)
            defer { cleanup(path) }

            let filePath = try File.Path(path)
            let readData = try File.Handle.withOpen(filePath, mode: .read) { handle in
                try handle.read(count: 10)
            }

            #expect(readData == content)
        }

        @Test("withOpen writes file content")
        func withOpenWritesContent() throws {
            let path = try createTempFile()
            defer { cleanup(path) }

            let filePath = try File.Path(path)
            let dataToWrite: [UInt8] = [10, 20, 30, 40, 50]

            try File.Handle.withOpen(filePath, mode: .write, options: [.truncate]) { handle in
                try dataToWrite.withUnsafeBufferPointer { buffer in
                    let span = Span<UInt8>(_unsafeElements: buffer)
                    try handle.write(span)
                }
            }

            let readBack = try [UInt8](Data(contentsOf: URL(fileURLWithPath: path)))
            #expect(readBack == dataToWrite)
        }

        @Test("withOpen closes handle after normal completion")
        func withOpenClosesHandleNormally() throws {
            let content: [UInt8] = [1, 2, 3]
            let path = try createTempFile(content: content)
            defer { cleanup(path) }

            let filePath = try File.Path(path)

            // After withOpen completes, the handle should be closed
            // We verify this by being able to open it again
            _ = try File.Handle.withOpen(filePath, mode: .read) { handle in
                try handle.read(count: 3)
            }

            // If handle wasn't closed, this might fail or behave unexpectedly
            let secondRead = try File.Handle.withOpen(filePath, mode: .read) { handle in
                try handle.read(count: 3)
            }

            #expect(secondRead == content)
        }

        @Test("withOpen closes handle after error")
        func withOpenClosesHandleAfterError() throws {
            let path = try createTempFile()
            defer { cleanup(path) }

            let filePath = try File.Path(path)

            struct TestError: Error {}

            // The handle should be closed even if the closure throws
            do {
                try File.Handle.withOpen(filePath, mode: .read) { _ in
                    throw TestError()
                }
                Issue.record("Expected error to be thrown")
            } catch is TestError {
                // Expected
            }

            // Verify handle was closed by opening successfully again
            let result = try File.Handle.withOpen(filePath, mode: .read) { handle in
                try handle.read(count: 10)
            }
            #expect(result.isEmpty)
        }

        @Test("withOpen returns closure result")
        func withOpenReturnsResult() throws {
            let content: [UInt8] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
            let path = try createTempFile(content: content)
            defer { cleanup(path) }

            let filePath = try File.Path(path)

            let sum = try File.Handle.withOpen(filePath, mode: .read) { handle in
                let bytes = try handle.read(count: 10)
                return bytes.reduce(0, +)
            }

            #expect(sum == 55)  // 1+2+3+4+5+6+7+8+9+10
        }

        @Test("withOpen with create option creates file")
        func withOpenCreatesFile() throws {
            let path = "/tmp/handle-convenience-create-\(UUID().uuidString).txt"
            defer { cleanup(path) }

            let filePath = try File.Path(path)
            #expect(!FileManager.default.fileExists(atPath: path))

            try File.Handle.withOpen(filePath, mode: .write, options: [.create]) { handle in
                let bytes: [UInt8] = [72, 105]  // "Hi"
                try bytes.withUnsafeBufferPointer { buffer in
                    let span = Span<UInt8>(_unsafeElements: buffer)
                    try handle.write(span)
                }
            }

            #expect(FileManager.default.fileExists(atPath: path))
        }

        @Test("withOpen propagates open error")
        func withOpenPropagatesOpenError() throws {
            let nonExistent = "/tmp/non-existent-\(UUID().uuidString).txt"
            let filePath = try File.Path(nonExistent)

            #expect(throws: File.Handle.Error.self) {
                try File.Handle.withOpen(filePath, mode: .read) { _ in
                    // Should never reach here
                }
            }
        }

        // MARK: - rewind

        @Test("rewind seeks to beginning")
        func rewindSeeksToBeginning() throws {
            let content: [UInt8] = [1, 2, 3, 4, 5]
            let path = try createTempFile(content: content)
            defer { cleanup(path) }

            let filePath = try File.Path(path)
            let result = try File.Handle.withOpen(filePath, mode: .read) { handle in
                // Read some data
                _ = try handle.read(count: 3)

                // Rewind to beginning
                let position = try handle.rewind()
                #expect(position == 0)

                // Read from beginning again
                return try handle.read(count: 5)
            }

            #expect(result == content)
        }

        @Test("rewind returns zero position")
        func rewindReturnsZero() throws {
            let content: [UInt8] = [1, 2, 3, 4, 5]
            let path = try createTempFile(content: content)
            defer { cleanup(path) }

            let filePath = try File.Path(path)
            let position = try File.Handle.withOpen(filePath, mode: .read) { handle in
                // Seek to middle
                _ = try handle.seek(to: 3, from: .start)

                // Rewind and check position
                return try handle.rewind()
            }

            #expect(position == 0)
        }

        // MARK: - seekToEnd

        @Test("seekToEnd returns file size")
        func seekToEndReturnsFileSize() throws {
            let content: [UInt8] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
            let path = try createTempFile(content: content)
            defer { cleanup(path) }

            let filePath = try File.Path(path)
            let size = try File.Handle.withOpen(filePath, mode: .read) { handle in
                try handle.seekToEnd()
            }

            #expect(size == 10)
        }

        @Test("seekToEnd on empty file returns zero")
        func seekToEndOnEmptyFile() throws {
            let path = try createTempFile(content: [])
            defer { cleanup(path) }

            let filePath = try File.Path(path)
            let size = try File.Handle.withOpen(filePath, mode: .read) { handle in
                try handle.seekToEnd()
            }

            #expect(size == 0)
        }

        @Test("seekToEnd then rewind allows re-read")
        func seekToEndThenRewindAllowsReRead() throws {
            let content: [UInt8] = [10, 20, 30]
            let path = try createTempFile(content: content)
            defer { cleanup(path) }

            let filePath = try File.Path(path)
            let result = try File.Handle.withOpen(filePath, mode: .read) { handle in
                // Seek to end
                let size = try handle.seekToEnd()
                #expect(size == 3)

                // Rewind
                try handle.rewind()

                // Read all content
                return try handle.read(count: Int(size))
            }

            #expect(result == content)
        }

        // MARK: - Async withOpen

        @Test("async withOpen reads file content")
        func asyncWithOpenReadsContent() async throws {
            let content: [UInt8] = [1, 2, 3, 4, 5]
            let path = try createTempFile(content: content)
            defer { cleanup(path) }

            let filePath = try File.Path(path)
            let readData = try await File.Handle.withOpen(filePath, mode: .read) { handle in
                try handle.read(count: 10)
            }

            #expect(readData == content)
        }

        @Test("async withOpen with async body")
        func asyncWithOpenAsyncBody() async throws {
            let content: [UInt8] = [1, 2, 3]
            let path = try createTempFile(content: content)
            defer { cleanup(path) }

            let filePath = try File.Path(path)

            let result = try await File.Handle.withOpen(filePath, mode: .read) {
                handle async throws in
                // Simulate async work
                try await Task.sleep(for: .milliseconds(1))
                return try handle.read(count: 10)
            }

            #expect(result == content)
        }

        // MARK: - .open namespace

        @Test("open.read reads file")
        func openReadReadsFile() throws {
            let content: [UInt8] = [1, 2, 3, 4, 5]
            let path = try createTempFile(content: content)
            defer { cleanup(path) }

            let filePath = try File.Path(path)
            let readData = try File.Handle.open(filePath).read { handle in
                try handle.read(count: 10)
            }

            #expect(readData == content)
        }

        @Test("open.write writes to file")
        func openWriteWritesToFile() throws {
            let path = try createTempFile()
            defer { cleanup(path) }

            let filePath = try File.Path(path)
            let dataToWrite: [UInt8] = [100, 200]

            try File.Handle.open(filePath, options: [.truncate]).write { handle in
                try dataToWrite.withUnsafeBufferPointer { buffer in
                    let span = Span<UInt8>(_unsafeElements: buffer)
                    try handle.write(span)
                }
            }

            let readBack = try [UInt8](Data(contentsOf: URL(fileURLWithPath: path)))
            #expect(readBack == dataToWrite)
        }

        @Test("open.appending appends to file")
        func openAppendingAppendsToFile() throws {
            let initialContent: [UInt8] = [1, 2, 3]
            let path = try createTempFile(content: initialContent)
            defer { cleanup(path) }

            let filePath = try File.Path(path)
            let dataToAppend: [UInt8] = [4, 5, 6]

            try File.Handle.open(filePath).appending { handle in
                try dataToAppend.withUnsafeBufferPointer { buffer in
                    let span = Span<UInt8>(_unsafeElements: buffer)
                    try handle.write(span)
                }
            }

            let readBack = try [UInt8](Data(contentsOf: URL(fileURLWithPath: path)))
            #expect(readBack == [1, 2, 3, 4, 5, 6])
        }

        @Test("open.readWrite allows read and write")
        func openReadWriteAllowsReadAndWrite() throws {
            let initialContent: [UInt8] = [1, 2, 3, 4, 5]
            let path = try createTempFile(content: initialContent)
            defer { cleanup(path) }

            let filePath = try File.Path(path)

            let result = try File.Handle.open(filePath).readWrite { handle in
                // Read first
                let data = try handle.read(count: 3)
                // Seek back
                try handle.rewind()
                // Write
                let newData: [UInt8] = [10, 20, 30]
                try newData.withUnsafeBufferPointer { buffer in
                    let span = Span<UInt8>(_unsafeElements: buffer)
                    try handle.write(span)
                }
                return data
            }

            #expect(result == [1, 2, 3])

            let readBack = try [UInt8](Data(contentsOf: URL(fileURLWithPath: path)))
            #expect(readBack == [10, 20, 30, 4, 5])
        }
    }
}
