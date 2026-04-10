// Size.swift
// A fixed-size dimensions with compile-time known number of dimensions.

extension Geometry {
    /// A fixed-size dimensions with compile-time known number of dimensions.
    ///
    /// This generic structure represents N-dimensional sizes (width, height, depth, etc.)
    /// and can be specialized for different coordinate systems.
    ///
    /// Uses Swift 6.2 integer generic parameters (SE-0452) for type-safe
    /// dimension checking at compile time.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let pageSize: Geometry.Size<2> = .init(width: 612, height: 792)
    /// let boxSize: Geometry.Size<3, Double> = .init(width: 10, height: 20, depth: 30)
    /// ```
    public struct Size<let N: Int> {
        /// The size dimensions stored inline
        public var dimensions: InlineArray<N, Scalar>

        /// Create a size from an inline array of dimensions
        @inlinable
        public init(_ dimensions: consuming InlineArray<N, Scalar>) {
            self.dimensions = dimensions
        }
    }
}

extension Geometry.Size: Sendable where Scalar: Sendable {}

// MARK: - Equatable

extension Geometry.Size: Equatable where Scalar: Equatable {
    @inlinable
    public static func == (lhs: borrowing Self, rhs: borrowing Self) -> Bool {
        for i in 0..<N {
            if lhs.dimensions[i] != rhs.dimensions[i] {
                return false
            }
        }
        return true
    }
}

// MARK: - Hashable

extension Geometry.Size: Hashable where Scalar: Hashable {
    @inlinable
    public func hash(into hasher: inout Hasher) {
        for i in 0..<N {
            hasher.combine(dimensions[i])
        }
    }
}

// MARK: - Typealiases

extension Geometry {
    /// A 2D size
    public typealias Size2 = Size<2>

    /// A 3D size
    public typealias Size3 = Size<3>
}

// MARK: - Codable

extension Geometry.Size: Codable where Scalar: Codable {
    public init(from decoder: any Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var dimensions = InlineArray<N, Scalar>(repeating: try container.decode(Scalar.self))
        for i in 1..<N {
            dimensions[i] = try container.decode(Scalar.self)
        }
        self.dimensions = dimensions
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.unkeyedContainer()
        for i in 0..<N {
            try container.encode(dimensions[i])
        }
    }
}

// MARK: - Subscript

extension Geometry.Size {
    /// Access dimension by index
    @inlinable
    public subscript(index: Int) -> Scalar {
        get { dimensions[index] }
        set { dimensions[index] = newValue }
    }
}

// MARK: - Functorial Map

extension Geometry.Size {
    /// Create a size by transforming each dimension of another size
    @inlinable
    public init<U, E: Error>(
        _ other: borrowing Geometry<U>.Size<N>,
        _ transform: (U) throws(E) -> Scalar
    ) throws(E) {
        var dims = InlineArray<N, Scalar>(repeating: try transform(other.dimensions[0]))
        for i in 1..<N {
            dims[i] = try transform(other.dimensions[i])
        }
        self.init(dims)
    }

    /// Transform each dimension using the given closure
    @inlinable
    public func map<Result, E: Error>(
        _ transform: (Scalar) throws(E) -> Result
    ) throws(E) -> Geometry<Result>.Size<N> {
        var result = InlineArray<N, Result>(repeating: try transform(dimensions[0]))
        for i in 1..<N {
            result[i] = try transform(dimensions[i])
        }
        return Geometry<Result>.Size<N>(result)
    }
}

// MARK: - AdditiveArithmetic

extension Geometry.Size: AdditiveArithmetic where Scalar: AdditiveArithmetic {
    /// Zero size (all dimensions zero)
    @inlinable
    public static var zero: Self {
        Self(InlineArray(repeating: .zero))
    }

    /// Add two sizes component-wise
    @inlinable
    @_disfavoredOverload
    public static func + (lhs: borrowing Self, rhs: borrowing Self) -> Self {
        var result = InlineArray<N, Scalar>(repeating: .zero)
        for i in 0..<N {
            result[i] = lhs.dimensions[i] + rhs.dimensions[i]
        }
        return Self(result)
    }

    /// Subtract two sizes component-wise
    @inlinable
    @_disfavoredOverload
    public static func - (lhs: borrowing Self, rhs: borrowing Self) -> Self {
        var result = InlineArray<N, Scalar>(repeating: .zero)
        for i in 0..<N {
            result[i] = lhs.dimensions[i] - rhs.dimensions[i]
        }
        return Self(result)
    }
}

// MARK: - Negation

extension Geometry.Size where Scalar: SignedNumeric {
    /// Negate all dimensions
    @inlinable
    @_disfavoredOverload
    public static prefix func - (value: borrowing Self) -> Self {
        var result = InlineArray<N, Scalar>(repeating: .zero)
        for i in 0..<N {
            result[i] = -value.dimensions[i]
        }
        return Self(result)
    }
}

// MARK: - Scalar Multiplication

extension Geometry.Size where Scalar: Numeric {
    /// Multiply all dimensions by a scalar
    @inlinable
    @_disfavoredOverload
    public static func * (lhs: borrowing Self, rhs: Scalar) -> Self {
        var result = lhs.dimensions
        for i in 0..<N {
            result[i] = lhs.dimensions[i] * rhs
        }
        return Self(result)
    }

    /// Multiply scalar by size
    @inlinable
    @_disfavoredOverload
    public static func * (lhs: Scalar, rhs: borrowing Self) -> Self {
        rhs * lhs
    }
}

// MARK: - Scalar Division

extension Geometry.Size where Scalar: FloatingPoint {
    /// Divide all dimensions by a scalar
    @inlinable
    @_disfavoredOverload
    public static func / (lhs: borrowing Self, rhs: Scalar) -> Self {
        var result = lhs.dimensions
        for i in 0..<N {
            result[i] = lhs.dimensions[i] / rhs
        }
        return Self(result)
    }
}

// MARK: - 2D Convenience

extension Geometry.Size where N == 2 {
    /// Width (first dimension, type-safe)
    @inlinable
    public var width: Geometry.Width {
        get { Geometry.Width(dimensions[0]) }
        set { dimensions[0] = newValue.value }
    }

    /// Height (second dimension, type-safe)
    @inlinable
    public var height: Geometry.Height {
        get { Geometry.Height(dimensions[1]) }
        set { dimensions[1] = newValue.value }
    }
    //
    //    /// Create a 2D size with the given dimensions (raw scalar values)
    //    @inlinable
    //    public init(width: Scalar, height: Scalar) {
    //        self.init([width, height])
    //    }

    /// Create a 2D size from typed Width and Height values
    @inlinable
    public init(width: Geometry.Width, height: Geometry.Height) {
        self.init([width.value, height.value])
    }
}

// MARK: - 3D Convenience

extension Geometry.Size where N == 3 {
    /// Width (first dimension)
    @inlinable
    public var width: Geometry.Width {
        get { .init(dimensions[0]) }
        set { dimensions[0] = newValue.value }
    }

    /// Height (second dimension)
    @inlinable
    public var height: Geometry.Height {
        get { .init(dimensions[1]) }
        set { dimensions[1] = newValue.value }
    }

    /// Depth (third dimension)
    @inlinable
    public var depth: Scalar {
        get { dimensions[2] }
        set { dimensions[2] = newValue }
    }

    /// Create a 3D size with the given dimensions
    @inlinable
    public init(width: Scalar, height: Scalar, depth: Scalar) {
        self.init([width, height, depth])
    }

    /// Create a 3D size from a 2D size with depth
    @inlinable
    public init(_ size2: Geometry.Size<2>, depth: Scalar) {
        self.init(width: size2.width.value, height: size2.height.value, depth: depth)
    }
}

// MARK: - Zip

extension Geometry.Size {
    /// Combine two sizes component-wise
    @inlinable
    public static func zip(_ a: Self, _ b: Self, _ combine: (Scalar, Scalar) -> Scalar) -> Self {
        var result = a.dimensions
        for i in 0..<N {
            result[i] = combine(a.dimensions[i], b.dimensions[i])
        }
        return Self(result)
    }
}
