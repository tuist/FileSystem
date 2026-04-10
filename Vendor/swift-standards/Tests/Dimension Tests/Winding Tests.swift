// Winding Tests.swift

import Algebra
import Foundation
import Testing

@testable import Dimension

@Suite
struct WindingTests {
    @Test
    func `Winding cases`() {
        #expect(Winding.allCases.count == 2)
        #expect(Winding.allCases.contains(.clockwise))
        #expect(Winding.allCases.contains(.counterclockwise))
    }

    @Test
    func `Winding opposite is involution`() {
        #expect(Winding.clockwise.opposite == .counterclockwise)
        #expect(Winding.counterclockwise.opposite == .clockwise)
        #expect(Winding.clockwise.opposite.opposite == .clockwise)
        #expect(Winding.counterclockwise.opposite.opposite == .counterclockwise)
    }

    @Test
    func `Winding negation operator`() {
        #expect(!Winding.clockwise == .counterclockwise)
        #expect(!Winding.counterclockwise == .clockwise)
        #expect(!(!Winding.clockwise) == .clockwise)
    }

    @Test
    func `Winding aliases`() {
        #expect(Winding.cw == .clockwise)
        #expect(Winding.ccw == .counterclockwise)
    }

    @Test
    func `Winding Value typealias`() {
        let tagged: Winding.Value<Double> = .init(tag: .clockwise, value: .pi)
        #expect(tagged.tag == .clockwise)
        #expect(tagged.value == .pi)
    }

    @Test
    func `Winding Hashable`() {
        let set: Set<Winding> = [.clockwise, .counterclockwise, .clockwise]
        #expect(set.count == 2)
    }

    @Test
    func `Winding Codable`() throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        let original = Winding.clockwise
        let data = try encoder.encode(original)
        let decoded = try decoder.decode(Winding.self, from: data)
        #expect(decoded == original)
    }
}
