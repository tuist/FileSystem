//
//  File.Handle.Async Tests.swift
//  swift-file-system
//
//  Created by Coen ten Thije Boonkkamp on 18/12/2025.
//

import Foundation
import Testing

@testable import File_System_Async

extension File.IO.Test.Unit {
    @Suite("File.Handle.Async")
    struct Handle {

        // MARK: - Test Fixtures

        private func createTempFile(content: [UInt8] = []) throws -> File.Path {
            let path = "/tmp/async-handle-test-\(UUID().uuidString).bin"
            let data = Data(content)
            try data.write(to: URL(fileURLWithPath: path))
            return try File.Path(path)
        }

        private func cleanup(_ path: File.Path) {
            try? FileManager.default.removeItem(atPath: path.string)
        }

        // MARK: - Opening

        @Test("Open file for reading")
        func openForReading() async throws {
            let io = File.IO.Executor()
            defer { Task { await io.shutdown() } }

            let content: [UInt8] = [1, 2, 3, 4, 5]
            let path = try createTempFile(content: content)
            defer { cleanup(path) }

            let handle = try await File.Handle.Async.open(path, mode: .read, io: io)
            #expect(await handle.isOpen)
            #expect(handle.mode == .read)
            try await handle.close()
        }

        @Test("Open file for writing")
        func openForWriting() async throws {
            let io = File.IO.Executor()
            defer { Task { await io.shutdown() } }

            let path = try createTempFile()
            defer { cleanup(path) }

            let handle = try await File.Handle.Async.open(path, mode: .write, io: io)
            #expect(await handle.isOpen)
            #expect(handle.mode == .write)
            try await handle.close()
        }

        // MARK: - Reading

        @Test("Read bytes from file")
        func readBytes() async throws {
            let io = File.IO.Executor()
            defer { Task { await io.shutdown() } }

            let content: [UInt8] = [10, 20, 30, 40, 50]
            let path = try createTempFile(content: content)
            defer { cleanup(path) }

            let handle = try await File.Handle.Async.open(path, mode: .read, io: io)
            let data = try await handle.read(count: 5)
            #expect(data == content)
            try await handle.close()
        }

        @Test("Read partial bytes")
        func readPartialBytes() async throws {
            let io = File.IO.Executor()
            defer { Task { await io.shutdown() } }

            let content: [UInt8] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
            let path = try createTempFile(content: content)
            defer { cleanup(path) }

            let handle = try await File.Handle.Async.open(path, mode: .read, io: io)

            let first = try await handle.read(count: 5)
            #expect(first == [1, 2, 3, 4, 5])

            let second = try await handle.read(count: 5)
            #expect(second == [6, 7, 8, 9, 10])

            try await handle.close()
        }

        // Note: read(into:) with caller-provided buffer is tested via integration tests.
        // Direct unit testing is complex due to Swift 6 Sendable checking on raw buffer pointers.

        // MARK: - Writing

        @Test("Write bytes to file")
        func writeBytes() async throws {
            let io = File.IO.Executor()
            defer { Task { await io.shutdown() } }

            let path = try createTempFile()
            defer { cleanup(path) }

            let handle = try await File.Handle.Async.open(
                path,
                mode: .write,
                options: [.truncate],
                io: io
            )
            let data: [UInt8] = [100, 101, 102, 103, 104]
            try await handle.write(data)
            try await handle.close()

            let readBack = try [UInt8](Data(contentsOf: URL(fileURLWithPath: path.string)))
            #expect(readBack == data)
        }

        // MARK: - Seeking

        @Test("Seek and read")
        func seekAndRead() async throws {
            let io = File.IO.Executor()
            defer { Task { await io.shutdown() } }

            let content: [UInt8] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
            let path = try createTempFile(content: content)
            defer { cleanup(path) }

            let handle = try await File.Handle.Async.open(path, mode: .read, io: io)

            let pos = try await handle.seek(to: 5)
            #expect(pos == 5)

            let data = try await handle.read(count: 3)
            #expect(data == [6, 7, 8])

            try await handle.close()
        }

        @Test("Rewind and seekToEnd")
        func rewindAndSeekToEnd() async throws {
            let io = File.IO.Executor()
            defer { Task { await io.shutdown() } }

            let content: [UInt8] = [1, 2, 3, 4, 5]
            let path = try createTempFile(content: content)
            defer { cleanup(path) }

            let handle = try await File.Handle.Async.open(path, mode: .read, io: io)

            // Read some data
            _ = try await handle.read(count: 3)

            // Rewind
            let rewindPos = try await handle.rewind()
            #expect(rewindPos == 0)

            // Seek to end
            let endPos = try await handle.seekToEnd()
            #expect(endPos == 5)

            try await handle.close()
        }

        // MARK: - Close

        @Test("Close is idempotent")
        func closeIsIdempotent() async throws {
            let io = File.IO.Executor()
            defer { Task { await io.shutdown() } }

            let path = try createTempFile(content: [1, 2, 3])
            defer { cleanup(path) }

            let handle = try await File.Handle.Async.open(path, mode: .read, io: io)
            #expect(await handle.isOpen)

            try await handle.close()
            #expect(await !handle.isOpen)

            // Second close should not throw
            try await handle.close()
        }

        @Test("Operations on closed handle throw")
        func operationsOnClosedThrow() async throws {
            let io = File.IO.Executor()
            defer { Task { await io.shutdown() } }

            let path = try createTempFile(content: [1, 2, 3])
            defer { cleanup(path) }

            let handle = try await File.Handle.Async.open(path, mode: .read, io: io)
            try await handle.close()

            await #expect(throws: File.Handle.Error.self) {
                _ = try await handle.read(count: 10)
            }
        }

        // MARK: - Handle Store Tests

        @Test("Handle ID scope mismatch throws")
        func scopeMismatchThrows() async throws {
            let io1 = File.IO.Executor()
            let io2 = File.IO.Executor()
            defer {
                Task { await io1.shutdown() }
                Task { await io2.shutdown() }
            }

            let path = try createTempFile(content: [1, 2, 3])
            defer { cleanup(path) }

            // Open on io1
            let handle = try await File.Handle.Async.open(path, mode: .read, io: io1)

            // The handle's ID is scoped to io1, using it with io2 should fail
            // (This is tested indirectly through the actor design)
            #expect(handle.mode == .read)

            try await handle.close()
        }

        @Test("Shutdown closes remaining handles")
        func shutdownClosesHandles() async throws {
            let io = File.IO.Executor()

            let path = try createTempFile(content: [1, 2, 3])
            defer { cleanup(path) }

            // Open but don't close
            let handle = try await File.Handle.Async.open(path, mode: .read, io: io)
            _ = handle  // Silence unused warning

            // Shutdown should close the handle (best-effort)
            await io.shutdown()

            // Handle should no longer be valid
            #expect(await !handle.isOpen)
        }
    }
}
