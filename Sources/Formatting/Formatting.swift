/// A namespace for formatting functionality.
///
/// The `Formatting` namespace provides protocols and extensions for type-safe formatting
/// of values to strings and parsing strings back to values.
///
/// ## Overview
///
/// This package provides the core protocols that enable the `.formatted()` API pattern:
///
/// ```swift
/// let value = 42.0
/// let formatted = value.formatted(.number)
/// ```
///
/// Extension packages can provide specific format styles:
/// - swift-numeric-formatting-standard: Numeric formatting
/// - swift-percent: Percentage formatting
/// - swift-iso-8601: ISO 8601 date formatting
/// - swift-measurement: Unit and measurement formatting
public enum Format {}

// MARK: - FormatStyle Protocol

/// A type that can convert a value to a formatted output.
///
/// Conform to this protocol to create custom formatting styles that work
/// with the `.formatted(_:)` API.
///
/// ## Example
///
/// ```swift
/// struct MyStyle: FormatStyle {
///     typealias FormatInput = Double
///     typealias FormatOutput = String
///
///     func format(_ value: Double) -> String {
///         // Custom formatting logic
///     }
/// }
///
/// let result = 42.0.formatted(MyStyle())
/// ```
public protocol FormatStyle<FormatInput, FormatOutput>: Sendable {
    /// The type of value this style can format
    associatedtype FormatInput

    /// The type of output produced by formatting
    associatedtype FormatOutput

    /// Format a value to the output type
    ///
    /// - Parameter value: The value to format
    /// - Returns: The formatted output
    func format(_ value: FormatInput) -> FormatOutput
}

// MARK: - BinaryFloatingPoint + formatted()

extension BinaryFloatingPoint {
    /// Format this value using the given format style.
    ///
    /// - Parameter format: The format style to use
    /// - Returns: The formatted output
    @inlinable
    public func formatted<S>(_ format: S) -> S.FormatOutput
    where Self == S.FormatInput, S: FormatStyle {
        format.format(self)
    }

    /// Format this value using the given format style, converting to the style's input type.
    ///
    /// - Parameter format: The format style to use
    /// - Returns: The formatted output
    @inlinable
    public func formatted<S>(_ format: S) -> S.FormatOutput
    where S: FormatStyle, S.FormatInput: BinaryFloatingPoint {
        format.format(S.FormatInput(self))
    }
}

// MARK: - BinaryInteger + formatted()

extension BinaryInteger {
    /// Format this value using the given format style.
    ///
    /// - Parameter format: The format style to use
    /// - Returns: The formatted output
    @inlinable
    public func formatted<S>(_ format: S) -> S.FormatOutput
    where Self == S.FormatInput, S: FormatStyle {
        format.format(self)
    }

    /// Format this value using the given format style, converting to the style's input type.
    ///
    /// - Parameter format: The format style to use
    /// - Returns: The formatted output
    @inlinable
    public func formatted<S>(_ format: S) -> S.FormatOutput
    where S: FormatStyle, S.FormatInput: BinaryInteger {
        format.format(S.FormatInput(self))
    }
}
