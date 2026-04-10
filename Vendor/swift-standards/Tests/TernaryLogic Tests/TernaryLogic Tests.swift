// TernaryLogic Tests.swift
// Tests for Strong Kleene three-valued logic.

import Testing

@testable import TernaryLogic

// MARK: - Test Cases

/// Represents a binary logic test case with optional Bool values.
struct BinaryTestCase: CustomTestStringConvertible, Sendable {
    let lhs: Bool?
    let rhs: Bool?
    let expected: Bool?

    var testDescription: String {
        "\(lhs.map(String.init(describing:)) ?? "nil") → \(rhs.map(String.init(describing:)) ?? "nil") = \(expected.map(String.init(describing:)) ?? "nil")"
    }
}

/// Represents a unary logic test case.
struct UnaryTestCase: CustomTestStringConvertible, Sendable {
    let input: Bool?
    let expected: Bool?

    var testDescription: String {
        "\(input.map(String.init(describing:)) ?? "nil") → \(expected.map(String.init(describing:)) ?? "nil")"
    }
}

// MARK: - AND Tests

@Suite
struct ThreeValuedLogicANDTests {
    static let andCases: [BinaryTestCase] = [
        // Known values
        .init(lhs: false, rhs: false, expected: false),
        .init(lhs: false, rhs: true, expected: false),
        .init(lhs: true, rhs: false, expected: false),
        .init(lhs: true, rhs: true, expected: true),
        // Short-circuit on false
        .init(lhs: false, rhs: nil, expected: false),
        .init(lhs: nil, rhs: false, expected: false),
        // Nil propagation
        .init(lhs: true, rhs: nil, expected: nil),
        .init(lhs: nil, rhs: true, expected: nil),
        .init(lhs: nil, rhs: nil, expected: nil),
    ]

    @Test(arguments: andCases)
    func and(_ testCase: BinaryTestCase) {
        #expect((testCase.lhs && testCase.rhs) == testCase.expected)
    }

    @Test
    func lazyEvaluation() {
        var evaluated = false
        let lazyValue: () -> Bool? = {
            evaluated = true
            return true
        }
        // Should NOT evaluate rhs when lhs is false
        _ = false && lazyValue()
        #expect(evaluated == false)
    }
}

// MARK: - OR Tests

@Suite
struct ThreeValuedLogicORTests {
    static let orCases: [BinaryTestCase] = [
        // Known values
        .init(lhs: false, rhs: false, expected: false),
        .init(lhs: false, rhs: true, expected: true),
        .init(lhs: true, rhs: false, expected: true),
        .init(lhs: true, rhs: true, expected: true),
        // Short-circuit on true
        .init(lhs: true, rhs: nil, expected: true),
        .init(lhs: nil, rhs: true, expected: true),
        // Nil propagation
        .init(lhs: false, rhs: nil, expected: nil),
        .init(lhs: nil, rhs: false, expected: nil),
        .init(lhs: nil, rhs: nil, expected: nil),
    ]

    @Test(arguments: orCases)
    func or(_ testCase: BinaryTestCase) {
        #expect((testCase.lhs || testCase.rhs) == testCase.expected)
    }

    @Test
    func lazyEvaluation() {
        var evaluated = false
        let lazyValue: () -> Bool? = {
            evaluated = true
            return false
        }
        // Should NOT evaluate rhs when lhs is true
        _ = true || lazyValue()
        #expect(evaluated == false)
    }
}

// MARK: - NOT Tests

@Suite
struct ThreeValuedLogicNOTTests {
    static let notCases: [UnaryTestCase] = [
        .init(input: true, expected: false),
        .init(input: false, expected: true),
        .init(input: nil, expected: nil),
    ]

    @Test(arguments: notCases)
    func not(_ testCase: UnaryTestCase) {
        #expect((!testCase.input) == testCase.expected)
    }

    @Test(arguments: [true, false])
    func involution(_ value: Bool) {
        #expect((!(!value)) == value)
    }
}

// MARK: - XOR Tests

@Suite
struct ThreeValuedLogicXORTests {
    static let xorCases: [BinaryTestCase] = [
        // Known values
        .init(lhs: false, rhs: false, expected: false),
        .init(lhs: false, rhs: true, expected: true),
        .init(lhs: true, rhs: false, expected: true),
        .init(lhs: true, rhs: true, expected: false),
        // Nil always propagates
        .init(lhs: false, rhs: nil, expected: nil),
        .init(lhs: true, rhs: nil, expected: nil),
        .init(lhs: nil, rhs: false, expected: nil),
        .init(lhs: nil, rhs: true, expected: nil),
        .init(lhs: nil, rhs: nil, expected: nil),
    ]

    @Test(arguments: xorCases)
    func xor(_ testCase: BinaryTestCase) {
        #expect((testCase.lhs ^ testCase.rhs) == testCase.expected)
    }
}

// MARK: - NAND Tests

@Suite
struct ThreeValuedLogicNANDTests {
    static let nandCases: [BinaryTestCase] = [
        // Known values
        .init(lhs: false, rhs: false, expected: true),
        .init(lhs: false, rhs: true, expected: true),
        .init(lhs: true, rhs: false, expected: true),
        .init(lhs: true, rhs: true, expected: false),
        // NAND(false, nil) = NOT(AND(false, nil)) = NOT(false) = true
        .init(lhs: false, rhs: nil, expected: true),
        .init(lhs: nil, rhs: false, expected: true),
        // NAND(true, nil) = NOT(AND(true, nil)) = NOT(nil) = nil
        .init(lhs: true, rhs: nil, expected: nil),
        .init(lhs: nil, rhs: true, expected: nil),
    ]

    @Test(arguments: nandCases)
    func nand(_ testCase: BinaryTestCase) {
        #expect((testCase.lhs !&& testCase.rhs) == testCase.expected)
    }
}

// MARK: - NOR Tests

@Suite
struct ThreeValuedLogicNORTests {
    static let norCases: [BinaryTestCase] = [
        // Known values
        .init(lhs: false, rhs: false, expected: true),
        .init(lhs: false, rhs: true, expected: false),
        .init(lhs: true, rhs: false, expected: false),
        .init(lhs: true, rhs: true, expected: false),
        // NOR(true, nil) = NOT(OR(true, nil)) = NOT(true) = false
        .init(lhs: true, rhs: nil, expected: false),
        .init(lhs: nil, rhs: true, expected: false),
        // NOR(false, nil) = NOT(OR(false, nil)) = NOT(nil) = nil
        .init(lhs: false, rhs: nil, expected: nil),
        .init(lhs: nil, rhs: false, expected: nil),
    ]

    @Test(arguments: norCases)
    func nor(_ testCase: BinaryTestCase) {
        #expect((testCase.lhs !|| testCase.rhs) == testCase.expected)
    }
}

// MARK: - XNOR Tests

@Suite
struct ThreeValuedLogicXNORTests {
    static let xnorCases: [BinaryTestCase] = [
        // Known values
        .init(lhs: false, rhs: false, expected: true),
        .init(lhs: false, rhs: true, expected: false),
        .init(lhs: true, rhs: false, expected: false),
        .init(lhs: true, rhs: true, expected: true),
        // Nil always propagates
        .init(lhs: false, rhs: nil, expected: nil),
        .init(lhs: true, rhs: nil, expected: nil),
        .init(lhs: nil, rhs: false, expected: nil),
        .init(lhs: nil, rhs: true, expected: nil),
        .init(lhs: nil, rhs: nil, expected: nil),
    ]

    @Test(arguments: xnorCases)
    func xnor(_ testCase: BinaryTestCase) {
        #expect((testCase.lhs !^ testCase.rhs) == testCase.expected)
    }
}

// MARK: - De Morgan Tests

@Suite
struct ThreeValuedLogicDeMorganTests {
    static let knownPairs: [(Bool, Bool)] = [
        (false, false),
        (false, true),
        (true, false),
        (true, true),
    ]

    @Test(arguments: knownPairs)
    func deMorganAnd(_ pair: (Bool, Bool)) {
        let (a, b) = pair
        // !(a && b) == !a || !b
        #expect(!(a && b) == (!a || !b))
    }

    @Test(arguments: knownPairs)
    func deMorganOr(_ pair: (Bool, Bool)) {
        let (a, b) = pair
        // !(a || b) == !a && !b
        #expect(!(a || b) == (!a && !b))
    }

    @Test
    func deMorganWithNil() {
        let nilValue: Bool? = nil
        // !(false && nil) = !false = true
        // !false || !nil = true || nil = true ✓
        #expect(!(false && nilValue) == ((!false) || (!nilValue)))
        // !(true || nil) = !true = false
        // !true && !nil = false && nil = false ✓
        #expect(!(true || nilValue) == ((!true) && (!nilValue)))
    }
}

// MARK: - Implication Tests

@Suite
struct ThreeValuedLogicImplicationTests {
    struct ImplicationCase: CustomTestStringConvertible, Sendable {
        let a: Bool?
        let b: Bool?
        let expected: Bool?

        var testDescription: String {
            "\(a.map(String.init(describing:)) ?? "nil") → \(b.map(String.init(describing:)) ?? "nil") = \(expected.map(String.init(describing:)) ?? "nil")"
        }
    }

    static let implicationCases: [ImplicationCase] = [
        .init(a: true, b: true, expected: true),
        .init(a: true, b: false, expected: false),
        // false → anything = true (vacuous truth)
        .init(a: false, b: true, expected: true),
        .init(a: false, b: false, expected: true),
        .init(a: false, b: nil, expected: true),
        // nil → true = nil || true = true
        .init(a: nil, b: true, expected: true),
        // nil → false = nil || false = nil
        .init(a: nil, b: false, expected: nil),
    ]

    /// Implication: a → b ≡ !a || b
    @Test(arguments: implicationCases)
    func implication(_ testCase: ImplicationCase) {
        let result = !testCase.a || testCase.b
        #expect(result == testCase.expected)
    }
}

// MARK: - Complex Expression Tests

@Suite
struct ThreeValuedLogicComplexExpressionTests {
    @Test
    func mixedValues() {
        let a: Bool? = true
        let b: Bool? = false
        let c: Bool? = nil

        // (true && false) || nil = false || nil = nil
        #expect(((a && b) || c) == nil)
        // true && (false || nil) = true && nil = nil
        #expect((a && (b || c)) == nil)
        // (true || nil) && false = true && false = false
        #expect(((a || c) && b) == false)
    }
}
