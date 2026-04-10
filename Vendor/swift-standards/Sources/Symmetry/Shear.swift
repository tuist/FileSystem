// Shear.swift
// An N-dimensional shear transformation (dimensionless).

public import Geometry

/// A 2D shear transformation.
///
/// Shear factors are dimensionless - they represent the amount by which
/// coordinates in one axis are shifted proportionally to the other axis.
///
/// In 2D, a shear transforms coordinates as:
/// - x' = x + shearX * y
/// - y' = shearY * x + y
///
/// ## Example
///
/// ```swift
/// let horizontalShear = Shear<2>(x: 0.5, y: 0)  // Shear along x-axis
/// ```
///
/// - Note: For N > 2, shear becomes more complex (N*(N-1) parameters).
///   This implementation focuses on 2D and 3D cases.
public struct Shear<let N: Int>: Sendable {
    /// The shear factors.
    ///
    /// For 2D: [shearX, shearY] where shearX affects x based on y, and vice versa.
    /// For 3D: [xy, xz, yx, yz, zx, zy] - 6 off-diagonal terms.
    public var factors: InlineArray<N, InlineArray<N, Double>>

    /// Create a shear from a matrix of factors (off-diagonal elements)
    @inlinable
    public init(_ factors: consuming InlineArray<N, InlineArray<N, Double>>) {
        self.factors = factors
    }
}

// MARK: - Equatable (2D)
// Note: InlineArray doesn't yet conform to Equatable/Hashable/Codable in Swift 6.2
// These conformances are planned for future Swift releases. For now, we implement
// manual conformances for the 2D case which is our primary use case.

extension Shear: Equatable where N == 2 {
    @inlinable
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.x == rhs.x && lhs.y == rhs.y
    }
}

// MARK: - Hashable (2D)

extension Shear: Hashable where N == 2 {
    @inlinable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
}

// MARK: - Codable (2D)

extension Shear: Codable where N == 2 {
    private enum CodingKeys: String, CodingKey {
        case x, y
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let x = try container.decode(Double.self, forKey: .x)
        let y = try container.decode(Double.self, forKey: .y)
        self.init(x: x, y: y)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(x, forKey: .x)
        try container.encode(y, forKey: .y)
    }
}

// MARK: - Identity

extension Shear {
    /// Identity shear (no shearing, all off-diagonal factors = 0)
    @inlinable
    public static var identity: Self {
        Self(InlineArray(repeating: InlineArray(repeating: 0.0)))
    }
}

// MARK: - 2D Convenience

extension Shear where N == 2 {
    /// Shear factor: how much x shifts per unit y
    @inlinable
    public var x: Double {
        get { factors[0][1] }
        set { factors[0][1] = newValue }
    }

    /// Shear factor: how much y shifts per unit x
    @inlinable
    public var y: Double {
        get { factors[1][0] }
        set { factors[1][0] = newValue }
    }

    /// Create a 2D shear with the given factors
    ///
    /// - Parameters:
    ///   - x: How much x shifts per unit y
    ///   - y: How much y shifts per unit x
    @inlinable
    public init(x: Double, y: Double) {
        var matrix = InlineArray<2, InlineArray<2, Double>>(
            repeating: InlineArray<2, Double>(repeating: 0.0)
        )
        matrix[0][1] = x  // shear x by y
        matrix[1][0] = y  // shear y by x
        self.init(matrix)
    }

    /// Create a horizontal shear (x shifts based on y)
    @inlinable
    public static func horizontal(_ factor: Double) -> Self {
        Self(x: factor, y: 0)
    }

    /// Create a vertical shear (y shifts based on x)
    @inlinable
    public static func vertical(_ factor: Double) -> Self {
        Self(x: 0, y: factor)
    }
}

// MARK: - Conversion to Linear

extension Shear where N == 2 {
    /// Convert to a 2D linear transformation matrix
    @inlinable
    public var linear: Linear<2> {
        Linear(a: 1, b: x, c: y, d: 1)
    }
}
