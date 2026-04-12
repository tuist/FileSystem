// Double.swift
// swift-standards
//
// Extensions for Swift standard library Double

extension Double {
    /// Rounds to specified decimal places
    ///
    /// Quantization morphism to discrete subset.
    /// Projects continuous reals onto decimal lattice.
    ///
    /// Category theory: Quotient morphism ℝ → ℝ/~
    /// where x ~ y iff round(x, n) = round(y, n)
    ///
    /// Example:
    /// ```swift
    /// 3.14159.rounded(to: 2)  // 3.14
    /// ```
    public func rounded(to places: Int) -> Double {
        guard places >= 0 else { return self }
        var divisor: Double = 1.0
        for _ in 0..<places {
            divisor *= 10.0
        }
        return (self * divisor).rounded() / divisor
    }
}
