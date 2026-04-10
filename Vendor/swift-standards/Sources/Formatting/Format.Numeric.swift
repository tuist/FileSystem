// Format.Numeric.swift
// Namespace for numeric formatting functionality.

/// A namespace for numeric formatting functionality.
///
/// Provides types and protocols for formatting integers and floating-point numbers.
///
/// ## Example
///
/// ```swift
/// 42.formatted(.number)  // "42"
/// 3.14159.formatted(.number.precision(.fractionLength(2)))  // "3.14"
/// ```
extension Format {
    public enum Numeric {}
}
