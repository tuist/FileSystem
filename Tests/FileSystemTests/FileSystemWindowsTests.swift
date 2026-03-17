#if os(Windows)
    import Path
    import Testing
    @testable import FileSystem

    struct FileSystemWindowsTests {
        let subject = FileSystem()

        @Test
        func test_exists_returnsTrueForDirectoryAndFalseForFileFlag() async throws {
            let temporaryDirectory = try await subject.makeTemporaryDirectory(prefix: "FileSystem")

            let exists = try await subject.exists(temporaryDirectory)
            #expect(exists)
            let isDirectory = try await subject.exists(temporaryDirectory, isDirectory: true)
            #expect(isDirectory)
            let isFile = try await subject.exists(temporaryDirectory, isDirectory: false)
            #expect(!isFile)
        }

        @Test
        func test_exists_returnsTrueForFile() async throws {
            let temporaryDirectory = try await subject.makeTemporaryDirectory(prefix: "FileSystem")
            let file = temporaryDirectory.appending(component: "file.txt")
            try await subject.touch(file)

            let exists = try await subject.exists(file)
            #expect(exists)
            let isFile = try await subject.exists(file, isDirectory: false)
            #expect(isFile)
            let isDirectory = try await subject.exists(file, isDirectory: true)
            #expect(!isDirectory)
        }

        @Test
        func test_exists_returnsFalseForMissingPath() async throws {
            let temporaryDirectory = try await subject.makeTemporaryDirectory(prefix: "FileSystem")
            let missing = temporaryDirectory.appending(component: "missing")

            let exists = try await subject.exists(missing)
            #expect(!exists)
        }

        @Test
        func test_makeDirectory_touch_and_contentsOfDirectory() async throws {
            let temporaryDirectory = try await subject.makeTemporaryDirectory(prefix: "FileSystem")
            let directory = temporaryDirectory.appending(component: "directory")
            let file = directory.appending(component: "file.txt")

            try await subject.makeDirectory(at: directory)
            try await subject.touch(file)

            let contents = try await subject.contentsOfDirectory(directory)

            #expect(contents.map(\.basename) == ["file.txt"])
        }

        @Test
        func test_move_movesAFile() async throws {
            let temporaryDirectory = try await subject.makeTemporaryDirectory(prefix: "FileSystem")
            let source = temporaryDirectory.appending(component: "source.txt")
            let destination = temporaryDirectory.appending(component: "destination.txt")
            try await subject.touch(source)

            try await subject.move(from: source, to: destination)

            let sourceExists = try await subject.exists(source)
            let destinationExists = try await subject.exists(destination)
            #expect(!sourceExists)
            #expect(destinationExists)
        }

        @Test
        func test_glob_returnsMatches() async throws {
            let temporaryDirectory = try await subject.makeTemporaryDirectory(prefix: "FileSystem")
            let sourceDirectory = temporaryDirectory.appending(component: "Sources")
            let file = sourceDirectory.appending(component: "File.swift")
            try await subject.makeDirectory(at: sourceDirectory)
            try await subject.touch(file)

            let got = try await subject.glob(directory: temporaryDirectory, include: ["**/*.swift"])
                .collect()
                .sorted()

            #expect(got == [file])
        }
    }
#endif
