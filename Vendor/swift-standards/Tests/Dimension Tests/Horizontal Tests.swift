// Horizontal Tests.swift

import Algebra
import Testing

@testable import Dimension

@Suite
struct HorizontalTests {
    @Test
    func `Horizontal cases`() {
        let rightward: Horizontal = .rightward
        let leftward: Horizontal = .leftward
        #expect(rightward != leftward)
    }

    @Test
    func `Horizontal opposite`() {
        #expect(Horizontal.rightward.opposite == .leftward)
        #expect(Horizontal.leftward.opposite == .rightward)
    }

    @Test
    func `Horizontal negation operator`() {
        #expect(!Horizontal.rightward == .leftward)
        #expect(!Horizontal.leftward == .rightward)
        #expect(!(!Horizontal.rightward) == .rightward)
    }

    @Test
    func `Horizontal CaseIterable`() {
        #expect(Horizontal.allCases.count == 2)
        #expect(Horizontal.allCases.contains(.rightward))
        #expect(Horizontal.allCases.contains(.leftward))
    }

    @Test
    func `Horizontal Equatable`() {
        #expect(Horizontal.rightward == Horizontal.rightward)
        #expect(Horizontal.leftward == Horizontal.leftward)
        #expect(Horizontal.rightward != Horizontal.leftward)
    }

    @Test
    func `Horizontal Hashable`() {
        let set: Set<Horizontal> = [.rightward, .leftward, .rightward]
        #expect(set.count == 2)
    }
}

// MARK: - Horizontal.Value Struct Tests

@Suite
struct HorizontalValueTests {
    @Test
    func `Horizontal Value holds direction and value`() {
        let h = Horizontal.Value(direction: .rightward, value: 10.0)
        #expect(h.direction == .rightward)
        #expect(h.value == 10.0)
    }

    @Test
    func `Horizontal Value Equatable`() {
        let h1 = Horizontal.Value(direction: .rightward, value: 10.0)
        let h2 = Horizontal.Value(direction: .rightward, value: 10.0)
        let h3 = Horizontal.Value(direction: .leftward, value: 10.0)
        #expect(h1 == h2)
        #expect(h1 != h3)
    }
}

// MARK: - Axis.Horizontal Typealias Tests

@Suite
struct AxisHorizontalTypealiasTests {
    @Test
    func `Horizontal is same type across dimensions`() {
        let h2: Axis<2>.Horizontal = .rightward
        let h: Horizontal = .rightward
        let hLeft: Horizontal = .leftward

        // Both resolve to the same underlying Horizontal type
        #expect(h2 == h)
        #expect(h2 != hLeft)
    }

    @Test
    func `Axis Horizontal not available on Axis 1`() {
        // Axis<1>.Horizontal should not exist
        // This is a compile-time check
        let _: Axis<2>.Horizontal = .rightward
    }
}
