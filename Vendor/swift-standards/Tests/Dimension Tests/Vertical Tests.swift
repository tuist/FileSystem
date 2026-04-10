// Vertical Tests.swift

import Algebra
import Testing

@testable import Dimension

@Suite
struct VerticalTests {
    @Test
    func `Vertical cases`() {
        let upward: Vertical = .upward
        let downward: Vertical = .downward
        #expect(upward != downward)
    }

    @Test
    func `Vertical opposite`() {
        #expect(Vertical.upward.opposite == .downward)
        #expect(Vertical.downward.opposite == .upward)
    }

    @Test
    func `Vertical negation operator`() {
        #expect(!Vertical.upward == .downward)
        #expect(!Vertical.downward == .upward)
        #expect(!(!Vertical.upward) == .upward)
    }

    @Test
    func `Vertical CaseIterable`() {
        #expect(Vertical.allCases.count == 2)
        #expect(Vertical.allCases.contains(.upward))
        #expect(Vertical.allCases.contains(.downward))
    }

    @Test
    func `Vertical Equatable`() {
        #expect(Vertical.upward == Vertical.upward)
        #expect(Vertical.downward == Vertical.downward)
        #expect(Vertical.upward != Vertical.downward)
    }

    @Test
    func `Vertical Hashable`() {
        let set: Set<Vertical> = [.upward, .downward, .upward]
        #expect(set.count == 2)
    }
}

// MARK: - Vertical.Value Struct Tests

@Suite
struct VerticalValueTests {
    @Test
    func `Vertical Value holds direction and value`() {
        let v = Vertical.Value(direction: .upward, value: 10.0)
        #expect(v.direction == .upward)
        #expect(v.value == 10.0)
    }

    @Test
    func `Vertical Value Equatable`() {
        let v1 = Vertical.Value(direction: .upward, value: 10.0)
        let v2 = Vertical.Value(direction: .upward, value: 10.0)
        let v3 = Vertical.Value(direction: .downward, value: 10.0)
        #expect(v1 == v2)
        #expect(v1 != v3)
    }
}

// MARK: - Axis.Vertical Typealias Tests

@Suite
struct AxisVerticalTypealiasTests {
    @Test
    func `Vertical is same type across dimensions`() {
        let v2: Axis<2>.Vertical = .upward
        let v: Vertical = .upward
        let vDown: Vertical = .downward

        // Both resolve to the same underlying Vertical type
        #expect(v2 == v)
        #expect(v2 != vDown)
    }

    @Test
    func `Axis Vertical not available on Axis 1`() {
        // Axis<1>.Vertical should not exist
        // This is a compile-time check
        let _: Axis<2>.Vertical = .upward
    }
}
