// FloatingPoint.swift
// swift-standards
//
// Extensions for Swift standard library FloatingPoint protocol

extension FloatingPoint {
    /// Tests approximate equality within tolerance
    ///
    /// Compares floating-point values with epsilon tolerance.
    /// Essential for numerical computing due to rounding errors.
    ///
    /// Category theory: Equivalence relation in metric space (ℝ, d)
    /// where d(x, y) ≤ ε defines equivalence classes
    ///
    /// Example:
    /// ```swift
    /// let a = 0.1 + 0.2
    /// let b = 0.3
    /// a.isApproximatelyEqual(to: b, tolerance: 0.0001)  // true
    /// a == b  // false (due to floating-point representation)
    /// ```
    public func isApproximatelyEqual(to other: Self, tolerance: Self) -> Bool {
        abs(self - other) <= tolerance
    }

    /// Linear interpolation between two values
    ///
    /// Computes point along line segment from self to other.
    /// Parameter t ∈ [0, 1] determines position (0 = self, 1 = other).
    ///
    /// Category theory: Affine combination in vector space
    /// lerp: ℝ × ℝ × [0,1] → ℝ where lerp(a, b, t) = a + t(b - a)
    /// Satisfies: lerp(a, b, 0) = a, lerp(a, b, 1) = b, lerp is continuous
    ///
    /// Example:
    /// ```swift
    /// let a = 0.0
    /// let b = 10.0
    /// a.lerp(to: b, t: 0.5)  // 5.0 (midpoint)
    /// a.lerp(to: b, t: 0.25) // 2.5 (quarter way)
    /// ```
    public func lerp(to other: Self, t: Self) -> Self {
        self + t * (other - self)
    }

    /// Computes self raised to an integer power using fast exponentiation
    ///
    /// Uses exponentiation by squaring for O(log n) complexity.
    /// More efficient than Foundation's pow() for integer exponents.
    ///
    /// Category theory: Group homomorphism from (ℤ, +) to (ℝ*, ×)
    /// power: ℝ × ℤ → ℝ where power(x, m+n) = power(x, m) × power(x, n)
    ///
    /// Example:
    /// ```swift
    /// 2.0.power(10)   // 1024.0
    /// 10.0.power(3)   // 1000.0
    /// 0.5.power(4)    // 0.0625
    /// ```
    public func power(_ exponent: Int) -> Self {
        guard exponent > 0 else { return exponent == 0 ? 1 : 0 }

        var result: Self = 1
        var base = self
        var n = exponent

        // Fast exponentiation by squaring: O(log n)
        while n > 0 {
            if n & 1 == 1 {
                result *= base
            }
            base *= base
            n >>= 1
        }
        return result
    }

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
    /// let pi: Double = 3.14159265359
    /// pi.rounded(to: 2)  // 3.14
    /// pi.rounded(to: 4)  // 3.1416
    /// ```
    public func rounded(to places: Int) -> Self {
        guard places >= 0 else { return self }
        let divisor = Self(10).power(places)
        return (self * divisor).rounded() / divisor
    }
}
