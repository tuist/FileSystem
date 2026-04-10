// Bit.Order.swift
// Bit significance order within a byte.

public import Algebra

/// Bit significance order within a byte.
///
/// Specifies which bit is considered "first" when processing bits
/// within a byte or when serializing bit streams.
///
/// ## Cases
///
/// - `msb`: Most significant bit first (bit 7 → bit 0)
/// - `lsb`: Least significant bit first (bit 0 → bit 7)
///
/// ## Usage
///
/// ```swift
/// // Process bits from most significant to least
/// for bit in byte.bits(order: .msb) { ... }
///
/// // Process bits from least significant to most
/// for bit in byte.bits(order: .lsb) { ... }
/// ```
///
/// ## Common Conventions
///
/// - **MSB first**: Network protocols, most serial protocols, human-readable binary
/// - **LSB first**: Some hardware interfaces, certain compression algorithms
///
extension Bit {
    public enum Order: Sendable, Hashable, Codable, CaseIterable {
        /// Most significant bit first (bit 7 → bit 0).
        case msb

        /// Least significant bit first (bit 0 → bit 7).
        case lsb
    }
}

extension Bit.Order {
    @inlinable
    public static var `most significant bit first`: Self { .msb }

    @inlinable
    public static var `least significant bit first`: Self { .msb }
}

// MARK: - Opposite

extension Bit.Order {
    /// The opposite bit order.
    @inlinable
    public var opposite: Bit.Order {
        switch self {
        case .msb: return .lsb
        case .lsb: return .msb
        }
    }

    /// Returns the opposite bit order.
    @inlinable
    public static prefix func ! (value: Bit.Order) -> Bit.Order {
        value.opposite
    }
}

// MARK: - Tagged Value

extension Bit.Order {
    /// A value paired with its bit order.
    public typealias Value<Payload> = Tagged<Bit.Order, Payload>
}
