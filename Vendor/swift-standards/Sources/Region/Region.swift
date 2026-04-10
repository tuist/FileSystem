// Region.swift
// Namespace for finite spatial partitions.

/// Namespace for discrete spatial partitions.
///
/// Region types represent finite decompositions of N-dimensional space
/// into discrete labeled regions. They are combinatorial/algebraic structures
/// rather than continuous geometric objects.
///
/// ## Types
///
/// - ``Region/Cardinal``: Four compass directions (Z₄ group)
/// - ``Region/Quadrant``: Four regions of the 2D plane (Z₄ group)
/// - ``Region/Octant``: Eight regions of 3D space (Z₂³ group)
/// - ``Region/Edge``: Four edges of a rectangle
/// - ``Region/Corner``: Four corners of a rectangle
///
/// ## Mathematical Background
///
/// These types form finite groups under rotation/reflection operations.
/// Cardinal and Quadrant are isomorphic to the cyclic group Z₄.
/// Octant is isomorphic to Z₂ × Z₂ × Z₂.
public enum Region {
    // Types are defined in separate files and extended onto this enum
}
