import Foundation
import Logging
import Path

public enum FileSystemItemType: CaseIterable, Equatable {
    case directory
    case file
}

public protocol FileSysteming {
    func createTemporaryDirectory(prefix: String) throws -> AbsolutePath
    func exists(_ path: AbsolutePath) -> Bool
    func exists(_ path: AbsolutePath, isDirectory: Bool) -> Bool
}

public struct FileSystem: FileSysteming {
    fileprivate let logger: Logger?

    public init(logger: Logger? = nil) {
        self.logger = logger
    }

    public func createTemporaryDirectory(prefix: String) throws -> AbsolutePath {
        let systemTemporaryDirectory = NSTemporaryDirectory()
        let temporaryDirectory = try AbsolutePath(validating: systemTemporaryDirectory)
            .appending(component: "\(prefix)-\(UUID().uuidString)")
        try FileManager.default.createDirectory(
            at: URL(fileURLWithPath: temporaryDirectory.pathString),
            withIntermediateDirectories: true
        )
        return temporaryDirectory
    }

    public func exists(_ path: AbsolutePath) -> Bool {
        FileManager.default.fileExists(atPath: path.pathString)
    }

    public func exists(_ path: AbsolutePath, isDirectory: Bool) -> Bool {
        var checkedIsDirectory: ObjCBool = false
        let exists = FileManager.default.fileExists(atPath: path.pathString, isDirectory: &checkedIsDirectory)
        return exists && checkedIsDirectory.boolValue == isDirectory
    }
}
