//
//  File.Directory.Walk Tests.swift
//  swift-file-system
//
//  Created by Coen ten Thije Boonkkamp on 18/12/2025.
//

import Foundation
import Testing

@testable import File_System_Async

extension File.IO.Test.Unit {
    @Suite("File.Directory.Walk")
    struct DirectoryWalk {

        // MARK: - Test Fixtures

        private func createTempDir() throws -> File.Path {
            let path = "/tmp/async-walk-test-\(UUID().uuidString)"
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

        private func createSubdir(in dir: File.Path, name: String) throws -> File.Path {
            let subPath = dir.string + "/" + name
            try FileManager.default.createDirectory(
                atPath: subPath,
                withIntermediateDirectories: true
            )
            return try File.Path(subPath)
        }

        private func cleanup(_ path: File.Path) {
            try? FileManager.default.removeItem(atPath: path.string)
        }

        // MARK: - Basic Walking

        @Test("Walk empty directory")
        func walkEmptyDirectory() async throws {
            let io = File.IO.Executor()
            defer { Task { await io.shutdown() } }

            let dir = try createTempDir()
            defer { cleanup(dir) }

            let walk = File.Directory.Async(io: io).walk(at: dir)
            var count = 0

            for try await _ in walk {
                count += 1
            }

            #expect(count == 0)
        }

        @Test("Walk directory with files")
        func walkDirectoryWithFiles() async throws {
            let io = File.IO.Executor()
            defer { Task { await io.shutdown() } }

            let dir = try createTempDir()
            defer { cleanup(dir) }

            try createFile(in: dir, name: "file1.txt")
            try createFile(in: dir, name: "file2.txt")
            try createFile(in: dir, name: "file3.txt")

            let walk = File.Directory.Async(io: io).walk(at: dir)
            var paths: [String] = []

            for try await path in walk {
                paths.append(path.string)
            }

            #expect(paths.count == 3)
        }

        @Test("Walk directory recursively")
        func walkDirectoryRecursively() async throws {
            let io = File.IO.Executor()
            defer { Task { await io.shutdown() } }

            let dir = try createTempDir()
            defer { cleanup(dir) }

            // Create structure:
            // dir/
            //   file1.txt
            //   subdir1/
            //     file2.txt
            //     subsubdir/
            //       file3.txt
            //   subdir2/
            //     file4.txt

            try createFile(in: dir, name: "file1.txt")

            let sub1 = try createSubdir(in: dir, name: "subdir1")
            try createFile(in: sub1, name: "file2.txt")

            let subsub = try createSubdir(in: sub1, name: "subsubdir")
            try createFile(in: subsub, name: "file3.txt")

            let sub2 = try createSubdir(in: dir, name: "subdir2")
            try createFile(in: sub2, name: "file4.txt")

            let walk = File.Directory.Async(io: io).walk(at: dir)
            var paths: Set<String> = []

            for try await path in walk {
                paths.insert(path.string)
            }

            // Should find: subdir1, file2.txt, subsubdir, file3.txt, subdir2, file4.txt, file1.txt
            // (7 entries total)
            #expect(paths.count == 7)
            #expect(paths.contains(dir.string + "/file1.txt"))
            #expect(paths.contains(dir.string + "/subdir1"))
            #expect(paths.contains(dir.string + "/subdir1/file2.txt"))
            #expect(paths.contains(dir.string + "/subdir1/subsubdir"))
            #expect(paths.contains(dir.string + "/subdir1/subsubdir/file3.txt"))
            #expect(paths.contains(dir.string + "/subdir2"))
            #expect(paths.contains(dir.string + "/subdir2/file4.txt"))
        }

        // MARK: - Error Handling

        @Test("Walk non-existent directory throws")
        func walkNonExistentThrows() async throws {
            let io = File.IO.Executor()
            defer { Task { await io.shutdown() } }

            let path = try File.Path("/tmp/nonexistent-\(UUID().uuidString)")

            let walk = File.Directory.Async(io: io).walk(at: path)

            await #expect(throws: (any Error).self) {
                for try await _ in walk {
                    // Should throw
                }
            }
        }

        // MARK: - Termination

        @Test("Terminate stops walking")
        func terminateStopsWalking() async throws {
            let io = File.IO.Executor()
            defer { Task { await io.shutdown() } }

            let dir = try createTempDir()
            defer { cleanup(dir) }

            // Create nested structure
            for i in 0..<5 {
                let sub = try createSubdir(in: dir, name: "dir\(i)")
                for j in 0..<5 {
                    try createFile(in: sub, name: "file\(j).txt")
                }
            }

            let walk = File.Directory.Async(io: io).walk(at: dir)
            var iterator = walk.makeAsyncIterator()
            var count = 0

            // Read a few paths
            while try await iterator.next() != nil, count < 10 {
                count += 1
            }

            // Explicitly terminate
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

            let dir = try createTempDir()
            defer { cleanup(dir) }

            for i in 0..<10 {
                try createFile(in: dir, name: "file\(i).txt")
            }

            let walk = File.Directory.Async(io: io).walk(at: dir)
            var count = 0

            for try await _ in walk {
                count += 1
                if count >= 5 {
                    break
                }
            }

            #expect(count == 5)
            // Resources should be cleaned up
        }

        // MARK: - Large Tree

        @Test("Walk large directory tree")
        func walkLargeTree() async throws {
            let io = File.IO.Executor()
            defer { Task { await io.shutdown() } }

            let dir = try createTempDir()
            defer { cleanup(dir) }

            // Create 10 subdirs, each with 10 files
            for i in 0..<10 {
                let sub = try createSubdir(in: dir, name: "dir\(i)")
                for j in 0..<10 {
                    try createFile(in: sub, name: "file\(j).txt")
                }
            }

            let walk = File.Directory.Async(io: io).walk(at: dir)
            var count = 0

            for try await _ in walk {
                count += 1
            }

            // 10 subdirs + 100 files = 110 entries
            #expect(count == 110)
        }

        // MARK: - Concurrency Options

        @Test("Walk with custom concurrency")
        func walkWithCustomConcurrency() async throws {
            let io = File.IO.Executor()
            defer { Task { await io.shutdown() } }

            let dir = try createTempDir()
            defer { cleanup(dir) }

            for i in 0..<5 {
                let sub = try createSubdir(in: dir, name: "dir\(i)")
                try createFile(in: sub, name: "file.txt")
            }

            let options = File.Directory.Async.WalkOptions(maxConcurrency: 2)
            let walk = File.Directory.Async(io: io).walk(at: dir, options: options)
            var count = 0

            for try await _ in walk {
                count += 1
            }

            // 5 subdirs + 5 files = 10 entries
            #expect(count == 10)
        }
    }
}
