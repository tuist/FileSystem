//
//  File.System.Metadata.Info.swift
//  swift-file-system
//
//  Created by Coen ten Thije Boonkkamp on 17/12/2025.
//

extension File.System.Metadata {
    /// File metadata information (stat result).
    public struct Info: Sendable {
        /// File size in bytes.
        public let size: Int64

        /// File permissions.
        public let permissions: Permissions

        /// File ownership.
        public let owner: Ownership

        /// File timestamps.
        public let timestamps: Timestamps

        /// File type.
        public let type: FileType

        /// Inode number.
        public let inode: UInt64

        /// Device ID.
        public let deviceId: UInt64

        /// Number of hard links.
        public let linkCount: UInt32

        public init(
            size: Int64,
            permissions: Permissions,
            owner: Ownership,
            timestamps: Timestamps,
            type: FileType,
            inode: UInt64,
            deviceId: UInt64,
            linkCount: UInt32
        ) {
            self.size = size
            self.permissions = permissions
            self.owner = owner
            self.timestamps = timestamps
            self.type = type
            self.inode = inode
            self.deviceId = deviceId
            self.linkCount = linkCount
        }
    }

    /// File type classification.
    public enum FileType: Sendable {
        case regular
        case directory
        case symbolicLink
        case blockDevice
        case characterDevice
        case fifo
        case socket
    }
}
