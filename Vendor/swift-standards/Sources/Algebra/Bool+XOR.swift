// Bool+XOR.swift
// Logical XOR operator for Bool.

/// Logical XOR (exclusive or) operator for Bool.
///
/// Returns `true` if exactly one operand is `true`.
///
/// ## Truth Table
///
/// | A | B | A ^ B |
/// |---|---|-------|
/// | F | F |   F   |
/// | F | T |   T   |
/// | T | F |   T   |
/// | T | T |   F   |
///
/// ## Example
///
/// ```swift
/// let a = true
/// let b = false
/// print(a ^ b)  // true
/// print(a ^ a)  // false
/// ```
@inlinable
public func ^ (lhs: Bool, rhs: Bool) -> Bool {
    lhs != rhs
}
