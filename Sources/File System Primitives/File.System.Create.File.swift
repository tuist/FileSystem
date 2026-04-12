//
//  File.System.Create.File.swift
//  swift-file-system
//
//  Created by Coen ten Thije Boonkkamp on 17/12/2025.
//

extension File.System.Create {
    /// Create new files.
    public enum File {
        // TODO: Implementation
    }
}

extension File.System.Create.File {
    /// Error type for file creation operations.
    public enum Error: Swift.Error, Equatable, Sendable {
        case alreadyExists(File_System_Primitives.File.Path)
        case permissionDenied(File_System_Primitives.File.Path)
        case parentDirectoryNotFound(File_System_Primitives.File.Path)
        case createFailed(errno: Int32, message: String)
    }
}
