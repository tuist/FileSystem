// Edge.swift
// Rectangle edges.

public import Algebra

extension Region {
    /// Edge of a rectangle.
    ///
    /// Uses absolute directions (left/right, top/bottom), not layout-relative
    /// terms (leading/trailing). For layout-aware edges, see `Layout.Edge`.
    ///
    /// ## Tagged Values
    ///
    /// Use `Edge.Value<T>` to pair an offset with its edge:
    ///
    /// ```swift
    /// let inset: Region.Edge.Value<CGFloat> = .init(tag: .top, value: 20)
    /// ```
    public enum Edge: Sendable, Hashable, Codable, CaseIterable {
        /// Top edge.
        case top

        /// Left edge.
        case left

        /// Bottom edge.
        case bottom

        /// Right edge.
        case right
    }
}

// MARK: - Opposite

extension Region.Edge {
    /// The opposite edge.
    @inlinable
    public var opposite: Region.Edge {
        switch self {
        case .top: return .bottom
        case .left: return .right
        case .bottom: return .top
        case .right: return .left
        }
    }

    /// Returns the opposite edge.
    @inlinable
    public static prefix func ! (value: Region.Edge) -> Region.Edge {
        value.opposite
    }
}

// MARK: - Orientation

extension Region.Edge {
    /// True if this is a horizontal edge (top/bottom).
    @inlinable
    public var isHorizontal: Bool {
        self == .top || self == .bottom
    }

    /// True if this is a vertical edge (left/right).
    @inlinable
    public var isVertical: Bool {
        self == .left || self == .right
    }
}

// MARK: - Adjacent Corners

extension Region.Edge {
    /// The two corners that bound this edge.
    @inlinable
    public var corners: (Region.Corner, Region.Corner) {
        switch self {
        case .top: return (.topLeft, .topRight)
        case .left: return (.topLeft, .bottomLeft)
        case .bottom: return (.bottomLeft, .bottomRight)
        case .right: return (.topRight, .bottomRight)
        }
    }
}

// MARK: - Tagged Value

extension Region.Edge {
    /// A value paired with its edge.
    public typealias Value<Payload> = Tagged<Region.Edge, Payload>
}
