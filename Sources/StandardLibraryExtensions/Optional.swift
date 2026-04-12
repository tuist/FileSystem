// Optional.swift
// swift-standards
//
// Extensions for Swift standard library Optional

extension Optional {
    /// Extracts value or throws error
    ///
    /// Partial evaluation made explicit via error channel.
    /// Natural transformation from Maybe to Either, mapping None to Left(Error).
    ///
    /// Category theory: η: Maybe(A) → Either(Error, A)
    /// None ↦ Left(e), Some(a) ↦ Right(a)
    ///
    /// Example:
    /// ```swift
    /// let value = try maybeValue.unwrap(or: MyError.notFound)
    /// ```
    public func unwrap(or error: any Error) throws -> Wrapped {
        guard let value = self else { throw error }
        return value
    }

    /// Monadic application of optional function to optional value
    ///
    /// Applicative functor operation: apply wrapped function to wrapped value.
    /// Extends functor structure with function application in Maybe context.
    ///
    /// Category theory: Applicative functor operation
    /// <*>: Maybe(A → B) → Maybe(A) → Maybe(B)
    /// Satisfies: pure(f) <*> pure(x) = pure(f(x))
    ///
    /// Example:
    /// ```swift
    /// let fn: ((Int) -> String)? = { String($0) }
    /// let value: Int? = 42
    /// value.apply(fn)  // Optional("42")
    /// ```
    public func apply<Result>(_ transform: ((Wrapped) -> Result)?) -> Result? {
        guard let transform = transform, let value = self else { return nil }
        return transform(value)
    }

    /// Combines two optional values into tuple
    ///
    /// Product in category of optional values.
    /// Categorical product: A × B in slice category Maybe.
    ///
    /// Category theory: Product morphism in Maybe category
    /// zip: Maybe(A) × Maybe(B) → Maybe(A × B)
    /// Satisfies: π₁ ∘ zip = id, π₂ ∘ zip = id
    ///
    /// Example:
    /// ```swift
    /// let a: Int? = 1
    /// let b: String? = "hello"
    /// a.zip(b)  // Optional((1, "hello"))
    /// ```
    public func zip<Other>(_ other: Other?) -> (Wrapped, Other)? {
        guard let value = self, let otherValue = other else { return nil }
        return (value, otherValue)
    }
}
