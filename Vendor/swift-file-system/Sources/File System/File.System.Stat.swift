//
//  File.System.Stat+Convenience.swift
//  swift-file-system
//
//  Created by Coen ten Thije Boonkkamp on 18/12/2025.
//

extension File.System.Stat {
    /// Checks if the path is a regular file.
    ///
    /// - Parameter path: The path to check.
    /// - Returns: `true` if the path is a regular file, `false` otherwise.
    public static func isFile(at path: File.Path) -> Bool {
        guard let info = try? info(at: path) else { return false }
        return info.type == .regular
    }

    /// Checks if the path is a directory.
    ///
    /// - Parameter path: The path to check.
    /// - Returns: `true` if the path is a directory, `false` otherwise.
    public static func isDirectory(at path: File.Path) -> Bool {
        guard let info = try? info(at: path) else { return false }
        return info.type == .directory
    }

    /// Checks if the path is a symbolic link.
    ///
    /// - Parameter path: The path to check.
    /// - Returns: `true` if the path is a symbolic link, `false` otherwise.
    public static func isSymlink(at path: File.Path) -> Bool {
        guard let info = try? lstatInfo(at: path) else { return false }
        return info.type == .symbolicLink
    }
}
