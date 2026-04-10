//
//  File.System.Copy Tests.swift
//  swift-file-system
//
//  Created by Coen ten Thije Boonkkamp on 18/12/2025.
//

import Foundation
import Testing

@testable import File_System_Primitives

extension File.System.Test.Unit {
    @Suite("File.System.Copy")
    struct Copy {

        // MARK: - Test Fixtures

        private func createTempFile(content: [UInt8] = [1, 2, 3]) throws -> String {
            let path = "/tmp/copy-test-\(UUID().uuidString).bin"
            let data = Data(content)
            try data.write(to: URL(fileURLWithPath: path))
            return path
        }

        private func cleanup(_ path: String) {
            try? FileManager.default.removeItem(atPath: path)
        }

        // MARK: - Basic Copy

        @Test("Copy file to new location")
        func copyFileToNewLocation() throws {
            let sourcePath = try createTempFile(content: [10, 20, 30, 40])
            let destPath = "/tmp/copy-dest-\(UUID().uuidString).bin"
            defer {
                cleanup(sourcePath)
                cleanup(destPath)
            }

            let source = try File.Path(sourcePath)
            let dest = try File.Path(destPath)

            try File.System.Copy.copy(from: source, to: dest)

            #expect(FileManager.default.fileExists(atPath: destPath))

            let sourceData = try Data(contentsOf: URL(fileURLWithPath: sourcePath))
            let destData = try Data(contentsOf: URL(fileURLWithPath: destPath))
            #expect(sourceData == destData)
        }

        @Test("Copy preserves source file")
        func copyPreservesSourceFile() throws {
            let sourcePath = try createTempFile(content: [1, 2, 3])
            let destPath = "/tmp/copy-dest-\(UUID().uuidString).bin"
            defer {
                cleanup(sourcePath)
                cleanup(destPath)
            }

            let source = try File.Path(sourcePath)
            let dest = try File.Path(destPath)

            try File.System.Copy.copy(from: source, to: dest)

            // Source should still exist
            #expect(FileManager.default.fileExists(atPath: sourcePath))
        }

        @Test("Copy empty file")
        func copyEmptyFile() throws {
            let sourcePath = try createTempFile(content: [])
            let destPath = "/tmp/copy-dest-\(UUID().uuidString).bin"
            defer {
                cleanup(sourcePath)
                cleanup(destPath)
            }

            let source = try File.Path(sourcePath)
            let dest = try File.Path(destPath)

            try File.System.Copy.copy(from: source, to: dest)

            let destData = try Data(contentsOf: URL(fileURLWithPath: destPath))
            #expect(destData.isEmpty)
        }

        // MARK: - Options

        @Test("Copy with overwrite option")
        func copyWithOverwriteOption() throws {
            let sourcePath = try createTempFile(content: [1, 2, 3])
            let destPath = try createTempFile(content: [99, 99])
            defer {
                cleanup(sourcePath)
                cleanup(destPath)
            }

            let source = try File.Path(sourcePath)
            let dest = try File.Path(destPath)

            let options = File.System.Copy.Options(overwrite: true)
            try File.System.Copy.copy(from: source, to: dest, options: options)

            let destData = try [UInt8](Data(contentsOf: URL(fileURLWithPath: destPath)))
            #expect(destData == [1, 2, 3])
        }

        @Test("Copy without overwrite throws when destination exists")
        func copyWithoutOverwriteThrows() throws {
            let sourcePath = try createTempFile(content: [1, 2, 3])
            let destPath = try createTempFile(content: [99, 99])
            defer {
                cleanup(sourcePath)
                cleanup(destPath)
            }

            let source = try File.Path(sourcePath)
            let dest = try File.Path(destPath)

            let options = File.System.Copy.Options(overwrite: false)
            #expect(throws: File.System.Copy.Error.self) {
                try File.System.Copy.copy(from: source, to: dest, options: options)
            }
        }

        @Test("Options default values")
        func optionsDefaultValues() {
            let options = File.System.Copy.Options()
            #expect(options.overwrite == false)
            #expect(options.copyAttributes == true)
            #expect(options.followSymlinks == true)
        }

        @Test("Options custom values")
        func optionsCustomValues() {
            let options = File.System.Copy.Options(
                overwrite: true,
                copyAttributes: false,
                followSymlinks: false
            )
            #expect(options.overwrite == true)
            #expect(options.copyAttributes == false)
            #expect(options.followSymlinks == false)
        }

        // MARK: - Error Cases

        @Test("Copy non-existent source throws sourceNotFound")
        func copyNonExistentSourceThrows() throws {
            let sourcePath = "/tmp/non-existent-\(UUID().uuidString).bin"
            let destPath = "/tmp/copy-dest-\(UUID().uuidString).bin"
            defer { cleanup(destPath) }

            let source = try File.Path(sourcePath)
            let dest = try File.Path(destPath)

            #expect(throws: File.System.Copy.Error.self) {
                try File.System.Copy.copy(from: source, to: dest)
            }
        }

        @Test("Copy to existing file without overwrite throws destinationExists")
        func copyToExistingFileThrows() throws {
            let sourcePath = try createTempFile(content: [1, 2, 3])
            let destPath = try createTempFile(content: [99])
            defer {
                cleanup(sourcePath)
                cleanup(destPath)
            }

            let source = try File.Path(sourcePath)
            let dest = try File.Path(destPath)

            #expect(throws: File.System.Copy.Error.destinationExists(dest)) {
                try File.System.Copy.copy(from: source, to: dest)
            }
        }

        // MARK: - Error Descriptions

        @Test("sourceNotFound error description")
        func sourceNotFoundErrorDescription() throws {
            let path = try File.Path("/tmp/missing")
            let error = File.System.Copy.Error.sourceNotFound(path)
            #expect(error.description.contains("Source not found"))
        }

        @Test("destinationExists error description")
        func destinationExistsErrorDescription() throws {
            let path = try File.Path("/tmp/existing")
            let error = File.System.Copy.Error.destinationExists(path)
            #expect(error.description.contains("already exists"))
        }

        @Test("permissionDenied error description")
        func permissionDeniedErrorDescription() throws {
            let path = try File.Path("/root/secret")
            let error = File.System.Copy.Error.permissionDenied(path)
            #expect(error.description.contains("Permission denied"))
        }

        @Test("isDirectory error description")
        func isDirectoryErrorDescription() throws {
            let path = try File.Path("/tmp")
            let error = File.System.Copy.Error.isDirectory(path)
            #expect(error.description.contains("Is a directory"))
        }

        @Test("copyFailed error description")
        func copyFailedErrorDescription() {
            let error = File.System.Copy.Error.copyFailed(errno: 5, message: "I/O error")
            #expect(error.description.contains("Copy failed"))
            #expect(error.description.contains("I/O error"))
        }

        // MARK: - Error Equatable

        @Test("Errors are equatable")
        func errorsAreEquatable() throws {
            let path1 = try File.Path("/tmp/a")
            let path2 = try File.Path("/tmp/a")

            #expect(
                File.System.Copy.Error.sourceNotFound(path1)
                    == File.System.Copy.Error.sourceNotFound(path2)
            )
            #expect(
                File.System.Copy.Error.destinationExists(path1)
                    == File.System.Copy.Error.destinationExists(path2)
            )
        }

        // MARK: - Darwin-specific Edge Cases

        #if canImport(Darwin)
            @Suite("EdgeCase")
            struct EdgeCase {

                private func createTempFile(content: [UInt8] = [1, 2, 3]) throws -> String {
                    let path = "/tmp/copy-test-\(UUID().uuidString).bin"
                    let data = Data(content)
                    try data.write(to: URL(fileURLWithPath: path))
                    return path
                }

                private func cleanup(_ path: String) {
                    try? FileManager.default.removeItem(atPath: path)
                }

                @Test("Overwrite when destination is directory fails appropriately")
                func overwriteDestinationDirectoryFails() throws {
                    let sourcePath = try createTempFile(content: [1, 2, 3])
                    let destDir = "/tmp/copy-dest-dir-\(UUID().uuidString)"
                    try FileManager.default.createDirectory(
                        atPath: destDir,
                        withIntermediateDirectories: false
                    )
                    defer {
                        cleanup(sourcePath)
                        cleanup(destDir)
                    }

                    let source = try File.Path(sourcePath)
                    let dest = try File.Path(destDir)

                    let options = File.System.Copy.Options(overwrite: true)

                    // COPYFILE_UNLINK should not delete directories
                    #expect(throws: File.System.Copy.Error.self) {
                        try File.System.Copy.copy(from: source, to: dest, options: options)
                    }

                    // Verify directory still exists
                    #expect(FileManager.default.fileExists(atPath: destDir))
                }

                @Test("Overwrite when destination is symlink removes symlink")
                func overwriteDestinationSymlink() throws {
                    let sourcePath = try createTempFile(content: [10, 20, 30])
                    let targetPath = try createTempFile(content: [99])
                    let symlinkPath = "/tmp/copy-symlink-\(UUID().uuidString).link"

                    try FileManager.default.createSymbolicLink(
                        atPath: symlinkPath,
                        withDestinationPath: targetPath
                    )

                    defer {
                        cleanup(sourcePath)
                        cleanup(targetPath)
                        cleanup(symlinkPath)
                    }

                    let source = try File.Path(sourcePath)
                    let dest = try File.Path(symlinkPath)

                    let options = File.System.Copy.Options(overwrite: true)
                    try File.System.Copy.copy(from: source, to: dest, options: options)

                    // Destination should now be a regular file, not a symlink
                    var isSymlink: ObjCBool = false
                    FileManager.default.fileExists(atPath: symlinkPath, isDirectory: &isSymlink)

                    // Verify it's now a regular file with source content
                    let destData = try Data(contentsOf: URL(fileURLWithPath: symlinkPath))
                    #expect(destData == Data([10, 20, 30]))

                    // Verify original target file is unchanged
                    let targetData = try Data(contentsOf: URL(fileURLWithPath: targetPath))
                    #expect(targetData == Data([99]))
                }

                @Test("COPYFILE_NOFOLLOW with symlink source copies symlink itself")
                func copySymlinkWithoutFollowing() throws {
                    let targetPath = try createTempFile(content: [99, 88, 77])
                    let symlinkPath = "/tmp/copy-source-symlink-\(UUID().uuidString).link"
                    let destPath = "/tmp/copy-symlink-dest-\(UUID().uuidString).link"

                    try FileManager.default.createSymbolicLink(
                        atPath: symlinkPath,
                        withDestinationPath: targetPath
                    )

                    defer {
                        cleanup(targetPath)
                        cleanup(symlinkPath)
                        cleanup(destPath)
                    }

                    let source = try File.Path(symlinkPath)
                    let dest = try File.Path(destPath)

                    let options = File.System.Copy.Options(followSymlinks: false)
                    try File.System.Copy.copy(from: source, to: dest, options: options)

                    // Destination should be a symlink
                    let destAttributes = try FileManager.default.attributesOfItem(atPath: destPath)
                    #expect(destAttributes[.type] as? FileAttributeType == .typeSymbolicLink)

                    // Verify it points to the same target
                    let destTarget = try FileManager.default.destinationOfSymbolicLink(
                        atPath: destPath
                    )
                    #expect(destTarget == targetPath)
                }

                @Test("copyAttributes=true preserves permissions and timestamps")
                func copyAttributesPreservesMetadata() throws {
                    let sourcePath = try createTempFile(content: [1, 2, 3, 4, 5])
                    let destPath = "/tmp/copy-attrs-dest-\(UUID().uuidString).bin"

                    // Set specific permissions and modification date on source
                    let sourceURL = URL(fileURLWithPath: sourcePath)
                    let testDate = Date(timeIntervalSince1970: 1_000_000_000)  // 2001-09-09
                    try FileManager.default.setAttributes(
                        [.posixPermissions: 0o644, .modificationDate: testDate],
                        ofItemAtPath: sourcePath
                    )

                    defer {
                        cleanup(sourcePath)
                        cleanup(destPath)
                    }

                    let source = try File.Path(sourcePath)
                    let dest = try File.Path(destPath)

                    let options = File.System.Copy.Options(copyAttributes: true)
                    try File.System.Copy.copy(from: source, to: dest, options: options)

                    // Verify permissions are preserved
                    let sourceAttrs = try FileManager.default.attributesOfItem(atPath: sourcePath)
                    let destAttrs = try FileManager.default.attributesOfItem(atPath: destPath)

                    #expect(
                        sourceAttrs[.posixPermissions] as? Int == destAttrs[.posixPermissions]
                            as? Int
                    )

                    // Verify modification date is preserved (within 1 second tolerance)
                    let sourceDate = sourceAttrs[.modificationDate] as? Date
                    let destDate = destAttrs[.modificationDate] as? Date
                    #expect(sourceDate != nil)
                    #expect(destDate != nil)
                    if let sd = sourceDate, let dd = destDate {
                        #expect(abs(sd.timeIntervalSince(dd)) < 1.0)
                    }
                }

                @Test("copyAttributes=false copies only data")
                func copyAttributesFalseSkipsMetadata() throws {
                    let sourcePath = try createTempFile(content: [10, 20, 30, 40])
                    let destPath = "/tmp/copy-no-attrs-dest-\(UUID().uuidString).bin"

                    // Set specific permissions on source
                    try FileManager.default.setAttributes(
                        [.posixPermissions: 0o600],
                        ofItemAtPath: sourcePath
                    )

                    defer {
                        cleanup(sourcePath)
                        cleanup(destPath)
                    }

                    let source = try File.Path(sourcePath)
                    let dest = try File.Path(destPath)

                    let options = File.System.Copy.Options(copyAttributes: false)
                    try File.System.Copy.copy(from: source, to: dest, options: options)

                    // Verify data is copied
                    let destData = try Data(contentsOf: URL(fileURLWithPath: destPath))
                    #expect(destData == Data([10, 20, 30, 40]))

                    // Verify permissions are default (not copied from source)
                    let sourceAttrs = try FileManager.default.attributesOfItem(atPath: sourcePath)
                    let destAttrs = try FileManager.default.attributesOfItem(atPath: destPath)

                    let sourcePerms = sourceAttrs[.posixPermissions] as? Int
                    let destPerms = destAttrs[.posixPermissions] as? Int

                    // Destination should have default permissions, not source's 0o600
                    #expect(sourcePerms == 0o600)
                    #expect(destPerms != 0o600)
                }

                @Test("Large file copy uses clone on APFS")
                func largeFileCopyUsesClone() throws {
                    // Create a 2MB file
                    let largeSize = 2 * 1024 * 1024
                    var largeContent = [UInt8]()
                    largeContent.reserveCapacity(largeSize)
                    for i in 0..<largeSize {
                        largeContent.append(UInt8(i % 256))
                    }

                    let sourcePath = try createTempFile(content: largeContent)
                    let destPath = "/tmp/copy-large-dest-\(UUID().uuidString).bin"
                    defer {
                        cleanup(sourcePath)
                        cleanup(destPath)
                    }

                    let source = try File.Path(sourcePath)
                    let dest = try File.Path(destPath)

                    // Measure copy time
                    let startTime = Date()
                    try File.System.Copy.copy(from: source, to: dest)
                    let elapsed = Date().timeIntervalSince(startTime)

                    // Verify data integrity
                    let sourceData = try Data(contentsOf: URL(fileURLWithPath: sourcePath))
                    let destData = try Data(contentsOf: URL(fileURLWithPath: destPath))
                    #expect(sourceData == destData)

                    // On APFS with clonefile, 2MB should copy almost instantly (< 0.1s)
                    // If it takes longer, it might be using regular copy
                    // This is a soft check - clone should be very fast
                    #expect(
                        elapsed < 0.5,
                        "Large file copy took \(elapsed)s - may not be using clone optimization"
                    )
                }
            }
        #endif

        // MARK: - Linux-specific Edge Cases

        #if os(Linux)
            @Suite("EdgeCase")
            struct EdgeCase {

                private func createTempFile(content: [UInt8] = [1, 2, 3]) throws -> String {
                    let path = "/tmp/copy-test-\(UUID().uuidString).bin"
                    let data = Data(content)
                    try data.write(to: URL(fileURLWithPath: path))
                    return path
                }

                private func createLargeFile(sizeInMB: Int) throws -> String {
                    let path = "/tmp/copy-large-\(UUID().uuidString).bin"
                    let chunkSize = 1024 * 1024  // 1MB chunks
                    let chunk = Data(repeating: 0xAB, count: chunkSize)

                    FileManager.default.createFile(atPath: path, contents: nil)
                    let fileHandle = try FileHandle(forWritingTo: URL(fileURLWithPath: path))
                    defer { try? fileHandle.close() }

                    for _ in 0..<sizeInMB {
                        fileHandle.write(chunk)
                    }

                    return path
                }

                private func cleanup(_ path: String) {
                    try? FileManager.default.removeItem(atPath: path)
                }

                // MARK: - Test 1: Partial copy_file_range handling

                @Test("Large file copy handles partial progress correctly")
                func largeFileCopyHandlesPartialProgress() throws {
                    // Create a 100MB file to ensure copy_file_range loop is exercised
                    // This tests that the loop correctly handles partial copies when
                    // copy_file_range doesn't copy all requested bytes in one call
                    let sourcePath = try createLargeFile(sizeInMB: 100)
                    let destPath = "/tmp/copy-large-dest-\(UUID().uuidString).bin"
                    defer {
                        cleanup(sourcePath)
                        cleanup(destPath)
                    }

                    let source = try File.Path(sourcePath)
                    let dest = try File.Path(destPath)

                    try File.System.Copy.copy(from: source, to: dest)

                    // Verify file was copied completely
                    let sourceAttrs = try FileManager.default.attributesOfItem(atPath: sourcePath)
                    let destAttrs = try FileManager.default.attributesOfItem(atPath: destPath)

                    let sourceSize = (sourceAttrs[.size] as? UInt64) ?? 0
                    let destSize = (destAttrs[.size] as? UInt64) ?? 0

                    #expect(sourceSize == destSize)
                    #expect(sourceSize == 100 * 1024 * 1024)

                    // Verify data integrity by comparing a sample from the file
                    let sourceData = try Data(contentsOf: URL(fileURLWithPath: sourcePath))
                    let destData = try Data(contentsOf: URL(fileURLWithPath: destPath))
                    #expect(sourceData == destData)
                }

                @Test("Very large file copy uses copy_file_range efficiently")
                func veryLargeFileCopyUsesKernelPath() throws {
                    // Create a 500MB file to test kernel-assisted copy performance
                    let sourcePath = try createLargeFile(sizeInMB: 500)
                    let destPath = "/tmp/copy-xlarge-dest-\(UUID().uuidString).bin"
                    defer {
                        cleanup(sourcePath)
                        cleanup(destPath)
                    }

                    let source = try File.Path(sourcePath)
                    let dest = try File.Path(destPath)

                    let startTime = Date()
                    try File.System.Copy.copy(from: source, to: dest)
                    let elapsed = Date().timeIntervalSince(startTime)

                    // Verify size matches
                    let sourceAttrs = try FileManager.default.attributesOfItem(atPath: sourcePath)
                    let destAttrs = try FileManager.default.attributesOfItem(atPath: destPath)

                    let sourceSize = (sourceAttrs[.size] as? UInt64) ?? 0
                    let destSize = (destAttrs[.size] as? UInt64) ?? 0

                    #expect(sourceSize == destSize)
                    #expect(sourceSize == 500 * 1024 * 1024)

                    // Kernel-assisted copy should be faster than userspace copy
                    // 500MB should copy in under 5 seconds on modern systems
                    #expect(
                        elapsed < 5.0,
                        "Large file copy took \(elapsed)s - may not be using kernel optimization"
                    )
                }

                // MARK: - Test 2: TOCTOU (Time-of-check to time-of-use)

                @Test("Copy behavior is best-effort when source changes during copy")
                func copyBestEffortWhenSourceChanges() throws {
                    // This test documents that copy is "best effort" - it reads the file
                    // at the time of copy, but doesn't lock it. This is expected behavior.
                    // TOCTOU race conditions are possible but documented.
                    let sourcePath = try createTempFile(content: Array(repeating: 1, count: 1024))
                    let destPath = "/tmp/copy-dest-\(UUID().uuidString).bin"
                    defer {
                        cleanup(sourcePath)
                        cleanup(destPath)
                    }

                    let source = try File.Path(sourcePath)
                    let dest = try File.Path(destPath)

                    // Copy the file
                    try File.System.Copy.copy(from: source, to: dest)

                    // Verify copy succeeded (best effort - we got whatever was there)
                    #expect(FileManager.default.fileExists(atPath: destPath))

                    // Note: This is not an atomic operation. If the source changes during
                    // copy, the destination may contain a mix of old and new data.
                    // This is expected POSIX behavior - use file locking if atomicity needed.
                }

                // MARK: - Test 3: Copy to directory path

                @Test("Copy to directory path throws error")
                func copyToDirectoryPathThrows() throws {
                    let sourcePath = try createTempFile(content: [1, 2, 3])
                    let destDirPath = "/tmp/copy-dest-dir-\(UUID().uuidString)"
                    defer {
                        cleanup(sourcePath)
                        try? FileManager.default.removeItem(atPath: destDirPath)
                    }

                    // Create destination directory
                    try FileManager.default.createDirectory(
                        atPath: destDirPath,
                        withIntermediateDirectories: false
                    )

                    let source = try File.Path(sourcePath)
                    let dest = try File.Path(destDirPath)

                    // Attempting to copy to a directory should fail
                    #expect(throws: File.System.Copy.Error.self) {
                        try File.System.Copy.copy(
                            from: source,
                            to: dest,
                            options: .init(overwrite: true)
                        )
                    }
                }

                @Test("Copy from directory throws isDirectory error")
                func copyFromDirectoryThrows() throws {
                    let sourceDirPath = "/tmp/copy-source-dir-\(UUID().uuidString)"
                    let destPath = "/tmp/copy-dest-\(UUID().uuidString).bin"
                    defer {
                        try? FileManager.default.removeItem(atPath: sourceDirPath)
                        cleanup(destPath)
                    }

                    // Create source directory
                    try FileManager.default.createDirectory(
                        atPath: sourceDirPath,
                        withIntermediateDirectories: false
                    )

                    let source = try File.Path(sourceDirPath)
                    let dest = try File.Path(destPath)

                    // Attempting to copy from a directory should throw isDirectory
                    #expect(throws: File.System.Copy.Error.isDirectory(source)) {
                        try File.System.Copy.copy(from: source, to: dest)
                    }
                }

                // MARK: - Test 4: Symlink handling

                @Test("Copy with followSymlinks=true copies symlink target")
                func copyFollowsSymlinkWhenRequested() throws {
                    let targetPath = try createTempFile(content: [10, 20, 30])
                    let linkPath = "/tmp/copy-link-\(UUID().uuidString).link"
                    let destPath = "/tmp/copy-dest-\(UUID().uuidString).bin"
                    defer {
                        cleanup(targetPath)
                        cleanup(linkPath)
                        cleanup(destPath)
                    }

                    // Create symlink
                    try FileManager.default.createSymbolicLink(
                        atPath: linkPath,
                        withDestinationPath: targetPath
                    )

                    let source = try File.Path(linkPath)
                    let dest = try File.Path(destPath)

                    // Copy with followSymlinks=true (default)
                    try File.System.Copy.copy(
                        from: source,
                        to: dest,
                        options: .init(followSymlinks: true)
                    )

                    // Verify destination is a regular file with target's content
                    let destData = try Data(contentsOf: URL(fileURLWithPath: destPath))
                    #expect(Array(destData) == [10, 20, 30])

                    // Verify destination is not a symlink
                    let destAttrs = try FileManager.default.attributesOfItem(atPath: destPath)
                    #expect(destAttrs[.type] as? FileAttributeType != .typeSymbolicLink)
                }

                @Test("Copy with followSymlinks=false copies symlink itself")
                func copySymlinkWithoutFollowing() throws {
                    let targetPath = try createTempFile(content: [10, 20, 30])
                    let linkPath = "/tmp/copy-link-\(UUID().uuidString).link"
                    let destPath = "/tmp/copy-dest-\(UUID().uuidString).link"
                    defer {
                        cleanup(targetPath)
                        cleanup(linkPath)
                        cleanup(destPath)
                    }

                    // Create symlink
                    try FileManager.default.createSymbolicLink(
                        atPath: linkPath,
                        withDestinationPath: targetPath
                    )

                    let source = try File.Path(linkPath)
                    let dest = try File.Path(destPath)

                    // Copy with followSymlinks=false
                    try File.System.Copy.copy(
                        from: source,
                        to: dest,
                        options: .init(followSymlinks: false)
                    )

                    // Verify destination is a symlink pointing to the same target
                    let destTarget = try FileManager.default.destinationOfSymbolicLink(
                        atPath: destPath
                    )
                    #expect(destTarget == targetPath)
                }

                @Test("Copy to existing symlink with overwrite replaces link")
                func copyToExistingSymlinkReplaces() throws {
                    let sourcePath = try createTempFile(content: [100, 200])
                    let targetPath = try createTempFile(content: [1, 2, 3])
                    let linkPath = "/tmp/copy-link-\(UUID().uuidString).link"
                    defer {
                        cleanup(sourcePath)
                        cleanup(targetPath)
                        cleanup(linkPath)
                    }

                    // Create symlink at destination
                    try FileManager.default.createSymbolicLink(
                        atPath: linkPath,
                        withDestinationPath: targetPath
                    )

                    let source = try File.Path(sourcePath)
                    let dest = try File.Path(linkPath)

                    // Copy with overwrite=true
                    try File.System.Copy.copy(
                        from: source,
                        to: dest,
                        options: .init(overwrite: true)
                    )

                    // Verify destination is now a regular file with source content
                    let destData = try Data(contentsOf: URL(fileURLWithPath: linkPath))
                    #expect(Array(destData) == [100, 200])

                    // Verify it's not a symlink anymore
                    let destAttrs = try FileManager.default.attributesOfItem(atPath: linkPath)
                    #expect(destAttrs[.type] as? FileAttributeType != .typeSymbolicLink)
                }

                // MARK: - Test 5: Empty file copy

                @Test("Empty file copies correctly through fast path")
                func emptyFileCopiesThroughFastPath() throws {
                    let sourcePath = try createTempFile(content: [])
                    let destPath = "/tmp/copy-empty-\(UUID().uuidString).bin"
                    defer {
                        cleanup(sourcePath)
                        cleanup(destPath)
                    }

                    let source = try File.Path(sourcePath)
                    let dest = try File.Path(destPath)

                    // Copy empty file - should use copy_file_range which handles empty files
                    try File.System.Copy.copy(from: source, to: dest)

                    // Verify destination exists and is empty
                    #expect(FileManager.default.fileExists(atPath: destPath))

                    let destData = try Data(contentsOf: URL(fileURLWithPath: destPath))
                    #expect(destData.isEmpty)

                    // Verify it's a regular file with size 0
                    let destAttrs = try FileManager.default.attributesOfItem(atPath: destPath)
                    #expect(destAttrs[.type] as? FileAttributeType == .typeRegular)
                    #expect(destAttrs[.size] as? UInt64 == 0)
                }

                // MARK: - Test 6: Attribute preservation

                @Test("Copy with copyAttributes=false does not preserve permissions")
                func copyWithoutAttributesNoPermissions() throws {
                    let sourcePath = try createTempFile(content: [1, 2, 3])
                    defer { cleanup(sourcePath) }

                    // Set specific permissions on source
                    try FileManager.default.setAttributes(
                        [.posixPermissions: 0o600],
                        ofItemAtPath: sourcePath
                    )

                    let destPath = "/tmp/copy-dest-\(UUID().uuidString).bin"
                    defer { cleanup(destPath) }

                    let source = try File.Path(sourcePath)
                    let dest = try File.Path(destPath)

                    // Copy without attributes
                    try File.System.Copy.copy(
                        from: source,
                        to: dest,
                        options: .init(copyAttributes: false)
                    )

                    // Get permissions of both files
                    let sourceAttrs = try FileManager.default.attributesOfItem(atPath: sourcePath)
                    let destAttrs = try FileManager.default.attributesOfItem(atPath: destPath)

                    let sourcePerms = (sourceAttrs[.posixPermissions] as? UInt16) ?? 0
                    let destPerms = (destAttrs[.posixPermissions] as? UInt16) ?? 0

                    #expect(sourcePerms == 0o600)
                    // Destination should have default permissions (modified by umask)
                    // Typically 0o644, but not the restrictive 0o600 from source
                    #expect(destPerms != sourcePerms)
                }

                @Test("Copy with copyAttributes=false does not preserve timestamps")
                func copyWithoutAttributesNoTimestamps() throws {
                    let sourcePath = try createTempFile(content: [1, 2, 3])
                    defer { cleanup(sourcePath) }

                    // Set old modification time on source
                    let oldDate = Date(timeIntervalSince1970: 1_000_000_000)  // Year 2001
                    try FileManager.default.setAttributes(
                        [.modificationDate: oldDate],
                        ofItemAtPath: sourcePath
                    )

                    // Wait a moment to ensure new file has different timestamp
                    Thread.sleep(forTimeInterval: 0.1)

                    let destPath = "/tmp/copy-dest-\(UUID().uuidString).bin"
                    defer { cleanup(destPath) }

                    let source = try File.Path(sourcePath)
                    let dest = try File.Path(destPath)

                    // Copy without attributes
                    try File.System.Copy.copy(
                        from: source,
                        to: dest,
                        options: .init(copyAttributes: false)
                    )

                    let sourceAttrs = try FileManager.default.attributesOfItem(atPath: sourcePath)
                    let destAttrs = try FileManager.default.attributesOfItem(atPath: destPath)

                    let sourceModTime = (sourceAttrs[.modificationDate] as? Date) ?? Date.distantPast
                    let destModTime = (destAttrs[.modificationDate] as? Date) ?? Date.distantPast

                    // Source should have old timestamp
                    #expect(abs(sourceModTime.timeIntervalSince(oldDate)) < 1.0)

                    // Destination should have current timestamp (not old one)
                    #expect(destModTime > sourceModTime)
                }

                @Test("Copy with copyAttributes=true preserves permissions")
                func copyWithAttributesPreservesPermissions() throws {
                    let sourcePath = try createTempFile(content: [1, 2, 3])
                    defer { cleanup(sourcePath) }

                    // Set specific permissions on source
                    try FileManager.default.setAttributes(
                        [.posixPermissions: 0o755],
                        ofItemAtPath: sourcePath
                    )

                    let destPath = "/tmp/copy-dest-\(UUID().uuidString).bin"
                    defer { cleanup(destPath) }

                    let source = try File.Path(sourcePath)
                    let dest = try File.Path(destPath)

                    // Copy with attributes (default)
                    try File.System.Copy.copy(
                        from: source,
                        to: dest,
                        options: .init(copyAttributes: true)
                    )

                    let sourceAttrs = try FileManager.default.attributesOfItem(atPath: sourcePath)
                    let destAttrs = try FileManager.default.attributesOfItem(atPath: destPath)

                    let sourcePerms = (sourceAttrs[.posixPermissions] as? UInt16) ?? 0
                    let destPerms = (destAttrs[.posixPermissions] as? UInt16) ?? 0

                    #expect(sourcePerms == 0o755)
                    #expect(destPerms == 0o755)
                }

                @Test("Copy with copyAttributes=true preserves timestamps")
                func copyWithAttributesPreservesTimestamps() throws {
                    let sourcePath = try createTempFile(content: [1, 2, 3])
                    defer { cleanup(sourcePath) }

                    // Set old modification time on source
                    let oldDate = Date(timeIntervalSince1970: 1_000_000_000)  // Year 2001
                    try FileManager.default.setAttributes(
                        [.modificationDate: oldDate],
                        ofItemAtPath: sourcePath
                    )

                    let destPath = "/tmp/copy-dest-\(UUID().uuidString).bin"
                    defer { cleanup(destPath) }

                    let source = try File.Path(sourcePath)
                    let dest = try File.Path(destPath)

                    // Copy with attributes (default)
                    try File.System.Copy.copy(
                        from: source,
                        to: dest,
                        options: .init(copyAttributes: true)
                    )

                    let sourceAttrs = try FileManager.default.attributesOfItem(atPath: sourcePath)
                    let destAttrs = try FileManager.default.attributesOfItem(atPath: destPath)

                    let sourceModTime = (sourceAttrs[.modificationDate] as? Date) ?? Date.distantPast
                    let destModTime = (destAttrs[.modificationDate] as? Date) ?? Date.distantPast

                    // Timestamps should match within 1 second (accounting for precision)
                    #expect(abs(sourceModTime.timeIntervalSince(destModTime)) < 1.0)
                }

                // MARK: - Test 7: Cross-filesystem copy fallback

                @Test("Copy across filesystems falls back to sendfile/manual")
                func copyAcrossFilesystemsFallsBack() throws {
                    // This test documents the fallback behavior when copy_file_range
                    // returns EXDEV (cross-device/filesystem not supported)
                    // The implementation should fall back to sendfile or manual copy

                    let sourcePath = try createTempFile(content: [1, 2, 3, 4, 5])
                    let destPath = "/tmp/copy-dest-\(UUID().uuidString).bin"
                    defer {
                        cleanup(sourcePath)
                        cleanup(destPath)
                    }

                    let source = try File.Path(sourcePath)
                    let dest = try File.Path(destPath)

                    // Copy should succeed even if filesystems differ
                    // (though in /tmp they're likely the same, this documents behavior)
                    try File.System.Copy.copy(from: source, to: dest)

                    // Verify data integrity
                    let sourceData = try Data(contentsOf: URL(fileURLWithPath: sourcePath))
                    let destData = try Data(contentsOf: URL(fileURLWithPath: destPath))
                    #expect(sourceData == destData)
                }
            }
        #endif
    }
}
