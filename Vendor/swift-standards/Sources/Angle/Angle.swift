// Angle.swift
// Namespace for angular measurements.

/// Namespace for angular measurements.
///
/// Angular types represent elements of the circle group S¹ = ℝ/2πℤ.
/// They are dimensionless quantities (ratios) independent of any
/// coordinate system.
///
/// ## Types
///
/// - ``Radian``: Angle measured in radians (arc length / radius)
/// - ``Degree``: Angle measured in degrees (1/360 of a circle)
///
/// ## Mathematical Background
///
/// Angles form an abelian group under addition, with 2π (or 360°)
/// as the identity modulo normalization. They can be added, subtracted,
/// and scaled by real numbers.
public enum Angle {}
