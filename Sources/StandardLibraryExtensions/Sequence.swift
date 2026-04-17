// Sequence.swift
// swift-standards
//
// Extensions for Swift standard library Sequence

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

}
