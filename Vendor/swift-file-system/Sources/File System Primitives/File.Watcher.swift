//
//  File.Watcher.swift
//  swift-file-system
//
//  Created by Coen ten Thije Boonkkamp on 17/12/2025.
//

extension File {
    /// File system event watching (future implementation).
    public enum Watcher {
        // TODO: Implementation using FSEvents/inotify
    }
}

extension File.Watcher {
    /// A file system event.
    public struct Event: Sendable {
        /// The path that changed.
        public let path: File.Path

        /// The type of event.
        public let type: EventType

        public init(path: File.Path, type: EventType) {
            self.path = path
            self.type = type
        }
    }

    /// The type of file system event.
    public enum EventType: Sendable {
        case created
        case modified
        case deleted
        case renamed
        case attributesChanged
    }

    /// Options for file watching.
    public struct Options: Sendable {
        /// Whether to watch subdirectories recursively.
        public var recursive: Bool

        /// Latency in seconds before coalescing events.
        public var latency: Double

        public init(
            recursive: Bool = false,
            latency: Double = 0.5
        ) {
            self.recursive = recursive
            self.latency = latency
        }
    }
}
