// Distribution.swift
// Space distribution along the main axis.

/// How space is distributed among items along the main axis.
///
/// Distribution controls how remaining space (after subtracting item sizes
/// and minimum spacing) is allocated within a container.
///
/// ## Visual Examples
///
/// Given a container `[          ]` with three items:
///
/// ```
/// fill:            [A  B  C      ]  // Items use only their spacing
/// space(.between): [A     B     C]  // Equal space between, none at edges
/// space(.around):  [ A    B    C ]  // Equal space around each item
/// space(.evenly):  [  A   B   C  ]  // Equal space everywhere
/// ```
public enum Distribution: Sendable, Hashable, Codable {
    /// Items are packed together, using only the specified spacing.
    case fill

    /// Distribute remaining space according to the given strategy.
    case space(Space)
}

// MARK: - Space

extension Distribution {
    /// Space distribution strategy.
    public enum Space: Sendable, Hashable, Codable, CaseIterable {
        /// Equal space between items, no space at edges.
        case between

        /// Equal space around each item (half-space at edges).
        case around

        /// Equal space between items and at edges.
        case evenly
    }
}

// MARK: - Convenience

extension Distribution {
    /// Equal space between items, no space at edges.
    @inlinable
    public static var spaceBetween: Self { .space(.between) }

    /// Equal space around each item (half-space at edges).
    @inlinable
    public static var spaceAround: Self { .space(.around) }

    /// Equal space between items and at edges.
    @inlinable
    public static var spaceEvenly: Self { .space(.evenly) }
}

// MARK: - CaseIterable

extension Distribution: CaseIterable {
    public static var allCases: [Distribution] {
        [.fill, .space(.between), .space(.around), .space(.evenly)]
    }
}
