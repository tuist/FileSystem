//
//  File.Directory.Entries Tests.swift
//  swift-file-system
//
//  Created by Coen ten Thije Boonkkamp on 18/12/2025.
//

import Foundation
import Testing

@testable import File_System_Async

extension File.IO.Test.Unit {
    @Suite("File.Directory.Entries")
    struct DirectoryEntries {

        // MARK: - Test Fixtures

        private func createTempDir() throws -> File.Path {
            let path = "/tmp/async-entries-test-\(UUID().uuidString)"
            try FileManager.default.createDirectory(
                atPath: path,
                withIntermediateDirectories: true
            )
            return try File.Path(path)
        }

        private func createFile(in dir: File.Path, name: String, content: String = "") throws {
            let filePath = dir.string + "/" + name
            try content.write(toFile: filePath, atomically: true, encoding: .utf8)
        }

        private func createSubdir(in dir: File.Path, name: String) throws {
            let subPath = dir.string + "/" + name
            try FileManager.default.createDirectory(
                atPath: subPath,
                withIntermediateDirectories: true
            )
        }

        private func cleanup(_ path: File.Path) {
            try? FileManager.default.removeItem(atPath: path.string)
        }

        // MARK: - Basic Iteration

        @Test("Stream empty directory")
        func streamEmptyDirectory() async throws {
            let io = File.IO.Executor()
            defer { Task { await io.shutdown() } }

            let dir = try createTempDir()
            defer { cleanup(dir) }

            let entries = File.Directory.Async(io: io).entries(at: dir)
            var count = 0

            for try await _ in entries {
                count += 1
            }

            #expect(count == 0)
        }

        @Test("Stream directory with files")
        func streamDirectoryWithFiles() async throws {
            let io = File.IO.Executor()
            defer { Task { await io.shutdown() } }

            let dir = try createTempDir()
            defer { cleanup(dir) }

            try createFile(in: dir, name: "file1.txt", content: "hello")
            try createFile(in: dir, name: "file2.txt", content: "world")
            try createFile(in: dir, name: "file3.txt", content: "test")

            let entries = File.Directory.Async(io: io).entries(at: dir)
            var names: [String] = []

            for try await entry in entries {
                names.append(entry.name)
            }

            #expect(names.count == 3)
            #expect(names.contains("file1.txt"))
            #expect(names.contains("file2.txt"))
            #expect(names.contains("file3.txt"))
        }

        @Test("Stream directory with subdirectories")
        func streamDirectoryWithSubdirs() async throws {
            let io = File.IO.Executor()
            defer { Task { await io.shutdown() } }

            let dir = try createTempDir()
            defer { cleanup(dir) }

            try createFile(in: dir, name: "file.txt")
            try createSubdir(in: dir, name: "subdir1")
            try createSubdir(in: dir, name: "subdir2")

            let entries = File.Directory.Async(io: io).entries(at: dir)
            var files: [String] = []
            var dirs: [String] = []

            for try await entry in entries {
                if entry.type == .file {
                    files.append(entry.name)
                } else if entry.type == .directory {
                    dirs.append(entry.name)
                }
            }

            #expect(files.count == 1)
            #expect(files.contains("file.txt"))
            #expect(dirs.count == 2)
            #expect(dirs.contains("subdir1"))
            #expect(dirs.contains("subdir2"))
        }

        @Test("Entry has correct path")
        func entryHasCorrectPath() async throws {
            let io = File.IO.Executor()
            defer { Task { await io.shutdown() } }

            let dir = try createTempDir()
            defer { cleanup(dir) }

            try createFile(in: dir, name: "test.txt")

            let entries = File.Directory.Async(io: io).entries(at: dir)
            var foundEntry: File.Directory.Entry?

            for try await entry in entries {
                foundEntry = entry
            }

            #expect(foundEntry != nil)
            #expect(foundEntry?.path.string == dir.string + "/test.txt")
        }

        // MARK: - Error Handling

        @Test("Stream non-existent directory throws")
        func streamNonExistentThrows() async throws {
            let io = File.IO.Executor()
            defer { Task { await io.shutdown() } }

            let path = try File.Path("/tmp/nonexistent-\(UUID().uuidString)")

            let entries = File.Directory.Async(io: io).entries(at: path)

            await #expect(throws: (any Error).self) {
                for try await _ in entries {
                    // Should throw before yielding
                }
            }
        }

        // MARK: - Explicit Termination

        @Test("Terminate stops iteration")
        func terminateStopsIteration() async throws {
            let io = File.IO.Executor()
            defer { Task { await io.shutdown() } }

            let dir = try createTempDir()
            defer { cleanup(dir) }

            // Create many files
            for i in 0..<10 {
                try createFile(in: dir, name: "file\(i).txt")
            }

            let entries = File.Directory.Async(io: io).entries(at: dir)
            var iterator = entries.makeAsyncIterator()
            var count = 0

            // Read a few entries
            while try await iterator.next() != nil, count < 3 {
                count += 1
            }

            // Explicitly terminate
            iterator.terminate()

            // After termination, next() should return nil
            let afterTerminate = try await iterator.next()
            #expect(afterTerminate == nil)
        }

        @Test("Terminate is idempotent")
        func terminateIsIdempotent() async throws {
            let io = File.IO.Executor()
            defer { Task { await io.shutdown() } }

            let dir = try createTempDir()
            defer { cleanup(dir) }

            let entries = File.Directory.Async(io: io).entries(at: dir)
            var iterator = entries.makeAsyncIterator()

            // Terminate multiple times - should not crash
            iterator.terminate()
            iterator.terminate()
            iterator.terminate()

            let result = try await iterator.next()
            #expect(result == nil)
        }

        // MARK: - Break from Loop

        @Test("Breaking from loop cleans up resources")
        func breakFromLoopCleansUp() async throws {
            let io = File.IO.Executor()
            defer { Task { await io.shutdown() } }

            let dir = try createTempDir()
            defer { cleanup(dir) }

            for i in 0..<10 {
                try createFile(in: dir, name: "file\(i).txt")
            }

            let entries = File.Directory.Async(io: io).entries(at: dir)
            var count = 0

            for try await _ in entries {
                count += 1
                if count >= 3 {
                    break
                }
            }

            #expect(count == 3)
            // Resources should be cleaned up (no leak)
        }

        // MARK: - Large Directory

        @Test("Stream large directory with backpressure")
        func streamLargeDirectory() async throws {
            let io = File.IO.Executor()
            defer { Task { await io.shutdown() } }

            let dir = try createTempDir()
            defer { cleanup(dir) }

            // Create 100 files
            for i in 0..<100 {
                try createFile(in: dir, name: "file\(String(format: "%03d", i)).txt")
            }

            let entries = File.Directory.Async(io: io).entries(at: dir)
            var count = 0

            for try await _ in entries {
                count += 1
            }

            #expect(count == 100)
        }
    }
}
