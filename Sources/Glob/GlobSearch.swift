import Foundation

/// The result of a custom matcher for searching directory components
public struct MatchResult {
    /// When true, the url will be added to the output
    var matches: Bool
    /// When true, the descendents of a directory will be skipped entirely
    ///
    /// This has no effect if the url is not a directory.
    var skipDescendents: Bool
}

/// Recursively search the contents of a directory, filtering by the provided patterns
///
/// Searching is done asynchronously, with each subdirectory searched in parallel. Results are emitted as they are found.
///
/// The results are returned as they are matched and do not have a consistent order to them. If you need the results sorted, wait
/// for the entire search to complete and then sort the results.
///
/// - Parameters:
///   - baseURL: The directory to search, defaults to the current working directory.
///   - include: When provided, only includes results that match these patterns.
///   - exclude: When provided, ignore results that match these patterns. If a directory matches an exclude pattern, none of it's
/// descendents will be matched.
///   - keys: An array of keys that identify the properties that you want pre-fetched for each returned url. The values for these
/// keys are cached in the corresponding URL objects. You may specify nil for this parameter. For a list of keys you can specify,
/// see [Common File System Resource
/// Keys](https://developer.apple.com/documentation/corefoundation/cfurl/common_file_system_resource_keys).
///   - skipHiddenFiles: When true, hidden files will not be returned.
/// - Returns: An async collection of urls.
@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
// swiftlint:disable:next function_body_length
public func search(
    // swiftformat:disable unusedArguments
    directory baseURL: URL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath),
    include: [Pattern] = [],
    exclude: [Pattern] = [],
    includingPropertiesForKeys keys: [URLResourceKey] = [],
    skipHiddenFiles: Bool = true
) -> AsyncThrowingStream<URL, any Error> {
    AsyncThrowingStream(bufferingPolicy: .unbounded) { continuation in
        let task = Task {
            do {
                for include in include {
                    let (baseURL, include) = switch include.sections.first {
                    case let .constant(constant):
                        if constant.hasSuffix("/") {
                            (
                                baseURL.appendingPath(constant.dropLast()),
                                Pattern(sections: Array(include.sections.dropFirst()), options: include.options)
                            )
                        } else if include.sections.count == 1 {
                            (
                                baseURL.appendingPath(constant),
                                Pattern(sections: Array(include.sections.dropFirst()), options: include.options)
                            )
                        } else if case .componentWildcard = include.sections[1] {
                            (
                                baseURL.appendingPath(constant.components(separatedBy: "/").dropLast().joined(separator: "/")),
                                Pattern(
                                    sections: [.constant(constant.components(separatedBy: "/").last ?? "")] +
                                        Array(include.sections.dropFirst()),
                                    options: include.options
                                )
                            )
                        } else {
                            (
                                baseURL.appendingPath(constant),
                                Pattern(sections: Array(include.sections.dropFirst()), options: include.options)
                            )
                        }
                    default:
                        (baseURL, include)
                    }

                    if include.sections.isEmpty {
                        if FileManager.default
                            .fileExists(atPath: baseURL.path)
                        {
                            continuation.yield(baseURL)
                        }
                        continue
                    }

                    let path = baseURL.path
                    let symbolicLinkDestination = URL.with(filePath: path).resolvingSymlinksInPath()
                    var isDirectory: ObjCBool = false

                    let symbolicLinkDestinationPath: String = symbolicLinkDestination.path()
                        .removingPercentEncoding ?? symbolicLinkDestination.path()

                    guard FileManager.default.fileExists(
                        atPath: symbolicLinkDestinationPath,
                        isDirectory: &isDirectory
                    ),
                        isDirectory.boolValue
                    else { continue }

                    try await search(
                        directory: baseURL,
                        symbolicLinkDestination: symbolicLinkDestination,
                        matching: { _, relativePath in
                            guard include.match(relativePath) else {
                                // for patterns like `**/*.swift`, parent folders won't be matched but we don't want to skip those
                                // folder's descendents or we won't find the files that do match
                                let skipDescendents = !include.sections.enumerated().contains(where: { index, element in
                                    switch element {
                                    case .pathWildcard:
                                        return true
                                    case .componentWildcard:
                                        if index == include.sections.endIndex - 1 {
                                            return false
                                        } else if index == include.sections.endIndex - 2 {
                                            if case let .constant(constant) = include.sections.last {
                                                return constant.contains("/")
                                            } else {
                                                return true
                                            }
                                        } else {
                                            return true
                                        }
                                    default:
                                        return false
                                    }
                                })
                                return .init(matches: false, skipDescendents: skipDescendents)
                            }

                            for pattern in exclude {
                                if pattern.match(relativePath) {
                                    return .init(matches: false, skipDescendents: true)
                                }
                            }

                            return .init(matches: true, skipDescendents: false)
                        },
                        includingPropertiesForKeys: keys,
                        skipHiddenFiles: skipHiddenFiles,
                        relativePath: "",
                        continuation: continuation
                    )
                }

                continuation.finish()
            } catch {
                continuation.finish(throwing: error)
            }
        }

        continuation.onTermination = { _ in
            task.cancel()
        }
    }
}

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
private func search(
    directory: URL,
    symbolicLinkDestination: URL?,
    matching: @escaping @Sendable (_ url: URL, _ relativePath: String) throws -> MatchResult,
    includingPropertiesForKeys keys: [URLResourceKey],
    skipHiddenFiles: Bool,
    relativePath relativeDirectoryPath: String,
    continuation: AsyncThrowingStream<URL, any Error>.Continuation
) async throws {
    var options: FileManager.DirectoryEnumerationOptions = [
        .producesRelativePathURLs,
    ]
    if skipHiddenFiles {
        options.insert(.skipsHiddenFiles)
    }
    let contents = try FileManager.default.contentsOfDirectory(
        at: symbolicLinkDestination ?? directory,
        includingPropertiesForKeys: keys + [.isDirectoryKey],
        options: options
    )

    func handleEntry(_ url: URL) async throws {
        let relativePath = relativeDirectoryPath + url.lastPathComponent

        let matchResult = try matching(url, relativePath)

        let foundPath = directory.appendingPath(url.lastPathComponent)

        if matchResult.matches {
            continuation.yield(foundPath)
        }

        guard !matchResult.skipDescendents else { return }

        let resourceValues = try url.resourceValues(forKeys: [.isDirectoryKey, .isSymbolicLinkKey])
        let isDirectory: Bool
        let symbolicLinkDestination: URL?
        if resourceValues.isDirectory == true {
            isDirectory = true
            symbolicLinkDestination = nil
        } else if resourceValues.isSymbolicLink == true {
            let resourceValues = try url.resolvingSymlinksInPath().resourceValues(forKeys: [.isDirectoryKey])
            isDirectory = resourceValues.isDirectory == true
            symbolicLinkDestination = url.resolvingSymlinksInPath()
        } else {
            isDirectory = false
            symbolicLinkDestination = nil
        }
        if isDirectory {
            // This check prevents infinite loops when a symbolic link
            // points to an ancestor directory of the current path.
            if symbolicLinkDestination?.isAncestorOf(directory) != true {
                try await search(
                    directory: foundPath,
                    symbolicLinkDestination: symbolicLinkDestination,
                    matching: matching,
                    includingPropertiesForKeys: keys,
                    skipHiddenFiles: skipHiddenFiles,
                    relativePath: relativePath + "/",
                    continuation: continuation
                )
            }
        }
    }

    #if os(Windows)
        // Windows CI has known hangs with highly-parallel FileManager traversal.
        for url in contents {
            try await handleEntry(url)
        }
    #else
        try await withThrowingTaskGroup(of: Void.self) { group in
            for url in contents {
                group.addTask {
                    try await handleEntry(url)
                }
            }

            try await group.waitForAll()
        }
    #endif
}

extension URL {
    fileprivate func isAncestorOf(_ maybeChild: URL) -> Bool {
        let maybeChildFileURL = maybeChild.isFileURL ? maybeChild : .with(filePath: maybeChild.path)
        let maybeAncestorFileURL = isFileURL ? self : .with(filePath: path)

        do {
            let maybeChildResourceValues = try maybeChildFileURL.standardizedFileURL.resolvingSymlinksInPath()
                .resourceValues(forKeys: [.canonicalPathKey])
            let maybeAncestorResourceValues = try maybeAncestorFileURL.standardizedFileURL.resolvingSymlinksInPath()
                .resourceValues(forKeys: [.canonicalPathKey])

            if let canonicalChildPath = maybeChildResourceValues.canonicalPath,
               let canonicalAncestorPath = maybeAncestorResourceValues.canonicalPath
            {
                return canonicalChildPath.hasPrefix(canonicalAncestorPath)
            }
            return false
        } catch {
            return false
        }
    }
}

extension URL {
    public static func with(filePath: String) -> URL {
        #if os(Linux)
            return URL(fileURLWithPath: filePath)
        #else
            return URL(filePath: filePath)
        #endif
    }

    public func appendingPath(_ path: any StringProtocol) -> URL {
        #if os(Linux)
            return path
                .split(separator: "/")
                .reduce(self) { $0.appendingPathComponent(String($1)) }
        #else
            return appending(path: path)
        #endif
    }
}
