// BoolOptional+CaseIterable.swift
// CaseIterable conformance for Bool? and tuple extensions.

/// Make Bool? conform to CaseIterable for exhaustive three-valued logic testing.
extension Bool?: @retroactive CaseIterable {
    /// All possible three-valued cases: `[true, false, nil]`.
    public static let allCases: [Bool?] = [.some(true), .some(false), .none]
}

// MARK: - Tuple Extensions for Exhaustive Testing

/// All combinations of two optional boolean values.
extension [(Bool?, Bool?)] {
    /// All 9 combinations of two three-valued booleans.
    public static let allCases: Self = Bool?.allCases.flatMap { first in
        Bool?.allCases.map { second in (first, second) }
    }
}

/// All combinations of three optional boolean values.
extension [(Bool?, Bool?, Bool?)] {
    /// All 27 combinations of three three-valued booleans.
    public static let allCases: Self = [(Bool?, Bool?)].allCases.flatMap { (first, second) in
        Bool?.allCases.map { third in (first, second, third) }
    }
}

/// All combinations of four optional boolean values.
extension [(Bool?, Bool?, Bool?, Bool?)] {
    /// All 81 combinations of four three-valued booleans.
    public static let allCases: Self = [(Bool?, Bool?, Bool?)].allCases.flatMap {
        (first, second, third) in
        Bool?.allCases.map { fourth in (first, second, third, fourth) }
    }
}

/// All combinations of five optional boolean values.
extension [(Bool?, Bool?, Bool?, Bool?, Bool?)] {
    /// All 243 combinations of five three-valued booleans.
    public static let allCases: Self = [(Bool?, Bool?, Bool?, Bool?)].allCases.flatMap {
        (first, second, third, fourth) in
        Bool?.allCases.map { fifth in (first, second, third, fourth, fifth) }
    }
}

/// All combinations of six optional boolean values.
extension [(Bool?, Bool?, Bool?, Bool?, Bool?, Bool?)] {
    /// All 729 combinations of six three-valued booleans.
    public static let allCases: Self = [(Bool?, Bool?, Bool?, Bool?, Bool?)].allCases.flatMap {
        (first, second, third, fourth, fifth) in
        Bool?.allCases.map { sixth in (first, second, third, fourth, fifth, sixth) }
    }
}
