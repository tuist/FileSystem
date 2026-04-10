// Quadrant.swift
// Cartesian plane quadrants.

public import Algebra

extension Region {
    /// Quadrant of the Cartesian plane.
    ///
    /// The four regions defined by the x and y axes, numbered counterclockwise
    /// starting from the positive x, positive y region.
    ///
    /// ## Convention
    ///
    /// - I: x > 0, y > 0 (upper right)
    /// - II: x < 0, y > 0 (upper left)
    /// - III: x < 0, y < 0 (lower left)
    /// - IV: x > 0, y < 0 (lower right)
    ///
    /// ## Mathematical Properties
    ///
    /// - Forms Z4 group under 90 degree rotation
    /// - Reflection swaps horizontally (I<->II, III<->IV) or vertically (I<->IV, II<->III)
    ///
    /// ## Tagged Values
    ///
    /// Use `Quadrant.Value<T>` to pair a point with its quadrant:
    ///
    /// ```swift
    /// let point: Region.Quadrant.Value<Point> = .init(tag: .I, value: p)
    /// ```
    public enum Quadrant: Int, Sendable, Hashable, Codable, CaseIterable {
        /// First quadrant: x > 0, y > 0.
        case I = 1

        /// Second quadrant: x < 0, y > 0.
        case II = 2

        /// Third quadrant: x < 0, y < 0.
        case III = 3

        /// Fourth quadrant: x > 0, y < 0.
        case IV = 4
    }
}

// MARK: - Rotation

extension Region.Quadrant {
    /// The next quadrant (90 degrees counterclockwise).
    @inlinable
    public var next: Region.Quadrant {
        Region.Quadrant(rawValue: (rawValue % 4) + 1)!
    }

    /// The previous quadrant (90 degrees clockwise).
    @inlinable
    public var previous: Region.Quadrant {
        Region.Quadrant(rawValue: ((rawValue + 2) % 4) + 1)!
    }

    /// The opposite quadrant (180 degree rotation).
    @inlinable
    public var opposite: Region.Quadrant {
        Region.Quadrant(rawValue: ((rawValue + 1) % 4) + 1)!
    }

    /// Returns the opposite quadrant.
    @inlinable
    public static prefix func ! (value: Region.Quadrant) -> Region.Quadrant {
        value.opposite
    }
}

// MARK: - Sign Properties

extension Region.Quadrant {
    /// True if x is positive in this quadrant.
    @inlinable
    public var hasPositiveX: Bool {
        self == .I || self == .IV
    }

    /// True if y is positive in this quadrant.
    @inlinable
    public var hasPositiveY: Bool {
        self == .I || self == .II
    }
}

// MARK: - Tagged Value

extension Region.Quadrant {
    /// A value paired with its quadrant.
    public typealias Value<Payload> = Tagged<Region.Quadrant, Payload>
}
