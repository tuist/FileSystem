// Axis.Horizontal.swift
// Typealias for horizontal orientation on 2D+ axes.

extension Axis where N == 2 {
    /// Horizontal (X) axis orientation convention.
    ///
    /// This is a typealias to `Horizontal`, providing convenient access
    /// via `Axis<2>.Horizontal`. The underlying type is dimension-independent.
    public typealias Horizontal = Dimension.Horizontal
}

extension Axis where N == 3 {
    /// Horizontal (X) axis orientation convention.
    public typealias Horizontal = Dimension.Horizontal
}

extension Axis where N == 4 {
    /// Horizontal (X) axis orientation convention.
    public typealias Horizontal = Dimension.Horizontal
}
