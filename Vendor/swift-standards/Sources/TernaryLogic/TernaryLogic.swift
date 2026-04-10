// TernaryLogic.swift
// Namespace and protocol for three-valued logic types.

// Namespace for ternary (three-valued) logic types and operations.
//
// Ternary logic extends classical boolean logic with a third value
// representing "unknown" or "indeterminate".
//
// The canonical ternary logic type is `Bool?`, which conforms to
// `TernaryLogic.Protocol`.
// public enum TernaryLogic {}
public enum TernaryLogic {}

// MARK: - Protocol

extension TernaryLogic {
    /// A type that represents three-valued (ternary) logic.
    ///
    /// Ternary logic extends classical boolean logic with a third value
    /// representing "unknown" or "indeterminate". Conforming types provide
    /// three distinct states and gain all Strong Kleene logic operators
    /// through protocol extensions.
    ///
    /// ## Conforming to TernaryLogic.Protocol
    ///
    /// To conform, provide the three static values and conversions to/from `Bool?`:
    ///
    /// ```swift
    /// enum Tribool: TernaryLogic.Protocol {
    ///     case yes, no, maybe
    ///
    ///     static var `true`: Tribool { .yes }
    ///     static var `false`: Tribool { .no }
    ///     static var unknown: Tribool { .maybe }
    ///
    ///     var boolValue: Bool? {
    ///         switch self {
    ///         case .yes: true
    ///         case .no: false
    ///         case .maybe: nil
    ///         }
    ///     }
    ///
    ///     init(boolValue: Bool?) {
    ///         switch boolValue {
    ///         case true: self = .yes
    ///         case false: self = .no
    ///         case nil: self = .maybe
    ///         }
    ///     }
    /// }
    /// ```
    ///
    /// Conforming types automatically receive all logic operators:
    /// `&&`, `||`, `!`, `^`, `!&&`, `!||`, `!^`
    public protocol `Protocol` {
        /// The true value.
        static var `true`: Self { get }

        /// The false value.
        static var `false`: Self { get }

        /// The unknown/indeterminate value.
        static var unknown: Self { get }

        static func from(_ self: Self) -> Bool?

        /// Creates a ternary value from an optional Bool.
        ///
        /// - Parameter boolValue: `true`, `false`, or `nil` for unknown.
        init(_ bool: Bool?)
    }
}

// MARK: - AND Operator

/// Strong Kleene three-valued logic AND for any `TernaryLogic.Protocol` type.
///
/// Returns `false` if either operand is `false` (short-circuit),
/// `nil` if either operand is unknown and neither is `false`,
/// `true` only if both operands are `true`.
@inlinable
public func && <T: TernaryLogic.`Protocol`>(
    lhs: T,
    rhs: @autoclosure () throws -> T
) rethrows -> T {
    if T.from(lhs) == false { return .false }
    let rhs = try rhs()
    if T.from(rhs) == false { return .false }
    if T.from(lhs) == nil || T.from(rhs) == nil { return .unknown }
    return .true
}

// MARK: - OR Operator

/// Strong Kleene three-valued logic OR for any `TernaryLogic.Protocol` type.
///
/// Returns `true` if either operand is `true` (short-circuit),
/// unknown if either operand is unknown and neither is `true`,
/// `false` only if both operands are `false`.
@inlinable
public func || <T: TernaryLogic.`Protocol`>(
    lhs: T,
    rhs: @autoclosure () throws -> T
) rethrows -> T {
    if T.from(lhs) == true { return .true }
    let rhs = try rhs()
    if T.from(rhs) == true { return .true }
    if T.from(lhs) == nil || T.from(rhs) == nil { return .unknown }
    return .false
}

// MARK: - NOT Operator

/// Strong Kleene three-valued logic NOT for any `TernaryLogic.Protocol` type.
///
/// Returns unknown if the operand is unknown, otherwise returns the negation.
@inlinable
public prefix func ! <T: TernaryLogic.`Protocol`>(value: T) -> T {
    switch T.from(value) {
    case true: return .false
    case false: return .true
    case nil: return .unknown
    }
}

// MARK: - XOR Operator

/// Strong Kleene three-valued logic XOR for any `TernaryLogic.Protocol` type.
///
/// Returns unknown if either operand is unknown,
/// otherwise returns `true` if exactly one operand is `true`.
@inlinable
public func ^ <T: TernaryLogic.`Protocol`>(lhs: T, rhs: T) -> T {
    guard let l = T.from(lhs), let r = T.from(rhs) else { return .unknown }
    return l != r ? .true : .false
}

// MARK: - NAND Operator

// Custom infix operator for NAND
infix operator !&& : LogicalConjunctionPrecedence

/// Strong Kleene three-valued logic NAND for any `TernaryLogic.Protocol` type.
///
/// Returns the negation of the AND result.
@inlinable
public func !&& <T: TernaryLogic.`Protocol`>(
    lhs: T,
    rhs: @autoclosure () throws -> T
) rethrows -> T {
    try !(lhs && rhs())
}

// MARK: - NOR Operator

// Custom infix operator for NOR
infix operator !|| : LogicalDisjunctionPrecedence

/// Strong Kleene three-valued logic NOR for any `TernaryLogic.Protocol` type.
///
/// Returns the negation of the OR result.
@inlinable
public func !|| <T: TernaryLogic.`Protocol`>(
    lhs: T,
    rhs: @autoclosure () throws -> T
) rethrows -> T {
    try !(lhs || rhs())
}

// MARK: - XNOR Operator

// Custom infix operator for XNOR
infix operator !^ : ComparisonPrecedence

/// Strong Kleene three-valued logic XNOR for any `TernaryLogic.Protocol` type.
///
/// Returns unknown if either operand is unknown,
/// otherwise returns `true` if both operands have the same value.
@inlinable
public func !^ <T: TernaryLogic.`Protocol`>(lhs: T, rhs: T) -> T {
    guard let l = T.from(lhs), let r = T.from(rhs) else { return .unknown }
    return l == r ? .true : .false
}
