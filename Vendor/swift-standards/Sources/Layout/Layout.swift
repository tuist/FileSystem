// Layout
//
// Layout primitives parameterized by spacing type.
//
// This module provides type-safe layout primitives for arranging content
// in space. Types are parameterized by their spacing type (the unit for
// gaps between elements).
//
// ## Structure
//
// The module separates:
// - **Alignment types** (dimensionless): `HorizontalAlignment`, `VerticalAlignment`, `Alignment`
// - **Distribution types** (dimensionless): `Distribution`
// - **Container types** (parameterized): `Stack`, `Grid`, `Flow`
//
// This reflects the design principle that alignment and distribution are
// abstract concepts, while spacing requires a concrete unit.
//
// ## Container Types (Layout<Spacing>)
//
// - `Stack<Content>`: Sequential arrangement along an axis
// - `Grid<Content>`: Two-dimensional row/column arrangement
// - `Flow<Content>`: Wrapping arrangement that flows to next line
//
// ## Usage
//
// Specialize with your spacing type:
//
// ```swift
// struct Points: AdditiveArithmetic { ... }
//
// typealias PageStack<C> = Layout<Points>.Stack<C>
// typealias PageGrid<C> = Layout<Points>.Grid<C>
// ```

/// The Layout namespace for layout primitives.
///
/// Parameterized by the spacing type used for gaps between elements.
/// Supports both copyable and non-copyable spacing types.
public enum Layout<Spacing: ~Copyable>: ~Copyable {}

extension Layout: Copyable where Spacing: Copyable {}
extension Layout: Sendable where Spacing: Sendable {}
