import Foundation
import Path

extension AbsolutePath {
    /// Returns the list of paths that match the given glob pattern.
    ///
    /// - Parameter pattern: Relative glob pattern used to match the paths.
    /// - Returns: List of paths that match the given pattern.
    func glob(_ pattern: String) -> [AbsolutePath] {
        // swiftlint:disable:next force_try
        Glob(pattern: appending(try! RelativePath(validating: pattern)).pathString).paths
            .map { try! AbsolutePath(validating: $0) } // swiftlint:disable:this force_try
    }
}
