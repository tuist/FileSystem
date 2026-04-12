// Enumerable.swift
// Protocol for types with finitely many indexed inhabitants.

/// A type with a finite number of values that can be enumerated by index.
///
/// `Enumerable` captures the essence of finite types that can be listed
/// exhaustively. Any type conforming to this protocol automatically gains
/// `CaseIterable` conformance with a zero-allocation sequence.
///
/// ## Mathematical Interpretation
///
/// An `Enumerable` type with `caseCount` N is isomorphic to `Ordinal<N>`.
/// The protocol witnesses this isomorphism:
/// - `init(caseIndex:)` is the map `Ordinal<N> -> Self`
/// - `caseIndex` is the inverse `Self -> Ordinal<N>`
///
/// ## Automatic CaseIterable
///
/// Types conforming to `Enumerable` get `CaseIterable` conformance for free,
/// with `Enumeration` as the `AllCases` type — a zero-allocation
/// `RandomAccessCollection`.
///
/// ## Usage
///
/// ```swift
/// struct CardSuit: Enumerable {
///     static let caseCount = 4
///     let caseIndex: Int
///
///     init(caseIndex: Int) {
///         self.caseIndex = caseIndex
///     }
///
///     static let hearts = CardSuit(caseIndex: 0)
///     static let diamonds = CardSuit(caseIndex: 1)
///     static let clubs = CardSuit(caseIndex: 2)
///     static let spades = CardSuit(caseIndex: 3)
/// }
///
/// // Automatically iterable
/// for suit in CardSuit.allCases { ... }
/// ```
///
/// ## For Integer-Generic Types
///
/// Types parameterized by `<let N: Int>` can conform easily:
///
/// ```swift
/// extension Axis: Enumerable {
///     public static var caseCount: Int { N }
///     public var caseIndex: Int { rawValue }
///     public init(caseIndex: Int) {
///         self.init(unchecked: caseIndex)
///     }
/// }
/// ```
///
public protocol Enumerable: CaseIterable, Sendable {
    /// The number of distinct values of this type.
    static var caseCount: Int { get }

    /// The index of this value (0 to caseCount-1).
    var caseIndex: Int { get }

    /// Creates a value from its index.
    ///
    /// - Precondition: `caseIndex` must be in 0..<caseCount
    init(caseIndex: Int)
}

// MARK: - Default CaseIterable Implementation

extension Enumerable {
    /// All values of this type, lazily enumerated.
    ///
    /// The `AllCases` associated type is inferred as `Enumeration<Self>`.
    @inlinable
    public static var allCases: Enumeration<Self> {
        Enumeration()
    }
}

// MARK: - Safe Initializer

extension Enumerable {
    /// Creates a value from its index, if within bounds.
    ///
    /// - Parameter index: An integer in 0..<caseCount
    /// - Returns: The value at that index, or nil if out of bounds
    @inlinable
    public init?(validatingCaseIndex index: Int) {
        guard index >= 0 && index < Self.caseCount else { return nil }
        self.init(caseIndex: index)
    }
}
