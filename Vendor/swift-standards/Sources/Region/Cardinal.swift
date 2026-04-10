// Cardinal.swift
// Cardinal directions (compass points).

public import Algebra

extension Region {
    /// Cardinal direction (primary compass point).
    ///
    /// The four principal compass directions.
    ///
    /// ## Convention
    ///
    /// In screen coordinates (y-down): north is up, east is right.
    /// In mathematical coordinates (y-up): depends on convention.
    ///
    /// ## Mathematical Properties
    ///
    /// - Forms Z4 group under 90 degree rotation
    /// - `opposite` gives 180 degree rotation
    ///
    /// ## Tagged Values
    ///
    /// Use `Cardinal.Value<T>` to pair a distance with its direction:
    ///
    /// ```swift
    /// let travel: Region.Cardinal.Value<Distance> = .init(tag: .north, value: 100)
    /// ```
    public enum Cardinal: Sendable, Hashable, Codable, CaseIterable {
        /// Upward / toward top.
        case north

        /// Rightward / toward east.
        case east

        /// Downward / toward bottom.
        case south

        /// Leftward / toward west.
        case west
    }
}

// MARK: - Rotation

extension Region.Cardinal {
    /// The next cardinal (90 degrees clockwise).
    @inlinable
    public var clockwise: Region.Cardinal {
        switch self {
        case .north: return .east
        case .east: return .south
        case .south: return .west
        case .west: return .north
        }
    }

    /// The previous cardinal (90 degrees counterclockwise).
    @inlinable
    public var counterclockwise: Region.Cardinal {
        switch self {
        case .north: return .west
        case .east: return .north
        case .south: return .east
        case .west: return .south
        }
    }

    /// The opposite cardinal (180 degree rotation).
    @inlinable
    public var opposite: Region.Cardinal {
        switch self {
        case .north: return .south
        case .east: return .west
        case .south: return .north
        case .west: return .east
        }
    }

    /// Returns the opposite cardinal.
    @inlinable
    public static prefix func ! (value: Region.Cardinal) -> Region.Cardinal {
        value.opposite
    }
}

// MARK: - Axis

extension Region.Cardinal {
    /// True if this is a horizontal direction (east/west).
    @inlinable
    public var isHorizontal: Bool {
        self == .east || self == .west
    }

    /// True if this is a vertical direction (north/south).
    @inlinable
    public var isVertical: Bool {
        self == .north || self == .south
    }
}

// MARK: - Tagged Value

extension Region.Cardinal {
    /// A value paired with its cardinal direction.
    public typealias Value<Payload> = Tagged<Region.Cardinal, Payload>
}
