// Cross.swift
// Cross-axis namespace.

/// Cross-axis namespace.
///
/// Contains types related to cross-axis positioning in layouts.
/// The cross axis is perpendicular to the main axis of a container.
public enum Cross {}

// MARK: - Alignment

extension Cross {
    /// Alignment along the cross axis of a stack.
    ///
    /// When stacking vertically (along `.secondary`), this controls horizontal alignment.
    /// When stacking horizontally (along `.primary`), this controls vertical alignment.
    ///
    /// ## Semantic Meaning
    ///
    /// The terms "leading", "center", and "trailing" are relative to the cross axis:
    /// - For vertical stacks: leading = left, trailing = right
    /// - For horizontal stacks: leading = top, trailing = bottom
    public enum Alignment: Sendable, Hashable, Codable, CaseIterable {
        /// Align to the start of the cross axis.
        ///
        /// - Vertical stack: left edge
        /// - Horizontal stack: top edge
        case leading

        /// Align to the center of the cross axis.
        case center

        /// Align to the end of the cross axis.
        ///
        /// - Vertical stack: right edge
        /// - Horizontal stack: bottom edge
        case trailing

        /// Stretch to fill the cross axis.
        ///
        /// Items are expanded to fill the available space perpendicular
        /// to the main axis.
        case fill
    }
}
