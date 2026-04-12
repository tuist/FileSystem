//
//  File.System.Metadata.Attributes.swift
//  swift-file-system
//
//  Created by Coen ten Thije Boonkkamp on 17/12/2025.
//

extension File.System.Metadata {
    /// Extended file attributes (xattrs).
    public enum Attributes {
        // TODO: Implementation
    }
}

extension File.System.Metadata.Attributes {
    /// Error type for extended attribute operations.
    public enum Error: Swift.Error, Equatable, Sendable {
        case pathNotFound(File.Path)
        case permissionDenied(File.Path)
        case attributeNotFound(name: String, path: File.Path)
        case notSupported(File.Path)
        case operationFailed(errno: Int32, message: String)
    }
}
