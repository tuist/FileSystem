//
//  File.Handle.Mode.swift
//  swift-file-system
//
//  Created by Coen ten Thije Boonkkamp on 17/12/2025.
//

extension File.Handle {
    /// The mode in which a file handle was opened.
    public enum Mode: Sendable {
        /// Read-only access.
        case read
        /// Write-only access.
        case write
        /// Read and write access.
        case readWrite
        /// Append-only access.
        case append
    }
}
