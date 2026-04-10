// Direction Tests.swift

import Testing

@testable import Dimension

// MARK: - Direction Tests

@Suite
struct DirectionTests {
    @Test
    func `Direction cases`() {
        let positive: Direction = .positive
        let negative: Direction = .negative
        #expect(positive != negative)
    }

    @Test
    func `Direction opposite`() {
        #expect(Direction.positive.opposite == .negative)
        #expect(Direction.negative.opposite == .positive)
    }

    @Test
    func `Direction negation operator`() {
        #expect(!Direction.positive == .negative)
        #expect(!Direction.negative == .positive)
        #expect(!(!Direction.positive) == .positive)
    }

    @Test
    func `Direction sign Int`() {
        #expect(Direction.positive.sign == 1)
        #expect(Direction.negative.sign == -1)
    }

    @Test
    func `Direction CaseIterable`() {
        #expect(Direction.allCases.count == 2)
        #expect(Direction.allCases.contains(.positive))
        #expect(Direction.allCases.contains(.negative))
    }

    @Test
    func `Direction Equatable`() {
        #expect(Direction.positive == Direction.positive)
        #expect(Direction.negative == Direction.negative)
        #expect(Direction.positive != Direction.negative)
    }

    @Test
    func `Direction Hashable`() {
        let set: Set<Direction> = [.positive, .negative, .positive]
        #expect(set.count == 2)
    }
}

// MARK: - Axis.Direction Typealias Tests

@Suite
struct AxisDirectionTypealiasTests {
    /// Direction is dimension-independent - same type across all Axis<N>.
    ///
    /// Mathematically, direction along an axis is just a sign (+1 or -1), which is
    /// the same concept regardless of the dimension of the space.
    @Test
    func `Direction is same type across all dimensions`() {
        let dir2: Axis<2>.Direction = .positive
        let dir3: Axis<3>.Direction = .positive
        let dir4: Axis<4>.Direction = .negative

        // These ARE the same type (via typealias to Direction)
        #expect(dir2 == dir3)
        #expect(dir2 != dir4)

        // Can use Direction directly
        let dir: Direction = .positive
        #expect(dir == dir2)
        #expect(dir == dir3)
    }

    @Test
    func `Axis Direction accessed via any dimension`() {
        // All of these resolve to the same Direction type
        let dir1: Axis<1>.Direction = .positive
        let dir2: Axis<2>.Direction = .positive
        let dir3: Axis<3>.Direction = .positive
        let dir4: Axis<4>.Direction = .positive

        #expect(dir1 == dir2)
        #expect(dir2 == dir3)
        #expect(dir3 == dir4)

        // Opposite works the same way
        #expect(dir1.opposite == Direction.negative)
        #expect(dir2.opposite == Direction.negative)
    }

    @Test
    func `Axis Direction has all Direction functionality`() {
        // Accessed via Axis<N>.Direction, but same underlying type
        let dir: Axis<2>.Direction = .negative

        #expect(dir.sign == -1)
        #expect(Double(dir.sign) == -1.0)
        #expect(dir.opposite == .positive)
    }
}
