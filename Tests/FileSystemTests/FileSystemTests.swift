import XCTest
@testable import FileSystem

final class FileSystemTests: XCTestCase {
    var subject: FileSystem!
    
    override func setUp() async throws {
        try await super.setUp()
        subject = FileSystem()
    }
    
    override func tearDown() async throws {
        subject = nil
        try await super.tearDown()
    }
    
    func test_createTemporaryDirectory_returnsAValidDirectory() async throws {
        // Given
        let got = try await subject.createTemporaryDirectory()
        
        print(got)
    }
}
