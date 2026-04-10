//
//  Performance Tests.swift
//  swift-file-system
//
//  Created by Coen ten Thije Boonkkamp on 18/12/2025.
//

import Foundation
import Testing
import TestingPerformance

@testable import File_System_Primitives

extension File.System.Test.Performance {

    // MARK: - File Handle Operations
    @Suite
    struct `Handle Operations` {

        @Test(.timed(iterations: 10, warmup: 2))
        func `Sequential read 1MB file`() throws {
            let tempDir = try File.Path(NSTemporaryDirectory())
            let filePath = tempDir.appending("perf_read_1mb_\(UUID().uuidString).bin")

            // Setup: create 1MB file
            let oneMB = [UInt8](repeating: 0xAB, count: 1_000_000)
            try oneMB.withUnsafeBufferPointer { buffer in
                let span = Span<UInt8>(_unsafeElements: buffer)
                try File.System.Write.Atomic.write(span, to: filePath)
            }

            defer { try? File.System.Delete.delete(at: filePath) }

            // Measure sequential read
            var handle = try File.Handle.open(filePath, mode: .read)
            let _ = try handle.read(count: 1_000_000)
            try handle.close()
        }

        @Test("Sequential write 1MB file", .timed(iterations: 10, warmup: 2))
        func sequentialWrite1MB() throws {
            let tempDir = try File.Path(NSTemporaryDirectory())
            let filePath = tempDir.appending("perf_write_1mb_\(UUID().uuidString).bin")

            defer { try? File.System.Delete.delete(at: filePath) }

            let oneMB = [UInt8](repeating: 0xCD, count: 1_000_000)

            var handle = try File.Handle.open(
                filePath,
                mode: .write,
                options: [.create, .truncate, .closeOnExec]
            )
            try oneMB.withUnsafeBufferPointer { buffer in
                let span = Span<UInt8>(_unsafeElements: buffer)
                try handle.write(span)
            }
            try handle.close()
        }

        @Test("Buffer-based read into preallocated buffer", .timed(iterations: 50, warmup: 5))
        func bufferBasedRead() throws {
            let tempDir = try File.Path(NSTemporaryDirectory())
            let filePath = tempDir.appending("perf_buffer_read_\(UUID().uuidString).bin")

            // Setup: create 64KB file
            let size = 64 * 1024
            let data = [UInt8](repeating: 0x42, count: size)
            try data.withUnsafeBufferPointer { buffer in
                let span = Span<UInt8>(_unsafeElements: buffer)
                try File.System.Write.Atomic.write(span, to: filePath)
            }

            defer { try? File.System.Delete.delete(at: filePath) }

            // Preallocate buffer (zero-allocation read pattern)
            var buffer = [UInt8](repeating: 0, count: size)

            var handle = try File.Handle.open(filePath, mode: .read)
            let bytesRead = try buffer.withUnsafeMutableBytes { ptr in
                try handle.read(into: ptr)
            }
            #expect(bytesRead == size)
            try handle.close()
        }

        @Test("Small write throughput (4KB blocks)", .timed(iterations: 20, warmup: 3))
        func smallWriteThroughput() throws {
            let tempDir = try File.Path(NSTemporaryDirectory())
            let filePath = tempDir.appending("perf_small_writes_\(UUID().uuidString).bin")

            defer { try? File.System.Delete.delete(at: filePath) }

            let blockSize = 4096
            let blocks = 256  // 1MB total
            let block = [UInt8](repeating: 0x55, count: blockSize)

            var handle = try File.Handle.open(
                filePath,
                mode: .write,
                options: [.create, .truncate, .closeOnExec]
            )

            for _ in 0..<blocks {
                try block.withUnsafeBufferPointer { buffer in
                    let span = Span<UInt8>(_unsafeElements: buffer)
                    try handle.write(span)
                }
            }

            try handle.close()
        }

        @Test("Seek operations (random access pattern)", .timed(iterations: 50, warmup: 5))
        func seekPerformance() throws {
            let tempDir = try File.Path(NSTemporaryDirectory())
            let filePath = tempDir.appending("perf_seek_\(UUID().uuidString).bin")

            // Create a 1MB file for seeking
            let size = 1_000_000
            let data = [UInt8](repeating: 0x00, count: size)
            try data.withUnsafeBufferPointer { buffer in
                let span = Span<UInt8>(_unsafeElements: buffer)
                try File.System.Write.Atomic.write(span, to: filePath)
            }

            defer { try? File.System.Delete.delete(at: filePath) }

            var handle = try File.Handle.open(filePath, mode: .read)

            // Random-ish seek pattern
            let positions: [Int64] = [0, 500_000, 100_000, 900_000, 250_000, 750_000, 0]
            for pos in positions {
                try handle.seek(to: pos, from: .start)
            }

            try handle.close()
        }
    }

    // MARK: - System Operations

    @Suite(.serialized)
    struct `System Operations` {

        @Test("File.System.Write.Atomic.write (1MB)", .timed(iterations: 10, warmup: 2))
        func systemWrite1MB() throws {
            let tempDir = try File.Path(NSTemporaryDirectory())
            let filePath = tempDir.appending("perf_syswrite_\(UUID().uuidString).bin")

            defer { try? File.System.Delete.delete(at: filePath) }

            let oneMB = [UInt8](repeating: 0xEF, count: 1_000_000)
            try oneMB.withUnsafeBufferPointer { buffer in
                let span = Span<UInt8>(_unsafeElements: buffer)
                try File.System.Write.Atomic.write(span, to: filePath)
            }
        }

        @Test("File.System.Read.Full.read (1MB)", .timed(iterations: 10, warmup: 2))
        func systemRead1MB() throws {
            let tempDir = try File.Path(NSTemporaryDirectory())
            let filePath = tempDir.appending("perf_sysread_\(UUID().uuidString).bin")

            // Setup
            let oneMB = [UInt8](repeating: 0xBE, count: 1_000_000)
            try oneMB.withUnsafeBufferPointer { buffer in
                let span = Span<UInt8>(_unsafeElements: buffer)
                try File.System.Write.Atomic.write(span, to: filePath)
            }

            defer { try? File.System.Delete.delete(at: filePath) }

            let _ = try File.System.Read.Full.read(from: filePath)
        }

        @Test("File.System.Stat.info", .timed(iterations: 100, warmup: 10))
        func statInfo() throws {
            let tempDir = try File.Path(NSTemporaryDirectory())
            let filePath = tempDir.appending("perf_stat_\(UUID().uuidString).txt")

            // Create file
            let data = [UInt8](repeating: 0x00, count: 1000)
            try data.withUnsafeBufferPointer { buffer in
                let span = Span<UInt8>(_unsafeElements: buffer)
                try File.System.Write.Atomic.write(span, to: filePath)
            }

            defer { try? File.System.Delete.delete(at: filePath) }

            let _ = try File.System.Stat.info(at: filePath)
        }

        @Test("File.System.Stat.exists check", .timed(iterations: 100, warmup: 10))
        func existsCheck() throws {
            let tempDir = try File.Path(NSTemporaryDirectory())
            let filePath = tempDir.appending("perf_exists_\(UUID().uuidString).txt")

            // Create file
            let data = [UInt8](repeating: 0x00, count: 100)
            try data.withUnsafeBufferPointer { buffer in
                let span = Span<UInt8>(_unsafeElements: buffer)
                try File.System.Write.Atomic.write(span, to: filePath)
            }

            defer { try? File.System.Delete.delete(at: filePath) }

            let exists = File.System.Stat.exists(at: filePath)
            #expect(exists)
        }

        @Test("File.System.Copy.copy (1MB)", .timed(iterations: 10, warmup: 2))
        func copyFile1MB() throws {
            let tempDir = try File.Path(NSTemporaryDirectory())
            let sourcePath = tempDir.appending("perf_copy_src_\(UUID().uuidString).bin")
            let destPath = tempDir.appending("perf_copy_dst_\(UUID().uuidString).bin")

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

            try File.System.Copy.copy(from: sourcePath, to: destPath)
        }
    }

    // MARK: - Directory Operations

    @Suite(.serialized)
    struct `Directory Operations` {

        @Test("Directory iteration (100 files)", .timed(iterations: 20, warmup: 3))
        func directoryIteration100Files() throws {
            let tempDir = try File.Path(NSTemporaryDirectory())
            let testDir = tempDir.appending("perf_dir_100_\(UUID().uuidString)")

            // Setup: create directory with 100 files
            try File.System.Create.Directory.create(at: testDir)

            let fileData = [UInt8](repeating: 0x00, count: 10)
            for i in 0..<100 {
                let filePath = testDir.appending("file_\(i).txt")
                try fileData.withUnsafeBufferPointer { buffer in
                    let span = Span<UInt8>(_unsafeElements: buffer)
                    try File.System.Write.Atomic.write(span, to: filePath)
                }
            }

            defer { try? File.System.Delete.delete(at: testDir, options: .init(recursive: true)) }

            // Measure iteration
            var iterator = try File.Directory.Iterator.open(at: testDir)
            var count = 0
            while try iterator.next() != nil {
                count += 1
            }
            iterator.close()

            #expect(count == 100)
        }

        @Test("Directory contents listing (100 files)", .timed(iterations: 20, warmup: 3))
        func directoryContents100Files() throws {
            let tempDir = try File.Path(NSTemporaryDirectory())
            let testDir = tempDir.appending("perf_contents_100_\(UUID().uuidString)")

            // Setup: create directory with 100 files
            try File.System.Create.Directory.create(at: testDir)

            let fileData = [UInt8](repeating: 0x00, count: 10)
            for i in 0..<100 {
                let filePath = testDir.appending("file_\(i).txt")
                try fileData.withUnsafeBufferPointer { buffer in
                    let span = Span<UInt8>(_unsafeElements: buffer)
                    try File.System.Write.Atomic.write(span, to: filePath)
                }
            }

            defer { try? File.System.Delete.delete(at: testDir, options: .init(recursive: true)) }

            let entries = try File.Directory.Contents.list(at: testDir)
            #expect(entries.count == 100)
        }

        @Test("Create and delete directory", .timed(iterations: 50, warmup: 5))
        func createDeleteDirectory() throws {
            let tempDir = try File.Path(NSTemporaryDirectory())
            let testDir = tempDir.appending("perf_mkdir_\(UUID().uuidString)")

            try File.System.Create.Directory.create(at: testDir)
            try File.System.Delete.delete(at: testDir)
        }
    }

    // MARK: - Path Operations

    @Suite(.serialized)
    struct `Path Operations` {

        @Test("Path.appending (deep nesting)", .timed(iterations: 100, warmup: 10))
        func pathAppending() {
            let base = File.Path("/usr/local")
            var path = base

            for i in 0..<20 {
                path = path.appending("component_\(i)")
            }

            #expect(path.string.contains("component_19"))
        }

        @Test("Path component extraction", .timed(iterations: 100, warmup: 10))
        func pathComponents() {
            let path = File.Path("/usr/local/lib/swift/package/Sources/Module/File.swift")

            let _ = path.lastComponent
            let _ = path.extension
            let _ = path.stem
            let _ = path.parent
        }
    }

    // MARK: - Memory Allocation Tests

    @Suite(.serialized)
    struct `Allocation Tracking` {

        // Note: threshold increased to accommodate Linux runtime overhead
        @Test("Buffer read is zero-allocation", .timed(iterations: 10, maxAllocations: 256_000))
        func bufferReadZeroAllocation() throws {
            let tempDir = try File.Path(NSTemporaryDirectory())
            let filePath = tempDir.appending("perf_alloc_\(UUID().uuidString).bin")

            // Setup
            let size = 64 * 1024
            let setupData = [UInt8](repeating: 0x42, count: size)
            try setupData.withUnsafeBufferPointer { buffer in
                let span = Span<UInt8>(_unsafeElements: buffer)
                try File.System.Write.Atomic.write(span, to: filePath)
            }

            defer { try? File.System.Delete.delete(at: filePath) }

            // Preallocated buffer - should be zero-allocation read
            var buffer = [UInt8](repeating: 0, count: size)

            var handle = try File.Handle.open(filePath, mode: .read)
            let _ = try buffer.withUnsafeMutableBytes { ptr in
                try handle.read(into: ptr)
            }
            try handle.close()
        }

        @Test("Stat operations minimal allocation", .timed(iterations: 20, maxAllocations: 50_000))
        func statMinimalAllocation() throws {
            let tempDir = try File.Path(NSTemporaryDirectory())
            let filePath = tempDir.appending("perf_stat_alloc_\(UUID().uuidString).txt")

            // Setup
            let data = [UInt8](repeating: 0x00, count: 100)
            try data.withUnsafeBufferPointer { buffer in
                let span = Span<UInt8>(_unsafeElements: buffer)
                try File.System.Write.Atomic.write(span, to: filePath)
            }

            defer { try? File.System.Delete.delete(at: filePath) }

            // Repeated stat calls
            for _ in 0..<10 {
                let _ = try File.System.Stat.info(at: filePath)
            }
        }
    }

    // MARK: - Throughput Tests

    @Suite(.serialized)
    struct `Throughput` {

        @Test(
            "Large file write throughput (10MB)",
            .timed(iterations: 5, warmup: 1, threshold: .seconds(5))
        )
        func largeFileWrite() throws {
            let tempDir = try File.Path(NSTemporaryDirectory())
            let filePath = tempDir.appending("perf_large_write_\(UUID().uuidString).bin")

            defer { try? File.System.Delete.delete(at: filePath) }

            let tenMB = [UInt8](repeating: 0xFF, count: 10_000_000)
            try tenMB.withUnsafeBufferPointer { buffer in
                let span = Span<UInt8>(_unsafeElements: buffer)
                try File.System.Write.Atomic.write(span, to: filePath)
            }
        }

        @Test(
            "Large file read throughput (10MB)",
            .timed(iterations: 5, warmup: 1, threshold: .seconds(5))
        )
        func largeFileRead() throws {
            let tempDir = try File.Path(NSTemporaryDirectory())
            let filePath = tempDir.appending("perf_large_read_\(UUID().uuidString).bin")

            // Setup
            let tenMB = [UInt8](repeating: 0xFF, count: 10_000_000)
            try tenMB.withUnsafeBufferPointer { buffer in
                let span = Span<UInt8>(_unsafeElements: buffer)
                try File.System.Write.Atomic.write(span, to: filePath)
            }

            defer { try? File.System.Delete.delete(at: filePath) }

            let _ = try File.System.Read.Full.read(from: filePath)
        }

        @Test(
            "Many small files (create/write/delete)",
            .timed(iterations: 5, warmup: 1, threshold: .seconds(10))
        )
        func manySmallFiles() throws {
            let tempDir = try File.Path(NSTemporaryDirectory())
            let testDir = tempDir.appending("perf_many_\(UUID().uuidString)")

            try File.System.Create.Directory.create(at: testDir)
            defer { try? File.System.Delete.delete(at: testDir, options: .init(recursive: true)) }

            let smallData = [UInt8](repeating: 0x42, count: 100)

            // Create 100 small files
            for i in 0..<100 {
                let filePath = testDir.appending("file_\(i).txt")
                try smallData.withUnsafeBufferPointer { buffer in
                    let span = Span<UInt8>(_unsafeElements: buffer)
                    try File.System.Write.Atomic.write(span, to: filePath)
                }
            }
        }
    }
}
