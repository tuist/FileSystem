// Corner.swift
// Rectangle corners as product of Horizontal × Vertical.

public import Algebra
public import Dimension

extension Region {
    /// Corner of a rectangle.
    ///
    /// A corner is the product of a horizontal position and a vertical position,
    /// representing `Horizontal × Vertical` (Z₂ × Z₂).
    ///
    /// ## Mathematical Properties
    ///
    /// - Product type: `Horizontal × Vertical`
    /// - 4 elements = 2 × 2
    /// - `opposite` flips both components
    ///
    /// ## Naming Convention
    ///
    /// Uses absolute directions (left/right, top/bottom), not layout-relative
    /// terms (leading/trailing). For layout-aware corners, see `Layout.Corner`.
    ///
    /// ## Tagged Values
    ///
    /// Use `Corner.Value<T>` to pair a value with its corner:
    ///
    /// ```swift
    /// let radius: Region.Corner.Value<CGFloat> = .init(tag: .topLeft, value: 8)
    /// ```
    public struct Corner: Sendable, Hashable, Codable {
        /// The horizontal position (leftward or rightward).
        public var horizontal: Horizontal

        /// The vertical position (upward = top, downward = bottom).
        public var vertical: Vertical

        /// Create a corner from horizontal and vertical positions.
        @inlinable
        public init(horizontal: Horizontal, vertical: Vertical) {
            self.horizontal = horizontal
            self.vertical = vertical
        }
    }
}

// MARK: - Named Corners

extension Region.Corner {
    /// Top-left corner.
    public static let topLeft = Region.Corner(horizontal: .leftward, vertical: .upward)

    /// Top-right corner.
    public static let topRight = Region.Corner(horizontal: .rightward, vertical: .upward)

    /// Bottom-left corner.
    public static let bottomLeft = Region.Corner(horizontal: .leftward, vertical: .downward)

    /// Bottom-right corner.
    public static let bottomRight = Region.Corner(horizontal: .rightward, vertical: .downward)
}

// MARK: - CaseIterable

extension Region.Corner: CaseIterable {
    public static let allCases: [Region.Corner] = [
        .topLeft, .topRight, .bottomLeft, .bottomRight,
    ]
}

// MARK: - Opposite

extension Region.Corner {
    /// The diagonally opposite corner.
    @inlinable
    public var opposite: Region.Corner {
        Region.Corner(horizontal: horizontal.opposite, vertical: vertical.opposite)
    }

    /// Returns the diagonally opposite corner.
    @inlinable
    public static prefix func ! (value: Region.Corner) -> Region.Corner {
        value.opposite
    }
}

// MARK: - Properties

extension Region.Corner {
    /// True if this is a top corner.
    @inlinable
    public var isTop: Bool { vertical == .upward }

    /// True if this is a bottom corner.
    @inlinable
    public var isBottom: Bool { vertical == .downward }

    /// True if this is a left corner.
    @inlinable
    public var isLeft: Bool { horizontal == .leftward }

    /// True if this is a right corner.
    @inlinable
    public var isRight: Bool { horizontal == .rightward }
}

// MARK: - Adjacent Corners

extension Region.Corner {
    /// The corner horizontally adjacent to this one.
    @inlinable
    public var horizontalAdjacent: Region.Corner {
        Region.Corner(horizontal: horizontal.opposite, vertical: vertical)
    }

    /// The corner vertically adjacent to this one.
    @inlinable
    public var verticalAdjacent: Region.Corner {
        Region.Corner(horizontal: horizontal, vertical: vertical.opposite)
    }
}

// MARK: - Tagged Value

extension Region.Corner {
    /// A value paired with its corner.
    public typealias Value<Payload> = Tagged<Region.Corner, Payload>
}
