import Foundation

#if os(Windows)
    import WinSDK
#elseif canImport(Darwin)
    import Darwin
#elseif canImport(Glibc)
    import Glibc
#elseif canImport(Musl)
    import Musl
#endif

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
    directory baseURL: URL = URL.with(filePath: ProcessInfo.processInfo.environment["PWD"] ?? "."),
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
                        if (try? normalizedFileURL(baseURL).checkResourceIsReachable()) == true {
                            continuation.yield(baseURL)
                        }
                        continue
                    }

                    let symbolicLinkDestination = normalizedFileURL(baseURL).resolvingSymlinksInPath()

                    let symbolicLinkDestinationPath = decodedPath(symbolicLinkDestination)

                    guard let resourceValues = try? URL.with(filePath: symbolicLinkDestinationPath)
                        .resourceValues(forKeys: [.isDirectoryKey]),
                        resourceValues.isDirectory == true
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
    let contents = try directoryContents(
        at: symbolicLinkDestination ?? directory,
        includingPropertiesForKeys: keys + [.isDirectoryKey, .isSymbolicLinkKey],
        skipHiddenFiles: skipHiddenFiles
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
                    group.addTask {
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
        }

        try await group.waitForAll()
    }
}

extension URL {
    fileprivate func isAncestorOf(_ maybeChild: URL) -> Bool {
        let maybeChildFileURL = maybeChild.isFileURL ? maybeChild : .with(filePath: decodedPath(maybeChild))
        let maybeAncestorFileURL = isFileURL ? self : .with(filePath: decodedPath(self))

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

private func directoryContents(
    at directory: URL,
    includingPropertiesForKeys keys: [URLResourceKey],
    skipHiddenFiles: Bool
) throws -> [URL] {
    let directoryPath = decodedPath(normalizedFileURL(directory).resolvingSymlinksInPath())
    let baseURL = URL.with(filePath: directoryPath)
    let entries = try directoryEntries(atPath: directoryPath)
    let requestedKeys = Set(keys)

    return try entries.compactMap { entry in
        guard !skipHiddenFiles || !entry.hasPrefix(".") else { return nil }
        let url = baseURL.appendingPath(entry)
        if !requestedKeys.isEmpty {
            _ = try url.resourceValues(forKeys: requestedKeys)
        }
        return url
    }
}

private func directoryEntries(atPath path: String) throws -> [String] {
    #if os(Windows)
        var entries: [String] = []
        var findData = WIN32_FIND_DATAW()
        let searchPath = "\(path.replacingOccurrences(of: "/", with: "\\"))\\*"
        let handle = searchPath.withCString(encodedAs: UTF16.self) { wpath in
            FindFirstFileW(wpath, &findData)
        }
        guard handle != INVALID_HANDLE_VALUE else {
            throw NSError(domain: "WinSDK", code: Int(GetLastError()))
        }
        defer { FindClose(handle) }

        repeat {
            let entry = withUnsafePointer(to: &findData.cFileName) { pointer in
                pointer.withMemoryRebound(
                    to: WCHAR.self,
                    capacity: MemoryLayout.size(ofValue: findData.cFileName) / MemoryLayout<WCHAR>.size
                ) {
                    String(decodingCString: $0, as: UTF16.self)
                }
            }
            guard entry != ".", entry != ".." else { continue }
            entries.append(entry)
        } while windowsSucceeded(FindNextFileW(handle, &findData))

        let lastError = GetLastError()
        if lastError != DWORD(ERROR_NO_MORE_FILES) {
            throw NSError(domain: "WinSDK", code: Int(lastError))
        }

        return entries
    #else
        guard let directory = opendir(path) else {
            throw NSError(domain: NSPOSIXErrorDomain, code: Int(errno))
        }
        defer { closedir(directory) }

        var entries: [String] = []
        errno = 0
        while let entryPointer = readdir(directory) {
            let entry = entryPointer.pointee
            var entryName = entry.d_name
            let capacity = MemoryLayout.size(ofValue: entryName) / MemoryLayout<CChar>.size
            let name = withUnsafePointer(to: &entryName) { pointer in
                pointer.withMemoryRebound(to: CChar.self, capacity: capacity) {
                    String(cString: $0)
                }
            }
            guard name != ".", name != ".." else { continue }
            entries.append(name)
        }
        if errno != 0 {
            throw NSError(domain: NSPOSIXErrorDomain, code: Int(errno))
        }
        return entries
    #endif
}

private func normalizedFileURL(_ url: URL) -> URL {
    if url.isFileURL {
        return url
    }
    return URL.with(filePath: url.absoluteString.removingPercentEncoding ?? url.absoluteString)
}

private func decodedPath(_ url: URL) -> String {
    let path = url.path()
    return path.removingPercentEncoding ?? path
}

#if os(Windows)
    private func windowsSucceeded(_ result: Bool) -> Bool {
        result
    }

    private func windowsSucceeded(_ result: some BinaryInteger) -> Bool {
        result != 0
    }
#endif

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
