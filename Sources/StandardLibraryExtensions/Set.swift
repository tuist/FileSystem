// Set.swift
// swift-standards
//
// Extensions for Swift standard library Set

extension Set {
    /// Partitions set into two disjoint sets based on predicate
    ///
    /// Decomposes set via characteristic function into coproduct.
    /// Creates disjoint union where elements satisfying predicate go to first set.
    ///
    /// Category theory: Coproduct decomposition via χ: S → 𝔹
    /// partition: (A → Bool) → Set(A) → Set(A) ⊕ Set(A)
    /// Satisfies: satisfying ∪ failing = original, satisfying ∩ failing = ∅
    ///
    /// Example:
    /// ```swift
    /// let numbers: Set = [1, 2, 3, 4, 5, 6]
    /// let (evens, odds) = numbers.partition(where: { $0.isMultiple(of: 2) })
    /// // evens: [2, 4, 6], odds: [1, 3, 5]
    /// ```
    public func partition(
        where predicate: (Element) -> Bool
    ) -> (satisfying: Set<Element>, failing: Set<Element>) {
        var satisfying = Set<Element>()
        var failing = Set<Element>()

        for element in self {
            if predicate(element) {
                satisfying.insert(element)
            } else {
                failing.insert(element)
            }
        }

        return (satisfying, failing)
    }

    /// Generates all k-sized subsets
    ///
    /// Computes combinations C(n, k) via binomial coefficient.
    /// Returns empty set for invalid k values.
    ///
    /// Category theory: Power set restriction to fixed cardinality
    /// subsets: ℕ → 𝒫(S) → 𝒫(𝒫(S)) where |each subset| = k
    /// Count satisfies: |subsets(k)| = C(n, k) = n! / (k!(n-k)!)
    ///
    /// Example:
    /// ```swift
    /// let set: Set = [1, 2, 3]
    /// set.subsets(ofSize: 2)  // [[1, 2], [1, 3], [2, 3]]
    /// set.subsets(ofSize: 0)  // [[]] (empty set)
    /// ```
    public func subsets(ofSize k: Int) -> Set<Set<Element>> {
        guard k >= 0 else { return [] }
        guard k <= count else { return [] }

        if k == 0 {
            return [[]]
        }

        if k == count {
            return [self]
        }

        var result = Set<Set<Element>>()
        let elements = Array(self)

        func combine(start: Int, current: Set<Element>) {
            if current.count == k {
                result.insert(current)
                return
            }

            for i in start..<elements.count {
                var next = current
                next.insert(elements[i])
                combine(start: i + 1, current: next)
            }
        }

        combine(start: 0, current: [])
        return result
    }

    /// Computes Cartesian product with another set
    ///
    /// Forms product set of all ordered pairs.
    /// Fundamental construction in category of sets.
    /// Returns array since tuple Hashable conformance is limited.
    ///
    /// Category theory: Categorical product S × T
    /// cartesianProduct: Set(A) × Set(B) → Array(A × B)
    /// Satisfies: |S × T| = |S| · |T|, π₁ ∘ product and π₂ ∘ product are projections
    ///
    /// Example:
    /// ```swift
    /// let a: Set = [1, 2]
    /// let b: Set = ["x", "y"]
    /// a.cartesianProduct(b)  // [(1, "x"), (1, "y"), (2, "x"), (2, "y")]
    /// ```
    public func cartesianProduct<Other>(_ other: Set<Other>) -> [(Element, Other)] {
        var result: [(Element, Other)] = []
        result.reserveCapacity(count * other.count)

        for element in self {
            for otherElement in other {
                result.append((element, otherElement))
            }
        }

        return result
    }

    /// Cartesian product with itself (self-product)
    ///
    /// Special case of Cartesian product where both sets are identical.
    /// Useful for generating all pairs from a single set.
    ///
    /// Category theory: Diagonal product Δ: S → S × S
    ///
    /// Example:
    /// ```swift
    /// let set: Set = [1, 2, 3]
    /// set.cartesianSquare()  // [(1,1), (1,2), (1,3), (2,1), (2,2), (2,3), (3,1), (3,2), (3,3)]
    /// ```
    public func cartesianSquare() -> [(Element, Element)] {
        cartesianProduct(self)
    }
}
