// Axis.Direction.swift
// Direction along an axis.

// MARK: - Axis.Direction typealias

extension Axis {
    /// Direction along an axis.
    ///
    /// This is a typealias to `Direction`, so `Axis<2>.Direction` and
    /// `Axis<3>.Direction` are the same type - as they should be,
    /// since direction is a dimension-independent concept.
    public typealias Direction = Dimension.Direction
}
