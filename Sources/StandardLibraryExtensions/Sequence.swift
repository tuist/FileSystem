// Sequence.swift
// swift-standards
//
// Extensions for Swift standard library Sequence

extension Sequence {
    /// Counts elements satisfying predicate
    ///
    /// Measures cardinality of preimage under characteristic function.
    /// Computes |f⁻¹(true)| where f: A → Bool is the predicate.
    ///
    /// Category theory: Composition of characteristic function with cardinality:
    /// count: (A → Bool) → Seq(A) → ℕ where count(p, s) = |{x ∈ s : p(x)}|
    ///
    /// Example:
    /// ```swift
    /// [1, 2, 3, 4, 5].count(where: { $0.isMultiple(of: 2) })  // 2
    /// ```
    public func count(where predicate: (Element) throws -> Bool) rethrows -> Int {
        try reduce(0) { try predicate($1) ? $0 + 1 : $0 }
    }

}

extension Sequence where Element: Hashable {
    /// Computes frequency distribution of elements
    ///
    /// Histogram operation counting element occurrences.
    /// Maps each unique element to its multiplicity in the sequence.
    ///
    /// Category theory: Homomorphism from free monoid to commutative monoid
    /// frequencies: Seq(A) → Map(A, ℕ) where frequencies preserves concatenation
    ///
    /// Example:
    /// ```swift
    /// [1, 2, 2, 3, 1, 4, 2].frequencies()  // [1: 2, 2: 3, 3: 1, 4: 1]
    /// "hello".frequencies()  // ["h": 1, "e": 1, "l": 2, "o": 1]
    /// ```
    public func frequencies() -> [Element: Int] {
        reduce(into: [:]) { counts, element in
            counts[element, default: 0] += 1
        }
    }
}

extension Sequence where Element: Comparable {
    /// Tests if sequence is sorted in ascending order
    ///
    /// Verifies monotonicity property via pairwise comparison.
    /// Checks if sequence respects total order relation.
    ///
    /// Category theory: Tests if sequence is monotone morphism
    /// isSorted: Seq(A) → Bool where ∀i: aᵢ ≤ aᵢ₊₁
    ///
    /// Example:
    /// ```swift
    /// [1, 2, 3, 4, 5].isSorted()     // true
    /// [1, 3, 2, 4, 5].isSorted()     // false
    /// [5, 4, 3, 2, 1].isSorted()     // false
    /// ```
    public func isSorted() -> Bool {
        var previous: Element?

        for element in self {
            if let prev = previous, prev > element {
                return false
            }
            previous = element
        }

        return true
    }

    /// Tests if sequence is sorted using custom comparator
    ///
    /// Generalized monotonicity test with explicit order relation.
    /// Verifies sequence respects provided partial order.
    ///
    /// Category theory: Tests monotonicity under arbitrary order
    /// isSorted: (A × A → Bool) → Seq(A) → Bool
    ///
    /// Example:
    /// ```swift
    /// [5, 4, 3, 2, 1].isSorted(by: >)  // true (descending)
    /// ["a", "bb", "ccc"].isSorted(by: { $0.count < $1.count })  // true
    /// ```
    public func isSorted(
        by areInIncreasingOrder: (Element, Element) throws -> Bool
    ) rethrows -> Bool {
        var previous: Element?

        for element in self {
            if let prev = previous, try !areInIncreasingOrder(prev, element) {
                return false
            }
            previous = element
        }

        return true
    }

    /// Returns N largest elements
    ///
    /// Partial order selection via top-N filter.
    /// Selects maximal elements up to specified count.
    ///
    /// Category theory: Order-preserving projection to prefix:
    /// max: ℕ → Seq(A) → Seq(A) where result is ordered maximum subset
    ///
    /// Example:
    /// ```swift
    /// [3, 1, 4, 1, 5, 9, 2].max(count: 3)  // [9, 5, 4]
    /// ```
    public func max(count: Int) -> [Element] {
        guard count > 0 else { return [] }
        var result: [Element] = []

        for element in self {
            if result.count < count {
                result.append(element)
                result.sort(by: >)
            } else if let last = result.last, element > last {
                result[count - 1] = element
                result.sort(by: >)
            }
        }

        return result
    }

    /// Returns N smallest elements
    ///
    /// Dual to max(count:), selects minimal elements.
    /// Partial order selection via bottom-N filter.
    ///
    /// Category theory: Order-reversing variant of max:
    /// min: ℕ → Seq(A) → Seq(A) where min ≡ max ∘ reverse_order
    ///
    /// Example:
    /// ```swift
    /// [3, 1, 4, 1, 5, 9, 2].min(count: 3)  // [1, 1, 2]
    /// ```
    public func min(count: Int) -> [Element] {
        guard count > 0 else { return [] }
        var result: [Element] = []

        for element in self {
            if result.count < count {
                result.append(element)
                result.sort()
            } else if let last = result.last, element < last {
                result[count - 1] = element
                result.sort()
            }
        }

        return result
    }
}
