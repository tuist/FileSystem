// Phase.swift
// Discrete rotational phases (Z₄ group).

/// Discrete rotational phases: 0°, 90°, 180°, 270°.
///
/// Represents the cyclic group Z₄ of quarter-turn rotations.
///
/// ## Mathematical Properties
///
/// - Forms Z₄ group under composition
/// - Identity is `zero` (0°)
/// - Each element has order dividing 4
/// - `opposite` is 180° rotation from current
/// - `next`/`previous` rotate by 90°
///
/// ## Tagged Values
///
/// Use `Phase.Value<T>` to pair a value with a phase:
///
/// ```swift
/// let signal: Phase.Value<Complex> = .init(tag: .quarter, value: z)
/// ```
public enum Phase: Int, Sendable, Hashable, Codable, CaseIterable {
    /// 0° (identity, no rotation).
    case zero = 0

    /// 90° (quarter turn counterclockwise).
    case quarter = 1

    /// 180° (half turn).
    case half = 2

    /// 270° (three-quarter turn, or 90° clockwise).
    case threeQuarter = 3
}

// MARK: - Rotation

extension Phase {
    /// The next phase (90° counterclockwise).
    @inlinable
    public var next: Phase {
        Phase(rawValue: (rawValue + 1) % 4)!
    }

    /// The previous phase (90° clockwise).
    @inlinable
    public var previous: Phase {
        Phase(rawValue: (rawValue + 3) % 4)!
    }

    /// The opposite phase (180° rotation).
    @inlinable
    public var opposite: Phase {
        Phase(rawValue: (rawValue + 2) % 4)!
    }

    /// Returns the opposite phase.
    @inlinable
    public static prefix func ! (value: Phase) -> Phase {
        value.opposite
    }
}

// MARK: - Composition

extension Phase {
    /// Composes two phases (adds rotations).
    @inlinable
    public func composed(with other: Phase) -> Phase {
        Phase(rawValue: (rawValue + other.rawValue) % 4)!
    }

    /// The inverse phase (rotation that undoes this one).
    @inlinable
    public var inverse: Phase {
        Phase(rawValue: (4 - rawValue) % 4)!
    }
}

// MARK: - Angle

extension Phase {
    /// The phase angle in degrees.
    @inlinable
    public var degrees: Int {
        rawValue * 90
    }

    /// Creates a phase from degrees (must be multiple of 90).
    @inlinable
    public init?(degrees: Int) {
        let normalized = ((degrees % 360) + 360) % 360
        guard normalized % 90 == 0 else { return nil }
        self.init(rawValue: normalized / 90)
    }
}

// MARK: - Tagged Value

extension Phase {
    /// A value paired with a phase.
    public typealias Value<Payload> = Tagged<Phase, Payload>
}
