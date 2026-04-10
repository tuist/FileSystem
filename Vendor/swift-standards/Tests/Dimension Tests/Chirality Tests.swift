// Chirality Tests.swift

import Algebra
import Foundation
import Testing

@testable import Dimension

@Suite
struct ChiralityTests {
    @Test
    func `Chirality cases`() {
        #expect(Chirality.allCases.count == 2)
        #expect(Chirality.allCases.contains(.left))
        #expect(Chirality.allCases.contains(.right))
    }

    @Test
    func `Chirality opposite is involution`() {
        #expect(Chirality.left.opposite == .right)
        #expect(Chirality.right.opposite == .left)
        #expect(Chirality.left.opposite.opposite == .left)
        #expect(Chirality.right.opposite.opposite == .right)
    }

    @Test
    func `Chirality negation operator`() {
        #expect(!Chirality.left == .right)
        #expect(!Chirality.right == .left)
        #expect(!(!Chirality.left) == .left)
    }

    @Test
    func `Chirality mirrored alias`() {
        #expect(Chirality.left.mirrored == .right)
        #expect(Chirality.right.mirrored == .left)
    }

    @Test
    func `Chirality coordinate system aliases`() {
        #expect(Chirality.standard == .right)
        #expect(Chirality.directX == .left)
    }

    @Test
    func `Chirality Value typealias`() {
        let tagged: Chirality.Value<String> = .init(tag: .left, value: "hand")
        #expect(tagged.tag == .left)
        #expect(tagged.value == "hand")
    }

    @Test
    func `Chirality Hashable`() {
        let set: Set<Chirality> = [.left, .right, .left]
        #expect(set.count == 2)
    }

    @Test
    func `Chirality Codable`() throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        let original = Chirality.right
        let data = try encoder.encode(original)
        let decoded = try decoder.decode(Chirality.self, from: data)
        #expect(decoded == original)
    }
}
