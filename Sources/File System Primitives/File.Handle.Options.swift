//
//  File.Handle.Options.swift
//  swift-file-system
//
//  Created by Coen ten Thije Boonkkamp on 17/12/2025.
//

extension File.Handle {
    /// Options for opening a file handle.
    public struct Options: OptionSet, Sendable {
        public let rawValue: UInt32

        public init(rawValue: UInt32) {
            self.rawValue = rawValue
        }

        /// Create the file if it doesn't exist.
        public static let create = Options(rawValue: 1 << 0)

        /// Truncate the file to zero length if it exists.
        public static let truncate = Options(rawValue: 1 << 1)

        /// Fail if the file already exists (used with `.create`).
        public static let exclusive = Options(rawValue: 1 << 2)

        /// Do not follow symbolic links.
        public static let noFollow = Options(rawValue: 1 << 3)

        /// Close the file descriptor on exec.
        public static let closeOnExec = Options(rawValue: 1 << 4)
    }
}
