// Set<Character>+INCITS_4_1986 Tests.swift
// swift-incits-4-1986
//
// Tests for Set<Character> ASCII whitespace constants

import StandardsTestSupport
import Testing

@testable import INCITS_4_1986

@Suite
struct `Set<Character>` {
    @Suite
    struct `Set<Character> - whitespaces` {
        @Test
        func `whitespace set contains space`() {
            #expect(Set<Character>.ascii.whitespaces.contains(" "))
        }

        @Test
        func `whitespace set contains tab`() {
            #expect(Set<Character>.ascii.whitespaces.contains("\t"))
        }

        @Test
        func `whitespace set contains newline`() {
            #expect(Set<Character>.ascii.whitespaces.contains("\n"))
        }

        @Test
        func `whitespace set contains carriage return`() {
            #expect(Set<Character>.ascii.whitespaces.contains("\r"))
        }

        @Test
        func `whitespace set has exactly 4 characters`() {
            #expect(INCITS_4_1986.whitespaces.count == 4)
        }

        @Test(arguments: ["a", "Z", "0", "!", "@", "#"])
        func `whitespace set does not contain non-whitespace`(char: Character) {
            #expect(!Set<Character>.ascii.whitespaces.contains(char))
        }

        @Test
        func `whitespace set matches expected characters`() {
            let expected: [Character] = [" ", "\t", "\n", "\r"].sorted()
            #expect(INCITS_4_1986.whitespaces.compactMap(Character.init).sorted() == expected)
        }

        @Test
        func `all whitespace characters are ASCII`() {
            for char in Set<Character>.ascii.whitespaces {
                #expect(char.isASCII)
            }
        }

        @Test
        func `whitespace characters match ASCII values`() {
            let whitespaceBytes: Set<UInt8> = [UInt8.ascii.sp, UInt8.ascii.htab, UInt8.ascii.lf, UInt8.ascii.cr]
            for char in Set<Character>.ascii.whitespaces {
                if let ascii = char.asciiValue {
                    #expect(whitespaceBytes.contains(ascii))
                }
            }
        }

        @Test
        func `can use whitespaces in Set operations`() {
            let custom: Set<Character> = [" ", "\t", "x", "y"]
            let intersection = custom.intersection(.ascii.whitespaces)
            #expect(intersection == [" ", "\t"])
        }
    }
}

extension `Performance Tests` {
    @Suite
    struct `Set<Character> - Performance` {
        @Test(.timed(threshold: .milliseconds(50)))
        func `whitespace set membership check 10K times`() {
            let ws = Set<Character>.ascii.whitespaces
            for _ in 0..<10000 {
                _ = ws.contains(" ")
                _ = ws.contains("\t")
                _ = ws.contains("a")
            }
        }

        @Test(.timed(threshold: .milliseconds(300)))
        func `whitespace set iteration 100K times`() {
            let ws = Set<Character>.ascii.whitespaces
            for _ in 0..<100_000 {
                for _ in ws {
                    // Iterate through all whitespace characters
                }
            }
        }
    }
}
