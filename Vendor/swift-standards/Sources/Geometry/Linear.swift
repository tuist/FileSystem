// Linear.swift
// Typealias for backward compatibility.

/// An N×N linear transformation matrix using Double scalars.
///
/// This is a typealias to `Geometry<Double>.Linear<N>` for backward compatibility.
/// For type-safe geometry with different scalar types, use `Geometry<Scalar>.Linear<N>` directly.
///
/// ## Example
///
/// ```swift
/// let identity = Linear<2>.identity
/// let scaled = Linear<2>(a: 2, b: 0, c: 0, d: 2)
/// let composed = identity.concatenating(scaled)
/// ```
public typealias Linear<let N: Int> = Geometry<Double>.Linear<N>
