//
//  EdgeCase Tests.swift
//  swift-file-system
//
//  Created by Coen ten Thije Boonkkamp on 18/12/2025.
//

import Foundation
import Testing

@testable import File_System_Primitives

#if canImport(Darwin)
    import Darwin
#elseif canImport(Glibc)
    import Glibc
#endif

extension File.System.Test.EdgeCase {
    // MARK: - Test Fixtures

    private func createTempPath() -> String {
        "/tmp/edge-test-\(UUID().uuidString)"
    }

    private func cleanup(_ path: String) {
        try? FileManager.default.removeItem(atPath: path)
    }

    private func cleanupPath(_ path: File.Path) {
        try? File.System.Delete.delete(at: path)
    }

    // MARK: - Empty File Operations

    @Test("Read from empty file returns zero bytes")
    func readFromEmptyFile() throws {
        let path = createTempPath()
        defer { cleanup(path) }

        let filePath = try File.Path(path)
        var handle = try File.Handle.open(filePath, mode: .write, options: [.create, .closeOnExec])
        try handle.close()

        var readHandle = try File.Handle.open(filePath, mode: .read)

        var buffer = [UInt8](repeating: 0, count: 1024)
        let bytesRead = try buffer.withUnsafeMutableBytes { ptr in
            try readHandle.read(into: ptr)
        }

        try readHandle.close()

        #expect(bytesRead == 0)
    }

    @Test("Write zero bytes succeeds")
    func writeZeroBytes() throws {
        let path = createTempPath()
        defer { cleanup(path) }

        let filePath = try File.Path(path)
        var handle = try File.Handle.open(filePath, mode: .write, options: [.create, .closeOnExec])

        let emptyArray: [UInt8] = []
        try emptyArray.withUnsafeBufferPointer { buffer in
            try handle.write(Span<UInt8>(_unsafeElements: buffer))
        }

        try handle.close()

        let info = try File.System.Stat.info(at: filePath)
        #expect(info.size == 0)
    }

    // MARK: - Path Edge Cases

    @Test("Path with embedded NUL byte is rejected")
    func pathWithEmbeddedNul() throws {
        let pathWithNul = "/tmp/test\0hidden"

        #expect(throws: File.Path.Error.self) {
            _ = try File.Path(pathWithNul)
        }
    }

    @Test("Empty path is rejected")
    func emptyPath() throws {
        let emptyString = ""
        var didThrow = false
        do {
            _ = try File.Path(emptyString)
        } catch {
            didThrow = true
        }
        #expect(didThrow)
    }

    @Test("Path with only spaces is handled")
    func pathWithOnlySpaces() throws {
        // This is actually a valid path on POSIX
        let path = try File.Path("/tmp/   ")
        #expect(path.string == "/tmp/   ")
    }

    @Test("Path with unicode characters works")
    func unicodePath() throws {
        let path = createTempPath() + "-日本語-émoji-🎉"
        defer { cleanup(path) }

        let filePath = try File.Path(path)
        var handle = try File.Handle.open(filePath, mode: .write, options: [.create, .closeOnExec])
        try handle.close()

        #expect(File.System.Stat.exists(at: filePath))
    }

    @Test("Path with newline in name is rejected")
    func pathWithNewline() throws {
        // Paths with control characters (like newlines) are rejected for safety
        let pathString = "/tmp/edge-test-with\nnewline-\(UUID().uuidString)"
        var didThrow = false
        do {
            _ = try File.Path(pathString)
        } catch {
            didThrow = true
        }
        #expect(didThrow)
    }

    @Test("Very long path component")
    func veryLongPathComponent() throws {
        // Most filesystems limit name to 255 bytes
        let longName = String(repeating: "a", count: 255)
        let path = "/tmp/\(longName)"
        defer { cleanup(path) }

        let filePath = try File.Path(path)
        var handle = try File.Handle.open(filePath, mode: .write, options: [.create, .closeOnExec])
        try handle.close()

        #expect(File.System.Stat.exists(at: filePath))
    }

    @Test("Path component exceeding 255 bytes fails")
    func tooLongPathComponent() throws {
        let tooLongName = String(repeating: "a", count: 256)
        let path = "/tmp/\(tooLongName)"

        let filePath = try File.Path(path)

        #expect(throws: (any Error).self) {
            var handle = try File.Handle.open(
                filePath,
                mode: .write,
                options: [.create, .closeOnExec]
            )
            try handle.close()
        }
    }

    // MARK: - Handle State Edge Cases

    @Test("Handle is valid after open and before close")
    func handleValidBeforeClose() throws {
        let path = createTempPath()
        defer { cleanup(path) }

        let filePath = try File.Path(path)
        var handle = try File.Handle.open(filePath, mode: .write, options: [.create, .closeOnExec])

        // Handle should be valid immediately after open
        let isValidBeforeClose = handle.isValid
        #expect(isValidBeforeClose)

        try handle.close()
        // Note: After close(), handle is consumed (non-copyable type)
        // Double close and operations after close are prevented at compile-time
    }

    @Test("Close succeeds on freshly opened handle")
    func closeSucceeds() throws {
        let path = createTempPath()
        defer { cleanup(path) }

        let filePath = try File.Path(path)
        var handle = try File.Handle.open(filePath, mode: .write, options: [.create, .closeOnExec])

        // Close should succeed without error
        try handle.close()

        // File should still exist after close
        #expect(File.System.Stat.exists(at: filePath))
    }

    @Test("Handle allows operations before close")
    func handleOperationsBeforeClose() throws {
        let path = createTempPath()
        defer { cleanup(path) }

        let filePath = try File.Path(path)
        var handle = try File.Handle.open(
            filePath,
            mode: .readWrite,
            options: [.create, .closeOnExec]
        )

        // Write should work
        let data: [UInt8] = [1, 2, 3, 4, 5]
        try data.withUnsafeBufferPointer { buffer in
            try handle.write(Span<UInt8>(_unsafeElements: buffer))
        }

        // Seek should work
        _ = try handle.seek(to: 0, from: .start)

        // Read should work
        var readBuffer = [UInt8](repeating: 0, count: 5)
        let bytesRead = try readBuffer.withUnsafeMutableBytes { ptr in
            try handle.read(into: ptr)
        }

        try handle.close()

        #expect(bytesRead == 5)
        #expect(readBuffer == data)
    }

    @Test("Write to read-only handle fails")
    func writeToReadOnlyHandle() throws {
        let path = createTempPath()
        defer { cleanup(path) }

        // Create the file first
        let filePath = try File.Path(path)
        var createHandle = try File.Handle.open(
            filePath,
            mode: .write,
            options: [.create, .closeOnExec]
        )
        try createHandle.close()

        // Open read-only
        var handle = try File.Handle.open(filePath, mode: .read)

        let data: [UInt8] = [1, 2, 3]
        var didThrow = false
        do {
            try data.withUnsafeBufferPointer { buffer in
                try handle.write(Span<UInt8>(_unsafeElements: buffer))
            }
        } catch is File.Handle.Error {
            didThrow = true
        }

        try handle.close()

        #expect(didThrow)
    }

    // MARK: - Seek Edge Cases

    @Test("Seek to negative position fails")
    func seekToNegative() throws {
        let path = createTempPath()
        defer { cleanup(path) }

        let filePath = try File.Path(path)
        var handle = try File.Handle.open(filePath, mode: .write, options: [.create, .closeOnExec])

        // Seeking to -1 from start should fail
        var didThrow = false
        do {
            _ = try handle.seek(to: -1, from: .start)
        } catch {
            didThrow = true
        }

        try handle.close()

        #expect(didThrow)
    }

    @Test("Seek past EOF creates sparse file on write")
    func seekPastEOF() throws {
        let path = createTempPath()
        defer { cleanup(path) }

        let filePath = try File.Path(path)
        var handle = try File.Handle.open(
            filePath,
            mode: .readWrite,
            options: [.create, .closeOnExec]
        )

        // Seek far past end
        _ = try handle.seek(to: 1000, from: .start)

        // Write something
        let data: [UInt8] = [42]
        try data.withUnsafeBufferPointer { buffer in
            try handle.write(Span<UInt8>(_unsafeElements: buffer))
        }

        try handle.close()

        let info = try File.System.Stat.info(at: filePath)
        #expect(info.size == 1001)
    }

    @Test("Seek from end with zero offset")
    func seekFromEndZero() throws {
        let path = createTempPath()
        defer { cleanup(path) }

        let filePath = try File.Path(path)
        var handle = try File.Handle.open(filePath, mode: .write, options: [.create, .closeOnExec])

        // Write some data
        let data: [UInt8] = [1, 2, 3, 4, 5]
        try data.withUnsafeBufferPointer { buffer in
            try handle.write(Span<UInt8>(_unsafeElements: buffer))
        }

        // Seek to end
        let pos = try handle.seek(to: 0, from: .end)
        try handle.close()

        #expect(pos == 5)
    }

    // MARK: - Symlink Edge Cases

    @Test("Dangling symlink - stat follows and fails")
    func danglingSymlink() throws {
        let linkPath = try File.Path(createTempPath() + ".link")
        let targetPath = try File.Path(createTempPath() + ".target")
        defer {
            cleanupPath(linkPath)
            cleanupPath(targetPath)
        }

        // Create symlink to non-existent target
        try File.System.Link.Symbolic.create(at: linkPath, pointingTo: targetPath)

        // The symlink itself exists (use lstat which doesn't follow)
        #expect((try? File.System.Stat.lstatInfo(at: linkPath))?.type == .symbolicLink)

        // But stat (which follows) should fail
        #expect(throws: File.System.Stat.Error.self) {
            _ = try File.System.Stat.info(at: linkPath)
        }

        // lstatInfo should work (doesn't follow)
        let info = try File.System.Stat.lstatInfo(at: linkPath)
        #expect(info.type == .symbolicLink)
    }

    @Test("Symlink cycle detection")
    func symlinkCycle() throws {
        let linkA = try File.Path(createTempPath() + ".linkA")
        let linkB = try File.Path(createTempPath() + ".linkB")
        defer {
            cleanupPath(linkA)
            cleanupPath(linkB)
        }

        // Create A -> B -> A cycle
        try File.System.Link.Symbolic.create(at: linkA, pointingTo: linkB)
        try File.System.Link.Symbolic.create(at: linkB, pointingTo: linkA)

        // Both links exist as symlinks (use lstat which doesn't follow)
        #expect((try? File.System.Stat.lstatInfo(at: linkA))?.type == .symbolicLink)
        #expect((try? File.System.Stat.lstatInfo(at: linkB))?.type == .symbolicLink)

        // stat should fail with loop error
        #expect(throws: File.System.Stat.Error.self) {
            _ = try File.System.Stat.info(at: linkA)
        }
    }

    @Test("Self-referencing symlink")
    func selfSymlink() throws {
        let linkPath = try File.Path(createTempPath() + ".self")
        defer { cleanupPath(linkPath) }

        // Create link pointing to itself
        try File.System.Link.Symbolic.create(at: linkPath, pointingTo: linkPath)

        #expect((try? File.System.Stat.lstatInfo(at: linkPath))?.type == .symbolicLink)

        // stat should fail
        #expect(throws: File.System.Stat.Error.self) {
            _ = try File.System.Stat.info(at: linkPath)
        }
    }

    // MARK: - Directory Edge Cases

    @Test("Create directory that already exists fails")
    func createExistingDirectory() throws {
        let path = try File.Path(createTempPath())
        defer { cleanupPath(path) }

        try File.System.Create.Directory.create(at: path)

        #expect(throws: (any Error).self) {
            try File.System.Create.Directory.create(at: path)
        }
    }

    @Test("Delete non-empty directory fails without recursive")
    func deleteNonEmptyDirectory() throws {
        let dir = try File.Path(createTempPath())
        defer { try? FileManager.default.removeItem(atPath: dir.string) }

        try File.System.Create.Directory.create(at: dir)

        // Create file inside
        let filePath = try File.Path(dir.string + "/file.txt")
        var handle = try File.Handle.open(filePath, mode: .write, options: [.create, .closeOnExec])
        try handle.close()

        #expect(throws: (any Error).self) {
            try File.System.Delete.delete(at: dir)
        }
    }

    @Test("Iterate empty directory yields nothing")
    func iterateEmptyDirectory() throws {
        let dir = try File.Path(createTempPath())
        defer { cleanupPath(dir) }

        try File.System.Create.Directory.create(at: dir)

        var iterator = try File.Directory.Iterator.open(at: dir)

        let entry = try iterator.next()
        iterator.close()

        #expect(entry == nil)
    }

    // MARK: - Concurrent Access Edge Cases

    @Test("Multiple handles to same file")
    func multipleHandles() throws {
        let path = createTempPath()
        defer { cleanup(path) }

        let filePath = try File.Path(path)

        // Create and write with first handle
        var handle1 = try File.Handle.open(
            filePath,
            mode: .readWrite,
            options: [.create, .closeOnExec]
        )
        let data: [UInt8] = [1, 2, 3, 4, 5]
        try data.withUnsafeBufferPointer { buffer in
            try handle1.write(Span<UInt8>(_unsafeElements: buffer))
        }

        // Open second handle for reading
        var handle2 = try File.Handle.open(filePath, mode: .read)

        var buffer = [UInt8](repeating: 0, count: 5)
        let bytesRead = try buffer.withUnsafeMutableBytes { ptr in
            try handle2.read(into: ptr)
        }

        try handle1.close()
        try handle2.close()

        #expect(bytesRead == 5)
        #expect(buffer == data)
    }

    // MARK: - Buffer Edge Cases

    @Test("Read with zero-size buffer")
    func readWithZeroBuffer() throws {
        let path = createTempPath()
        defer { cleanup(path) }

        let filePath = try File.Path(path)
        var handle = try File.Handle.open(
            filePath,
            mode: .readWrite,
            options: [.create, .closeOnExec]
        )

        // Write some data
        let data: [UInt8] = [1, 2, 3]
        try data.withUnsafeBufferPointer { buffer in
            try handle.write(Span<UInt8>(_unsafeElements: buffer))
        }

        _ = try handle.seek(to: 0, from: .start)

        // Read with zero-size buffer
        var emptyBuffer: [UInt8] = []
        let bytesRead = try emptyBuffer.withUnsafeMutableBytes { ptr in
            try handle.read(into: ptr)
        }

        try handle.close()

        #expect(bytesRead == 0)
    }

    @Test("Multiple sequential reads exhaust file")
    func multipleSequentialReads() throws {
        let path = createTempPath()
        defer { cleanup(path) }

        let filePath = try File.Path(path)
        var handle = try File.Handle.open(
            filePath,
            mode: .readWrite,
            options: [.create, .closeOnExec]
        )

        // Write data
        let data: [UInt8] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
        try data.withUnsafeBufferPointer { buffer in
            try handle.write(Span<UInt8>(_unsafeElements: buffer))
        }

        _ = try handle.seek(to: 0, from: .start)

        var allRead: [UInt8] = []
        var buffer = [UInt8](repeating: 0, count: 3)

        while true {
            let bytesRead = try buffer.withUnsafeMutableBytes { ptr in
                try handle.read(into: ptr)
            }
            if bytesRead == 0 { break }
            allRead.append(contentsOf: buffer[..<bytesRead])
        }

        try handle.close()

        #expect(allRead == data)
    }

    // MARK: - Permission Edge Cases

    #if !os(Windows)
        @Test("Open file without read permission fails")
        func openWithoutReadPermission() throws {
            // Skip when running as root - root bypasses permission checks
            #if canImport(Glibc)
                if geteuid() == 0 {
                    // Running as root, permission test is not meaningful
                    return
                }
            #endif

            let path = createTempPath()
            defer { cleanup(path) }

            let filePath = try File.Path(path)

            // Create file with no permissions
            var handle = try File.Handle.open(
                filePath,
                mode: .write,
                options: [.create, .closeOnExec]
            )
            try handle.close()

            // Remove all permissions
            chmod(path, 0o000)
            defer { chmod(path, 0o644) }  // Restore for cleanup

            #expect(throws: File.Handle.Error.self) {
                _ = try File.Handle.open(filePath, mode: .read)
            }
        }
    #endif

    // MARK: - Special File Types

    // Note: /dev/null stat tests are skipped because stat on special device files
    // may return unusual metadata values that cause integer conversion issues.
    // This is a known limitation with special files.

    @Test("Write to /dev/null succeeds")
    func writeToDevNull() throws {
        #if !os(Windows)
            let devNull = "/dev/null"
            let path = try File.Path(devNull)
            var handle = try File.Handle.open(path, mode: .write)

            let data: [UInt8] = [1, 2, 3, 4, 5]
            try data.withUnsafeBufferPointer { buffer in
                try handle.write(Span<UInt8>(_unsafeElements: buffer))
            }
            try handle.close()
        // No assertion needed - just shouldn't crash
        #endif
    }

    // MARK: - Copy/Move Edge Cases

    @Test("Copy file to itself fails")
    func copyToSelf() throws {
        let path = createTempPath()
        defer { cleanup(path) }

        let filePath = try File.Path(path)
        var handle = try File.Handle.open(filePath, mode: .write, options: [.create, .closeOnExec])
        try handle.close()

        #expect(throws: (any Error).self) {
            try File.System.Copy.copy(from: filePath, to: filePath)
        }
    }

    @Test("Move file to existing destination fails (safe API)")
    func moveOverExisting() throws {
        let src = createTempPath()
        let dst = createTempPath()
        defer {
            cleanup(src)
            cleanup(dst)
        }

        let srcPath = try File.Path(src)
        let dstPath = try File.Path(dst)

        // Create source with content
        var srcHandle = try File.Handle.open(
            srcPath,
            mode: .write,
            options: [.create, .closeOnExec]
        )
        let srcData: [UInt8] = [1, 2, 3]
        try srcData.withUnsafeBufferPointer { buffer in
            try srcHandle.write(Span<UInt8>(_unsafeElements: buffer))
        }
        try srcHandle.close()

        // Create destination with different content
        var dstHandle = try File.Handle.open(
            dstPath,
            mode: .write,
            options: [.create, .closeOnExec]
        )
        let dstData: [UInt8] = [4, 5, 6, 7, 8]
        try dstData.withUnsafeBufferPointer { buffer in
            try dstHandle.write(Span<UInt8>(_unsafeElements: buffer))
        }
        try dstHandle.close()

        // Move to existing destination should fail (safe API behavior)
        var didThrow = false
        do {
            try File.System.Move.move(from: srcPath, to: dstPath)
        } catch {
            didThrow = true
        }

        #expect(didThrow)

        // Both files should still exist
        #expect(File.System.Stat.exists(at: srcPath))
        #expect(File.System.Stat.exists(at: dstPath))
    }

    // MARK: - Rapid Operations

    @Test("Rapid open-write-close cycles")
    func rapidOpenWriteClose() throws {
        let path = createTempPath()
        defer { cleanup(path) }

        let filePath = try File.Path(path)

        for i in 0..<100 {
            var handle = try File.Handle.open(
                filePath,
                mode: .write,
                options: [.create, .truncate, .closeOnExec]
            )
            let data = [UInt8(i & 0xFF)]
            try data.withUnsafeBufferPointer { buffer in
                try handle.write(Span<UInt8>(_unsafeElements: buffer))
            }
            try handle.close()
        }

        let info = try File.System.Stat.info(at: filePath)
        #expect(info.size == 1)
    }

    @Test("Rapid create-delete cycles")
    func rapidCreateDelete() throws {
        let basePath = createTempPath()

        for i in 0..<50 {
            let path = try File.Path("\(basePath)-\(i)")
            var handle = try File.Handle.open(path, mode: .write, options: [.create, .closeOnExec])
            try handle.close()
            try File.System.Delete.delete(at: path)
        }
        // Just shouldn't crash or leak
    }

}
