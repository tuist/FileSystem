//
//  File.System.Create.swift
//  swift-file-system
//
//  Created by Coen ten Thije Boonkkamp on 17/12/2025.
//

extension File.System {
    /// Namespace for file and directory creation operations.
    public enum Create {}
}

extension File.System.Create {
    /// General options for creation operations.
    public struct Options: Sendable {
        /// File permissions for the created item.
        public var permissions: File_System_Primitives.File.System.Metadata.Permissions?

        public init(permissions: File_System_Primitives.File.System.Metadata.Permissions? = nil) {
            self.permissions = permissions
        }
    }
}
