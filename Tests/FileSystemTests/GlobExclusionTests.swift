import Glob
import Path
import Testing
@testable import FileSystem

/// Covers the filtering that backs the default implementation of
/// `glob(directory:include:exclude:)`, which conforming types get when they don't provide one.
struct GlobExclusionTests {
    private let directory = try! AbsolutePath(validating: "/root")

    @Test func excludesThePathsMatchingThePatterns() async throws {
        // Given
        let sourceFile = directory.appending(try RelativePath(validating: "first/file.swift"))
        let gitKeep = directory.appending(try RelativePath(validating: "first/.gitkeep"))

        // When
        let got = try await collect(
            paths([sourceFile, gitKeep]).excludingPaths(
                matching: [try Pattern("**/.gitkeep")],
                relativeTo: directory
            )
        )

        // Then
        #expect(got == [sourceFile])
    }

    @Test func excludesTheDescendantsOfAnExcludedDirectory() async throws {
        // Given
        let generatedDirectory = directory.appending(try RelativePath(validating: "Generated"))
        let generatedFile = directory.appending(try RelativePath(validating: "Generated/nested/generated.swift"))
        let sourceFile = directory.appending(try RelativePath(validating: "file.swift"))

        // When
        let got = try await collect(
            paths([generatedDirectory, generatedFile, sourceFile]).excludingPaths(
                matching: [try Pattern("Generated")],
                relativeTo: directory
            )
        )

        // Then
        #expect(got == [sourceFile])
    }

    @Test func keepsEveryPathWhenThereAreNoPatterns() async throws {
        // Given
        let gitKeep = directory.appending(try RelativePath(validating: "first/.gitkeep"))
        let dsStore = directory.appending(try RelativePath(validating: ".DS_Store"))

        // When
        let got = try await collect(
            paths([gitKeep, dsStore]).excludingPaths(matching: [], relativeTo: directory)
        )

        // Then
        #expect(got == [gitKeep, dsStore])
    }

    @Test func keepsThePathsThatDoNotMatchThePatterns() async throws {
        // Given
        let sourceFile = directory.appending(try RelativePath(validating: "first/file.swift"))

        // When
        let got = try await collect(
            paths([sourceFile]).excludingPaths(
                matching: [try Pattern("**/*.json")],
                relativeTo: directory
            )
        )

        // Then
        #expect(got == [sourceFile])
    }

    private func paths(_ paths: [AbsolutePath]) -> AsyncStream<AbsolutePath> {
        AsyncStream { continuation in
            for path in paths {
                continuation.yield(path)
            }
            continuation.finish()
        }
    }

    private func collect<S: AsyncSequence>(_ sequence: S) async throws -> [AbsolutePath]
        where S.Element == AbsolutePath
    {
        var collected: [AbsolutePath] = []
        for try await path in sequence {
            collected.append(path)
        }
        return collected
    }
}
