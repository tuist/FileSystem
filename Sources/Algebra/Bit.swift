// Bit.swift
// Binary digit (0 or 1).

// A single binary digit: zero or one.
//
// The fundamental unit of information in digital systems.
//
// ## Mathematical Properties
//
// - Forms Z₂ field under XOR (addition) and AND (multiplication)
// - `flipped` is the NOT operation
// - Identity for AND is `one`, for XOR is `zero`
//
// ## Tagged Values
//
// Use `Bit.Value<T>` to pair a value with a bit flag:
//
// ```swift
// let weighted: Bit.Value<Double> = .init(tag: .one, value: 0.5)
// ```
// public enum Bit: UInt8, Sendable, Hashable, Codable, CaseIterable {
//    /// Binary zero (false, off, low).
//    case zero = 0
//
//    /// Binary one (true, on, high).
//    case one = 1
// }

public typealias Bit = UInt8

extension Bit {
    public static let zero: Self = 0
    public static let one: Self = 1
}

extension Bit: @retroactive CaseIterable {
    public static let allCases: [UInt8] = [.zero, .one]
}

// MARK: - Flip

extension Bit {
    /// The flipped bit (NOT operation).
    @inlinable
    public var flipped: Bit { self ^ 1 }

    /// Returns the flipped bit.
    @inlinable
    public static prefix func ! (value: Bit) -> Bit {
        value.flipped
    }

    /// Alias for `flipped` following digital logic terminology.
    @inlinable
    public var toggled: Bit { flipped }
}

// MARK: - Boolean Operations

extension Bit {
    /// Logical AND of two bits.
    @inlinable
    public func and(_ other: Bit) -> Bit {
        (self == .one && other == .one) ? .one : .zero
    }

    /// Logical OR of two bits.
    @inlinable
    public func or(_ other: Bit) -> Bit {
        (self == .one || other == .one) ? .one : .zero
    }

    /// Logical XOR of two bits (addition in Z₂).
    @inlinable
    public func xor(_ other: Bit) -> Bit {
        (self != other) ? .one : .zero
    }
}

// MARK: - Boolean Conversion

extension Bit {
    /// Creates a bit from a boolean.
    @inlinable
    public init(_ bool: Bool) {
        self = bool ? .one : .zero
    }

    /// The boolean representation.
    @inlinable
    public var boolValue: Bool {
        self == .one
    }
}

// MARK: - Tagged Value

extension Bit {
    /// A value paired with a bit flag.
    public typealias Value<Payload> = Tagged<Bit, Payload>
}
