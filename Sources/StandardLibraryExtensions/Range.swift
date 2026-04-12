// Range.swift
// swift-standards
//
// Extensions for Swift standard library Range

extension Range where Bound: Strideable {
    /// Computes intersection of two ranges
    ///
    /// Returns overlapping interval, or nil if ranges are disjoint.
    /// Implements meet operation in lattice of intervals.
    ///
    /// Category theory: Greatest lower bound (meet) in interval lattice
    /// overlap: Range × Range → Maybe(Range)
    /// Satisfies: a ∩ b = b ∩ a (commutative), a ∩ (b ∩ c) = (a ∩ b) ∩ c (associative)
    ///
    /// Example:
    /// ```swift
    /// let a = 1..<5
    /// let b = 3..<7
    /// a.overlap(b)  // Optional(3..<5)
    ///
    /// let c = 1..<3
    /// let d = 5..<7
    /// c.overlap(d)  // nil (disjoint)
    /// ```
    public func overlap(_ other: Range<Bound>) -> Range<Bound>? {
        let lower = Swift.max(lowerBound, other.lowerBound)
        let upper = Swift.min(upperBound, other.upperBound)

        guard lower < upper else { return nil }
        return lower..<upper
    }

    /// Clamps range to bounds
    ///
    /// Restricts range to fit within specified bounds.
    /// Returns nil if range and bounds are completely disjoint.
    ///
    /// Category theory: Restriction morphism via intersection
    /// clamped: Range × Range → Maybe(Range)
    ///
    /// Example:
    /// ```swift
    /// let range = 1..<10
    /// range.clamped(to: 3..<7)   // Optional(3..<7)
    /// range.clamped(to: 5..<15)  // Optional(5..<10)
    /// range.clamped(to: 20..<30) // nil
    /// ```
    public func clamped(to bounds: Range<Bound>) -> Range<Bound>? {
        overlap(bounds)
    }

    /// Splits range at specified point
    ///
    /// Decomposes range into two adjacent non-empty ranges at split point.
    /// Returns nil if point is outside range or at bounds (would create empty range).
    ///
    /// Category theory: Coproduct decomposition
    /// split: Range × Bound → Maybe(Range ⊕ Range)
    /// Satisfies: lower ∪ upper = original (coverage), lower ∩ upper = ∅ (disjoint)
    ///
    /// Example:
    /// ```swift
    /// let range = 1..<10
    /// range.split(at: 5)  // Optional((1..<5, 5..<10))
    /// range.split(at: 1)  // nil (at lower bound)
    /// range.split(at: 10) // nil (at upper bound)
    /// range.split(at: 15) // nil (out of bounds)
    /// ```
    public func split(at point: Bound) -> (lower: Range<Bound>, upper: Range<Bound>)? {
        guard contains(point), point != lowerBound else { return nil }
        return (lowerBound..<point, point..<upperBound)
    }
}
