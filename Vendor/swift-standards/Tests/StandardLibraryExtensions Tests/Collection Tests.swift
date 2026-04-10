// Collection Tests.swift
// swift-standards
//
// Tests for Collection extensions

import Testing

@testable import StandardLibraryExtensions

@Suite
struct `Collection Safe Subscript` {

    // MARK: - Safe subscript with valid indices

    @Test
    func `Safe subscript returns element for valid index`() {
        let array = [1, 2, 3, 4, 5]
        #expect(array[safe: 0] == 1)
        #expect(array[safe: 2] == 3)
        #expect(array[safe: 4] == 5)
    }

    @Test
    func `Safe subscript with string`() {
        let string = "Hello"
        let index = string.index(string.startIndex, offsetBy: 1)
        #expect(string[safe: index] == "e")
        #expect(string[safe: string.startIndex] == "H")
    }

    @Test
    func `Safe subscript with dictionary values`() {
        let dict = ["a": 1, "b": 2, "c": 3]
        let values = Array(dict.values.sorted())
        #expect(values[safe: 0] == 1)
        #expect(values[safe: 1] == 2)
        #expect(values[safe: 2] == 3)
    }

    // MARK: - Safe subscript with invalid indices

    @Test
    func `Safe subscript returns nil for out of bounds positive index`() {
        let array = [1, 2, 3]
        #expect(array[safe: 10] == nil)
        #expect(array[safe: 100] == nil)
    }

    @Test
    func `Safe subscript returns nil for negative index`() {
        let array = [1, 2, 3]
        #expect(array[safe: -1] == nil)
        #expect(array[safe: -10] == nil)
    }

    @Test
    func `Safe subscript on empty collection`() {
        let empty: [Int] = []
        #expect(empty[safe: 0] == nil)
        #expect(empty[safe: 1] == nil)
    }

    // MARK: - Different collection types

    @Test
    func `Safe subscript with ArraySlice`() {
        let array = [1, 2, 3, 4, 5]
        let slice = array[1...3]  // [2, 3, 4]
        #expect(slice[safe: 1] == 2)
        #expect(slice[safe: 2] == 3)
        #expect(slice[safe: 3] == 4)
        #expect(slice[safe: 0] == nil)
        #expect(slice[safe: 4] == nil)
    }

    @Test
    func `Safe subscript with ContiguousArray`() {
        let array: ContiguousArray = [10, 20, 30]
        #expect(array[safe: 0] == 10)
        #expect(array[safe: 2] == 30)
        #expect(array[safe: 3] == nil)
    }

    // MARK: - Category theory properties

    @Test
    func `Natural transformation preserves structure`() {
        // η: Collection → Maybe where η(c)[i] = Some(c[i]) if valid, None otherwise
        let collection = [1, 2, 3]

        // Valid index: Collection(element) → Maybe(element)
        let validResult = collection[safe: 1]
        #expect(validResult != nil)
        #expect(validResult == collection[1])

        // Invalid index: Collection(?) → Maybe(None)
        let invalidResult = collection[safe: 10]
        #expect(invalidResult == nil)
    }

    @Test
    func `Totality property - never traps`() {
        let array = [1, 2, 3]

        // These would trap with regular subscript, but return nil with safe subscript
        _ = array[safe: -100]
        _ = array[safe: 100]
        _ = array[safe: Int.max]

        // Test passes if we reach here without trapping
        #expect(Bool(true))
    }
}
