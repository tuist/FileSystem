// Axis.Vertical.swift
// Typealias for vertical orientation on 2D+ axes.

extension Axis where N == 2 {
    /// Vertical (Y) axis orientation convention.
    ///
    /// This is a typealias to `Vertical`, providing convenient access
    /// via `Axis<2>.Vertical`. The underlying type is dimension-independent.
    public typealias Vertical = Dimension.Vertical
}

extension Axis where N == 3 {
    /// Vertical (Y) axis orientation convention.
    public typealias Vertical = Dimension.Vertical
}

extension Axis where N == 4 {
    /// Vertical (Y) axis orientation convention.
    public typealias Vertical = Dimension.Vertical
}
