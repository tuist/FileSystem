//
//  File.Path.Error Tests.swift
//  swift-file-system
//
//  Created by Coen ten Thije Boonkkamp on 18/12/2025.
//

import Testing

@testable import File_System_Primitives

extension File.System.Test.Unit {
    @Suite("File.Path.Error")
    struct PathError {

        // MARK: - Error Cases

        @Test("Empty error case")
        func emptyErrorCase() {
            let error = File.Path.Error.empty
            #expect(error == .empty)
        }

        @Test("ContainsControlCharacters error case")
        func containsControlCharactersErrorCase() {
            let error = File.Path.Error.containsControlCharacters
            #expect(error == .containsControlCharacters)
        }

        // MARK: - Error Triggering

        @Test("Empty path triggers empty error")
        func emptyPathTriggersEmptyError() {
            let emptyString = ""
            #expect(throws: File.Path.Error.empty) {
                try File.Path(emptyString)
            }
        }

        @Test("Null character triggers containsControlCharacters")
        func nullCharacterTriggersError() {
            let pathWithNull = "/tmp/file\0.txt"
            #expect(throws: File.Path.Error.containsControlCharacters) {
                try File.Path(pathWithNull)
            }
        }

        @Test("Newline character triggers containsControlCharacters")
        func newlineCharacterTriggersError() {
            let pathWithNewline = "/tmp/file\n.txt"
            #expect(throws: File.Path.Error.containsControlCharacters) {
                try File.Path(pathWithNewline)
            }
        }

        @Test("Carriage return triggers containsControlCharacters")
        func carriageReturnTriggersError() {
            let pathWithCR = "/tmp/file\r.txt"
            #expect(throws: File.Path.Error.containsControlCharacters) {
                try File.Path(pathWithCR)
            }
        }

        @Test("Tab character triggers containsControlCharacters")
        func tabCharacterTriggersError() {
            let pathWithTab = "/tmp/file\t.txt"
            #expect(throws: File.Path.Error.containsControlCharacters) {
                try File.Path(pathWithTab)
            }
        }

        @Test("Bell character triggers containsControlCharacters")
        func bellCharacterTriggersError() {
            let pathWithBell = "/tmp/file\u{07}.txt"
            #expect(throws: File.Path.Error.containsControlCharacters) {
                try File.Path(pathWithBell)
            }
        }

        // MARK: - CustomStringConvertible

        @Test("Empty error description")
        func emptyErrorDescription() {
            let error = File.Path.Error.empty
            #expect(error.description == "Path is empty")
        }

        @Test("ContainsControlCharacters error description")
        func containsControlCharactersErrorDescription() {
            let error = File.Path.Error.containsControlCharacters
            #expect(error.description == "Path contains control characters")
        }

        // MARK: - Equatable

        @Test("Same errors are equal")
        func sameErrorsAreEqual() {
            #expect(File.Path.Error.empty == File.Path.Error.empty)
            #expect(
                File.Path.Error.containsControlCharacters
                    == File.Path.Error.containsControlCharacters
            )
        }

        @Test("Different errors are not equal")
        func differentErrorsAreNotEqual() {
            #expect(File.Path.Error.empty != File.Path.Error.containsControlCharacters)
        }

        // MARK: - Sendable

        @Test("Error is Sendable")
        func errorIsSendable() async {
            let error = File.Path.Error.empty

            await Task {
                #expect(error == .empty)
            }.value
        }
    }
}
