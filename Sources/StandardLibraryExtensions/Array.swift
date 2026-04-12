// Array.swift
// swift-standards
//
// Extensions for Swift standard library Array

extension Array {
    /// Non-mutating element removal at index
    ///
    /// Produces new array with element removed, preserving original.
    /// Represents deletion morphism in free monoid of sequences.
    ///
    /// Category theory: Morphism in category of finite sequences
    /// delete: Seq(A) × ℕ → Seq(A) where |delete(s, i)| = |s| - 1
    ///
    /// Example:
    /// ```swift
    /// let array = [1, 2, 3, 4, 5]
    /// array.removing(at: 2)  // [1, 2, 4, 5]
    /// ```
    public func removing(at index: Int) -> [Element] {
        var result = self
        result.remove(at: index)
        return result
    }

    /// Non-mutating element insertion at index
    ///
    /// Produces new array with element inserted, preserving original.
    /// Represents insertion morphism in free monoid of sequences.
    ///
    /// Category theory: Morphism in category of finite sequences
    /// insert: Seq(A) × A × ℕ → Seq(A) where |insert(s, a, i)| = |s| + 1
    ///
    /// Example:
    /// ```swift
    /// let array = [1, 2, 4, 5]
    /// array.inserting(3, at: 2)  // [1, 2, 3, 4, 5]
    /// ```
    public func inserting(_ element: Element, at index: Int) -> [Element] {
        var result = self
        result.insert(element, at: index)
        return result
    }

    /// Safe subscript access with range
    ///
    /// Extends safe indexing to range projections.
    /// Natural transformation lifting partial range operations into Maybe.
    ///
    /// Category theory: η: Array × Range → Maybe(ArraySlice)
    ///
    /// Example:
    /// ```swift
    /// let array = [1, 2, 3, 4, 5]
    /// array[safe: 1..<3]   // Optional([2, 3])
    /// array[safe: 3..<10]  // nil
    /// ```
    public subscript(safe range: Range<Int>) -> ArraySlice<Element>? {
        guard range.lowerBound >= 0,
            range.upperBound <= count,
            range.lowerBound <= range.upperBound
        else { return nil }
        return self[range]
    }

    /// Safe subscript access with closed range
    ///
    /// Closed range variant of safe subscripting.
    /// Includes upper bound in result.
    ///
    /// Category theory: η: Array × ClosedRange → Maybe(ArraySlice)
    ///
    /// Example:
    /// ```swift
    /// let array = [1, 2, 3, 4, 5]
    /// array[safe: 1...3]   // Optional([2, 3, 4])
    /// array[safe: 3...10]  // nil
    /// ```
    public subscript(safe range: ClosedRange<Int>) -> ArraySlice<Element>? {
        guard range.lowerBound >= 0,
            range.upperBound < count,
            range.lowerBound <= range.upperBound
        else { return nil }
        return self[range]
    }
}
