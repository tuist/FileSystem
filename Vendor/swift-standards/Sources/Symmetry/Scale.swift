// Scale.swift
// An N-dimensional scale transformation (dimensionless).

public import Geometry

/// An N-dimensional scale transformation.
///
/// Scale factors are dimensionless - they represent ratios by which
/// coordinates are multiplied. A scale of 2 doubles the size regardless
/// of whether you're working in points, pixels, or meters.
///
/// ## Example
///
/// ```swift
/// let uniform = Scale<2>.uniform(2.0)      // 2x in both dimensions
/// let nonUniform = Scale<2>(x: 1.5, y: 2.0) // different per axis
/// ```
public struct Scale<let N: Int>: Sendable {
    /// The scale factors for each dimension
    public var factors: InlineArray<N, Double>

    /// Create a scale from an array of factors
    @inlinable
    public init(_ factors: consuming InlineArray<N, Double>) {
        self.factors = factors
    }
}

// MARK: - Equatable
// Note: InlineArray doesn't yet conform to Equatable/Hashable/Codable in Swift 6.2
// We implement these manually by iterating over factors.

extension Scale: Equatable {
    @inlinable
    public static func == (lhs: Self, rhs: Self) -> Bool {
        for i in 0..<N {
            if lhs.factors[i] != rhs.factors[i] { return false }
        }
        return true
    }
}

// MARK: - Hashable

extension Scale: Hashable {
    @inlinable
    public func hash(into hasher: inout Hasher) {
        for i in 0..<N {
            hasher.combine(factors[i])
        }
    }
}

// MARK: - Codable

extension Scale: Codable {
    public init(from decoder: any Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var factors = InlineArray<N, Double>(repeating: 0)
        for i in 0..<N {
            factors[i] = try container.decode(Double.self)
        }
        self.init(factors)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.unkeyedContainer()
        for i in 0..<N {
            try container.encode(factors[i])
        }
    }
}

// MARK: - Subscript

extension Scale {
    /// Access scale factor by dimension index
    @inlinable
    public subscript(index: Int) -> Double {
        get { factors[index] }
        set { factors[index] = newValue }
    }
}

// MARK: - Identity and Presets

extension Scale {
    /// Identity scale (no scaling, all factors = 1)
    @inlinable
    public static var identity: Self {
        Self(InlineArray(repeating: 1.0))
    }

    /// Create a uniform scale (same factor in all dimensions)
    @inlinable
    public static func uniform(_ factor: Double) -> Self {
        Self(InlineArray(repeating: factor))
    }

    /// Double scale (2x in all dimensions)
    @inlinable
    public static var double: Self {
        Self(InlineArray(repeating: 2.0))
    }

    /// Half scale (0.5x in all dimensions)
    @inlinable
    public static var half: Self {
        Self(InlineArray(repeating: 0.5))
    }
}

// MARK: - 1D Convenience

extension Scale where N == 1 {
    /// The scale factor value
    @inlinable
    public var value: Double {
        get { factors[0] }
        set { factors[0] = newValue }
    }

    /// Create a 1D scale with the given factor
    @inlinable
    public init(_ value: Double) {
        self.init([value])
    }
}

// MARK: - 1D Literals

extension Scale: ExpressibleByFloatLiteral where N == 1 {
    @inlinable
    public init(floatLiteral value: Double) {
        self.init(value)
    }
}

extension Scale: ExpressibleByIntegerLiteral where N == 1 {
    @inlinable
    public init(integerLiteral value: Int) {
        self.init(Double(value))
    }
}

// MARK: - 2D Convenience

extension Scale where N == 2 {
    /// The x scale factor
    @inlinable
    public var x: Double {
        get { factors[0] }
        set { factors[0] = newValue }
    }

    /// The y scale factor
    @inlinable
    public var y: Double {
        get { factors[1] }
        set { factors[1] = newValue }
    }

    /// Create a 2D scale with the given factors
    @inlinable
    public init(x: Double, y: Double) {
        self.init([x, y])
    }
}

// MARK: - 3D Convenience

extension Scale where N == 3 {
    /// The x scale factor
    @inlinable
    public var x: Double {
        get { factors[0] }
        set { factors[0] = newValue }
    }

    /// The y scale factor
    @inlinable
    public var y: Double {
        get { factors[1] }
        set { factors[1] = newValue }
    }

    /// The z scale factor
    @inlinable
    public var z: Double {
        get { factors[2] }
        set { factors[2] = newValue }
    }

    /// Create a 3D scale with the given factors
    @inlinable
    public init(x: Double, y: Double, z: Double) {
        self.init([x, y, z])
    }
}

// MARK: - Composition

extension Scale {
    /// Compose two scales (multiply factors component-wise)
    @inlinable
    public func concatenating(_ other: Self) -> Self {
        var result = factors
        for i in 0..<N {
            result[i] = factors[i] * other.factors[i]
        }
        return Self(result)
    }

    /// The inverse scale (1/factor for each dimension)
    @inlinable
    public var inverted: Self {
        var result = factors
        for i in 0..<N {
            result[i] = 1.0 / factors[i]
        }
        return Self(result)
    }
}

// MARK: - Conversion to Linear

extension Scale where N == 2 {
    /// Convert to a 2D linear transformation matrix
    @inlinable
    public var linear: Linear<2> {
        Linear(a: x, b: 0, c: 0, d: y)
    }
}
