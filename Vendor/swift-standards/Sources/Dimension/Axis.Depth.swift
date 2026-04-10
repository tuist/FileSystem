// Axis.Depth.swift
// Typealias for depth orientation on 3D+ axes.

extension Axis where N == 3 {
    /// Depth (Z) axis orientation convention.
    ///
    /// This is a typealias to `Depth`, providing convenient access
    /// via `Axis<3>.Depth`. The underlying type is dimension-independent.
    public typealias Depth = Dimension.Depth
}

extension Axis where N == 4 {
    /// Depth (Z) axis orientation convention.
    public typealias Depth = Dimension.Depth
}
