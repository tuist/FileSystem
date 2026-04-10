// EdgeInsets.swift
// Insets from the edges of a rectangle.

extension Geometry {
    /// Insets from the edges of a rectangle, parameterized by unit type.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let margins: Geometry.EdgeInsets<Double> = .init(
    ///     top: 72, leading: 72, bottom: 72, trailing: 72
    /// )
    /// ```
    public struct EdgeInsets {
        /// Top inset
        public var top: Scalar

        /// Leading (left in LTR) inset
        public var leading: Scalar

        /// Bottom inset
        public var bottom: Scalar

        /// Trailing (right in LTR) inset
        public var trailing: Scalar

        /// Create edge insets
        ///
        /// - Parameters:
        ///   - top: Top inset
        ///   - leading: Leading inset
        ///   - bottom: Bottom inset
        ///   - trailing: Trailing inset
        public init(
            top: consuming Scalar,
            leading: consuming Scalar,
            bottom: consuming Scalar,
            trailing: consuming Scalar
        ) {
            self.top = top
            self.leading = leading
            self.bottom = bottom
            self.trailing = trailing
        }
    }
}

extension Geometry.EdgeInsets: Sendable where Scalar: Sendable {}
extension Geometry.EdgeInsets: Equatable where Scalar: Equatable {}
extension Geometry.EdgeInsets: Hashable where Scalar: Hashable {}

// MARK: - Codable

extension Geometry.EdgeInsets: Codable where Scalar: Codable {}

// MARK: - Convenience Initializers

extension Geometry.EdgeInsets {
    /// Create edge insets with the same value on all edges
    ///
    /// - Parameter all: The inset value for all edges
    public init(all: Scalar) {
        self.top = all
        self.leading = all
        self.bottom = all
        self.trailing = all
    }

    /// Create edge insets with horizontal and vertical values
    ///
    /// - Parameters:
    ///   - horizontal: Inset for leading and trailing edges
    ///   - vertical: Inset for top and bottom edges
    public init(horizontal: Scalar, vertical: Scalar) {
        self.top = vertical
        self.leading = horizontal
        self.bottom = vertical
        self.trailing = horizontal
    }
}

// MARK: - AdditiveArithmetic

extension Geometry.EdgeInsets: AdditiveArithmetic where Scalar: AdditiveArithmetic {
    /// Zero insets
    @inlinable
    public static var zero: Self {
        Self(top: .zero, leading: .zero, bottom: .zero, trailing: .zero)
    }

    /// Add two edge insets component-wise
    @inlinable
    @_disfavoredOverload
    public static func + (lhs: borrowing Self, rhs: borrowing Self) -> Self {
        Self(
            top: lhs.top + rhs.top,
            leading: lhs.leading + rhs.leading,
            bottom: lhs.bottom + rhs.bottom,
            trailing: lhs.trailing + rhs.trailing
        )
    }

    /// Subtract two edge insets component-wise
    @inlinable
    @_disfavoredOverload
    public static func - (lhs: borrowing Self, rhs: borrowing Self) -> Self {
        Self(
            top: lhs.top - rhs.top,
            leading: lhs.leading - rhs.leading,
            bottom: lhs.bottom - rhs.bottom,
            trailing: lhs.trailing - rhs.trailing
        )
    }
}

// MARK: - Negation

extension Geometry.EdgeInsets where Scalar: SignedNumeric {
    /// Negate all insets
    @inlinable
    @_disfavoredOverload
    public static prefix func - (value: borrowing Self) -> Self {
        Self(
            top: -value.top,
            leading: -value.leading,
            bottom: -value.bottom,
            trailing: -value.trailing
        )
    }
}

// MARK: - Functorial Map

extension Geometry.EdgeInsets {
    /// Create edge insets by transforming each value of another edge insets
    @inlinable
    public init<U, E: Error>(
        _ other: borrowing Geometry<U>.EdgeInsets,
        _ transform: (U) throws(E) -> Scalar
    ) throws(E) {
        self.init(
            top: try transform(other.top),
            leading: try transform(other.leading),
            bottom: try transform(other.bottom),
            trailing: try transform(other.trailing)
        )
    }

    /// Transform each inset value using the given closure
    @inlinable
    public func map<Result, E: Error>(
        _ transform: (Scalar) throws(E) -> Result
    ) throws(E) -> Geometry<Result>.EdgeInsets {
        Geometry<Result>.EdgeInsets(
            top: try transform(top),
            leading: try transform(leading),
            bottom: try transform(bottom),
            trailing: try transform(trailing)
        )
    }
}

// MARK: - Monoid

extension Geometry.EdgeInsets where Scalar: AdditiveArithmetic {
    /// Combine two edge insets by adding their values
    @inlinable
    public static func combined(_ lhs: borrowing Self, _ rhs: borrowing Self) -> Self {
        Self(
            top: lhs.top + rhs.top,
            leading: lhs.leading + rhs.leading,
            bottom: lhs.bottom + rhs.bottom,
            trailing: lhs.trailing + rhs.trailing
        )
    }
}

extension Geometry.EdgeInsets where Scalar: AdditiveArithmetic {
    /// Total horizontal inset (leading + trailing)
    @inlinable
    public var horizontal: Scalar { leading + trailing }

    /// Total vertical inset (top + bottom)
    @inlinable
    public var vertical: Scalar { top + bottom }
}
