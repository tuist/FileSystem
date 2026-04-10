// Horizontal.swift
// Horizontal axis namespace.

/// Horizontal axis namespace.
///
/// Contains types related to the horizontal axis.
public import Dimension

// MARK: - Alignment

extension Horizontal {
    /// Horizontal alignment within a container.
    ///
    /// Used for positioning content along the horizontal axis.
    ///
    /// ## Semantic Meaning
    ///
    /// - `.leading`: Start edge (left in LTR, right in RTL)
    /// - `.center`: Horizontal center
    /// - `.trailing`: End edge (right in LTR, left in RTL)
    public enum Alignment: Sendable, Hashable, Codable, CaseIterable {
        /// Align to the leading edge (left in LTR, right in RTL).
        case leading

        /// Align to the horizontal center.
        case center

        /// Align to the trailing edge (right in LTR, left in RTL).
        case trailing
    }
}
