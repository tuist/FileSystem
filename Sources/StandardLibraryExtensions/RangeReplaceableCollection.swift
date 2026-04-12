//
//  File.swift
//  swift-standards
//
//  Created by Coen ten Thije Boonkkamp on 25/11/2025.
//

extension RangeReplaceableCollection {
    /// Non-mutating element prepending
    ///
    /// Adds element to beginning, preserving existing structure.
    /// Left unit operation for list construction.
    ///
    /// Category theory: Cons operation in list algebra,
    /// prepend(x, xs) ≡ [x] ⊕ xs
    ///
    /// Example:
    /// ```swift
    /// let result = [2, 3, 4].prepending(1)  // [1, 2, 3, 4]
    /// ```
    public func prepending(_ element: Element) -> Self {
        var result = self
        result.insert(element, at: startIndex)
        return result
    }
}

extension RangeReplaceableCollection where Element: Hashable {
    /// Removes duplicate elements preserving first occurrence order
    ///
    /// Implements idempotent operation: f ∘ f = f
    /// Projects collection onto its image under inclusion, removing redundancy.
    ///
    /// Category theory: Retraction morphism r: Collection → Set → Collection
    /// satisfying r ∘ r = r (idempotent endomorphism)
    ///
    /// Example:
    /// ```swift
    /// [1, 2, 2, 3, 1, 4].removingDuplicates()  // [1, 2, 3, 4]
    /// ```
    public func removingDuplicates() -> Self {
        var seen: Set<Element> = []
        return filter { seen.insert($0).inserted }
    }
}
