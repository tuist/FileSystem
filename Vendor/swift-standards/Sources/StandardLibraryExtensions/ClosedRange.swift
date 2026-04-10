// ClosedRange.swift
// swift-standards
//
// Extensions for Swift standard library ClosedRange

extension ClosedRange where Bound: Strideable {
    /// Computes intersection of two closed ranges
    ///
    /// Returns overlapping interval, or nil if ranges are disjoint.
    /// Implements meet operation in lattice of intervals.
    ///
    /// Category theory: Greatest lower bound (meet) in interval lattice
    /// overlap: ClosedRange × ClosedRange → Maybe(ClosedRange)
    ///
    /// Example:
    /// ```swift
    /// let a = 1...5
    /// let b = 3...7
    /// a.overlap(b)  // Optional(3...5)
    ///
    /// let c = 1...3
    /// let d = 5...7
    /// c.overlap(d)  // nil (disjoint)
    /// ```
    public func overlap(_ other: ClosedRange<Bound>) -> ClosedRange<Bound>? {
        let lower = Swift.max(lowerBound, other.lowerBound)
        let upper = Swift.min(upperBound, other.upperBound)

        guard lower <= upper else { return nil }
        return lower...upper
    }

    /// Clamps range to bounds
    ///
    /// Restricts range to fit within specified bounds.
    /// Returns nil if range and bounds are completely disjoint.
    ///
    /// Category theory: Restriction morphism via intersection
    /// clamped: ClosedRange × ClosedRange → Maybe(ClosedRange)
    ///
    /// Example:
    /// ```swift
    /// let range = 1...10
    /// range.clamped(to: 3...7)   // Optional(3...7)
    /// range.clamped(to: 5...15)  // Optional(5...10)
    /// range.clamped(to: 20...30) // nil
    /// ```
    public func clamped(to bounds: ClosedRange<Bound>) -> ClosedRange<Bound>? {
        overlap(bounds)
    }
}
