// Vertical.swift
// Vertical axis namespace.

public import Dimension

// MARK: - Baseline

extension Vertical {
    /// Text baseline position.
    public enum Baseline: Sendable, Hashable, Codable, CaseIterable {
        /// The first line's baseline.
        case first

        /// The last line's baseline.
        case last
    }
}

// MARK: - Alignment

extension Vertical {
    /// Vertical alignment within a container.
    ///
    /// Used for positioning content along the vertical axis.
    ///
    /// ## Semantic Meaning
    ///
    /// - `.top`: Top edge
    /// - `.center`: Vertical center
    /// - `.bottom`: Bottom edge
    /// - `.baseline(.first)`: Align to first line of text baseline
    /// - `.baseline(.last)`: Align to last line of text baseline
    public enum Alignment: Sendable, Hashable, Codable {
        /// Align to the top edge.
        case top

        /// Align to the vertical center.
        case center

        /// Align to the bottom edge.
        case bottom

        /// Align to a text baseline.
        case baseline(Vertical.Baseline)
    }
}

// MARK: - Alignment Convenience

extension Vertical.Alignment {
    /// Align to the first text baseline (for text content).
    @inlinable
    public static var firstBaseline: Self { .baseline(.first) }

    /// Align to the last text baseline (for text content).
    @inlinable
    public static var lastBaseline: Self { .baseline(.last) }
}

// MARK: - Alignment CaseIterable

extension Vertical.Alignment: CaseIterable {
    public static var allCases: [Vertical.Alignment] {
        [.top, .center, .bottom, .baseline(.first), .baseline(.last)]
    }
}
