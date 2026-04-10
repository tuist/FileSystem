// Comparable Tests.swift
// swift-standards
//
// Tests for Comparable extensions

import Testing

@testable import StandardLibraryExtensions

@Suite
struct `Comparable Clamping` {

    // MARK: - Values within range

    @Test
    func `Clamping value within range returns value`() {
        #expect(5.clamped(to: 0...10) == 5)
        #expect(0.clamped(to: 0...10) == 0)
        #expect(10.clamped(to: 0...10) == 10)
    }

    @Test
    func `Clamping at exact boundaries`() {
        #expect(0.clamped(to: 0...100) == 0)
        #expect(100.clamped(to: 0...100) == 100)
        #expect((-5).clamped(to: -5...5) == -5)
        #expect(5.clamped(to: -5...5) == 5)
    }

    // MARK: - Values outside range

    @Test
    func `Clamping value above range returns upper bound`() {
        #expect(15.clamped(to: 0...10) == 10)
        #expect(100.clamped(to: 0...10) == 10)
        #expect(1000.clamped(to: 0...10) == 10)
    }

    @Test
    func `Clamping value below range returns lower bound`() {
        #expect((-5).clamped(to: 0...10) == 0)
        #expect((-100).clamped(to: 0...10) == 0)
        #expect((-1000).clamped(to: 0...10) == 0)
    }

    // MARK: - Different numeric types

    @Test
    func `Clamping with Double`() {
        #expect(5.5.clamped(to: 0.0...10.0) == 5.5)
        #expect(15.5.clamped(to: 0.0...10.0) == 10.0)
        #expect((-5.5).clamped(to: 0.0...10.0) == 0.0)
    }

    @Test
    func `Clamping with Float`() {
        let value: Float = 5.5
        let clamped = value.clamped(to: 0.0...10.0)
        #expect(clamped == 5.5)
    }

    @Test
    func `Clamping with UInt8`() {
        let value: UInt8 = 200
        #expect(value.clamped(to: 0...100) == 100)
        #expect(UInt8(50).clamped(to: 0...100) == 50)
    }

    @Test
    func `Clamping with Int16`() {
        let value: Int16 = 1000
        #expect(value.clamped(to: -100...100) == 100)
        #expect(Int16(-500).clamped(to: -100...100) == -100)
    }

    // MARK: - Single value range

    @Test
    func `Clamping to single value range`() {
        #expect(5.clamped(to: 7...7) == 7)
        #expect(10.clamped(to: 7...7) == 7)
        #expect(0.clamped(to: 7...7) == 7)
    }

    // MARK: - String clamping (lexicographic order)

    @Test
    func `Clamping strings lexicographically`() {
        #expect("dog".clamped(to: "cat"..."zebra") == "dog")
        #expect("apple".clamped(to: "cat"..."zebra") == "cat")
        #expect("zoo".clamped(to: "cat"..."zebra") == "zebra")
    }

    // MARK: - Character clamping

    @Test
    func `Clamping characters`() {
        let char: Character = "m"
        #expect(char.clamped(to: "a"..."z") == "m")
        #expect(Character("5").clamped(to: "a"..."z") == "a")
        #expect(Character("~").clamped(to: "a"..."z") == "z")
    }

    // MARK: - Category theory properties

    @Test
    func `Order preservation - monotonicity`() {
        // ∀x,y ∈ T: x ≤ y ⟹ clamp(x) ≤ clamp(y)
        let range = 0...10

        let x = 3
        let y = 7
        #expect(x <= y)
        #expect(x.clamped(to: range) <= y.clamped(to: range))

        // Test with values outside range
        let a = -5
        let b = 15
        #expect(a <= b)
        #expect(a.clamped(to: range) <= b.clamped(to: range))
    }

    @Test
    func `Codomain restriction property`() {
        // ∀x ∈ T: a ≤ clamp(x) ≤ b
        let range = 0...10

        for value in [-100, -10, -1, 0, 5, 10, 11, 100] {
            let clamped = value.clamped(to: range)
            #expect(clamped >= range.lowerBound)
            #expect(clamped <= range.upperBound)
        }
    }

    @Test
    func `Identity morphism for values in range`() {
        // ∀x ∈ [a,b]: clamp(x) = x
        let range = 0...10

        for value in 0...10 {
            #expect(value.clamped(to: range) == value)
        }
    }

    @Test
    func `Idempotence property`() {
        // clamp(clamp(x)) = clamp(x)
        let range = 0...10

        for value in [-100, -10, 0, 5, 10, 100] {
            let onceClamped = value.clamped(to: range)
            let twiceClamped = onceClamped.clamped(to: range)
            #expect(onceClamped == twiceClamped)
        }
    }

    // MARK: - Edge cases

    @Test
    func `Clamping extreme values`() {
        #expect(Int.max.clamped(to: 0...100) == 100)
        #expect(Int.min.clamped(to: 0...100) == 0)
        #expect(Int.min.clamped(to: -100...100) == -100)
    }

    @Test
    func `Clamping with negative ranges`() {
        #expect((-3).clamped(to: -10...(-5)) == -5)
        #expect((-15).clamped(to: -10...(-5)) == -10)
        #expect(0.clamped(to: -10...(-5)) == -5)
    }
}
