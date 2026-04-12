// Dictionary.swift
// swift-standards
//
// Extensions for Swift standard library Dictionary

extension Dictionary {
    /// Transforms dictionary keys while preserving values
    ///
    /// Functorial mapping over key component of dictionary.
    /// Maps keys via injective function, maintaining dictionary structure.
    ///
    /// Category theory: Functor operation on key component
    /// mapKeys: (K → K') → Dict(K, V) → Dict(K', V)
    /// Note: Non-injective functions may cause key collisions
    ///
    /// Example:
    /// ```swift
    /// let dict = [1: "one", 2: "two"]
    /// dict.mapKeys { "key\($0)" }  // ["key1": "one", "key2": "two"]
    /// ```
    public func mapKeys<NewKey: Hashable>(
        _ transform: (Key) throws -> NewKey
    ) rethrows -> [NewKey: Value] {
        try reduce(into: [:]) { result, pair in
            result[try transform(pair.key)] = pair.value
        }
    }

    /// Transforms dictionary keys with optional results
    ///
    /// Partial key transformation lifting failures into Maybe.
    /// Filters out None results, preserving only successful transformations.
    ///
    /// Category theory: Natural transformation composed with filter
    /// compactMapKeys: (K → Maybe(K')) → Dict(K, V) → Dict(K', V)
    ///
    /// Example:
    /// ```swift
    /// let dict = [1: "one", 2: "two"]
    /// dict.compactMapKeys { $0 > 1 ? $0 : nil }  // [2: "two"]
    /// ```
    public func compactMapKeys<NewKey: Hashable>(
        _ transform: (Key) throws -> NewKey?
    ) rethrows -> [NewKey: Value] {
        try reduce(into: [:]) { result, pair in
            if let newKey = try transform(pair.key) {
                result[newKey] = pair.value
            }
        }
    }

    /// Compacts dictionary values, removing nil entries
    ///
    /// Natural transformation from Dict(K, Maybe(V)) to Dict(K, V).
    /// Flattens optional values, filtering out None cases.
    ///
    /// Category theory: Natural transformation ν: Dict ∘ Maybe → Dict
    /// ν: Dict(K, Maybe(V)) → Dict(K, V)
    ///
    /// Example:
    /// ```swift
    /// let dict: [String: Int?] = ["a": 1, "b": nil, "c": 3]
    /// dict.compactMapValues { $0 }  // Already exists in stdlib
    /// ```
    /// Note: compactMapValues already exists in Swift stdlib,
    /// but documented here for completeness
}

extension Dictionary where Value: Equatable {
    /// Inverts dictionary, swapping keys and values
    ///
    /// Represents bijective inverse when values are unique.
    /// For non-unique values, last occurrence wins.
    ///
    /// Category theory: Categorical dual (when values form set)
    /// invert: Dict(K, V) → Dict(V, K)
    /// Note: Only true inverse when V → K is injective
    ///
    /// Example:
    /// ```swift
    /// let dict = ["a": 1, "b": 2]
    /// dict.inverted()  // [1: "a", 2: "b"]
    /// ```
    public func inverted() -> [Value: Key] where Value: Hashable {
        reduce(into: [:]) { result, pair in
            result[pair.value] = pair.key
        }
    }
}
