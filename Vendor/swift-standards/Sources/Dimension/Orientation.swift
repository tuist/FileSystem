// Orientation.swift
// The abstract theory of binary orientation.

public import Algebra

/// A type with exactly two values that are opposites of each other.
///
/// `Orientation` captures the abstract structure shared by all binary
/// orientation types: `Direction`, `Horizontal`, `Vertical`, `Depth`,
/// and `Temporal`. Mathematically, any `Orientation` is isomorphic to:
/// - `Bool` (true/false)
/// - Z/2Z (integers mod 2)
/// - The multiplicative group {-1, +1}
/// - The finite set 2 = {0, 1}
///
/// ## The Theory
///
/// An orientation type has exactly two inhabitants that are each other's
/// opposite. This gives us:
/// - `opposite`: The other value
/// - `!`: Prefix negation operator (alias for opposite)
/// - Involution law: `x.opposite.opposite == x`
///
/// ## Relationship to Direction
///
/// `Direction` is the **canonical** orientation - it represents pure
/// polarity without domain-specific interpretation. Other orientations
/// interpret Direction in specific contexts:
/// - `Horizontal`: positive → rightward, negative → leftward
/// - `Vertical`: positive → upward, negative → downward
/// - `Depth`: positive → forward, negative → backward
/// - `Temporal`: positive → future, negative → past
///
/// All orientations can convert to/from `Direction`, making the
/// isomorphism explicit.
///
/// ## Category Theory
///
/// This protocol defines a **theory** (in the sense of categorical
/// semantics). Conforming types are **models** of this theory.
/// `Direction` is the **initial model** (free algebra), while the
/// struct-based orientations are models with additional semantic meaning.
///
public protocol Orientation: Sendable, Hashable, CaseIterable where AllCases == [Self] {
    /// The opposite orientation.
    ///
    /// This is an involution: `x.opposite.opposite == x`
    var opposite: Self { get }

    /// The underlying canonical direction.
    ///
    /// This makes the isomorphism `Self ≅ Direction` explicit.
    var direction: Direction { get }

    /// Creates an orientation from a canonical direction.
    ///
    /// This is the inverse of `direction`, completing the isomorphism.
    init(direction: Direction)
}

// MARK: - Default Implementations

extension Orientation {
    /// Returns the opposite orientation.
    ///
    /// Uses the `!` prefix operator, mirroring `Bool` negation.
    @inlinable
    public static prefix func ! (value: Self) -> Self {
        value.opposite
    }

    /// All cases, derived from Direction's cases.
    @inlinable
    public static var allCases: [Self] {
        Direction.allCases.map { Self(direction: $0) }
    }
}

// MARK: - Generic Operations

extension Orientation {
    /// Returns `positive` if the condition is true, `negative` otherwise.
    ///
    /// This is the isomorphism `Bool → Orientation`.
    @inlinable
    public init(_ condition: Bool) {
        self.init(direction: condition ? Direction.positive : Direction.negative)
    }

    /// Whether this is the "positive" orientation.
    @inlinable
    public var isPositive: Bool {
        direction == Direction.positive
    }

    /// Whether this is the "negative" orientation.
    @inlinable
    public var isNegative: Bool {
        direction == Direction.negative
    }
}

/// A value paired with an orientation.
///
/// `Oriented` is a specialization of `Tagged` for orientation types,
/// providing the `direction` property as an alias for `tag`.
///
/// ## Usage
///
/// ```swift
/// let velocity: Oriented<Vertical, Double> = Oriented(direction: .upward, value: 9.8)
/// print(velocity.direction)  // .upward
/// print(velocity.value)      // 9.8
/// ```
///
public typealias Oriented<O: Orientation, Scalar> = Tagged<O, Scalar>

// MARK: - Orientation-specific API

extension Tagged where Tag: Orientation {
    /// The orientation (alias for `tag`).
    @inlinable
    public var direction: Tag {
        get { tag }
        set { tag = newValue }
    }

    /// Creates an oriented value.
    @inlinable
    public init(direction: Tag, value: Value) {
        self.init(tag: direction, value: value)
    }
}

extension Orientation {
    public typealias Value<Scalar> = Oriented<Self, Scalar>
}
