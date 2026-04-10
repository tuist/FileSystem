// Corner.swift
// Layout-aware rectangle corners.

public import Dimension
public import Region

/// A layout-aware corner of a rectangle.
///
/// Uses leading/trailing terminology which adapts to layout direction.
/// For absolute left/right corners, see `Region.Corner`.
///
/// ## Resolving to Absolute Corners
///
/// ```swift
/// let corner: Corner = .topLeading
/// let absolute = Region.Corner(corner, direction: .leftToRight)  // .topLeft
/// let rtl = Region.Corner(corner, direction: .rightToLeft)       // .topRight
/// ```
public struct Corner: Sendable, Hashable, Codable {
    /// The horizontal side (leading or trailing).
    public var horizontal: Horizontal.Alignment.Side

    /// The vertical side (top or bottom).
    public var vertical: Vertical.Alignment.Side

    /// Create a corner from horizontal and vertical sides.
    @inlinable
    public init(horizontal: Horizontal.Alignment.Side, vertical: Vertical.Alignment.Side) {
        self.horizontal = horizontal
        self.vertical = vertical
    }
}

// MARK: - Horizontal Side

extension Horizontal.Alignment {
    /// A horizontal side (without center).
    public enum Side: Sendable, Hashable, Codable, CaseIterable {
        /// The leading side (left in LTR, right in RTL).
        case leading
        /// The trailing side (right in LTR, left in RTL).
        case trailing

        /// The opposite side.
        @inlinable
        public var opposite: Side {
            switch self {
            case .leading: return .trailing
            case .trailing: return .leading
            }
        }
    }
}

// MARK: - Horizontal from Side

extension Horizontal {
    /// Create from a layout-relative side and direction.
    @inlinable
    public init(_ side: Horizontal.Alignment.Side, direction: Direction) {
        switch (side, direction) {
        case (.leading, .leftToRight), (.trailing, .rightToLeft):
            self = .leftward
        case (.trailing, .leftToRight), (.leading, .rightToLeft):
            self = .rightward
        }
    }
}

// MARK: - Vertical Side

extension Vertical.Alignment {
    /// A vertical side (without center).
    public enum Side: Sendable, Hashable, Codable, CaseIterable {
        /// The top side.
        case top
        /// The bottom side.
        case bottom

        /// The opposite side.
        @inlinable
        public var opposite: Side {
            switch self {
            case .top: return .bottom
            case .bottom: return .top
            }
        }
    }
}

// MARK: - Vertical from Side

extension Vertical {
    /// Create from a layout-relative side.
    @inlinable
    public init(_ side: Vertical.Alignment.Side) {
        switch side {
        case .top: self = .upward
        case .bottom: self = .downward
        }
    }
}

// MARK: - Named Corners

extension Corner {
    /// Top-leading corner (top-left in LTR, top-right in RTL).
    public static let topLeading = Corner(horizontal: .leading, vertical: .top)

    /// Top-trailing corner (top-right in LTR, top-left in RTL).
    public static let topTrailing = Corner(horizontal: .trailing, vertical: .top)

    /// Bottom-leading corner (bottom-left in LTR, bottom-right in RTL).
    public static let bottomLeading = Corner(horizontal: .leading, vertical: .bottom)

    /// Bottom-trailing corner (bottom-right in LTR, bottom-left in RTL).
    public static let bottomTrailing = Corner(horizontal: .trailing, vertical: .bottom)
}

// MARK: - CaseIterable

extension Corner: CaseIterable {
    public static let allCases: [Corner] = [
        .topLeading, .topTrailing, .bottomLeading, .bottomTrailing,
    ]
}

// MARK: - Opposite

extension Corner {
    /// The diagonally opposite corner.
    @inlinable
    public var opposite: Corner {
        Corner(horizontal: horizontal.opposite, vertical: vertical.opposite)
    }

    /// Returns the diagonally opposite corner.
    @inlinable
    public static prefix func ! (value: Corner) -> Corner {
        value.opposite
    }
}

// MARK: - Properties

extension Corner {
    /// True if this is a top corner.
    @inlinable
    public var isTop: Bool { vertical == .top }

    /// True if this is a bottom corner.
    @inlinable
    public var isBottom: Bool { vertical == .bottom }

    /// True if this is a leading corner.
    @inlinable
    public var isLeading: Bool { horizontal == .leading }

    /// True if this is a trailing corner.
    @inlinable
    public var isTrailing: Bool { horizontal == .trailing }
}

// MARK: - Adjacent Corners

extension Corner {
    /// The corner horizontally adjacent to this one.
    @inlinable
    public var horizontalAdjacent: Corner {
        Corner(horizontal: horizontal.opposite, vertical: vertical)
    }

    /// The corner vertically adjacent to this one.
    @inlinable
    public var verticalAdjacent: Corner {
        Corner(horizontal: horizontal, vertical: vertical.opposite)
    }
}

// MARK: - Region.Corner from Layout.Corner

extension Region.Corner {
    /// Create from a layout-relative corner and direction.
    @inlinable
    public init(_ corner: Corner, direction: Direction) {
        self.init(
            horizontal: Horizontal(corner.horizontal, direction: direction),
            vertical: Vertical(corner.vertical)
        )
    }
}
