// Symmetry.swift
// Namespace for Lie group elements acting on Euclidean space.

/// Namespace for symmetry transformations.
///
/// Symmetry types represent elements of Lie groups that act on
/// Euclidean space. They are dimensionless (ratios/angles) and
/// independent of any coordinate system's units.
///
/// ## Types
///
/// - ``Rotation``: Element of SO(n), the special orthogonal group
/// - ``Scale``: Diagonal scaling transformation
/// - ``Shear``: Off-diagonal shear transformation
///
/// ## Mathematical Background
///
/// These transformations form groups under composition:
/// - Rotations form SO(n) (compact, non-abelian for n > 1)
/// - Scales form (ℝ⁺)ⁿ under component-wise multiplication
/// - Together with shear, they generate GL⁺(n) (orientation-preserving linear maps)
///
/// ## Relationship to Geometry
///
/// Symmetry types act on ``Geometry`` types via linear transformation.
/// The affine group Aff(n) = GL(n) ⋊ ℝⁿ combines these with translations.
public enum Symmetry {}
