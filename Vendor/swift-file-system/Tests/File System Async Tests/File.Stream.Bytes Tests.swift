//
//  File.Stream.Bytes Tests.swift
//  swift-file-system
//
//  Created by Coen ten Thije Boonkkamp on 18/12/2025.
//

import Foundation
import Testing

@testable import File_System_Async

extension File.IO.Test.Unit {
    @Suite("File.Stream.Bytes")
    struct StreamBytes {

        // MARK: - Test Fixtures

        private func createTempFile(content: [UInt8]) throws -> File.Path {
            let path = "/tmp/async-stream-test-\(UUID().uuidString).bin"
            let data = Data(content)
            try data.write(to: URL(fileURLWithPath: path))
            return try File.Path(path)
        }

        private func cleanup(_ path: File.Path) {
            try? FileManager.default.removeItem(atPath: path.string)
        }

        // MARK: - Basic Streaming

        @Test("Stream empty file")
        func streamEmptyFile() async throws {
            let io = File.IO.Executor()
            defer { Task { await io.shutdown() } }

            let path = try createTempFile(content: [])
            defer { cleanup(path) }

            let stream = File.Stream.Async(io: io).bytes(from: path)
            var count = 0

            for try await _ in stream {
                count += 1
            }

            #expect(count == 0)
        }

        @Test("Stream small file")
        func streamSmallFile() async throws {
            let io = File.IO.Executor()
            defer { Task { await io.shutdown() } }

            let content: [UInt8] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
            let path = try createTempFile(content: content)
            defer { cleanup(path) }

            let stream = File.Stream.Async(io: io).bytes(from: path)
            var allBytes: [UInt8] = []

            for try await chunk in stream {
                allBytes.append(contentsOf: chunk)
            }

            #expect(allBytes == content)
        }

        @Test("Stream large file in chunks")
        func streamLargeFileInChunks() async throws {
            let io = File.IO.Executor()
            defer { Task { await io.shutdown() } }

            // Create 1MB file
            let size = 1024 * 1024
            let content = [UInt8](repeating: 42, count: size)
            let path = try createTempFile(content: content)
            defer { cleanup(path) }

            // Stream with 64KB chunks (default)
            let stream = File.Stream.Async(io: io).bytes(from: path)
            var totalBytes = 0
            var chunkCount = 0

            for try await chunk in stream {
                totalBytes += chunk.count
                chunkCount += 1
            }

            #expect(totalBytes == size)
            // Should be ~16 chunks (1MB / 64KB)
            #expect(chunkCount >= 16)
        }

        @Test("Stream with custom chunk size")
        func streamWithCustomChunkSize() async throws {
            let io = File.IO.Executor()
            defer { Task { await io.shutdown() } }

            // Create 1000 byte file
            let content = [UInt8](repeating: 0xAB, count: 1000)
            let path = try createTempFile(content: content)
            defer { cleanup(path) }

            // Stream with 100 byte chunks
            let options = File.Stream.Async.BytesOptions(chunkSize: 100)
            let stream = File.Stream.Async(io: io).bytes(from: path, options: options)

            var chunkSizes: [Int] = []
            for try await chunk in stream {
                chunkSizes.append(chunk.count)
            }

            // Should be 10 chunks of 100 bytes each
            #expect(chunkSizes.count == 10)
            for size in chunkSizes {
                #expect(size == 100)
            }
        }

        @Test("Last chunk may be smaller")
        func lastChunkMayBeSmaller() async throws {
            let io = File.IO.Executor()
            defer { Task { await io.shutdown() } }

            // Create 150 byte file
            let content = [UInt8](repeating: 0xCD, count: 150)
            let path = try createTempFile(content: content)
            defer { cleanup(path) }

            // Stream with 100 byte chunks
            let options = File.Stream.Async.BytesOptions(chunkSize: 100)
            let stream = File.Stream.Async(io: io).bytes(from: path, options: options)

            var chunkSizes: [Int] = []
            for try await chunk in stream {
                chunkSizes.append(chunk.count)
            }

            // Should be 2 chunks: 100 + 50
            #expect(chunkSizes.count == 2)
            #expect(chunkSizes[0] == 100)
            #expect(chunkSizes[1] == 50)
        }

        // MARK: - Error Handling

        @Test("Stream non-existent file throws")
        func streamNonExistentThrows() async throws {
            let io = File.IO.Executor()
            defer { Task { await io.shutdown() } }

            let path = try File.Path("/tmp/nonexistent-\(UUID().uuidString).bin")

            let stream = File.Stream.Async(io: io).bytes(from: path)

            await #expect(throws: (any Error).self) {
                for try await _ in stream {
                    // Should throw
                }
            }
        }

        // MARK: - Termination

        @Test("Terminate stops streaming")
        func terminateStopsStreaming() async throws {
            let io = File.IO.Executor()
            defer { Task { await io.shutdown() } }

            // Create 10KB file
            let content = [UInt8](repeating: 0xFF, count: 10 * 1024)
            let path = try createTempFile(content: content)
            defer { cleanup(path) }

            // Stream with 1KB chunks
            let options = File.Stream.Async.BytesOptions(chunkSize: 1024)
            let stream = File.Stream.Async(io: io).bytes(from: path, options: options)
            var iterator = stream.makeAsyncIterator()
            var count = 0

            // Read 3 chunks
            while try await iterator.next() != nil, count < 3 {
                count += 1
            }

            // Terminate
            iterator.terminate()

            // After termination, next() should return nil
            let afterTerminate = try await iterator.next()
            #expect(afterTerminate == nil)
        }

        // MARK: - Break from Loop

        @Test("Breaking from loop cleans up resources")
        func breakFromLoopCleansUp() async throws {
            let io = File.IO.Executor()
            defer { Task { await io.shutdown() } }

            // Create 10KB file
            let content = [UInt8](repeating: 0xEE, count: 10 * 1024)
            let path = try createTempFile(content: content)
            defer { cleanup(path) }

            // Stream with 1KB chunks
            let options = File.Stream.Async.BytesOptions(chunkSize: 1024)
            let stream = File.Stream.Async(io: io).bytes(from: path, options: options)
            var count = 0

            for try await _ in stream {
                count += 1
                if count >= 3 {
                    break
                }
            }

            #expect(count == 3)
            // Resources should be cleaned up
        }

        // MARK: - Data Integrity

        @Test("Streamed content matches original")
        func streamedContentMatchesOriginal() async throws {
            let io = File.IO.Executor()
            defer { Task { await io.shutdown() } }

            // Create file with varied content
            var content: [UInt8] = []
            for i: UInt8 in 0..<255 {
                content.append(contentsOf: [UInt8](repeating: i, count: 100))
            }
            let path = try createTempFile(content: content)
            defer { cleanup(path) }

            let stream = File.Stream.Async(io: io).bytes(from: path)
            var allBytes: [UInt8] = []

            for try await chunk in stream {
                allBytes.append(contentsOf: chunk)
            }

            #expect(allBytes == content)
        }
    }
}
