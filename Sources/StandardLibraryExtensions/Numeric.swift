// Numeric.swift
// swift-standards
//
// Extensions for Swift standard library Numeric protocol

extension Sequence where Element: Numeric {
    /// Computes product of all elements
    ///
    /// Monoid fold operation using multiplicative identity and multiplication.
    /// Reduces sequence via left fold with one as identity element.
    ///
    /// Category theory: Fold morphism in multiplicative monoid (M, ·, 1)
    /// product: Seq(M) → M where product = foldr (·) 1
    /// Satisfies: product([]) = 1, product([a]) = a, product(xs ++ ys) = product(xs) · product(ys)
    ///
    /// Example:
    /// ```swift
    /// [1, 2, 3, 4, 5].product()  // 120
    /// [2, 3, 4].product()        // 24
    /// [].product()               // 1 (identity)
    /// ```
    public func product() -> Element {
        reduce(1, *)
    }
}

extension Sequence where Element: BinaryInteger {
    /// Computes arithmetic mean of elements
    ///
    /// Average value via sum divided by count.
    /// Returns nil for empty sequences to maintain totality.
    ///
    /// Category theory: Composition of sum with scalar division
    /// mean: Seq(ℤ) → Maybe(ℤ) where mean(xs) = sum(xs) / |xs|
    ///
    /// Example:
    /// ```swift
    /// [1, 2, 3, 4, 5].mean()  // Optional(3)
    /// [10, 20, 30].mean()     // Optional(20)
    /// [].mean()               // nil
    /// ```
    public func mean() -> Element? {
        let elements = Array(self)
        guard !elements.isEmpty else { return nil }
        return elements.reduce(.zero, +) / Element(elements.count)
    }
}

extension Sequence where Element: BinaryFloatingPoint {
    /// Computes arithmetic mean of elements
    ///
    /// Average value via sum divided by count.
    /// Returns nil for empty sequences to maintain totality.
    ///
    /// Category theory: Composition of sum with scalar division
    /// mean: Seq(ℝ) → Maybe(ℝ) where mean(xs) = sum(xs) / |xs|
    ///
    /// Example:
    /// ```swift
    /// [1.0, 2.0, 3.0, 4.0, 5.0].mean()  // Optional(3.0)
    /// [10.5, 20.5, 30.5].mean()         // Optional(20.5)
    /// [].mean()                          // nil
    /// ```
    public func mean() -> Element? {
        var sum: Element = 0
        var count: Element = 0

        for element in self {
            sum += element
            count += 1
        }

        guard count > 0 else { return nil }
        return sum / count
    }
}
