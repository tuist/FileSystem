// AdditiveArithmetic.swift
// swift-standards
//
// Extensions for Swift standard library AdditiveArithmetic protocol

extension Sequence where Element: AdditiveArithmetic {
    /// Computes sum of all elements
    ///
    /// Monoid fold operation using additive identity and addition.
    /// Reduces sequence via left fold with zero as identity element.
    ///
    /// Category theory: Fold morphism in additive monoid (M, +, 0)
    /// sum: Seq(M) → M where sum = foldr (+) 0
    /// Satisfies monoid laws: sum([]) = 0, sum([a]) = a, sum(xs ++ ys) = sum(xs) + sum(ys)
    ///
    /// Example:
    /// ```swift
    /// [1, 2, 3, 4, 5].sum()  // 15
    /// [].sum()               // 0 (identity)
    /// ```
    public func sum() -> Element {
        reduce(.zero, +)
    }
}
