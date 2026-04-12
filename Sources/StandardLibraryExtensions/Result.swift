// Result.swift
// swift-standards
//
// Extensions for Swift standard library Result

extension Result {
    /// Extracts success value if present
    ///
    /// Partial projection from Either to Maybe.
    /// Right projection: Either(E, A) → Maybe(A)
    ///
    /// Category theory: Natural transformation from Either to Maybe
    /// η: Either(E, A) → Maybe(A) where Right(a) ↦ Some(a), Left(_) ↦ None
    ///
    /// Example:
    /// ```swift
    /// let result: Result<Int, Error> = .success(42)
    /// result.success  // Optional(42)
    /// ```
    public var success: Success? {
        guard case .success(let value) = self else { return nil }
        return value
    }

    /// Extracts failure value if present
    ///
    /// Partial projection from Either to Maybe.
    /// Left projection: Either(E, A) → Maybe(E)
    ///
    /// Category theory: Natural transformation from Either to Maybe
    /// η: Either(E, A) → Maybe(E) where Left(e) ↦ Some(e), Right(_) ↦ None
    ///
    /// Example:
    /// ```swift
    /// let result: Result<Int, Error> = .failure(MyError.failed)
    /// result.failure  // Optional(MyError.failed)
    /// ```
    public var failure: Failure? {
        guard case .failure(let error) = self else { return nil }
        return error
    }

    /// Combines two results into tuple of successes
    ///
    /// Product in category of Result types.
    /// Categorical product preserving error semantics: fails if either fails.
    ///
    /// Category theory: Product in Either monad
    /// zip: Either(E, A) × Either(E, B) → Either(E, A × B)
    /// Left-biased: returns first error encountered
    ///
    /// Example:
    /// ```swift
    /// let r1: Result<Int, Error> = .success(1)
    /// let r2: Result<String, Error> = .success("hello")
    /// r1.zip(r2)  // Result.success((1, "hello"))
    /// ```
    public func zip<OtherSuccess>(
        _ other: Result<OtherSuccess, Failure>
    ) -> Result<(Success, OtherSuccess), Failure> {
        switch (self, other) {
        case (.success(let a), .success(let b)):
            return .success((a, b))
        case (.failure(let error), _):
            return .failure(error)
        case (_, .failure(let error)):
            return .failure(error)
        }
    }

    /// Combines results with binary operation on successes
    ///
    /// Applicative combination of two computations.
    /// Lifts binary operation into Result context.
    ///
    /// Category theory: Applicative functor combination
    /// liftA2: (A → B → C) → Either(E, A) → Either(E, B) → Either(E, C)
    ///
    /// Example:
    /// ```swift
    /// let r1: Result<Int, Error> = .success(2)
    /// let r2: Result<Int, Error> = .success(3)
    /// r1.zip(r2, with: +)  // Result.success(5)
    /// ```
    public func zip<OtherSuccess, Combined>(
        _ other: Result<OtherSuccess, Failure>,
        with combine: (Success, OtherSuccess) -> Combined
    ) -> Result<Combined, Failure> {
        zip(other).map { combine($0.0, $0.1) }
    }
}
