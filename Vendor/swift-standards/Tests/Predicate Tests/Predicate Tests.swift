// Predicate Tests.swift
// Tests for Predicate<T> type and composition operators.

import Testing

@testable import Predicate

// MARK: - Basic Tests

@Suite
struct PredicateBasicTests {
    @Test
    func `Predicate creation and evaluation`() {
        let isEven = Predicate<Int> { $0 % 2 == 0 }

        #expect(isEven(4) == true)
        #expect(isEven(3) == false)
        #expect(isEven.evaluate(4) == true)
    }

    @Test
    func `Predicate always`() {
        let always = Predicate<Int>.always

        #expect(always(0) == true)
        #expect(always(100) == true)
        #expect(always(-50) == true)
    }

    @Test
    func `Predicate never`() {
        let never = Predicate<Int>.never

        #expect(never(0) == false)
        #expect(never(100) == false)
        #expect(never(-50) == false)
    }
}

// MARK: - AND Tests

@Suite
struct PredicateANDTests {
    let isEven = Predicate<Int> { $0 % 2 == 0 }
    let isPositive = Predicate<Int> { $0 > 0 }

    @Test
    func `AND combines predicates`() {
        let isEvenAndPositive = isEven && isPositive

        #expect(isEvenAndPositive(4) == true)  // even and positive
        #expect(isEvenAndPositive(3) == false)  // odd
        #expect(isEvenAndPositive(-4) == false)  // negative
        #expect(isEvenAndPositive(-3) == false)  // odd and negative
    }

    @Test
    func `AND fluent method`() {
        let isEvenAndPositive = isEven.and(isPositive)

        #expect(isEvenAndPositive(4) == true)
        #expect(isEvenAndPositive(-4) == false)
    }

    @Test
    func `AND is commutative`() {
        let p1 = isEven && isPositive
        let p2 = isPositive && isEven

        for n in -10...10 {
            #expect(p1(n) == p2(n))
        }
    }

    @Test
    func `AND is associative`() {
        let greaterThan5 = Predicate<Int> { $0 > 5 }

        let p1 = (isEven && isPositive) && greaterThan5
        let p2 = isEven && (isPositive && greaterThan5)

        for n in -10...20 {
            #expect(p1(n) == p2(n))
        }
    }

    @Test
    func `AND identity`() {
        // p && .always == p
        let p = isEven && .always

        for n in -10...10 {
            #expect(p(n) == isEven(n))
        }
    }

    @Test
    func `AND annihilator`() {
        // p && .never == .never
        let p = isEven && .never

        for n in -10...10 {
            #expect(p(n) == false)
        }
    }
}

// MARK: - OR Tests

@Suite
struct PredicateORTests {
    let isEven = Predicate<Int> { $0 % 2 == 0 }
    let isNegative = Predicate<Int> { $0 < 0 }

    @Test
    func `OR combines predicates`() {
        let isEvenOrNegative = isEven || isNegative

        #expect(isEvenOrNegative(4) == true)  // even
        #expect(isEvenOrNegative(-3) == true)  // negative
        #expect(isEvenOrNegative(-4) == true)  // both
        #expect(isEvenOrNegative(3) == false)  // neither
    }

    @Test
    func `OR fluent method`() {
        let isEvenOrNegative = isEven.or(isNegative)

        #expect(isEvenOrNegative(4) == true)
        #expect(isEvenOrNegative(3) == false)
    }

    @Test
    func `OR is commutative`() {
        let p1 = isEven || isNegative
        let p2 = isNegative || isEven

        for n in -10...10 {
            #expect(p1(n) == p2(n))
        }
    }

    @Test
    func `OR is associative`() {
        let isZero = Predicate<Int> { $0 == 0 }

        let p1 = (isEven || isNegative) || isZero
        let p2 = isEven || (isNegative || isZero)

        for n in -10...10 {
            #expect(p1(n) == p2(n))
        }
    }

    @Test
    func `OR identity`() {
        // p || .never == p
        let p = isEven || .never

        for n in -10...10 {
            #expect(p(n) == isEven(n))
        }
    }

    @Test
    func `OR annihilator`() {
        // p || .always == .always
        let p = isEven || .always

        for n in -10...10 {
            #expect(p(n) == true)
        }
    }
}

// MARK: - NOT Tests

@Suite
struct PredicateNOTTests {
    let isEven = Predicate<Int> { $0 % 2 == 0 }

    @Test
    func `NOT negates predicate`() {
        let isOdd = !isEven

        #expect(isOdd(3) == true)
        #expect(isOdd(4) == false)
    }

    @Test
    func `NOT fluent property`() {
        let isOdd = isEven.negated

        #expect(isOdd(3) == true)
        #expect(isOdd(4) == false)
    }

    @Test
    func `NOT is involution`() {
        let doubleNegated = !(!isEven)

        for n in -10...10 {
            #expect(doubleNegated(n) == isEven(n))
        }
    }

    @Test
    func `NOT complement law`() {
        // p && !p == .never
        let contradiction = isEven && !isEven

        for n in -10...10 {
            #expect(contradiction(n) == false)
        }
    }

    @Test
    func `NOT tautology law`() {
        // p || !p == .always
        let tautology = isEven || !isEven

        for n in -10...10 {
            #expect(tautology(n) == true)
        }
    }
}

// MARK: - XOR Tests

@Suite
struct PredicateXORTests {
    let isEven = Predicate<Int> { $0 % 2 == 0 }
    let isPositive = Predicate<Int> { $0 > 0 }

    @Test
    func `XOR returns true when exactly one is true`() {
        let isEvenXorPositive = isEven ^ isPositive

        #expect(isEvenXorPositive(4) == false)  // both true
        #expect(isEvenXorPositive(3) == true)  // positive only
        #expect(isEvenXorPositive(-4) == true)  // even only
        #expect(isEvenXorPositive(-3) == false)  // neither
    }

    @Test
    func `XOR fluent method`() {
        let isEvenXorPositive = isEven.xor(isPositive)

        #expect(isEvenXorPositive(4) == false)
        #expect(isEvenXorPositive(3) == true)
    }

    @Test
    func `XOR is commutative`() {
        let p1 = isEven ^ isPositive
        let p2 = isPositive ^ isEven

        for n in -10...10 {
            #expect(p1(n) == p2(n))
        }
    }

    @Test
    func `XOR is associative`() {
        let isSmall = Predicate<Int> { abs($0) < 5 }

        let p1 = (isEven ^ isPositive) ^ isSmall
        let p2 = isEven ^ (isPositive ^ isSmall)

        for n in -10...10 {
            #expect(p1(n) == p2(n))
        }
    }
}

// MARK: - NAND / NOR Tests

@Suite
struct PredicateNANDNORTests {
    let isEven = Predicate<Int> { $0 % 2 == 0 }
    let isPositive = Predicate<Int> { $0 > 0 }

    @Test
    func `NAND is negation of AND`() {
        let nand = isEven.nand(isPositive)
        let notAnd = !(isEven && isPositive)

        for n in -10...10 {
            #expect(nand(n) == notAnd(n))
        }
    }

    @Test
    func `NOR is negation of OR`() {
        let nor = isEven.nor(isPositive)
        let notOr = !(isEven || isPositive)

        for n in -10...10 {
            #expect(nor(n) == notOr(n))
        }
    }
}

// MARK: - Implication Tests

@Suite
struct PredicateImplicationTests {
    let isEven = Predicate<Int> { $0 % 2 == 0 }
    let isPositive = Predicate<Int> { $0 > 0 }

    @Test
    func `implies is equivalent to not-or`() {
        let implies = isEven.implies(isPositive)
        let notOr = !isEven || isPositive

        for n in -10...10 {
            #expect(implies(n) == notOr(n))
        }
    }

    @Test
    func `iff is equivalent to not-xor`() {
        let iff = isEven.iff(isPositive)
        let notXor = !(isEven ^ isPositive)

        for n in -10...10 {
            #expect(iff(n) == notXor(n))
        }
    }
}

// MARK: - De Morgan Tests

@Suite
struct PredicateDeMorganTests {
    let isEven = Predicate<Int> { $0 % 2 == 0 }
    let isPositive = Predicate<Int> { $0 > 0 }

    @Test
    func `De Morgan law 1`() {
        // !(a && b) == !a || !b
        let p1 = !(isEven && isPositive)
        let p2 = !isEven || !isPositive

        for n in -10...10 {
            #expect(p1(n) == p2(n))
        }
    }

    @Test
    func `De Morgan law 2`() {
        // !(a || b) == !a && !b
        let p1 = !(isEven || isPositive)
        let p2 = !isEven && !isPositive

        for n in -10...10 {
            #expect(p1(n) == p2(n))
        }
    }
}

// MARK: - Distributivity Tests

@Suite
struct PredicateDistributivityTests {
    let isEven = Predicate<Int> { $0 % 2 == 0 }
    let isPositive = Predicate<Int> { $0 > 0 }
    let isSmall = Predicate<Int> { abs($0) < 5 }

    @Test
    func `AND distributes over OR`() {
        // a && (b || c) == (a && b) || (a && c)
        let p1 = isEven && (isPositive || isSmall)
        let p2 = (isEven && isPositive) || (isEven && isSmall)

        for n in -10...10 {
            #expect(p1(n) == p2(n))
        }
    }

    @Test
    func `OR distributes over AND`() {
        // a || (b && c) == (a || b) && (a || c)
        let p1 = isEven || (isPositive && isSmall)
        let p2 = (isEven || isPositive) && (isEven || isSmall)

        for n in -10...10 {
            #expect(p1(n) == p2(n))
        }
    }
}

// MARK: - Pullback Tests

@Suite
struct PredicatePullbackTests {
    @Test
    func `pullback with closure`() {
        let isEven = Predicate<Int> { $0 % 2 == 0 }
        let hasEvenLength = isEven.pullback { (s: String) in s.count }

        #expect(hasEvenLength("hi") == true)  // count 2
        #expect(hasEvenLength("hello") == false)  // count 5
    }

    @Test
    func `pullback with keyPath`() {
        let isLong = Predicate<Int> { $0 > 3 }
        let hasLongCount: Predicate<String> = isLong.pullback(\.count)

        #expect(hasLongCount("hi") == false)  // count 2
        #expect(hasLongCount("hello") == true)  // count 5
    }
}

// MARK: - Fluent Factory Tests

@Suite
struct PredicateFluentFactoryTests {
    @Test
    func `equal to predicate`() {
        let isZero = Predicate<Int>.equal.to(0)

        #expect(isZero(0) == true)
        #expect(isZero(1) == false)
    }

    @Test
    func `not equal to predicate`() {
        let isNotZero = Predicate<Int>.not.equalTo(0)

        #expect(isNotZero(0) == false)
        #expect(isNotZero(1) == true)
    }

    @Test
    func `in collection predicate`() {
        let isVowel = Predicate<Character>.in.collection("aeiou")

        #expect(isVowel("a") == true)
        #expect(isVowel("b") == false)
    }

    @Test
    func `comparison predicates`() {
        #expect(Predicate<Int>.less.than(5)(3) == true)
        #expect(Predicate<Int>.less.than(5)(5) == false)

        #expect(Predicate<Int>.less.thanOrEqualTo(5)(5) == true)
        #expect(Predicate<Int>.less.thanOrEqualTo(5)(6) == false)

        #expect(Predicate<Int>.greater.than(5)(6) == true)
        #expect(Predicate<Int>.greater.than(5)(5) == false)

        #expect(Predicate<Int>.greater.thanOrEqualTo(5)(5) == true)
        #expect(Predicate<Int>.greater.thanOrEqualTo(5)(4) == false)
    }

    @Test
    func `in range predicate`() {
        let isTeenager = Predicate<Int>.in.range(13...19)

        #expect(isTeenager(15) == true)
        #expect(isTeenager(12) == false)
        #expect(isTeenager(20) == false)
    }

    @Test
    func `collection predicates`() {
        #expect(Predicate<[Int]>.is.empty([]) == true)
        #expect(Predicate<[Int]>.is.empty([1]) == false)

        #expect(Predicate<[Int]>.is.notEmpty([1]) == true)
        #expect(Predicate<[Int]>.is.notEmpty([]) == false)

        #expect(Predicate<[Int]>.has.count(3)([1, 2, 3]) == true)
        #expect(Predicate<[Int]>.has.count(3)([1, 2]) == false)
    }

    @Test
    func `string predicates`() {
        #expect(Predicate<String>.contains.substring("ell")("hello") == true)
        #expect(Predicate<String>.contains.substring("xyz")("hello") == false)

        #expect(Predicate<String>.has.prefix("hel")("hello") == true)
        #expect(Predicate<String>.has.prefix("xyz")("hello") == false)

        #expect(Predicate<String>.has.suffix("llo")("hello") == true)
        #expect(Predicate<String>.has.suffix("xyz")("hello") == false)
    }

    @Test
    func `equal to any of predicate`() {
        let isPrimaryColor = Predicate<String>.equal.toAny(of: "red", "green", "blue")

        #expect(isPrimaryColor("red") == true)
        #expect(isPrimaryColor("yellow") == false)
    }

    @Test
    func `not in range predicate`() {
        let outsideTeenage = Predicate<Int>.not.inRange(13...19)

        #expect(outsideTeenage(10) == true)
        #expect(outsideTeenage(15) == false)
    }
}

// MARK: - Optional Tests

@Suite
struct PredicateOptionalTests {
    @Test
    func `is nil predicate`() {
        let isNil = Predicate<Int>.is.nil

        #expect(isNil(nil) == true)
        #expect(isNil(42) == false)
    }

    @Test
    func `is not nil predicate`() {
        let isNotNil = Predicate<Int>.is.notNil

        #expect(isNotNil(42) == true)
        #expect(isNotNil(nil) == false)
    }

    @Test
    func `optional lift with default`() {
        let isEven = Predicate<Int> { $0 % 2 == 0 }
        let optionalIsEven = isEven.optional(default: false)

        #expect(optionalIsEven(4) == true)
        #expect(optionalIsEven(3) == false)
        #expect(optionalIsEven(nil) == false)
    }
}

// MARK: - Quantifier Tests

@Suite
struct PredicateQuantifierTests {
    let isEven = Predicate<Int> { $0 % 2 == 0 }

    // MARK: Array Properties

    @Test
    func `all quantifier array`() {
        let allEven = isEven.all

        #expect(allEven([2, 4, 6]) == true)
        #expect(allEven([2, 3, 4]) == false)
        #expect(allEven([]) == true)  // vacuous truth
    }

    @Test
    func `any quantifier array`() {
        let anyEven = isEven.any

        #expect(anyEven([1, 2, 3]) == true)
        #expect(anyEven([1, 3, 5]) == false)
        #expect(anyEven([]) == false)
    }

    @Test
    func `none quantifier array`() {
        let noneEven = isEven.none

        #expect(noneEven([1, 3, 5]) == true)
        #expect(noneEven([1, 2, 3]) == false)
        #expect(noneEven([]) == true)
    }

    // MARK: Generic Sequence Methods

    @Test
    func `forAll quantifier with Set`() {
        let allEven: Predicate<Set<Int>> = isEven.forAll()

        #expect(allEven(Set([2, 4, 6])) == true)
        #expect(allEven(Set([2, 3, 4])) == false)
        #expect(allEven(Set()) == true)
    }

    @Test
    func `forAny quantifier with Set`() {
        let anyEven: Predicate<Set<Int>> = isEven.forAny()

        #expect(anyEven(Set([1, 2, 3])) == true)
        #expect(anyEven(Set([1, 3, 5])) == false)
        #expect(anyEven(Set()) == false)
    }

    @Test
    func `forNone quantifier with Set`() {
        let noneEven: Predicate<Set<Int>> = isEven.forNone()

        #expect(noneEven(Set([1, 3, 5])) == true)
        #expect(noneEven(Set([1, 2, 3])) == false)
        #expect(noneEven(Set()) == true)
    }

    @Test
    func `forAll quantifier with ClosedRange`() {
        let allEven: Predicate<ClosedRange<Int>> = isEven.forAll()

        #expect(allEven(2...2) == true)  // single even
        #expect(allEven(1...10) == false)  // mixed
    }

    @Test
    func `forAny quantifier with ClosedRange`() {
        let anyEven: Predicate<ClosedRange<Int>> = isEven.forAny()

        #expect(anyEven(1...10) == true)
        #expect(anyEven(1...1) == false)  // single odd
    }

    @Test
    func `quantifiers with type inference`() {
        // Type can be inferred from usage
        let set: Set<Int> = [2, 4, 6]
        #expect(isEven.forAll()(set) == true)
        #expect(isEven.forAny()(set) == true)
        #expect(isEven.forNone()(set) == false)
    }
}

// MARK: - Closure Operator Tests

@Suite
struct PredicateClosureOperatorTests {
    let isEvenClosure: (Int) -> Bool = { $0 % 2 == 0 }
    let isPositiveClosure: (Int) -> Bool = { $0 > 0 }
    let isEven = Predicate<Int> { $0 % 2 == 0 }

    @Test
    func `AND with two closures`() {
        let combined = isEvenClosure && isPositiveClosure

        #expect(combined(4) == true)
        #expect(combined(3) == false)
        #expect(combined(-4) == false)
    }

    @Test
    func `OR with two closures`() {
        let combined = isEvenClosure || isPositiveClosure

        #expect(combined(4) == true)
        #expect(combined(3) == true)
        #expect(combined(-3) == false)
    }

    @Test
    func `XOR with two closures`() {
        let combined = isEvenClosure ^ isPositiveClosure

        #expect(combined(4) == false)  // both
        #expect(combined(3) == true)  // positive only
        #expect(combined(-4) == true)  // even only
    }

    @Test
    func `NOT with closure`() {
        let isOdd = !isEvenClosure

        #expect(isOdd(3) == true)
        #expect(isOdd(4) == false)
    }

    @Test
    func `Predicate AND closure`() {
        let combined = isEven && isPositiveClosure

        #expect(combined(4) == true)
        #expect(combined(-4) == false)
    }

    @Test
    func `Closure AND Predicate`() {
        let combined = isEvenClosure && isEven.negated

        // This should be isEven && isOdd, always false
        for n in -10...10 {
            #expect(combined(n) == false)
        }
    }

    @Test
    func `Fluent methods with closures`() {
        let combined = isEven.and(isPositiveClosure)

        #expect(combined(4) == true)
        #expect(combined(-4) == false)
    }

    @Test
    func `Chained closure operations`() {
        let isSmall: (Int) -> Bool = { abs($0) < 5 }

        let combined = isEvenClosure && isPositiveClosure && isSmall

        #expect(combined(2) == true)
        #expect(combined(4) == true)
        #expect(combined(6) == false)  // not small
        #expect(combined(3) == false)  // not even
    }
}
