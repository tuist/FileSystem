// Enumeration.swift
// Zero-allocation sequence over Enumerable types.

/// A lazy, zero-allocation sequence over an ``Enumerable`` type.
///
/// `Enumeration` provides efficient iteration over any enumerable type without
/// allocating an intermediate array. It conforms to `RandomAccessCollection`,
/// enabling O(1) subscript access.
///
/// ## Zero-Size Type
///
/// `Enumeration` contains no stored properties — it's a zero-size type.
/// All information comes from the `Element` type's static properties.
///
/// ## Usage
///
/// This type is typically used indirectly through `CaseIterable`:
///
/// ```swift
/// for value in MyEnumerableType.allCases {
///     // Enumeration provides the iteration
/// }
///
/// // Random access works
/// let third = MyEnumerableType.allCases[2]
/// ```
///
public struct Enumeration<Element: Enumerable>: Sequence, Sendable {
    /// Creates a sequence over all values of the element type.
    @inlinable
    public init() {}

    /// Returns an iterator over all values.
    @inlinable
    public func makeIterator() -> Iterator {
        Iterator()
    }

    /// An iterator that lazily produces each value in index order.
    public struct Iterator: IteratorProtocol, Sendable {
        @usableFromInline
        var index: Int = 0

        @inlinable
        init() {}

        /// Returns the next value, or nil if exhausted.
        @inlinable
        public mutating func next() -> Element? {
            guard index < Element.caseCount else { return nil }
            defer { index += 1 }
            return Element(caseIndex: index)
        }
    }
}

// MARK: - Enumeration: Collection

extension Enumeration: Collection {
    /// The position of the first element (always 0).
    @inlinable
    public var startIndex: Int { 0 }

    /// The position past the last element.
    @inlinable
    public var endIndex: Int { Element.caseCount }

    /// Returns the element at the given position.
    @inlinable
    public subscript(position: Int) -> Element {
        precondition(
            position >= 0 && position < Element.caseCount,
            "Index \(position) out of bounds for \(Element.self)"
        )
        return Element(caseIndex: position)
    }

    /// Returns the position immediately after the given index.
    @inlinable
    public func index(after i: Int) -> Int {
        i + 1
    }
}

// MARK: - Enumeration: BidirectionalCollection

extension Enumeration: BidirectionalCollection {
    /// Returns the position immediately before the given index.
    @inlinable
    public func index(before i: Int) -> Int {
        i - 1
    }
}

// MARK: - Enumeration: RandomAccessCollection

extension Enumeration: RandomAccessCollection {
    /// The number of elements.
    @inlinable
    public var count: Int { Element.caseCount }

    /// Returns the distance between two indices.
    @inlinable
    public func distance(from start: Int, to end: Int) -> Int {
        end - start
    }

    /// Returns an index offset by the given distance.
    @inlinable
    public func index(_ i: Int, offsetBy distance: Int) -> Int {
        i + distance
    }

    /// Returns an index offset by the given distance, limited by a boundary.
    @inlinable
    public func index(_ i: Int, offsetBy distance: Int, limitedBy limit: Int) -> Int? {
        let result = i + distance
        if distance >= 0 {
            return result <= limit ? result : nil
        } else {
            return result >= limit ? result : nil
        }
    }
}
