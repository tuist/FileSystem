// Algebra Tests.swift

import Testing

@testable import Algebra

// MARK: - Parity Tests

@Suite
struct ParityTests {
    @Test
    func `Parity cases`() {
        #expect(Parity.allCases.count == 2)
        #expect(Parity.allCases.contains(.even))
        #expect(Parity.allCases.contains(.odd))
    }

    @Test
    func `Parity opposite is involution`() {
        #expect(Parity.even.opposite == .odd)
        #expect(Parity.odd.opposite == .even)
        #expect(Parity.even.opposite.opposite == .even)
        #expect(Parity.odd.opposite.opposite == .odd)
    }

    @Test
    func `Parity negation operator`() {
        #expect(!Parity.even == .odd)
        #expect(!Parity.odd == .even)
        #expect(!(!Parity.even) == .even)
    }

    @Test
    func `Parity integer constructor`() {
        #expect(Parity(0) == .even)
        #expect(Parity(1) == .odd)
        #expect(Parity(2) == .even)
        #expect(Parity(-1) == .odd)
        #expect(Parity(-2) == .even)
        #expect(Parity(42) == .even)
        #expect(Parity(43) == .odd)
    }

    @Test
    func `Parity Value typealias`() {
        let tagged: Parity.Value<Int> = .init(tag: .even, value: 42)
        #expect(tagged.tag == .even)
        #expect(tagged.value == 42)
    }
}

// MARK: - Sign Tests

@Suite
struct SignTests {
    @Test
    func `Sign cases`() {
        #expect(Sign.allCases.count == 3)
        #expect(Sign.allCases.contains(.positive))
        #expect(Sign.allCases.contains(.negative))
        #expect(Sign.allCases.contains(.zero))
    }

    @Test
    func `Sign negated`() {
        #expect(Sign.positive.negated == .negative)
        #expect(Sign.negative.negated == .positive)
        #expect(Sign.zero.negated == .zero)
    }

    @Test
    func `Sign negation operator`() {
        #expect(-Sign.positive == .negative)
        #expect(-Sign.negative == .positive)
        #expect(-Sign.zero == .zero)
    }

    @Test
    func `Sign from integer`() {
        #expect(Sign(42) == .positive)
        #expect(Sign(-42) == .negative)
        #expect(Sign(0) == .zero)
    }

    @Test
    func `Sign from floating point`() {
        #expect(Sign(3.14) == .positive)
        #expect(Sign(-3.14) == .negative)
        #expect(Sign(0.0) == .zero)
    }

    @Test
    func `Sign multiplication`() {
        #expect(Sign.positive.multiplying(.positive) == .positive)
        #expect(Sign.positive.multiplying(.negative) == .negative)
        #expect(Sign.negative.multiplying(.negative) == .positive)
        #expect(Sign.zero.multiplying(.positive) == .zero)
        #expect(Sign.positive.multiplying(.zero) == .zero)
    }

    @Test
    func `Sign Value typealias`() {
        let tagged: Sign.Value<Double> = .init(tag: .positive, value: 3.14)
        #expect(tagged.tag == .positive)
        #expect(tagged.value == 3.14)
    }
}

// MARK: - Comparison Tests

@Suite
struct ComparisonTests {
    @Test
    func `Comparison cases`() {
        #expect(Comparison.allCases.count == 3)
        #expect(Comparison.allCases.contains(.less))
        #expect(Comparison.allCases.contains(.equal))
        #expect(Comparison.allCases.contains(.greater))
    }

    @Test
    func `Comparison reversed`() {
        #expect(Comparison.less.reversed == .greater)
        #expect(Comparison.greater.reversed == .less)
        #expect(Comparison.equal.reversed == .equal)
    }

    @Test
    func `Comparison negation operator`() {
        #expect(!Comparison.less == .greater)
        #expect(!Comparison.greater == .less)
        #expect(!Comparison.equal == .equal)
    }

    @Test
    func `Comparison from Comparable`() {
        #expect(Comparison(1, 2) == .less)
        #expect(Comparison(2, 2) == .equal)
        #expect(Comparison(3, 2) == .greater)

        #expect(Comparison("a", "b") == .less)
        #expect(Comparison("x", "x") == .equal)
    }

    @Test
    func `Comparison boolean properties`() {
        #expect(Comparison.less.isLess == true)
        #expect(Comparison.equal.isEqual == true)
        #expect(Comparison.greater.isGreater == true)
        #expect(Comparison.less.isLessOrEqual == true)
        #expect(Comparison.equal.isLessOrEqual == true)
        #expect(Comparison.greater.isLessOrEqual == false)
    }

    @Test
    func `Comparison Value typealias`() {
        let tagged: Comparison.Value<String> = .init(tag: .equal, value: "match")
        #expect(tagged.tag == .equal)
        #expect(tagged.value == "match")
    }
}

// MARK: - Bit Tests

@Suite
struct BitTests {
    @Test
    func `Bit cases`() {
        #expect(Bit.allCases.count == 2)
        #expect(Bit.allCases.contains(.zero))
        #expect(Bit.allCases.contains(.one))
    }

    @Test
    func `Bit flipped is involution`() {
        #expect(Bit.zero.flipped == .one)
        #expect(Bit.one.flipped == .zero)
        #expect(Bit.zero.flipped.flipped == .zero)
    }

    @Test
    func `Bit negation operator`() {
        #expect(!Bit.zero == .one)
        #expect(!Bit.one == .zero)
    }

    @Test
    func `Bit toggled alias`() {
        #expect(Bit.zero.toggled == .one)
        #expect(Bit.one.toggled == .zero)
    }

    @Test
    func `Bit from Bool`() {
        #expect(Bit(false) == .zero)
        #expect(Bit(true) == .one)
    }

    @Test
    func `Bit boolValue`() {
        #expect(Bit.zero.boolValue == false)
        #expect(Bit.one.boolValue == true)
    }

    @Test
    func `Bit value`() {
        // Bit is a UInt8 typealias, so it IS the value
        #expect(Bit.zero == 0)
        #expect(Bit.one == 1)
    }

    @Test
    func `Bit logical operations`() {
        #expect(Bit.one.and(.one) == .one)
        #expect(Bit.one.and(.zero) == .zero)
        #expect(Bit.zero.or(.one) == .one)
        #expect(Bit.zero.or(.zero) == .zero)
        #expect(Bit.one.xor(.one) == .zero)
        #expect(Bit.one.xor(.zero) == .one)
    }

    @Test
    func `Bit Value typealias`() {
        let tagged: Bit.Value<String> = .init(tag: .one, value: "set")
        #expect(tagged.tag == .one)
        #expect(tagged.value == "set")
    }
}

// MARK: - Ternary Tests

@Suite
struct TernaryTests {
    @Test
    func `Ternary cases`() {
        #expect(Ternary.allCases.count == 3)
        #expect(Ternary.allCases.contains(.negative))
        #expect(Ternary.allCases.contains(.zero))
        #expect(Ternary.allCases.contains(.positive))
    }

    @Test
    func `Ternary negated`() {
        #expect(Ternary.negative.negated == .positive)
        #expect(Ternary.positive.negated == .negative)
        #expect(Ternary.zero.negated == .zero)
    }

    @Test
    func `Ternary negation operator`() {
        #expect(-Ternary.negative == .positive)
        #expect(-Ternary.positive == .negative)
        #expect(-Ternary.zero == .zero)
    }

    @Test
    func `Ternary intValue`() {
        #expect(Ternary.negative.intValue == -1)
        #expect(Ternary.zero.intValue == 0)
        #expect(Ternary.positive.intValue == 1)
    }

    @Test
    func `Ternary from Sign`() {
        #expect(Ternary(Sign.negative) == .negative)
        #expect(Ternary(Sign.zero) == .zero)
        #expect(Ternary(Sign.positive) == .positive)
    }

    @Test
    func `Ternary multiplication`() {
        #expect(Ternary.positive.multiplying(.positive) == .positive)
        #expect(Ternary.positive.multiplying(.negative) == .negative)
        #expect(Ternary.negative.multiplying(.negative) == .positive)
        #expect(Ternary.zero.multiplying(.positive) == .zero)
    }

    @Test
    func `Ternary Value typealias`() {
        let tagged: Ternary.Value<Double> = .init(tag: .positive, value: 1.0)
        #expect(tagged.tag == .positive)
        #expect(tagged.value == 1.0)
    }
}

// MARK: - Phase Tests

@Suite
struct PhaseTests {
    @Test
    func `Phase cases`() {
        #expect(Phase.allCases.count == 4)
        #expect(Phase.allCases.contains(.zero))
        #expect(Phase.allCases.contains(.quarter))
        #expect(Phase.allCases.contains(.half))
        #expect(Phase.allCases.contains(.threeQuarter))
    }

    @Test
    func `Phase opposite is 180 degree rotation`() {
        #expect(Phase.zero.opposite == .half)
        #expect(Phase.quarter.opposite == .threeQuarter)
        #expect(Phase.half.opposite == .zero)
        #expect(Phase.threeQuarter.opposite == .quarter)
    }

    @Test
    func `Phase negation operator`() {
        #expect(!Phase.zero == .half)
        #expect(!Phase.half == .zero)
    }

    @Test
    func `Phase rotation forms Z4 group`() {
        // Next (90° counterclockwise)
        #expect(Phase.zero.next == .quarter)
        #expect(Phase.quarter.next == .half)
        #expect(Phase.half.next == .threeQuarter)
        #expect(Phase.threeQuarter.next == .zero)

        // Previous (90° clockwise)
        #expect(Phase.zero.previous == .threeQuarter)
        #expect(Phase.quarter.previous == .zero)
        #expect(Phase.half.previous == .quarter)
        #expect(Phase.threeQuarter.previous == .half)

        // Four rotations return to start
        var phase = Phase.zero
        phase = phase.next.next.next.next
        #expect(phase == .zero)
    }

    @Test
    func `Phase composition`() {
        #expect(Phase.zero.composed(with: .quarter) == .quarter)
        #expect(Phase.quarter.composed(with: .quarter) == .half)
        #expect(Phase.half.composed(with: .half) == .zero)
    }

    @Test
    func `Phase inverse`() {
        #expect(Phase.zero.inverse == .zero)
        #expect(Phase.quarter.inverse == .threeQuarter)
        #expect(Phase.half.inverse == .half)
        #expect(Phase.threeQuarter.inverse == .quarter)
    }

    @Test
    func `Phase degrees`() {
        #expect(Phase.zero.degrees == 0)
        #expect(Phase.quarter.degrees == 90)
        #expect(Phase.half.degrees == 180)
        #expect(Phase.threeQuarter.degrees == 270)
    }

    @Test
    func `Phase Value typealias`() {
        let tagged: Phase.Value<Int> = .init(tag: .quarter, value: 90)
        #expect(tagged.tag == .quarter)
        #expect(tagged.value == 90)
    }
}

// MARK: - Bound Tests

@Suite
struct BoundTests {
    @Test
    func `Bound cases`() {
        #expect(Bound.allCases.count == 2)
        #expect(Bound.allCases.contains(.lower))
        #expect(Bound.allCases.contains(.upper))
    }

    @Test
    func `Bound opposite is involution`() {
        #expect(Bound.lower.opposite == .upper)
        #expect(Bound.upper.opposite == .lower)
        #expect(Bound.lower.opposite.opposite == .lower)
    }

    @Test
    func `Bound negation operator`() {
        #expect(!Bound.lower == .upper)
        #expect(!Bound.upper == .lower)
    }

    @Test
    func `Bound Value typealias`() {
        let tagged: Bound.Value<Int> = .init(tag: .lower, value: 0)
        #expect(tagged.tag == .lower)
        #expect(tagged.value == 0)
    }
}

// MARK: - Boundary Tests

@Suite
struct BoundaryTests {
    @Test
    func `Boundary cases`() {
        #expect(Boundary.allCases.count == 2)
        #expect(Boundary.allCases.contains(.open))
        #expect(Boundary.allCases.contains(.closed))
    }

    @Test
    func `Boundary opposite is involution`() {
        #expect(Boundary.open.opposite == .closed)
        #expect(Boundary.closed.opposite == .open)
        #expect(Boundary.open.opposite.opposite == .open)
    }

    @Test
    func `Boundary negation operator`() {
        #expect(!Boundary.open == .closed)
        #expect(!Boundary.closed == .open)
    }

    @Test
    func `Boundary isInclusive and isExclusive`() {
        #expect(Boundary.closed.isInclusive == true)
        #expect(Boundary.open.isInclusive == false)
        #expect(Boundary.open.isExclusive == true)
        #expect(Boundary.closed.isExclusive == false)
    }

    @Test
    func `Boundary Value typealias`() {
        let tagged: Boundary.Value<Double> = .init(tag: .closed, value: 1.0)
        #expect(tagged.tag == .closed)
        #expect(tagged.value == 1.0)
    }
}

// MARK: - Endpoint Tests

@Suite
struct EndpointTests {
    @Test
    func `Endpoint cases`() {
        #expect(Endpoint.allCases.count == 2)
        #expect(Endpoint.allCases.contains(.start))
        #expect(Endpoint.allCases.contains(.end))
    }

    @Test
    func `Endpoint opposite is involution`() {
        #expect(Endpoint.start.opposite == .end)
        #expect(Endpoint.end.opposite == .start)
        #expect(Endpoint.start.opposite.opposite == .start)
    }

    @Test
    func `Endpoint negation operator`() {
        #expect(!Endpoint.start == .end)
        #expect(!Endpoint.end == .start)
    }

    @Test
    func `Endpoint Value typealias`() {
        let tagged: Endpoint.Value<String> = .init(tag: .start, value: "begin")
        #expect(tagged.tag == .start)
        #expect(tagged.value == "begin")
    }
}

// MARK: - Monotonicity Tests

@Suite
struct MonotonicityTests {
    @Test
    func `Monotonicity cases`() {
        #expect(Monotonicity.allCases.count == 3)
        #expect(Monotonicity.allCases.contains(.increasing))
        #expect(Monotonicity.allCases.contains(.decreasing))
        #expect(Monotonicity.allCases.contains(.constant))
    }

    @Test
    func `Monotonicity reversed`() {
        #expect(Monotonicity.increasing.reversed == .decreasing)
        #expect(Monotonicity.decreasing.reversed == .increasing)
        #expect(Monotonicity.constant.reversed == .constant)
    }

    @Test
    func `Monotonicity negation operator`() {
        #expect(!Monotonicity.increasing == .decreasing)
        #expect(!Monotonicity.decreasing == .increasing)
        #expect(!Monotonicity.constant == .constant)
    }

    @Test
    func `Monotonicity composition`() {
        #expect(Monotonicity.increasing.composing(.increasing) == .increasing)
        #expect(Monotonicity.increasing.composing(.decreasing) == .decreasing)
        #expect(Monotonicity.decreasing.composing(.decreasing) == .increasing)
        #expect(Monotonicity.constant.composing(.increasing) == .constant)
    }

    @Test
    func `Monotonicity boolean properties`() {
        #expect(Monotonicity.increasing.isIncreasing == true)
        #expect(Monotonicity.decreasing.isDecreasing == true)
        #expect(Monotonicity.constant.isConstant == true)
        #expect(Monotonicity.increasing.isNonDecreasing == true)
        #expect(Monotonicity.constant.isNonDecreasing == true)
    }

    @Test
    func `Monotonicity Value typealias`() {
        let tagged: Monotonicity.Value<String> = .init(tag: .increasing, value: "growth")
        #expect(tagged.tag == .increasing)
        #expect(tagged.value == "growth")
    }
}

// MARK: - Gradient Tests

@Suite
struct GradientTests {
    @Test
    func `Gradient cases`() {
        #expect(Gradient.allCases.count == 2)
        #expect(Gradient.allCases.contains(.ascending))
        #expect(Gradient.allCases.contains(.descending))
    }

    @Test
    func `Gradient opposite is involution`() {
        #expect(Gradient.ascending.opposite == .descending)
        #expect(Gradient.descending.opposite == .ascending)
        #expect(Gradient.ascending.opposite.opposite == .ascending)
    }

    @Test
    func `Gradient negation operator`() {
        #expect(!Gradient.ascending == .descending)
        #expect(!Gradient.descending == .ascending)
    }

    @Test
    func `Gradient Value typealias`() {
        let tagged: Gradient.Value<Double> = .init(tag: .ascending, value: 0.5)
        #expect(tagged.tag == .ascending)
        #expect(tagged.value == 0.5)
    }
}

// MARK: - Polarity Tests

@Suite
struct PolarityTests {
    @Test
    func `Polarity cases`() {
        #expect(Polarity.allCases.count == 3)
        #expect(Polarity.allCases.contains(.positive))
        #expect(Polarity.allCases.contains(.negative))
        #expect(Polarity.allCases.contains(.neutral))
    }

    @Test
    func `Polarity opposite`() {
        #expect(Polarity.positive.opposite == .negative)
        #expect(Polarity.negative.opposite == .positive)
        #expect(Polarity.neutral.opposite == .neutral)
    }

    @Test
    func `Polarity negation operator`() {
        #expect(!Polarity.positive == .negative)
        #expect(!Polarity.negative == .positive)
        #expect(!Polarity.neutral == .neutral)
    }

    @Test
    func `Polarity Value typealias`() {
        let tagged: Polarity.Value<Int> = .init(tag: .positive, value: 1)
        #expect(tagged.tag == .positive)
        #expect(tagged.value == 1)
    }
}
