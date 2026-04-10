// Axis Tests.swift

import Algebra
import Testing

@testable import Dimension

// MARK: - Axis Tests

@Suite
struct AxisTests {
    @Test
    func `Axis 1D primary only`() {
        #expect(Axis<1>.primary.rawValue == 0)
        #expect(Axis<1>.allCases.count == 1)
    }

    @Test
    func `Axis 2D primary secondary`() {
        #expect(Axis<2>.primary.rawValue == 0)
        #expect(Axis<2>.secondary.rawValue == 1)
        #expect(Axis<2>.allCases.count == 2)
    }

    @Test
    func `Axis 3D primary secondary tertiary`() {
        #expect(Axis<3>.primary.rawValue == 0)
        #expect(Axis<3>.secondary.rawValue == 1)
        #expect(Axis<3>.tertiary.rawValue == 2)
        #expect(Axis<3>.allCases.count == 3)
    }

    @Test
    func `Axis 4D includes quaternary`() {
        #expect(Axis<4>.primary.rawValue == 0)
        #expect(Axis<4>.secondary.rawValue == 1)
        #expect(Axis<4>.tertiary.rawValue == 2)
        #expect(Axis<4>.quaternary.rawValue == 3)
        #expect(Axis<4>.allCases.count == 4)
    }

    @Test
    func `Axis perpendicular 2D only`() {
        #expect(Axis<2>.primary.perpendicular == .secondary)
        #expect(Axis<2>.secondary.perpendicular == .primary)
    }

    @Test
    func `Axis init bounds checking`() {
        #expect(Axis<1>(0) != nil)
        #expect(Axis<1>(1) == nil)

        #expect(Axis<2>(0) != nil)
        #expect(Axis<2>(1) != nil)
        #expect(Axis<2>(2) == nil)
        #expect(Axis<2>(-1) == nil)

        #expect(Axis<3>(2) != nil)
        #expect(Axis<3>(3) == nil)

        #expect(Axis<4>(3) != nil)
        #expect(Axis<4>(4) == nil)
    }

    @Test
    func `Axis Equatable`() {
        #expect(Axis<2>.primary == Axis<2>.primary)
        #expect(Axis<2>.primary != Axis<2>.secondary)
        #expect(Axis<3>.tertiary == Axis<3>.tertiary)
    }

    @Test
    func `Axis Hashable`() {
        let set: Set<Axis<3>> = [.primary, .secondary, .tertiary, .primary]
        #expect(set.count == 3)
    }

    /// Axis<N> types are distinct across dimensions - this is correct behavior.
    ///
    /// An axis in 2D space is fundamentally different from an axis in 3D space.
    /// Axis<2> has 2 possible values, Axis<3> has 3, etc.
    @Test
    func `Axis types are distinct across dimensions`() {
        let axis2: Axis<2> = .primary
        let axis3: Axis<3> = .primary

        // They have the same rawValue...
        #expect(axis2.rawValue == axis3.rawValue)

        // ...but are not directly comparable (this would not compile):
        // let same: Bool = (axis2 == axis3)  // Error: different types

        // This is the INTENDED behavior - dimensional safety
    }

    @Test
    func `Function accepting Axis of specific dimension`() {
        // This demonstrates type safety - you can't pass Axis<3> where Axis<2> is expected
        func process2D(_ axis: Axis<2>) -> Int {
            axis.rawValue
        }

        let axis2: Axis<2> = .secondary
        #expect(process2D(axis2) == 1)

        // This would NOT compile - type safety prevents dimensional mismatch:
        // let axis3: Axis<3> = .secondary
        // process2D(axis3)  // Error: cannot convert Axis<3> to Axis<2>
    }
}
