//
//  File.System.Metadata.Info Tests.swift
//  swift-file-system
//
//  Created by Coen ten Thije Boonkkamp on 18/12/2025.
//

import Foundation
@_spi(Internal) import StandardTime
import Testing

@testable import File_System_Primitives

extension File.System.Test.Unit {
    @Suite("File.System.Metadata.Info")
    struct MetadataInfo {

        // MARK: - Initialization

        @Test("Info initialization")
        func infoInitialization() {
            let now = Time(__unchecked: (), secondsSinceEpoch: 1_702_900_000, nanoseconds: 0)
            let timestamps = File.System.Metadata.Timestamps(
                accessTime: now,
                modificationTime: now,
                changeTime: now
            )
            let ownership = File.System.Metadata.Ownership(uid: 501, gid: 20)
            let permissions: File.System.Metadata.Permissions = .defaultFile

            let info = File.System.Metadata.Info(
                size: 1024,
                permissions: permissions,
                owner: ownership,
                timestamps: timestamps,
                type: .regular,
                inode: 12345,
                deviceId: 1,
                linkCount: 1
            )

            #expect(info.size == 1024)
            #expect(info.permissions == permissions)
            #expect(info.owner.uid == 501)
            #expect(info.owner.gid == 20)
            #expect(info.type == .regular)
            #expect(info.inode == 12345)
            #expect(info.deviceId == 1)
            #expect(info.linkCount == 1)
        }

        // MARK: - FileType

        @Test("FileType regular case")
        func fileTypeRegular() {
            let type: File.System.Metadata.FileType = .regular
            #expect(type == .regular)
        }

        @Test("FileType directory case")
        func fileTypeDirectory() {
            let type: File.System.Metadata.FileType = .directory
            #expect(type == .directory)
        }

        @Test("FileType symbolicLink case")
        func fileTypeSymbolicLink() {
            let type: File.System.Metadata.FileType = .symbolicLink
            #expect(type == .symbolicLink)
        }

        @Test("FileType blockDevice case")
        func fileTypeBlockDevice() {
            let type: File.System.Metadata.FileType = .blockDevice
            #expect(type == .blockDevice)
        }

        @Test("FileType characterDevice case")
        func fileTypeCharacterDevice() {
            let type: File.System.Metadata.FileType = .characterDevice
            #expect(type == .characterDevice)
        }

        @Test("FileType fifo case")
        func fileTypeFifo() {
            let type: File.System.Metadata.FileType = .fifo
            #expect(type == .fifo)
        }

        @Test("FileType socket case")
        func fileTypeSocket() {
            let type: File.System.Metadata.FileType = .socket
            #expect(type == .socket)
        }

        @Test("FileType cases are distinct")
        func fileTypeCasesAreDistinct() {
            #expect(File.System.Metadata.FileType.regular != .directory)
            #expect(File.System.Metadata.FileType.directory != .symbolicLink)
            #expect(File.System.Metadata.FileType.symbolicLink != .blockDevice)
            #expect(File.System.Metadata.FileType.blockDevice != .characterDevice)
            #expect(File.System.Metadata.FileType.characterDevice != .fifo)
            #expect(File.System.Metadata.FileType.fifo != .socket)
        }

        // MARK: - Info Properties

        @Test("Info size property")
        func infoSizeProperty() {
            let now = Time(__unchecked: (), secondsSinceEpoch: 1_702_900_000, nanoseconds: 0)
            let timestamps = File.System.Metadata.Timestamps(
                accessTime: now,
                modificationTime: now,
                changeTime: now
            )
            let ownership = File.System.Metadata.Ownership(uid: 0, gid: 0)

            let smallFile = File.System.Metadata.Info(
                size: 100,
                permissions: .defaultFile,
                owner: ownership,
                timestamps: timestamps,
                type: .regular,
                inode: 1,
                deviceId: 1,
                linkCount: 1
            )

            let largeFile = File.System.Metadata.Info(
                size: 1_000_000_000,
                permissions: .defaultFile,
                owner: ownership,
                timestamps: timestamps,
                type: .regular,
                inode: 2,
                deviceId: 1,
                linkCount: 1
            )

            #expect(smallFile.size == 100)
            #expect(largeFile.size == 1_000_000_000)
        }

        @Test("Info linkCount for hard links")
        func infoLinkCountForHardLinks() {
            let now = Time(__unchecked: (), secondsSinceEpoch: 1_702_900_000, nanoseconds: 0)
            let timestamps = File.System.Metadata.Timestamps(
                accessTime: now,
                modificationTime: now,
                changeTime: now
            )
            let ownership = File.System.Metadata.Ownership(uid: 0, gid: 0)

            let singleLink = File.System.Metadata.Info(
                size: 100,
                permissions: .defaultFile,
                owner: ownership,
                timestamps: timestamps,
                type: .regular,
                inode: 1,
                deviceId: 1,
                linkCount: 1
            )

            let multipleLinks = File.System.Metadata.Info(
                size: 100,
                permissions: .defaultFile,
                owner: ownership,
                timestamps: timestamps,
                type: .regular,
                inode: 1,
                deviceId: 1,
                linkCount: 5
            )

            #expect(singleLink.linkCount == 1)
            #expect(multipleLinks.linkCount == 5)
        }

        @Test("Info inode uniqueness")
        func infoInodeUniqueness() {
            let now = Time(__unchecked: (), secondsSinceEpoch: 1_702_900_000, nanoseconds: 0)
            let timestamps = File.System.Metadata.Timestamps(
                accessTime: now,
                modificationTime: now,
                changeTime: now
            )
            let ownership = File.System.Metadata.Ownership(uid: 0, gid: 0)

            let file1 = File.System.Metadata.Info(
                size: 100,
                permissions: .defaultFile,
                owner: ownership,
                timestamps: timestamps,
                type: .regular,
                inode: 12345,
                deviceId: 1,
                linkCount: 1
            )

            let file2 = File.System.Metadata.Info(
                size: 100,
                permissions: .defaultFile,
                owner: ownership,
                timestamps: timestamps,
                type: .regular,
                inode: 67890,
                deviceId: 1,
                linkCount: 1
            )

            #expect(file1.inode != file2.inode)
        }

        // MARK: - Sendable

        @Test("Info is sendable")
        func infoIsSendable() async {
            let now = Time(__unchecked: (), secondsSinceEpoch: 1_702_900_000, nanoseconds: 0)
            let timestamps = File.System.Metadata.Timestamps(
                accessTime: now,
                modificationTime: now,
                changeTime: now
            )
            let ownership = File.System.Metadata.Ownership(uid: 501, gid: 20)

            let info = File.System.Metadata.Info(
                size: 1024,
                permissions: .defaultFile,
                owner: ownership,
                timestamps: timestamps,
                type: .regular,
                inode: 12345,
                deviceId: 1,
                linkCount: 1
            )

            await Task {
                #expect(info.size == 1024)
                #expect(info.type == .regular)
            }.value
        }

        @Test("FileType is sendable")
        func fileTypeIsSendable() async {
            let type: File.System.Metadata.FileType = .directory

            await Task {
                #expect(type == .directory)
            }.value
        }
    }
}
