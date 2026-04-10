// Axis+CaseIterable.swift
// CaseIterable conformance for Axis<N> via Enumerable.

public import Algebra

// MARK: - Axis: Enumerable

/// Extends `Axis` with `Enumerable` and `CaseIterable` conformance.
///
/// By conforming to `Enumerable`, `Axis<N>` automatically gains
/// `CaseIterable` conformance with a zero-allocation `Enumerable.Cases`
/// as the `AllCases` type.
///
/// ## Why Enumerable?
///
/// `Axis<N>` is isomorphic to `Ordinal<N>` — both represent exactly N distinct
/// values indexed from 0 to N-1. The `Enumerable` protocol captures this
/// relationship, allowing `Axis` to share iteration infrastructure with
/// other finite types.
///
/// ## Theoretical Background
///
/// This conformance solves a **value-dependent type problem** — the set of
/// valid axes depends on a *value* (`N`), not just a *type*. In type theory,
/// this falls into the domain of **dependent types**.
///
/// Languages like Idris and Agda handle this natively through their `Fin n`
/// type. Swift's integer generic parameters (SE-0452) provide a limited form
/// of value-level parameterization, and `Enumerable` bridges the gap to
/// enable generic finite iteration.
///
/// ## Usage
///
/// ```swift
/// // Iterate over all 3D axes
/// for axis in Axis<3>.allCases {
///     print(axis.rawValue)  // 0, 1, 2
/// }
///
/// // Access by index
/// let axes = Axis<4>.allCases
/// let third = axes[2]  // Axis<4> with rawValue 2
///
/// // Use with higher-order functions
/// let doubled = Axis<2>.allCases.map { $0.rawValue * 2 }  // [0, 2]
/// ```
///
/// ## References
///
/// - [SE-0452: Integer Generic Parameters](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0452-integer-generic-parameters.md)
/// - [Wikipedia: Dependent Types](https://en.wikipedia.org/wiki/Dependent_type)
///
extension Axis: Enumerable {
    /// The number of axes in N-dimensional space.
    @inlinable
    public static var caseCount: Int { N }

    /// The index of this axis (0 to N-1).
    @inlinable
    public var caseIndex: Int { rawValue }

    /// Creates an axis from its index.
    ///
    /// - Precondition: `caseIndex` must be in 0..<N
    @inlinable
    public init(caseIndex: Int) {
        self.init(unchecked: caseIndex)
    }
}
