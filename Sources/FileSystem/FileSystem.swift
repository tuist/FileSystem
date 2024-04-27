import Foundation
import Logging
import Path

public protocol FileSysteming {
    func createTemporaryDirectory() async throws -> AbsolutePath
}

public struct FileSystem: FileSysteming {
    public func createTemporaryDirectory() async throws -> AbsolutePath {
        let temporaryDirectory = NSTemporaryDirectory()
        return try AbsolutePath(validating: temporaryDirectory)
    }
}
