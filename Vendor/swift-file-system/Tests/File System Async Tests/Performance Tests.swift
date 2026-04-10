//
//  Performance Tests.swift
//  swift-file-system
//
//  Created by Coen ten Thije Boonkkamp on 18/12/2025.
//

import File_System_Primitives
import Foundation
import Testing
import TestingPerformance

@testable import File_System_Async

extension File.IO.Test.Performance {

    // MARK: - Executor Performance

    @Suite(.serialized)
    struct `Executor Performance` {

        @Test("Job submission throughput (1000 lightweight jobs)", .timed(iterations: 5, warmup: 1))
        func jobSubmissionThroughput() async throws {
            let executor = File.IO.Executor()
            defer { Task { await executor.shutdown() } }

            // Submit 1000 lightweight jobs
            await withTaskGroup(of: Int.self) { group in
                for i in 0..<1000 {
                    group.addTask {
                        try? await executor.run { i * 2 }
                        return i
                    }
                }

                var count = 0
                for await _ in group {
                    count += 1
                }
                #expect(count == 1000)
            }
        }

        @Test("Sequential job execution", .timed(iterations: 20, warmup: 3))
        func sequentialJobExecution() async throws {
            let executor = File.IO.Executor()
            defer { Task { await executor.shutdown() } }

            // 50 sequential jobs
            for i in 0..<50 {
                let result = try await executor.run { i * 2 }
                #expect(result == i * 2)
            }
        }

        @Test("Executor startup latency", .timed(iterations: 10, warmup: 2))
        func executorStartupLatency() async throws {
            // Measure first job latency (includes worker startup)
            let executor = File.IO.Executor()
            defer { Task { await executor.shutdown() } }

            let result = try await executor.run { 42 }
            #expect(result == 42)
        }

        @Test("Concurrent job completion", .timed(iterations: 5, warmup: 1))
        func concurrentJobCompletion() async throws {
            let executor = File.IO.Executor(.init(workers: 8))
            defer { Task { await executor.shutdown() } }

            // 100 concurrent jobs with small sleep
            await withTaskGroup(of: Bool.self) { group in
                for _ in 0..<100 {
                    group.addTask {
                        do {
                            return try await executor.run {
                                Thread.sleep(forTimeInterval: 0.001)  // 1ms
                                return true
                            }
                        } catch {
                            return false
                        }
                    }
                }

                var successCount = 0
                for await success in group {
                    if success { successCount += 1 }
                }
                #expect(successCount == 100)
            }
        }
    }

    // MARK: - Handle Store Performance

    @Suite(.serialized)
    struct `Handle Store Performance` {

        @Test("Handle registration and destruction", .timed(iterations: 20, warmup: 3))
        func handleRegistrationDestruction() async throws {
            let tempDir = try File.Path(NSTemporaryDirectory())
            let filePath = tempDir.appending("perf_handle_reg_\(UUID().uuidString).txt")

            let data = [UInt8](repeating: 0x00, count: 100)
            try data.withUnsafeBufferPointer { buffer in
                let span = Span<UInt8>(_unsafeElements: buffer)
                try File.System.Write.Atomic.write(span, to: filePath)
            }

            defer { try? File.System.Delete.delete(at: filePath) }

            let executor = File.IO.Executor()
            defer { Task { await executor.shutdown() } }

            // Register and destroy 20 handles
            for _ in 0..<20 {
                let handleId = try await executor.run {
                    let handle = try File.Handle.open(filePath, mode: .read)
                    return try executor.registerHandle(handle)
                }
                try await executor.destroyHandle(handleId)
            }
        }

        @Test("withHandle access pattern", .timed(iterations: 20, warmup: 3))
        func withHandleAccess() async throws {
            let tempDir = try File.Path(NSTemporaryDirectory())
            let filePath = tempDir.appending("perf_withhandle_\(UUID().uuidString).txt")

            let data = [UInt8](repeating: 0x42, count: 1000)
            try data.withUnsafeBufferPointer { buffer in
                let span = Span<UInt8>(_unsafeElements: buffer)
                try File.System.Write.Atomic.write(span, to: filePath)
            }

            defer { try? File.System.Delete.delete(at: filePath) }

            let executor = File.IO.Executor()
            defer { Task { await executor.shutdown() } }

            let handleId = try await executor.run {
                let handle = try File.Handle.open(filePath, mode: .read)
                return try executor.registerHandle(handle)
            }

            // 50 withHandle accesses
            for _ in 0..<50 {
                let bytes: [UInt8] = try await executor.withHandle(handleId) { handle in
                    try handle.seek(to: 0)
                    return try handle.read(count: 100)
                }
                #expect(bytes.count == 100)
            }

            try await executor.destroyHandle(handleId)
        }
    }

    // MARK: - Directory Operations

    @Suite(.serialized)
    struct `Directory Operations` {

        @Test("Async directory contents (100 files)", .timed(iterations: 10, warmup: 2))
        func asyncDirectoryContents() async throws {
            let tempDir = try File.Path(NSTemporaryDirectory())
            let testDir = tempDir.appending("perf_async_dir_\(UUID().uuidString)")

            // Setup
            try await File.System.Create.Directory.create(at: testDir)
            let fileData = [UInt8](repeating: 0x00, count: 10)
            for i in 0..<100 {
                let filePath = testDir.appending("file_\(i).txt")
                try await File.System.Write.Atomic.write(fileData, to: filePath)
            }

            defer { Task { try? await File.System.Delete.delete(at: testDir, options: .init(recursive: true)) } }

            let entries = try await File.Directory.contents(at: testDir)
            #expect(entries.count == 100)
        }

        @Test("Directory entries streaming (100 files)", .timed(iterations: 10, warmup: 2))
        func directoryEntriesStreaming() async throws {
            let tempDir = try File.Path(NSTemporaryDirectory())
            let testDir = tempDir.appending("perf_async_entries_\(UUID().uuidString)")

            // Setup
            try await File.System.Create.Directory.create(at: testDir)
            let fileData = [UInt8](repeating: 0x00, count: 10)
            for i in 0..<100 {
                let filePath = testDir.appending("file_\(i).txt")
                try await File.System.Write.Atomic.write(fileData, to: filePath)
            }

            defer { Task { try? await File.System.Delete.delete(at: testDir, options: .init(recursive: true)) } }

            var count = 0
            for try await _ in File.Directory.entries(at: testDir) {
                count += 1
            }
            #expect(count == 100)
        }

        @Test("Directory walk (shallow tree: 10 dirs × 10 files)", .timed(iterations: 5, warmup: 1))
        func directoryWalkShallow() async throws {
            let tempDir = try File.Path(NSTemporaryDirectory())
            let testDir = tempDir.appending("perf_walk_shallow_\(UUID().uuidString)")

            // Setup: 10 subdirs, each with 10 files = 100 files total + 10 dirs
            try await File.System.Create.Directory.create(at: testDir)
            let fileData = [UInt8](repeating: 0x00, count: 10)

            for i in 0..<10 {
                let subDir = testDir.appending("dir_\(i)")
                try await File.System.Create.Directory.create(at: subDir)

                for j in 0..<10 {
                    let filePath = subDir.appending("file_\(j).txt")
                    try await File.System.Write.Atomic.write(fileData, to: filePath)
                }
            }

            defer { Task { try? await File.System.Delete.delete(at: testDir, options: .init(recursive: true)) } }

            var count = 0
            for try await _ in File.Directory.walk(at: testDir) {
                count += 1
            }
            // 10 dirs + 100 files = 110 entries
            #expect(count == 110)
        }

        @Test("Directory walk (deep tree: 5 levels)", .timed(iterations: 5, warmup: 1))
        func directoryWalkDeep() async throws {
            let tempDir = try File.Path(NSTemporaryDirectory())
            let testDir = tempDir.appending("perf_walk_deep_\(UUID().uuidString)")

            // Setup: 5 levels deep with 3 files per level
            try await File.System.Create.Directory.create(at: testDir)
            let fileData = [UInt8](repeating: 0x00, count: 10)

            var currentDir = testDir
            for level in 0..<5 {
                // Add files at this level
                for j in 0..<3 {
                    let filePath = currentDir.appending("file_\(j).txt")
                    try await File.System.Write.Atomic.write(fileData, to: filePath)
                }

                // Create next level
                let subDir = currentDir.appending("level_\(level)")
                try await File.System.Create.Directory.create(at: subDir)
                currentDir = subDir
            }

            // Add files at deepest level
            for j in 0..<3 {
                let filePath = currentDir.appending("file_\(j).txt")
                try await File.System.Write.Atomic.write(fileData, to: filePath)
            }

            defer { Task { try? await File.System.Delete.delete(at: testDir, options: .init(recursive: true)) } }

            var count = 0
            for try await _ in File.Directory.walk(at: testDir) {
                count += 1
            }
            // 5 dirs + (6 levels × 3 files) = 5 + 18 = 23 entries
            #expect(count == 23)
        }
    }

    // MARK: - Byte Streaming

    @Suite(.serialized)
    struct `Byte Streaming` {

        @Test("Stream 1MB file (64KB chunks)", .timed(iterations: 5, warmup: 1))
        func stream1MBFile() async throws {
            let tempDir = try File.Path(NSTemporaryDirectory())
            let filePath = tempDir.appending("perf_stream_1mb_\(UUID().uuidString).bin")

            // Setup
            let oneMB = [UInt8](repeating: 0xAB, count: 1_000_000)
            try oneMB.withUnsafeBufferPointer { buffer in
                let span = Span<UInt8>(_unsafeElements: buffer)
                try File.System.Write.Atomic.write(span, to: filePath)
            }

            defer { try? File.System.Delete.delete(at: filePath) }

            let executor = File.IO.Executor()
            defer { Task { await executor.shutdown() } }

            let stream = File.Stream.Async(io: executor)
            var totalBytes = 0
            for try await chunk in stream.bytes(from: filePath) {
                totalBytes += chunk.count
            }
            #expect(totalBytes == 1_000_000)
        }

        @Test("Stream 1MB file (4KB chunks)", .timed(iterations: 5, warmup: 1))
        func stream1MBSmallChunks() async throws {
            let tempDir = try File.Path(NSTemporaryDirectory())
            let filePath = tempDir.appending("perf_stream_small_\(UUID().uuidString).bin")

            // Setup
            let oneMB = [UInt8](repeating: 0xCD, count: 1_000_000)
            try oneMB.withUnsafeBufferPointer { buffer in
                let span = Span<UInt8>(_unsafeElements: buffer)
                try File.System.Write.Atomic.write(span, to: filePath)
            }

            defer { try? File.System.Delete.delete(at: filePath) }

            let executor = File.IO.Executor()
            defer { Task { await executor.shutdown() } }

            let stream = File.Stream.Async(io: executor)
            let options = File.Stream.Async.BytesOptions(chunkSize: 4096)
            var totalBytes = 0
            var chunkCount = 0
            for try await chunk in stream.bytes(from: filePath, options: options) {
                totalBytes += chunk.count
                chunkCount += 1
            }
            #expect(totalBytes == 1_000_000)
            // ~244 chunks for 1MB / 4KB
            #expect(chunkCount > 240)
        }

        @Test("Early termination streaming", .timed(iterations: 20, warmup: 3))
        func earlyTermination() async throws {
            let tempDir = try File.Path(NSTemporaryDirectory())
            let filePath = tempDir.appending("perf_stream_early_\(UUID().uuidString).bin")

            // Setup: larger file
            let fiveMB = [UInt8](repeating: 0xEF, count: 5_000_000)
            try fiveMB.withUnsafeBufferPointer { buffer in
                let span = Span<UInt8>(_unsafeElements: buffer)
                try File.System.Write.Atomic.write(span, to: filePath)
            }

            defer { try? File.System.Delete.delete(at: filePath) }

            let executor = File.IO.Executor()
            defer { Task { await executor.shutdown() } }

            let stream = File.Stream.Async(io: executor)
            var bytesRead = 0

            for try await chunk in stream.bytes(from: filePath) {
                bytesRead += chunk.count
                if bytesRead >= 100_000 {
                    break  // Early exit
                }
            }

            #expect(bytesRead >= 100_000)
        }
    }

    // MARK: - Async System Operations

    @Suite(.serialized)
    struct `Async System Operations` {

        @Test("Async stat operations", .timed(iterations: 20, warmup: 3))
        func asyncStatOperations() async throws {
            let tempDir = try File.Path(NSTemporaryDirectory())
            let filePath = tempDir.appending("perf_async_stat_\(UUID().uuidString).txt")

            let data = [UInt8](repeating: 0x00, count: 1000)
            try data.withUnsafeBufferPointer { buffer in
                let span = Span<UInt8>(_unsafeElements: buffer)
                try File.System.Write.Atomic.write(span, to: filePath)
            }

            defer { try? File.System.Delete.delete(at: filePath) }

            let executor = File.IO.Executor()
            defer { Task { await executor.shutdown() } }

            // 50 stat operations using static async methods
            for _ in 0..<50 {
                let exists = await File.System.Stat.exists(at: filePath, io: executor)
                #expect(exists)
            }
        }

        @Test("Async file copy (1MB)", .timed(iterations: 5, warmup: 1))
        func asyncFileCopy() async throws {
            let tempDir = try File.Path(NSTemporaryDirectory())
            let sourcePath = tempDir.appending("perf_async_copy_src_\(UUID().uuidString).bin")
            let destPath = tempDir.appending("perf_async_copy_dst_\(UUID().uuidString).bin")

            // Setup
            let oneMB = [UInt8](repeating: 0xAA, count: 1_000_000)
            try oneMB.withUnsafeBufferPointer { buffer in
                let span = Span<UInt8>(_unsafeElements: buffer)
                try File.System.Write.Atomic.write(span, to: sourcePath)
            }

            defer {
                try? File.System.Delete.delete(at: sourcePath)
                try? File.System.Delete.delete(at: destPath)
            }

            let executor = File.IO.Executor()
            defer { Task { await executor.shutdown() } }

            try await File.System.Copy.copy(from: sourcePath, to: destPath, io: executor)

            let destExists = await File.System.Stat.exists(at: destPath, io: executor)
            #expect(destExists)
        }
    }

    // MARK: - Concurrency Stress

    @Suite(.serialized)
    struct `Concurrency Stress` {

        @Test("Concurrent file reads (10 files)", .timed(iterations: 5, warmup: 1))
        func concurrentFileReads() async throws {
            let tempDir = try File.Path(NSTemporaryDirectory())
            let testDir = tempDir.appending("perf_concurrent_\(UUID().uuidString)")

            // Setup: 10 files, 100KB each
            try await File.System.Create.Directory.create(at: testDir)
            let fileData = [UInt8](repeating: 0x55, count: 100_000)

            var filePaths: [File.Path] = []
            for i in 0..<10 {
                let filePath = testDir.appending("file_\(i).bin")
                try await File.System.Write.Atomic.write(fileData, to: filePath)
                filePaths.append(filePath)
            }

            defer { Task { try? await File.System.Delete.delete(at: testDir, options: .init(recursive: true)) } }

            let executor = File.IO.Executor()
            defer { Task { await executor.shutdown() } }

            // Read all files concurrently
            await withTaskGroup(of: Int.self) { group in
                for path in filePaths {
                    group.addTask {
                        do {
                            let data = try await executor.run {
                                try File.System.Read.Full.read(from: path)
                            }
                            return data.count
                        } catch {
                            return 0
                        }
                    }
                }

                var totalBytes = 0
                for await bytes in group {
                    totalBytes += bytes
                }
                #expect(totalBytes == 10 * 100_000)
            }
        }

        @Test("Mixed read/write operations", .timed(iterations: 5, warmup: 1))
        func mixedReadWriteOperations() async throws {
            let tempDir = try File.Path(NSTemporaryDirectory())
            let testDir = tempDir.appending("perf_mixed_\(UUID().uuidString)")

            try await File.System.Create.Directory.create(at: testDir)
            defer { Task { try? await File.System.Delete.delete(at: testDir, options: .init(recursive: true)) } }

            let executor = File.IO.Executor()
            defer { Task { await executor.shutdown() } }

            // Concurrent writes and reads
            await withTaskGroup(of: Bool.self) { group in
                // Writers
                for i in 0..<20 {
                    group.addTask {
                        do {
                            let data = [UInt8](repeating: UInt8(i % 256), count: 10_000)
                            let filePath = testDir.appending("write_\(i).bin")
                            try await executor.run {
                                try data.withUnsafeBufferPointer { buffer in
                                    let span = Span<UInt8>(_unsafeElements: buffer)
                                    try File.System.Write.Atomic.write(span, to: filePath)
                                }
                            }
                            return true
                        } catch {
                            return false
                        }
                    }
                }

                // Let some writes complete, then do reads
                var successCount = 0
                for await success in group {
                    if success { successCount += 1 }
                }

                #expect(successCount == 20)
            }
        }
    }

    // MARK: - Memory Tracking

    @Suite(.serialized)
    struct `Memory Tracking` {

        @Test("Executor job execution", .timed(iterations: 5))
        func executorJobExecution() async throws {
            let executor = File.IO.Executor()

            // Run some jobs
            for i in 0..<100 {
                let result = try await executor.run { i * 2 }
                #expect(result == i * 2)
            }

            await executor.shutdown()
        }

        @Test(
            "Streaming doesn't accumulate memory",
            .timed(iterations: 3, maxAllocations: 5_000_000)
        )
        func streamingMemoryBounded() async throws {
            let tempDir = try File.Path(NSTemporaryDirectory())
            let filePath = tempDir.appending("perf_mem_stream_\(UUID().uuidString).bin")

            // Create 1MB file
            let oneMB = [UInt8](repeating: 0xAB, count: 1_000_000)
            try oneMB.withUnsafeBufferPointer { buffer in
                let span = Span<UInt8>(_unsafeElements: buffer)
                try File.System.Write.Atomic.write(span, to: filePath)
            }

            defer { try? File.System.Delete.delete(at: filePath) }

            let executor = File.IO.Executor()
            defer { Task { await executor.shutdown() } }

            let stream = File.Stream.Async(io: executor)

            // Stream and discard - should not accumulate memory
            var totalBytes = 0
            for try await chunk in stream.bytes(from: filePath) {
                totalBytes += chunk.count
            }
            #expect(totalBytes == 1_000_000)
        }

        @Test("Handle store cleanup", .timed(iterations: 5))
        func handleStoreCleanup() async throws {
            let tempDir = try File.Path(NSTemporaryDirectory())
            let filePath = tempDir.appending("perf_handle_cleanup_\(UUID().uuidString).txt")

            let data = [UInt8](repeating: 0x00, count: 100)
            try data.withUnsafeBufferPointer { buffer in
                let span = Span<UInt8>(_unsafeElements: buffer)
                try File.System.Write.Atomic.write(span, to: filePath)
            }

            defer { try? File.System.Delete.delete(at: filePath) }

            let executor = File.IO.Executor()

            // Register and destroy many handles
            for _ in 0..<50 {
                let handleId = try await executor.run {
                    let handle = try File.Handle.open(filePath, mode: .read)
                    return try executor.registerHandle(handle)
                }
                try await executor.destroyHandle(handleId)
            }

            await executor.shutdown()
        }
    }
}
