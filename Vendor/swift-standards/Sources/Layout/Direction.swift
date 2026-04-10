// Direction.swift
// Text/content layout direction.

/// Typealias for convenient access to Layout.Direction.
public typealias Direction = Layout<Never>.Direction

extension Layout {
    /// Layout direction for text and content flow.
    ///
    /// Determines how "leading" and "trailing" map to "left" and "right".
    ///
    /// ## Convention
    ///
    /// - `.leftToRight`: leading = left, trailing = right (e.g., English)
    /// - `.rightToLeft`: leading = right, trailing = left (e.g., Arabic, Hebrew)
    public enum Direction: Sendable, Hashable, Codable, CaseIterable {
        /// Left-to-right layout (leading = left).
        case leftToRight

        /// Right-to-left layout (leading = right).
        case rightToLeft
    }
}

// MARK: - Aliases

extension Layout.Direction {
    /// Left-to-right layout.
    public static var ltr: Self { .leftToRight }

    /// Right-to-left layout.
    public static var rtl: Self { .rightToLeft }
}

// MARK: - Opposite

extension Layout.Direction {
    /// The opposite layout direction.
    @inlinable
    public var opposite: Layout.Direction {
        switch self {
        case .leftToRight: return .rightToLeft
        case .rightToLeft: return .leftToRight
        }
    }
}
