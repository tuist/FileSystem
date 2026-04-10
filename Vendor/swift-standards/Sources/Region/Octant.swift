// Octant.swift
// 3D space octants.

public import Algebra

extension Region {
    /// Octant of 3D Cartesian space.
    ///
    /// The eight regions defined by the x, y, and z planes, analogous to
    /// quadrants in 2D.
    ///
    /// ## Convention
    ///
    /// Named by signs: PPP means x > 0, y > 0, z > 0.
    ///
    /// ## Mathematical Properties
    ///
    /// - 8 regions = 2^3 (three binary sign choices)
    /// - Reflection through origin maps octant to opposite
    ///
    /// ## Tagged Values
    ///
    /// Use `Octant.Value<T>` to pair a point with its octant:
    ///
    /// ```swift
    /// let point: Region.Octant.Value<Point3D> = .init(tag: .ppp, value: p)
    /// ```
    public enum Octant: Sendable, Hashable, Codable, CaseIterable {
        /// x > 0, y > 0, z > 0
        case ppp
        /// x > 0, y > 0, z < 0
        case ppn
        /// x > 0, y < 0, z > 0
        case pnp
        /// x > 0, y < 0, z < 0
        case pnn
        /// x < 0, y > 0, z > 0
        case npp
        /// x < 0, y > 0, z < 0
        case npn
        /// x < 0, y < 0, z > 0
        case nnp
        /// x < 0, y < 0, z < 0
        case nnn
    }
}

// MARK: - Opposite

extension Region.Octant {
    /// The opposite octant (reflection through origin).
    @inlinable
    public var opposite: Region.Octant {
        switch self {
        case .ppp: return .nnn
        case .ppn: return .nnp
        case .pnp: return .npn
        case .pnn: return .npp
        case .npp: return .pnn
        case .npn: return .pnp
        case .nnp: return .ppn
        case .nnn: return .ppp
        }
    }

    /// Returns the opposite octant.
    @inlinable
    public static prefix func ! (value: Region.Octant) -> Region.Octant {
        value.opposite
    }
}

// MARK: - Sign Properties

extension Region.Octant {
    /// True if x is positive in this octant.
    @inlinable
    public var hasPositiveX: Bool {
        switch self {
        case .ppp, .ppn, .pnp, .pnn: return true
        case .npp, .npn, .nnp, .nnn: return false
        }
    }

    /// True if y is positive in this octant.
    @inlinable
    public var hasPositiveY: Bool {
        switch self {
        case .ppp, .ppn, .npp, .npn: return true
        case .pnp, .pnn, .nnp, .nnn: return false
        }
    }

    /// True if z is positive in this octant.
    @inlinable
    public var hasPositiveZ: Bool {
        switch self {
        case .ppp, .pnp, .npp, .nnp: return true
        case .ppn, .pnn, .npn, .nnn: return false
        }
    }
}

// MARK: - Tagged Value

extension Region.Octant {
    /// A value paired with its octant.
    public typealias Value<Payload> = Tagged<Region.Octant, Payload>
}
