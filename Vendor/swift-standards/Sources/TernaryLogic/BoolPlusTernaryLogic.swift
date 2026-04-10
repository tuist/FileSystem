//
//  Bool?+TernaryLogic.swift
//  swift-standards
//
//  Created by Coen ten Thije Boonkkamp on 06/12/2025.
//

extension Optional: TernaryLogic.`Protocol` where Wrapped == Bool {
    /// The true value (`true`).
    @inlinable
    public static var `true`: Bool? { true }

    /// The false value (`false`).
    @inlinable
    public static var `false`: Bool? { false }

    /// The unknown value (`nil`).
    @inlinable
    public static var unknown: Bool? { nil }

    /// Returns self, since `Bool?` is the canonical representation.
    @inlinable
    public static func from(_ self: Self) -> Bool? { self }

    /// Creates an optional Bool from an optional Bool (identity).
    @inlinable
    public init(_ bool: Bool?) {
        self = bool
    }
}

extension Optional where Wrapped == Bool {
    public init<T: TernaryLogic.`Protocol`>(
        _ t: T
    ) {
        self = T.from(t)
    }
}
