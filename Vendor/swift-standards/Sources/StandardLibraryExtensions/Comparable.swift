// Comparable.swift
// swift-standards
//
// Pure Swift comparable utilities

extension Comparable {
    /// Restricts value to closed interval [a, b]
    ///
    /// Order-preserving morphism from totally ordered set to restricted codomain.
    /// For any totally ordered set (T, ≤), this morphism f: T → [a,b] satisfies:
    /// - ∀x,y ∈ T: x ≤ y ⟹ f(x) ≤ f(y) (order preservation)
    /// - ∀x ∈ T: a ≤ f(x) ≤ b (codomain restriction)
    ///
    /// Category theory: Morphism in Ord (category of ordered sets and monotone functions)
    /// that restricts codomain while preserving order relations.
    ///
    /// Example:
    /// ```swift
    /// 5.clamped(to: 0...10)   // 5
    /// 15.clamped(to: 0...10)  // 10
    /// (-5).clamped(to: 0...10) // 0
    /// ```
    public func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
