// Bool.swift
// swift-standards
//
// Extensions for Swift standard library Bool

extension Bool {
    /// Numeric representation as integer
    ///
    /// Natural embedding 𝔹 → ℤ/2ℤ into integers mod 2.
    /// Maps Boolean algebra into ring structure.
    ///
    /// Category theory: Ring homomorphism from (𝔹, ∧, ∨) to (ℤ/2ℤ, ·, +)
    /// where true ↦ 1, false ↦ 0
    ///
    /// Example:
    /// ```swift
    /// true.int   // 1
    /// false.int  // 0
    /// ```
    public var int: Int { .init(self) }
}
