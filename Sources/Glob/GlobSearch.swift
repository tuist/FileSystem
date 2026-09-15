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
                    let searchRoot = searchRoot(for: include, in: baseURL)
                    let (baseURL, include, searchRootPrefix) = (searchRoot.url, searchRoot.pattern, searchRoot.prefix)

                    if include.sections.isEmpty {
                        if FileManager.default
                            .fileExists(atPath: baseURL.absoluteString.removingPercentEncoding ?? baseURL.absoluteString)
                        {
                            continuation.yield(baseURL)
                        }
                        continue
                    }

                    let path = baseURL.absoluteString.removingPercentEncoding ?? baseURL.absoluteString
                    let symbolicLinkDestination = URL.with(filePath: path).resolvingSymlinksInPath()
                    var isDirectory: ObjCBool = false

                    let symbolicLinkDestinationPath: String = symbolicLinkDestination
                        .path()
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
                            // Excludes are checked before includes so that an excluded directory is pruned even
                            // though it doesn't match the include pattern itself (e.g. `**/*.swift`).
                            for pattern in exclude where pattern.match(searchRootPrefix + relativePath) {
                                return .init(matches: false, skipDescendents: true)
                            }

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

                            return .init(matches: true, skipDescendents: false)
                        },
                        includingPropertiesForKeys: keys,
                        skipHiddenFiles: skipHiddenFiles,
                        relativePath: "",
                        followedSymbolicLinkDestinations: FollowedSymbolicLinkDestinations(),
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

private struct SearchRoot {
    /// The directory the search starts from.
    let url: URL
    /// The include pattern relative to `url`.
    let pattern: Pattern
    /// The path of `url` relative to the caller's base directory, with a trailing slash when non-empty.
    let prefix: String
}

/// Folds the constant prefix of an include pattern into the directory the search starts from.
///
/// The prefix is kept so exclude patterns can be matched against paths relative to the caller's base directory,
/// like the include patterns are.
private func searchRoot(for include: Pattern, in baseURL: URL) -> SearchRoot {
    guard case let .constant(constant) = include.sections.first else {
        return SearchRoot(url: baseURL, pattern: include, prefix: "")
    }
    let remainingSections = Array(include.sections.dropFirst())
    if constant.hasSuffix("/") {
        return SearchRoot(
            url: baseURL.appendingPath(constant.dropLast()),
            pattern: Pattern(sections: remainingSections, options: include.options),
            prefix: constant
        )
    } else if include.sections.count > 1, case .componentWildcard = include.sections[1] {
        let components = constant.components(separatedBy: "/")
        return SearchRoot(
            url: baseURL.appendingPath(components.dropLast().joined(separator: "/")),
            pattern: Pattern(
                sections: [.constant(components.last ?? "")] + remainingSections,
                options: include.options
            ),
            prefix: components.dropLast().map { $0 + "/" }.joined()
        )
    } else {
        return SearchRoot(
            url: baseURL.appendingPath(constant),
            pattern: Pattern(sections: remainingSections, options: include.options),
            prefix: constant + "/"
        )
    }
}

/// Resolves whether a directory entry is a directory to descend into and, for symbolic links, where it points to.
private func directoryDestination(of url: URL) throws -> (isDirectory: Bool, symbolicLinkDestination: URL?) {
    let resourceValues = try url.resourceValues(forKeys: [.isDirectoryKey, .isSymbolicLinkKey])
    if resourceValues.isDirectory == true {
        return (true, nil)
    } else if resourceValues.isSymbolicLink == true {
        let symbolicLinkDestination = url.resolvingSymlinksInPath()
        let resourceValues = try symbolicLinkDestination.resourceValues(forKeys: [.isDirectoryKey])
        return (resourceValues.isDirectory == true, symbolicLinkDestination)
    } else {
        return (false, nil)
    }
}

/// The canonical destinations of the directory symbolic links a search has already followed.
///
/// A directory that many symbolic links point to (for example a cached framework linked from every target of a
/// project) is walked once, through the first link the search comes across, instead of once per link.
private final class FollowedSymbolicLinkDestinations: @unchecked Sendable {
    private let lock = NSLock()
    private var destinations: Set<String> = []

    /// Returns `true` if the destination hadn't been followed before.
    func insert(_ destination: URL) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        return destinations.insert(destination.standardizedFileURL.path).inserted
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
    followedSymbolicLinkDestinations: FollowedSymbolicLinkDestinations,
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

    try await withThrowingTaskGroup(of: Void.self) { group in
        for url in contents {
            let relativePath = relativeDirectoryPath + url.lastPathComponent

            let matchResult = try matching(url, relativePath)

            let foundPath = directory.appendingPath(url.lastPathComponent)

            if matchResult.matches {
                continuation.yield(foundPath)
            }

            guard !matchResult.skipDescendents else { continue }

            let (isDirectory, symbolicLinkDestination) = try directoryDestination(of: url)
            if isDirectory {
                if let symbolicLinkDestination {
                    // This check prevents infinite loops when a symbolic link
                    // points to an ancestor directory of the current path.
                    guard !symbolicLinkDestination.isAncestorOf(directory) else { continue }
                    // Real directories are always walked; a destination is only walked through the first
                    // symbolic link that points to it.
                    guard followedSymbolicLinkDestinations.insert(symbolicLinkDestination) else { continue }
                }
                group.addTask {
                    try await search(
                        directory: foundPath,
                        symbolicLinkDestination: symbolicLinkDestination,
                        matching: matching,
                        includingPropertiesForKeys: keys,
                        skipHiddenFiles: skipHiddenFiles,
                        relativePath: relativePath + "/",
                        followedSymbolicLinkDestinations: followedSymbolicLinkDestinations,
                        continuation: continuation
                    )
                }
            }
        }

        try await group.waitForAll()
    }
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
