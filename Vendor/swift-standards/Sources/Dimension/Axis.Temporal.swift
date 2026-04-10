// Axis.Temporal.swift
// Typealias for temporal orientation on 4D+ axes.

extension Axis where N == 4 {
    /// Temporal (W/T) axis orientation convention.
    ///
    /// This is a typealias to `Temporal`, providing convenient access
    /// via `Axis<4>.Temporal`. The underlying type is dimension-independent.
    public typealias Temporal = Dimension.Temporal
}
