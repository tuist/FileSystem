// Rectangle.swift
// A rectangle defined by corner coordinates, parameterized by unit type.

public import Dimension

extension Geometry {
    /// A rectangle parameterized by its unit type.
    ///
    /// Rectangles are defined by their lower-left (ll) and upper-right (ur) corners,
    /// following the convention used in PDF and many graphics systems.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let bounds: Geometry.Rectangle<Double> = .init(x: 0, y: 0, width: 612, height: 792)
    /// ```
    public struct Rectangle {
        /// Lower-left x coordinate
        public var llx: Geometry.X

        /// Lower-left y coordinate
        public var lly: Geometry.Y

        /// Upper-right x coordinate
        public var urx: Geometry.X

        /// Upper-right y coordinate
        public var ury: Geometry.Y

        /// Create a rectangle from corner coordinates
        ///
        /// - Parameters:
        ///   - llx: Lower-left x coordinate
        ///   - lly: Lower-left y coordinate
        ///   - urx: Upper-right x coordinate
        ///   - ury: Upper-right y coordinate
        public init(
            llx: consuming Geometry.X,
            lly: consuming Geometry.Y,
            urx: consuming Geometry.X,
            ury: consuming Geometry.Y
        ) {
            self.llx = llx
            self.lly = lly
            self.urx = urx
            self.ury = ury
        }
    }
}

extension Geometry.Rectangle: Sendable where Scalar: Sendable {}
extension Geometry.Rectangle: Equatable where Scalar: Equatable {}
extension Geometry.Rectangle: Hashable where Scalar: Hashable {}

// MARK: - Codable

extension Geometry.Rectangle: Codable where Scalar: Codable {}

// MARK: - AdditiveArithmetic Convenience

extension Geometry.Rectangle where Scalar: AdditiveArithmetic {
    /// Create a rectangle from origin and size
    ///
    /// - Parameters:
    ///   - x: Lower-left x coordinate
    ///   - y: Lower-left y coordinate
    ///   - width: Width of the rectangle
    ///   - height: Height of the rectangle
    @inlinable
    public init(x: Geometry.X, y: Geometry.Y, width: Geometry.Width, height: Geometry.Height) {
        self.llx = x
        self.lly = y
        self.urx = .init(x.value + width.value)
        self.ury = .init(y.value + height.value)
    }

    /// Create a rectangle from raw scalar values
    ///
    /// - Parameters:
    ///   - x: Lower-left x coordinate
    ///   - y: Lower-left y coordinate
    ///   - width: Width of the rectangle
    ///   - height: Height of the rectangle
    @_disfavoredOverload
    @inlinable
    public init(x: Scalar, y: Scalar, width: Scalar, height: Scalar) {
        self.llx = .init(x)
        self.lly = .init(y)
        self.urx = .init(x + width)
        self.ury = .init(y + height)
    }

    /// Width of the rectangle
    @inlinable
    public var width: Geometry.Width {
        get { .init(urx.value - llx.value) }
        set { urx = .init(llx.value + newValue.value) }
    }

    /// Height of the rectangle
    @inlinable
    public var height: Geometry.Height {
        get { .init(ury.value - lly.value) }
        set { ury = .init(lly.value + newValue.value) }
    }

    /// Size of the rectangle
    @inlinable
    public var size: Geometry.Size<2> {
        get { Geometry.Size(width: width, height: height) }
        set {
            urx = .init(llx.value + newValue.width.value)
            ury = .init(lly.value + newValue.height.value)
        }
    }

    /// Origin (lower-left corner) of the rectangle
    @inlinable
    public var origin: Geometry.Point<2> {
        get { Geometry.Point(x: llx, y: lly) }
        set {
            let w = width
            let h = height
            llx = newValue.x
            lly = newValue.y
            urx = .init(newValue.x.value + w.value)
            ury = .init(newValue.y.value + h.value)
        }
    }
    /// Create a rectangle from origin point and size
    ///
    /// - Parameters:
    ///   - origin: Lower-left corner point
    ///   - size: Width and height of the rectangle
    @inlinable
    public init(origin: Geometry.Point<2>, size: Geometry.Size<2>) {
        self.llx = origin.x
        self.lly = origin.y
        self.urx = origin.x + size.width.value
        self.ury = origin.y + size.height.value
    }
}

// MARK: - Corner Access

extension Geometry.Rectangle {
    /// Lower edge corners
    public enum LowerEdge {
        case left, right
    }

    /// Upper edge corners
    public enum UpperEdge {
        case left, right
    }

    /// All four corners
    public enum Corner {
        case lowerLeft, lowerRight, upperLeft, upperRight
    }

    /// Get a corner coordinate
    ///
    /// - Parameter corner: The corner to retrieve
    /// - Returns: The corner as a Point
    @inlinable
    public func corner(_ corner: Corner) -> Geometry.Point<2> {
        switch corner {
        case .lowerLeft:
            return Geometry.Point(x: llx, y: lly)
        case .lowerRight:
            return Geometry.Point(x: urx, y: lly)
        case .upperLeft:
            return Geometry.Point(x: llx, y: ury)
        case .upperRight:
            return Geometry.Point(x: urx, y: ury)
        }
    }
}

// MARK: - Functional Updates

extension Geometry.Rectangle {
    /// Create a new rectangle with a modified lower-left x
    @inlinable
    public func with(llx: Geometry.X) -> Self {
        Self(llx: llx, lly: lly, urx: urx, ury: ury)
    }

    /// Create a new rectangle with a modified lower-left y
    @inlinable
    public func with(lly: Geometry.Y) -> Self {
        Self(llx: llx, lly: lly, urx: urx, ury: ury)
    }

    /// Create a new rectangle with a modified upper-right x
    @inlinable
    public func with(urx: Geometry.X) -> Self {
        Self(llx: llx, lly: lly, urx: urx, ury: ury)
    }

    /// Create a new rectangle with a modified upper-right y
    @inlinable
    public func with(ury: Geometry.Y) -> Self {
        Self(llx: llx, lly: lly, urx: urx, ury: ury)
    }
}

// MARK: - Translation

extension Geometry.Rectangle where Scalar: AdditiveArithmetic {
    /// Translate the rectangle by the given amounts.
    ///
    /// - Parameters:
    ///   - dx: Horizontal translation
    ///   - dy: Vertical translation
    /// - Returns: A new rectangle with translated origin
    @inlinable
    public func translated(dx: Scalar, dy: Scalar) -> Self {
        Self(
            llx: .init(llx.value + dx),
            lly: .init(lly.value + dy),
            urx: .init(urx.value + dx),
            ury: .init(ury.value + dy)
        )
    }

    /// Translate the rectangle by a vector.
    ///
    /// - Parameter vector: The translation vector
    /// - Returns: A new rectangle with translated origin
    @inlinable
    public func translated(by vector: Geometry.Vector<2>) -> Self {
        translated(dx: vector.dx.value, dy: vector.dy.value)
    }
}

// MARK: - Comparable-based Rectangle Operations

extension Geometry.Rectangle where Scalar: Comparable {
    /// Minimum x (same as llx for normalized rectangles)
    @inlinable
    public var minX: Geometry.X { min(llx, urx) }

    /// Maximum x (same as urx for normalized rectangles)
    @inlinable
    public var maxX: Geometry.X { max(llx, urx) }

    /// Minimum y (same as lly for normalized rectangles)
    @inlinable
    public var minY: Geometry.Y { min(lly, ury) }

    /// Maximum y (same as ury for normalized rectangles)
    @inlinable
    public var maxY: Geometry.Y { max(lly, ury) }
}

extension Geometry.Rectangle where Scalar: SignedNumeric & Comparable {
    /// Check if the rectangle has zero or negative area.
    ///
    /// A rectangle is empty if either its width or height is less than or equal to zero.
    @inlinable
    public var isEmpty: Bool {
        urx.value - llx.value <= .zero || ury.value - lly.value <= .zero
    }
}

extension Geometry.Rectangle where Scalar: Comparable {
    /// Check if the rectangle contains a point
    @inlinable
    public func contains(_ point: Geometry.Point<2>) -> Bool {
        point.x >= minX && point.x <= maxX && point.y >= minY && point.y <= maxY
    }

    /// Check if this rectangle contains another rectangle
    @inlinable
    public func contains(_ other: Self) -> Bool {
        other.minX >= minX && other.maxX <= maxX && other.minY >= minY && other.maxY <= maxY
    }

    /// Check if this rectangle intersects another
    @inlinable
    public func intersects(_ other: Self) -> Bool {
        minX <= other.maxX && maxX >= other.minX && minY <= other.maxY && maxY >= other.minY
    }

    /// The union of this rectangle with another
    @inlinable
    public func union(_ other: Self) -> Self {
        Self(
            llx: min(minX, other.minX),
            lly: min(minY, other.minY),
            urx: max(maxX, other.maxX),
            ury: max(maxY, other.maxY)
        )
    }

    /// The intersection of this rectangle with another, if they intersect
    @inlinable
    public func intersection(_ other: Self) -> Self? {
        guard intersects(other) else { return nil }
        return Self(
            llx: max(minX, other.minX),
            lly: max(minY, other.minY),
            urx: min(maxX, other.maxX),
            ury: min(maxY, other.maxY)
        )
    }
}

// MARK: - FloatingPoint-based Rectangle Operations

extension Geometry.Rectangle where Scalar: FloatingPoint {
    /// Center x coordinate
    @inlinable
    public var midX: Geometry.X { (llx + urx) / 2 }

    /// Center y coordinate
    @inlinable
    public var midY: Geometry.Y { lly + ury / 2 }

    /// Center point
    @inlinable
    public var center: Geometry.Point<2> {
        Geometry.Point(x: midX, y: midY)
    }

    /// Return a rectangle inset by the given amounts
    @inlinable
    public func insetBy(dx: Scalar, dy: Scalar) -> Self {
        Self(llx: llx + dx, lly: lly + dy, urx: urx - dx, ury: ury - dy)
    }

    /// Return a rectangle inset by edge insets.
    ///
    /// Uses upward (standard Cartesian) orientation where "top" affects `ury`.
    /// For screen coordinates where Y increases downward, use `inset(by:y:)`.
    @inlinable
    public func inset(by insets: Geometry.EdgeInsets) -> Self {
        inset(by: insets, y: .upward)
    }

    /// Return a rectangle inset by edge insets with explicit Y-axis direction.
    ///
    /// - Parameters:
    ///   - insets: The edge insets to apply
    ///   - y: The vertical axis direction
    /// - Returns: A new rectangle with the insets applied
    ///
    /// ## Axis Direction Effects
    ///
    /// - `.upward` (Cartesian): top→ury, bottom→lly
    /// - `.downward` (screen): top→lly, bottom→ury
    @inlinable
    public func inset(
        by insets: Geometry.EdgeInsets,
        y: Axis<2>.Vertical
    ) -> Self {
        switch y {
        case .upward:
            return Self(
                llx: llx + insets.leading,
                lly: lly + insets.bottom,
                urx: urx - insets.trailing,
                ury: ury - insets.top
            )
        case .downward:
            return Self(
                llx: llx + insets.leading,
                lly: lly + insets.top,
                urx: urx - insets.trailing,
                ury: ury - insets.bottom
            )
        }
    }
}

// MARK: - Dimension Clamping

extension Geometry.Rectangle where Scalar: Comparable & AdditiveArithmetic {
    /// Returns a rectangle with width clamped to at most the given maximum.
    ///
    /// The rectangle's origin and height are preserved. If the current width
    /// is already ≤ maxWidth, returns self unchanged.
    ///
    /// - Parameter maxWidth: The upper bound for width
    /// - Returns: A rectangle with `width ≤ maxWidth`
    @inlinable
    public func clamped(maxWidth: Geometry.Width) -> Self {
        guard width.value > maxWidth.value else { return self }
        var copy = self
        copy.width = maxWidth
        return copy
    }

    /// Returns a rectangle with height clamped to at most the given maximum.
    ///
    /// The rectangle's origin and width are preserved. If the current height
    /// is already ≤ maxHeight, returns self unchanged.
    ///
    /// - Parameter maxHeight: The upper bound for height
    /// - Returns: A rectangle with `height ≤ maxHeight`
    @inlinable
    public func clamped(maxHeight: Geometry.Height) -> Self {
        guard height.value > maxHeight.value else { return self }
        var copy = self
        copy.height = maxHeight
        return copy
    }
}

// MARK: - Functorial Map

extension Geometry.Rectangle {
    /// Create a rectangle by transforming each coordinate of another rectangle
    @inlinable
    public init<U, E: Error>(
        _ other: borrowing Geometry<U>.Rectangle,
        _ transform: (U) throws(E) -> Scalar
    ) throws(E) {
        self.init(
            llx: .init(try transform(other.llx.value)),
            lly: .init(try transform(other.lly.value)),
            urx: .init(try transform(other.urx.value)),
            ury: .init(try transform(other.ury.value))
        )
    }

    /// Transform each coordinate using the given closure
    @inlinable
    public func map<Result, E: Error>(
        _ transform: (Scalar) throws(E) -> Result
    ) throws(E) -> Geometry<Result>.Rectangle {
        Geometry<Result>.Rectangle(
            llx: .init(try transform(llx.value)),
            lly: .init(try transform(lly.value)),
            urx: .init(try transform(urx.value)),
            ury: .init(try transform(ury.value))
        )
    }
}

// MARK: - Bifunctor

extension Geometry.Rectangle where Scalar: AdditiveArithmetic {
    /// Create a rectangle by independently transforming origin and size
    @inlinable
    public init<U>(
        _ other: Geometry<U>.Rectangle,
        transformOrigin: (Geometry<U>.Point<2>) -> Geometry.Point<2>,
        transformSize: (Geometry<U>.Size<2>) -> Geometry.Size<2>
    ) where U: AdditiveArithmetic {
        let newOrigin = transformOrigin(other.origin)
        let newSize = transformSize(other.size)
        self.init(origin: newOrigin, size: newSize)
    }
}
