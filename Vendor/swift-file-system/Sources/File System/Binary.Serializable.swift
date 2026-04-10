//
//  Binary.Serializable+Convenience.swift
//  swift-file-system
//
//  Created by Coen ten Thije Boonkkamp on 18/12/2025.
//

public import Binary

extension Binary.Serializable {
    /// Writes this serializable value atomically to a file.
    ///
    /// Uses the atomic write-sync-rename pattern for crash safety.
    ///
    /// - Parameters:
    ///   - path: Destination file path.
    ///   - options: Write options (strategy, durability, metadata preservation).
    /// - Throws: `File.System.Write.Atomic.Error` on failure.
    public func write(
        to path: File.Path,
        options: File.System.Write.Atomic.Options = .init()
    ) throws(File.System.Write.Atomic.Error) {
        try File.System.Write.Atomic.write(self, to: path, options: options)
    }
}
