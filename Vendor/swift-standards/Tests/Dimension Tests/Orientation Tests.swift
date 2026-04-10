// Orientation Tests.swift

import Testing

@testable import Dimension

@Suite
struct OrientationTests {
    // MARK: - Protocol Requirements

    @Test
    func `All orientation types conform to Orientation`() {
        func checkOrientation<T: Orientation>(_: T.Type) {
            #expect(T.allCases.count == 2)
        }

        checkOrientation(Direction.self)
        checkOrientation(Horizontal.self)
        checkOrientation(Vertical.self)
        checkOrientation(Depth.self)
        checkOrientation(Temporal.self)
    }

    @Test
    func `Opposite is an involution`() {
        func checkInvolution<T: Orientation>(_ value: T) {
            #expect(value.opposite.opposite == value)
            #expect(!(!value) == value)
        }

        checkInvolution(Direction.positive)
        checkInvolution(Direction.negative)
        checkInvolution(Horizontal.rightward)
        checkInvolution(Horizontal.leftward)
        checkInvolution(Vertical.upward)
        checkInvolution(Vertical.downward)
        checkInvolution(Depth.forward)
        checkInvolution(Depth.backward)
        checkInvolution(Temporal.future)
        checkInvolution(Temporal.past)
    }

    // MARK: - Isomorphisms via Direction

    @Test
    func `All orientations are isomorphic to Direction`() {
        // positive → domain-specific "positive"
        #expect(Horizontal(direction: .positive) == .rightward)
        #expect(Vertical(direction: .positive) == .upward)
        #expect(Depth(direction: .positive) == .forward)
        #expect(Temporal(direction: .positive) == .future)

        // negative → domain-specific "negative"
        #expect(Horizontal(direction: .negative) == .leftward)
        #expect(Vertical(direction: .negative) == .downward)
        #expect(Depth(direction: .negative) == .backward)
        #expect(Temporal(direction: .negative) == .past)
    }

    @Test
    func `Direction property recovers the underlying direction`() {
        #expect(Horizontal.rightward.direction == .positive)
        #expect(Horizontal.leftward.direction == .negative)
        #expect(Vertical.upward.direction == .positive)
        #expect(Vertical.downward.direction == .negative)
        #expect(Depth.forward.direction == .positive)
        #expect(Depth.backward.direction == .negative)
        #expect(Temporal.future.direction == .positive)
        #expect(Temporal.past.direction == .negative)
    }

    @Test
    func `Round-trip through Direction preserves value`() {
        func checkRoundTrip<T: Orientation>(_ value: T) {
            let dir = value.direction
            let back = T(direction: dir)
            #expect(back == value)
        }

        checkRoundTrip(Horizontal.rightward)
        checkRoundTrip(Horizontal.leftward)
        checkRoundTrip(Vertical.upward)
        checkRoundTrip(Vertical.downward)
        checkRoundTrip(Depth.forward)
        checkRoundTrip(Depth.backward)
        checkRoundTrip(Temporal.future)
        checkRoundTrip(Temporal.past)
    }

    // MARK: - Bool Isomorphism

    @Test
    func `Orientation from Bool`() {
        #expect(Direction(true) == .positive)
        #expect(Direction(false) == .negative)
        #expect(Horizontal(true) == .rightward)
        #expect(Horizontal(false) == .leftward)
    }

    @Test
    func `isPositive and isNegative`() {
        #expect(Direction.positive.isPositive)
        #expect(!Direction.positive.isNegative)
        #expect(Direction.negative.isNegative)
        #expect(!Direction.negative.isPositive)

        #expect(Horizontal.rightward.isPositive)
        #expect(Horizontal.leftward.isNegative)
    }

    // MARK: - Generic Algorithms

    @Test
    func `Generic function works on any Orientation`() {
        func flip<T: Orientation>(_ orientation: T) -> T {
            !orientation
        }

        #expect(flip(Direction.positive) == .negative)
        #expect(flip(Horizontal.rightward) == .leftward)
        #expect(flip(Vertical.upward) == .downward)
        #expect(flip(Depth.forward) == .backward)
        #expect(flip(Temporal.future) == .past)
    }

    @Test
    func `Convert between orientation types via Direction`() {
        func convert<From: Orientation, To: Orientation>(
            _ from: From,
            to _: To.Type
        ) -> To {
            To(direction: from.direction)
        }

        let horizontal: Horizontal = .rightward
        let vertical: Vertical = convert(horizontal, to: Vertical.self)
        #expect(vertical == .upward)

        let depth: Depth = convert(vertical, to: Depth.self)
        #expect(depth == .forward)
    }
}

// MARK: - Sum ↔ Product Duality

@Suite
struct SumProductDualityTests {
    @Test
    func `Enum Direction and struct orientations are isomorphic`() {
        // Direction is the canonical (initial) orientation
        // Other types interpret it in domain-specific contexts

        // The isomorphism: Direction ≅ Horizontal ≅ Vertical ≅ Depth ≅ Temporal
        for dir in Direction.allCases {
            let h = Horizontal(direction: dir)
            let v = Vertical(direction: dir)
            let d = Depth(direction: dir)
            let t = Temporal(direction: dir)

            // All map back to the same Direction
            #expect(h.direction == dir)
            #expect(v.direction == dir)
            #expect(d.direction == dir)
            #expect(t.direction == dir)
        }
    }

    @Test
    func `Struct wrapping enables composition`() {
        // Because Horizontal wraps Direction, we can compose operations
        let h: Horizontal = .rightward

        // Access the underlying direction
        let dir = h.direction
        #expect(dir == .positive)

        // Use Direction's sign property
        #expect(h.direction.sign == 1)
        #expect(Horizontal.leftward.direction.sign == -1)
    }
}
