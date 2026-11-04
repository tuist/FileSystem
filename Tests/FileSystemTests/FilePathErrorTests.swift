import Path
import XCTest
@testable import FileSystem

#if !os(Windows)
    import File_System_Primitives

    final class FilePathErrorTests: XCTestCase {
        func test_containsControlCharacters_carriesTheOffendingPath() throws {
            let path = "/tmp/foo\nbar"

            XCTAssertThrowsError(try File.Path(path)) { error in
                XCTAssertEqual(error as? File.Path.Error, .containsControlCharacters(path))
            }
        }

        func test_containsControlCharacters_descriptionEscapesControlCharacters() throws {
            let cases: [(path: String, expected: String)] = [
                ("/tmp/foo\nbar", #"Path contains control characters: "/tmp/foo\nbar""#),
                ("/tmp/foo\rbar", #"Path contains control characters: "/tmp/foo\rbar""#),
                ("/tmp/foo\u{0}bar", #"Path contains control characters: "/tmp/foo\0bar""#),
                ("/tmp/foo\tbar", #"Path contains control characters: "/tmp/foo\tbar""#),
            ]

            for (path, expected) in cases {
                XCTAssertThrowsError(try File.Path(path)) { error in
                    XCTAssertEqual("\(error)", expected, "Unexpected description for \(path.debugDescription)")
                }
            }
        }

        func test_fileSystemSurfacesTheOffendingPath() async throws {
            let subject = FileSystem()
            let path = try AbsolutePath(validating: "/tmp/foo\nbar")

            do {
                _ = try await subject.exists(path)
                XCTFail("Expected exists(_:) to throw for a path containing control characters")
            } catch {
                XCTAssertEqual("\(error)", #"Path contains control characters: "/tmp/foo\nbar""#)
            }
        }
    }
#endif
