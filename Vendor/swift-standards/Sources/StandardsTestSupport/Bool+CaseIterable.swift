// Bool+CaseIterable.swift
// CaseIterable conformance for Bool and tuple extensions.

/// Make Bool conform to CaseIterable for exhaustive testing.
extension Bool: @retroactive CaseIterable {
    /// All possible boolean values: `[true, false]`.
    public static let allCases: [Bool] = [true, false]
}

// MARK: - Tuple Extensions for Exhaustive Testing

/// All combinations of two boolean values.
extension [(Bool, Bool)] {
    /// All 4 combinations: `[(true, true), (true, false), (false, true), (false, false)]`.
    public static let allCases: Self = Bool.allCases.flatMap { first in
        Bool.allCases.map { second in (first, second) }
    }
}

/// All combinations of three boolean values.
extension [(Bool, Bool, Bool)] {
    /// All 8 combinations of three booleans.
    public static let allCases: Self = [(Bool, Bool)].allCases.flatMap { (first, second) in
        Bool.allCases.map { third in (first, second, third) }
    }
}

/// All combinations of four boolean values.
extension [(Bool, Bool, Bool, Bool)] {
    /// All 16 combinations of four booleans.
    public static let allCases: Self = [(Bool, Bool, Bool)].allCases.flatMap {
        (first, second, third) in
        Bool.allCases.map { fourth in (first, second, third, fourth) }
    }
}

/// All combinations of five boolean values.
extension [(Bool, Bool, Bool, Bool, Bool)] {
    /// All 32 combinations of five booleans.
    public static let allCases: Self = [(Bool, Bool, Bool, Bool)].allCases.flatMap {
        (first, second, third, fourth) in
        Bool.allCases.map { fifth in (first, second, third, fourth, fifth) }
    }
}

/// All combinations of six boolean values.
extension [(Bool, Bool, Bool, Bool, Bool, Bool)] {
    /// All 64 combinations of six booleans.
    public static let allCases: Self = [(Bool, Bool, Bool, Bool, Bool)].allCases.flatMap {
        (first, second, third, fourth, fifth) in
        Bool.allCases.map { sixth in (first, second, third, fourth, fifth, sixth) }
    }
}
