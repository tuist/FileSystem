// Tagged.swift
// A value paired with a classifying tag.

/// A value paired with a classifying tag.
///
/// `Tagged` captures the general pattern of associating a value with
/// a discrete classifier. This is the product type `Tag × Value` in
/// category-theoretic terms.
///
/// ## Examples
///
/// Many domain-specific types follow this pattern:
///
/// ```swift
/// // An orientation paired with a magnitude
/// typealias Oriented<O: Orientation, S> = Tagged<O, S>
/// let velocity: Oriented<Vertical, Double> = Tagged(tag: .upward, value: 9.8)
///
/// // A bound paired with a limit value
/// typealias Bounded<S> = Tagged<Bound, S>
/// let lower: Bounded<Int> = Tagged(tag: .lower, value: 0)
///
/// // A boundary type paired with an endpoint
/// typealias Endpoint<S> = Tagged<Boundary, S>
/// let open: Endpoint<Double> = Tagged(tag: .open, value: 1.0)
/// ```
///
/// ## Mathematical Background
///
/// In type theory, `Tagged<Tag, Value>` is the dependent pair (Σ-type)
/// where the second component doesn't depend on the first. This is
/// simply the cartesian product `Tag × Value`.
///
/// When `Tag` is a finite type (like an enum), `Tagged<Tag, Value>`
/// can be seen as a coproduct (sum type) where each variant carries
/// the same payload type — but represented as a product for efficiency.
///
public struct Tagged<Tag, Value> {
    /// The classifying tag.
    public var tag: Tag

    /// The associated value.
    public var value: Value

    /// Creates a tagged value.
    @inlinable
    public init(tag: Tag, value: Value) {
        self.tag = tag
        self.value = value
    }
}

// MARK: - Conditional Conformances

extension Tagged: Sendable where Tag: Sendable, Value: Sendable {}
extension Tagged: Equatable where Tag: Equatable, Value: Equatable {}
extension Tagged: Hashable where Tag: Hashable, Value: Hashable {}
extension Tagged: Codable where Tag: Codable, Value: Codable {}

// MARK: - Functor

extension Tagged {
    /// Transform the value while preserving the tag.
    ///
    /// This is the functorial map for `Tagged<Tag, _>`.
    @inlinable
    public func map<NewValue>(
        _ transform: (Value) throws -> NewValue
    ) rethrows -> Tagged<Tag, NewValue> {
        Tagged<Tag, NewValue>(tag: tag, value: try transform(value))
    }

    /// Transform the tag while preserving the value.
    ///
    /// This is the functorial map for `Tagged<_, Value>`.
    @inlinable
    public func mapTag<NewTag>(
        _ transform: (Tag) throws -> NewTag
    ) rethrows -> Tagged<NewTag, Value> {
        Tagged<NewTag, Value>(tag: try transform(tag), value: value)
    }

    /// Transform both the tag and value.
    ///
    /// This is the bifunctorial map.
    @inlinable
    public func bimap<NewTag, NewValue>(
        tag tagTransform: (Tag) throws -> NewTag,
        value valueTransform: (Value) throws -> NewValue
    ) rethrows -> Tagged<NewTag, NewValue> {
        Tagged<NewTag, NewValue>(
            tag: try tagTransform(tag),
            value: try valueTransform(value)
        )
    }
}

// MARK: - Enumerable Tags

extension Tagged where Tag: CaseIterable {
    /// All possible tags for this tagged type.
    @inlinable
    public static var allTags: Tag.AllCases {
        Tag.allCases
    }
}
