// Geometry+Formatting.swift
// FormatStyle support for Geometry types.

public import Formatting

// MARK: - X + formatted()

extension Geometry.X where Scalar: BinaryFloatingPoint {
    /// Format this X coordinate using the given format style.
    ///
    /// - Parameter format: The format style to use
    /// - Returns: The formatted output
    ///
    /// ## Example
    ///
    /// ```swift
    /// let x: Geometry<Double>.X = 72.5
    /// x.formatted(.number)  // "72.5"
    /// x.formatted(.number.precision(.fractionLength(2)))  // "72.50"
    /// ```
    @inlinable
    public func formatted<S>(_ format: S) -> S.FormatOutput
    where S: FormatStyle, S.FormatInput: BinaryFloatingPoint {
        format.format(S.FormatInput(value))
    }
}

// MARK: - Y + formatted()

extension Geometry.Y where Scalar: BinaryFloatingPoint {
    /// Format this Y coordinate using the given format style.
    ///
    /// - Parameter format: The format style to use
    /// - Returns: The formatted output
    ///
    /// ## Example
    ///
    /// ```swift
    /// let y: Geometry<Double>.Y = 144.0
    /// y.formatted(.number)  // "144"
    /// ```
    @inlinable
    public func formatted<S>(_ format: S) -> S.FormatOutput
    where S: FormatStyle, S.FormatInput: BinaryFloatingPoint {
        format.format(S.FormatInput(value))
    }
}

// MARK: - Width + formatted()

extension Geometry.Width where Scalar: BinaryFloatingPoint {
    /// Format this width using the given format style.
    ///
    /// - Parameter format: The format style to use
    /// - Returns: The formatted output
    ///
    /// ## Example
    ///
    /// ```swift
    /// let width: Geometry<Double>.Width = 612.0
    /// width.formatted(.number)  // "612"
    /// ```
    @inlinable
    public func formatted<S>(_ format: S) -> S.FormatOutput
    where S: FormatStyle, S.FormatInput: BinaryFloatingPoint {
        format.format(S.FormatInput(value))
    }
}

// MARK: - Height + formatted()

extension Geometry.Height where Scalar: BinaryFloatingPoint {
    /// Format this height using the given format style.
    ///
    /// - Parameter format: The format style to use
    /// - Returns: The formatted output
    ///
    /// ## Example
    ///
    /// ```swift
    /// let height: Geometry<Double>.Height = 792.0
    /// height.formatted(.number)  // "792"
    /// ```
    @inlinable
    public func formatted<S>(_ format: S) -> S.FormatOutput
    where S: FormatStyle, S.FormatInput: BinaryFloatingPoint {
        format.format(S.FormatInput(value))
    }
}

// MARK: - Length + formatted()

extension Geometry.Length where Scalar: BinaryFloatingPoint {
    /// Format this length using the given format style.
    ///
    /// - Parameter format: The format style to use
    /// - Returns: The formatted output
    @inlinable
    public func formatted<S>(_ format: S) -> S.FormatOutput
    where S: FormatStyle, S.FormatInput: BinaryFloatingPoint {
        format.format(S.FormatInput(value))
    }
}

// MARK: - Dimension + formatted()

extension Geometry.Dimension where Scalar: BinaryFloatingPoint {
    /// Format this dimension using the given format style.
    ///
    /// - Parameter format: The format style to use
    /// - Returns: The formatted output
    @inlinable
    public func formatted<S>(_ format: S) -> S.FormatOutput
    where S: FormatStyle, S.FormatInput: BinaryFloatingPoint {
        format.format(S.FormatInput(value))
    }
}
