// Ordinal.swift
// The canonical finite type with exactly N inhabitants.

/// A value in the finite set {0, 1, ..., N-1}.
///
/// `Ordinal<N>` represents the finite ordinal n in set theory — the set of
/// all natural numbers less than n. It is the canonical type with exactly N
/// distinct inhabitants, and serves as the foundation for any type with a
/// fixed, finite number of values determined at compile time.
///
/// ## Mathematical Background
///
/// In set theory, the **ordinal n** is defined as:
/// ```
/// 0 = {}
/// 1 = {0}
/// 2 = {0, 1}
/// n = {0, 1, ..., n-1}
/// ```
///
/// This is also known as the **von Neumann ordinal** construction. Each
/// ordinal n is simultaneously:
/// - The set of all smaller ordinals
/// - A canonical representative of the cardinality n
///
/// In type theory (Idris, Agda, Coq), this type is called `Fin n`.
///
/// ## Relationship to Other Types
///
/// Many types are isomorphic to `Ordinal<N>`:
/// - `Axis<N>` (coordinate axes in N-dimensional space)
/// - `Bool` is isomorphic to `Ordinal<2>`
/// - `Ordering` is isomorphic to `Ordinal<3>`
/// - Array indices for fixed-size arrays are `Ordinal<N>`
///
/// ## Usage
///
/// ```swift
/// // Create ordinal values
/// let zero: Ordinal<5> = .zero
/// let three = Ordinal<5>(3)!
///
/// // Iterate over all values
/// for i in Ordinal<4>.allCases {
///     print(i.rawValue)  // 0, 1, 2, 3
/// }
///
/// // Use as array index (type-safe)
/// let values = [10, 20, 30]
/// let index: Ordinal<3> = Ordinal(1)!
/// let value = values[index]  // 20
/// ```
///
/// ## References
///
/// - [Von Neumann Ordinals](https://en.wikipedia.org/wiki/Ordinal_number#Von_Neumann_definition_of_ordinals)
/// - [Idris Fin Type](https://docs.idris-lang.org/en/latest/tutorial/typesfuns.html)
/// - [Agda Data.Fin](https://agda.github.io/agda-stdlib/Data.Fin.html)
///
public struct Ordinal<let N: Int>: Sendable, Hashable {
    /// The underlying integer value (0 to N-1).
    public let rawValue: Int

    /// Creates an ordinal from an integer, if within bounds.
    ///
    /// - Parameter rawValue: An integer in the range 0..<N
    /// - Returns: The ordinal, or nil if out of bounds
    @inlinable
    public init?(_ rawValue: Int) {
        guard rawValue >= 0 && rawValue < N else { return nil }
        self.rawValue = rawValue
    }

    /// Creates an ordinal without bounds checking.
    ///
    /// - Precondition: `rawValue` must be in 0..<N
    @inlinable
    public init(unchecked rawValue: Int) {
        self.rawValue = rawValue
    }
}

// MARK: - Special Values

extension Ordinal {
    // The zero value (first element).
    //
    // - Note: Ideally this would only be available when N >= 1, but Swift
    //   does not yet support `where` clauses on properties.
    // FUTURE: public static var zero: Self where N >= 1 { ... }
    @inlinable
    public static var zero: Self {
        Self(unchecked: 0)
    }

    // The maximum value (N - 1).
    //
    // - Note: Ideally this would only be available when N >= 1, but Swift
    //   does not yet support `where` clauses on properties.
    // FUTURE: public static var max: Self where N >= 1 { ... }
    @inlinable
    public static var max: Self {
        Self(unchecked: N - 1)
    }

    /// The number of inhabitants of this type.
    @inlinable
    public static var count: Int { N }
}

// MARK: - Comparable

extension Ordinal: Comparable {
    @inlinable
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

// MARK: - Codable

extension Ordinal: Codable {
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(Int.self)
        guard let ordinal = Self(value) else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription:
                        "Value \(value) out of bounds for Ordinal<\(N)> (expected 0..<\(N))"
                )
            )
        }
        self = ordinal
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

// MARK: - Conversion

extension Ordinal {
    // Converts this value to an `Ordinal` of a different domain.
    //
    // This is safe when M >= N, as every value in Ordinal<N> is also valid in Ordinal<M>.
    //
    // ```swift
    // let small: Ordinal<3> = Ordinal(2)!
    // let large: Ordinal<10> = small.injected()  // Still represents 2
    // ```
    //
    // - Note: Ideally this would have a `where M >= N` constraint, but Swift
    //   does not yet support comparison constraints on integer generic parameters.
    // FUTURE: public func injected<let M: Int>() -> Ordinal<M> where M >= N { ... }
    // - Precondition: `rawValue` must be less than M
    @inlinable
    public func injected<let M: Int>() -> Ordinal<M> {
        Ordinal<M>(unchecked: rawValue)
    }

    /// Attempts to convert this value to an `Ordinal` of a smaller domain.
    ///
    /// Returns nil if the value is too large for the target domain.
    ///
    /// ```swift
    /// let large: Ordinal<10> = try Ordinal(2)
    /// let small: Ordinal<3>? = large.projected()  // Ordinal<3>(2)
    ///
    /// let tooBig: Ordinal<10> = try Ordinal(5)
    /// let failed: Ordinal<3>? = tooBig.projected()  // nil
    /// ```
    @inlinable
    public func projected<let M: Int>() -> Ordinal<M>? {
        Ordinal<M>(rawValue)
    }
}

// MARK: - Ordinal: Enumerable

extension Ordinal: Enumerable {
    /// The number of values in Ordinal<N>.
    @inlinable
    public static var caseCount: Int { N }

    /// The index of this value.
    @inlinable
    public var caseIndex: Int { rawValue }

    /// Creates a value from its index.
    @inlinable
    public init(caseIndex: Int) {
        self.init(unchecked: caseIndex)
    }
}

// MARK: - Array Subscripting

extension Array {
    /// Accesses the element at a type-safe index.
    ///
    /// Using `Ordinal<N>` as an index guarantees the access is within bounds
    /// for arrays of exactly N elements.
    ///
    /// ```swift
    /// let colors = ["red", "green", "blue"]
    /// let index: Ordinal<3> = Ordinal(1)!
    /// print(colors[index])  // "green"
    /// ```
    @inlinable
    public subscript<let N: Int>(index: Ordinal<N>) -> Element {
        self[index.rawValue]
    }
}

// MARK: - Type Alias

/// Type alias for `Ordinal`, using the traditional type-theoretic name.
///
/// In dependent type theory (Idris, Agda, Coq), the finite type with N
/// inhabitants is conventionally called `Fin n`. This alias is provided
/// for those familiar with that convention.
public typealias Fin = Ordinal
