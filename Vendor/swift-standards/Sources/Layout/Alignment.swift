// Alignment.swift
// Combined horizontal and vertical alignment.

public import Dimension

/// A combined horizontal and vertical alignment.
///
/// Use this when you need to specify alignment in both dimensions,
/// such as positioning a single item within a container or aligning
/// grid cell content.
public struct Alignment: Sendable, Hashable, Codable {
    /// The horizontal alignment.
    public var horizontal: Horizontal.Alignment

    /// The vertical alignment.
    public var vertical: Vertical.Alignment

    /// Create an alignment with the given horizontal and vertical components.
    @inlinable
    public init(horizontal: Horizontal.Alignment, vertical: Vertical.Alignment) {
        self.horizontal = horizontal
        self.vertical = vertical
    }
}

// MARK: - Presets

extension Alignment {
    /// Top-leading corner.
    public static let topLeading = Self(horizontal: .leading, vertical: .top)

    /// Top center.
    public static let top = Self(horizontal: .center, vertical: .top)

    /// Top-trailing corner.
    public static let topTrailing = Self(horizontal: .trailing, vertical: .top)

    /// Center-leading.
    public static let leading = Self(horizontal: .leading, vertical: .center)

    /// Center.
    public static let center = Self(horizontal: .center, vertical: .center)

    /// Center-trailing.
    public static let trailing = Self(horizontal: .trailing, vertical: .center)

    /// Bottom-leading corner.
    public static let bottomLeading = Self(horizontal: .leading, vertical: .bottom)

    /// Bottom center.
    public static let bottom = Self(horizontal: .center, vertical: .bottom)

    /// Bottom-trailing corner.
    public static let bottomTrailing = Self(horizontal: .trailing, vertical: .bottom)
}
