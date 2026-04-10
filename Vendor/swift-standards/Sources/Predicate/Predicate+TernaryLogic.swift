// Predicate+TernaryLogic.swift
// Three-valued logic lifting for predicates.

public import TernaryLogic

// MARK: - Three-Valued Evaluation

extension Predicate {
    /// Evaluates the predicate on an optional value, returning a three-valued result.
    ///
    /// This is the mathematically principled lifting of a total predicate to a partial one:
    /// - Input: `T?` (Optional as a container - presence/absence of a value)
    /// - Output: `TernaryLogic` (truth value - true/false/unknown)
    ///
    /// Returns `.unknown` for `nil` input, following Strong Kleene semantics.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let isEven = Predicate<Int> { $0 % 2 == 0 }
    ///
    /// let a: Bool? = isEven(4)    // .some(true)
    /// let b: Bool? = isEven(nil)  // nil (unknown)
    ///
    /// // Or with custom TernaryLogic types:
    /// let c: MyTernary = isEven(nil)  // .unknown
    /// ```
    ///
    /// ## Composition with TernaryLogic Operators
    ///
    /// Results compose using TernaryLogic's three-valued operators:
    ///
    /// ```swift
    /// let isEven = Predicate<Int> { $0 % 2 == 0 }
    /// let isPositive = Predicate<Int> { $0 > 0 }
    ///
    /// let a: Int? = 4
    /// let b: Int? = nil
    ///
    /// // Strong Kleene short-circuit evaluation:
    /// isEven(b) && isPositive(a)  // nil && true = nil
    /// isEven(b) || isPositive(a)  // nil || true = true
    /// ```
    ///
    /// - Parameter value: An optional value to test (container semantics).
    /// - Returns: A truth value: `.true`, `.false`, or `.unknown` if input is `nil`.
    @inlinable
    public func callAsFunction<L: TernaryLogic.`Protocol`>(_ value: T?) -> L {
        guard let value else { return .unknown }
        return evaluate(value) ? .true : .false
    }
}
