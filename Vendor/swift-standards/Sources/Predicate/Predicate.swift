// Predicate.swift
// A composable boolean test on values of type T.

/// A predicate that tests whether values of type `T` satisfy a condition.
///
/// Predicates are composable boolean functions. They can be combined using
/// logical operators to build complex conditions from simple ones.
///
/// ## Creating Predicates
///
/// ```swift
/// let isEven = Predicate<Int> { $0 % 2 == 0 }
/// let isPositive = Predicate<Int> { $0 > 0 }
/// ```
///
/// ## Fluent Factory Methods
///
/// ```swift
/// Predicate<String>.is.empty
/// Predicate<Int>.in.range(1...10)
/// Predicate<String>.has.prefix("foo")
/// Predicate<Int>.greater.than(5)
/// Predicate<Int>.equal.to(42)
/// ```
///
/// ## Evaluating Predicates
///
/// Predicates are callable, so you can use them like functions:
///
/// ```swift
/// isEven(4)      // true
/// isEven(3)      // false
/// ```
///
/// ## Composing Predicates
///
/// Use logical operators or fluent methods:
///
/// ```swift
/// // Operators
/// let isEvenAndPositive = isEven && isPositive
/// let isEvenOrPositive = isEven || isPositive
/// let isOdd = !isEven
///
/// // Fluent methods
/// let isEvenAndPositive = isEven.and(isPositive)
/// let isOdd = isEven.negated
/// ```
///
/// ## Mathematical Properties
///
/// Predicates form a Boolean algebra under `and`, `or`, and `negated`:
///
/// - **Identity**: `p.and(.always) ≡ p`, `p.or(.never) ≡ p`
/// - **Annihilation**: `p.and(.never) ≡ .never`, `p.or(.always) ≡ .always`
/// - **Idempotence**: `p.and(p) ≡ p`, `p.or(p) ≡ p`
/// - **Complement**: `p.and(p.negated) ≡ .never`, `p.or(p.negated) ≡ .always`
/// - **Double negation**: `p.negated.negated ≡ p`
/// - **De Morgan**: `!(p && q) ≡ !p || !q`, `!(p || q) ≡ !p && !q`
/// - **Distributivity**: `p && (q || r) ≡ (p && q) || (p && r)`
///
/// ## Operator Precedence
///
/// Predicate operators follow Swift's standard precedence:
/// - `!` (negation) binds tightest
/// - `&&` (conjunction) binds tighter than `||`
/// - `||` (disjunction) binds loosest
///
/// This means `a || b && c` parses as `a || (b && c)`, matching Boolean algebra convention.
public struct Predicate<T>: @unchecked Sendable {
    /// The underlying evaluation function.
    public var evaluate: (T) -> Bool

    /// Creates a predicate from an evaluation closure.
    ///
    /// - Parameter evaluate: A closure that returns `true` if the value satisfies the condition.
    @inlinable
    public init(_ evaluate: @escaping (T) -> Bool) {
        self.evaluate = evaluate
    }
}

// MARK: - Call as Function

extension Predicate {
    /// Evaluates the predicate on a value.
    ///
    /// This allows predicates to be used like functions:
    /// ```swift
    /// let isEven = Predicate<Int> { $0 % 2 == 0 }
    /// isEven(4)  // true
    /// ```
    @inlinable
    public func callAsFunction(_ value: T) -> Bool {
        evaluate(value)
    }
}

// MARK: - Constants

extension Predicate {
    /// A predicate that always returns `true`.
    ///
    /// This is the identity element for `and`:
    /// ```swift
    /// p.and(.always) ≡ p
    /// ```
    @inlinable
    public static var always: Predicate {
        Predicate { _ in true }
    }

    /// A predicate that always returns `false`.
    ///
    /// This is the identity element for `or`:
    /// ```swift
    /// p.or(.never) ≡ p
    /// ```
    @inlinable
    public static var never: Predicate {
        Predicate { _ in false }
    }
}

// MARK: - Negation

extension Predicate {
    /// The negation of this predicate.
    ///
    /// Returns a predicate that returns `true` when this predicate returns `false`,
    /// and vice versa.
    ///
    /// ```swift
    /// let isEven = Predicate<Int> { $0 % 2 == 0 }
    /// let isOdd = isEven.negated
    /// isOdd(3)  // true
    /// ```
    @inlinable
    public var negated: Predicate {
        Predicate { !self.evaluate($0) }
    }

    /// Returns the negation of the predicate.
    @inlinable
    public static prefix func ! (predicate: Predicate) -> Predicate {
        predicate.negated
    }
}

// MARK: - Conjunction (AND)

extension Predicate {
    /// Combines this predicate with another using logical AND.
    ///
    /// The resulting predicate returns `true` only if both predicates return `true`.
    ///
    /// ```swift
    /// let isEven = Predicate<Int> { $0 % 2 == 0 }
    /// let isPositive = Predicate<Int> { $0 > 0 }
    /// let isEvenAndPositive = isEven.and(isPositive)
    /// isEvenAndPositive(4)   // true
    /// isEvenAndPositive(-4)  // false
    /// ```
    @inlinable
    public func and(_ other: Predicate) -> Predicate {
        Predicate { self.evaluate($0) && other.evaluate($0) }
    }

    /// Combines two predicates using logical AND.
    @inlinable
    public static func && (lhs: Predicate, rhs: Predicate) -> Predicate {
        lhs.and(rhs)
    }
}

// MARK: - Disjunction (OR)

extension Predicate {
    /// Combines this predicate with another using logical OR.
    ///
    /// The resulting predicate returns `true` if either predicate returns `true`.
    ///
    /// ```swift
    /// let isEven = Predicate<Int> { $0 % 2 == 0 }
    /// let isNegative = Predicate<Int> { $0 < 0 }
    /// let isEvenOrNegative = isEven.or(isNegative)
    /// isEvenOrNegative(4)   // true
    /// isEvenOrNegative(-3)  // true
    /// isEvenOrNegative(3)   // false
    /// ```
    @inlinable
    public func or(_ other: Predicate) -> Predicate {
        Predicate { self.evaluate($0) || other.evaluate($0) }
    }

    /// Combines two predicates using logical OR.
    @inlinable
    public static func || (lhs: Predicate, rhs: Predicate) -> Predicate {
        lhs.or(rhs)
    }
}

// MARK: - Exclusive Or (XOR)

extension Predicate {
    /// Combines this predicate with another using logical XOR.
    ///
    /// The resulting predicate returns `true` if exactly one predicate returns `true`.
    ///
    /// ```swift
    /// let isEven = Predicate<Int> { $0 % 2 == 0 }
    /// let isPositive = Predicate<Int> { $0 > 0 }
    /// let isEvenXorPositive = isEven.xor(isPositive)
    /// isEvenXorPositive(4)   // false (both true)
    /// isEvenXorPositive(3)   // true (positive only)
    /// isEvenXorPositive(-4)  // true (even only)
    /// ```
    @inlinable
    public func xor(_ other: Predicate) -> Predicate {
        Predicate { self.evaluate($0) != other.evaluate($0) }
    }

    /// Combines two predicates using logical XOR.
    @inlinable
    public static func ^ (lhs: Predicate, rhs: Predicate) -> Predicate {
        lhs.xor(rhs)
    }
}

// MARK: - NAND / NOR

extension Predicate {
    /// Combines this predicate with another using logical NAND.
    ///
    /// Returns `true` unless both predicates return `true`.
    /// Short-circuits: if `self` is `false`, `other` is not evaluated.
    ///
    /// Equivalent to `!(self && other)`.
    @inlinable
    public func nand(_ other: Predicate) -> Predicate {
        Predicate { !self.evaluate($0) || !other.evaluate($0) }
    }

    /// Combines this predicate with another using logical NOR.
    ///
    /// Returns `true` only if both predicates return `false`.
    /// Short-circuits: if `self` is `true`, `other` is not evaluated.
    ///
    /// Equivalent to `!(self || other)`.
    @inlinable
    public func nor(_ other: Predicate) -> Predicate {
        Predicate { !self.evaluate($0) && !other.evaluate($0) }
    }
}

// MARK: - Implication

extension Predicate {
    /// Creates a predicate representing logical implication.
    ///
    /// `self.implies(other)` is equivalent to `!self || other`.
    /// Returns `true` unless `self` is `true` and `other` is `false`.
    ///
    /// ```swift
    /// let hasPermission = isAdmin.implies(canDelete)
    /// // If admin, must be able to delete; non-admins always pass
    /// ```
    @inlinable
    public func implies(_ other: Predicate) -> Predicate {
        self.negated.or(other)
    }

    /// Creates a predicate representing logical biconditional (if and only if).
    ///
    /// Returns `true` when both predicates have the same truth value.
    /// Equivalent to `!(self.xor(other))`.
    @inlinable
    public func iff(_ other: Predicate) -> Predicate {
        self.xor(other).negated
    }

    /// Creates a predicate representing reverse implication.
    ///
    /// `self.unless(condition)` returns `true` unless `condition` is `true` and `self` is `false`.
    /// Equivalent to `condition.implies(self)` or `!condition || self`.
    ///
    /// Reads naturally in validation contexts:
    /// ```swift
    /// let isValid = hasPayment.unless(isFreeUser)
    /// // Must have payment unless user is free tier
    /// ```
    @inlinable
    public func unless(_ condition: Predicate) -> Predicate {
        condition.implies(self)
    }
}

// MARK: - Contravariant Mapping

extension Predicate {
    /// Transforms a predicate to work on a different input type.
    ///
    /// Given a function from `U` to `T`, creates a predicate on `U`
    /// by first applying the transformation.
    ///
    /// ```swift
    /// let isEven = Predicate<Int> { $0 % 2 == 0 }
    /// let hasEvenLength = isEven.pullback(\.count)
    /// hasEvenLength("hi")    // true (count 2)
    /// hasEvenLength("hello") // false (count 5)
    /// ```
    ///
    /// - Parameter transform: A function that transforms `U` values to `T` values.
    /// - Returns: A predicate that tests `U` values.
    @inlinable
    public func pullback<U>(_ transform: @escaping (U) -> T) -> Predicate<U> {
        Predicate<U> { self.evaluate(transform($0)) }
    }

    /// Transforms a predicate using a key path.
    ///
    /// ```swift
    /// let isLong = Predicate<Int> { $0 > 10 }
    /// let hasLongName = isLong.pullback(\User.name.count)
    /// ```
    @inlinable
    public func pullback<U>(_ keyPath: KeyPath<U, T>) -> Predicate<U> {
        pullback { $0[keyPath: keyPath] }
    }
}

// MARK: - Where Clause

extension Predicate {
    /// Creates a predicate that tests a property of the input using another predicate.
    ///
    /// ```swift
    /// let isAdult = Predicate<Person>.where(\.age, Predicate<Int>.greater.thanOrEqualTo(18))
    /// ```
    @inlinable
    public static func `where`<V>(_ keyPath: KeyPath<T, V>, _ predicate: Predicate<V>) -> Predicate
    {
        predicate.pullback(keyPath)
    }

    /// Creates a predicate that tests a property using a closure.
    ///
    /// ```swift
    /// let isLongName = Predicate<Person>.where(\.name) { $0.count > 10 }
    /// ```
    @inlinable
    public static func `where`<V>(
        _ keyPath: KeyPath<T, V>,
        _ test: @escaping (V) -> Bool
    ) -> Predicate {
        Predicate<V>(test).pullback(keyPath)
    }
}

// MARK: - Optional Lifting

extension Predicate {
    /// Lifts this predicate to work on optional values.
    ///
    /// Returns the default value for `nil`, otherwise evaluates the wrapped value.
    ///
    /// ```swift
    /// let isEven = Predicate<Int> { $0 % 2 == 0 }
    /// let isEvenOrNil = isEven.optional(default: false)
    /// isEvenOrNil(4)    // true
    /// isEvenOrNil(nil)  // false
    /// ```
    @inlinable
    public func optional(default defaultValue: Bool) -> Predicate<T?> {
        Predicate<T?> { value in
            guard let value else { return defaultValue }
            return self.evaluate(value)
        }
    }
}

// MARK: - Quantifiers

extension Predicate {
    /// Creates a predicate that tests if all elements in an array satisfy this predicate.
    ///
    /// ```swift
    /// let isEven = Predicate<Int> { $0 % 2 == 0 }
    /// let allEven = isEven.all
    /// allEven([2, 4, 6])  // true
    /// allEven([2, 3, 4])  // false
    /// ```
    @inlinable
    public var all: Predicate<[T]> {
        Predicate<[T]> { $0.allSatisfy(self.evaluate) }
    }

    /// Creates a predicate that tests if any element in an array satisfies this predicate.
    ///
    /// ```swift
    /// let isEven = Predicate<Int> { $0 % 2 == 0 }
    /// let anyEven = isEven.any
    /// anyEven([1, 2, 3])  // true
    /// anyEven([1, 3, 5])  // false
    /// ```
    @inlinable
    public var any: Predicate<[T]> {
        Predicate<[T]> { $0.contains(where: self.evaluate) }
    }

    /// Creates a predicate that tests if no elements in an array satisfy this predicate.
    @inlinable
    public var none: Predicate<[T]> {
        Predicate<[T]> { !$0.contains(where: self.evaluate) }
    }

    /// Creates a predicate that tests if all elements in a sequence satisfy this predicate.
    @inlinable
    public func forAll<S: Sequence>() -> Predicate<S> where S.Element == T {
        Predicate<S> { $0.allSatisfy(self.evaluate) }
    }

    /// Creates a predicate that tests if any element in a sequence satisfies this predicate.
    @inlinable
    public func forAny<S: Sequence>() -> Predicate<S> where S.Element == T {
        Predicate<S> { $0.contains(where: self.evaluate) }
    }

    /// Creates a predicate that tests if no elements in a sequence satisfy this predicate.
    @inlinable
    public func forNone<S: Sequence>() -> Predicate<S> where S.Element == T {
        Predicate<S> { !$0.contains(where: self.evaluate) }
    }
}

// MARK: - Is

extension Predicate {
    /// Namespace for "is" predicates.
    public struct Is {
        @usableFromInline
        init() {}
    }

    public static var `is`: Is.Type { Is.self }
}

extension Predicate.Is where T: Collection {
    @inlinable
    public static var empty: Predicate<T> {
        Predicate { $0.isEmpty }
    }

    @inlinable
    public static var notEmpty: Predicate<T> {
        Predicate { !$0.isEmpty }
    }
}

extension Predicate.Is {
    @inlinable
    public static var `nil`: Predicate<T?> {
        Predicate<T?> { $0 == nil }
    }

    @inlinable
    public static var notNil: Predicate<T?> {
        Predicate<T?> { $0 != nil }
    }
}

// MARK: - In

extension Predicate {
    /// Namespace for "in" predicates.
    public struct In {
        @usableFromInline
        init() {}
    }

    public static var `in`: In.Type { In.self }
}

extension Predicate.In where T: Comparable {
    @inlinable
    public static func range(_ range: ClosedRange<T>) -> Predicate<T> {
        Predicate { range.contains($0) }
    }

    @inlinable
    public static func range(_ range: Range<T>) -> Predicate<T> {
        Predicate { range.contains($0) }
    }
}

extension Predicate.In where T: Equatable {
    @inlinable
    public static func collection<C: Collection>(_ collection: C) -> Predicate<T>
    where C.Element == T {
        Predicate { collection.contains($0) }
    }
}

// MARK: - Has

extension Predicate {
    /// Namespace for "has" predicates.
    public struct Has {
        @usableFromInline
        init() {}
    }

    public static var has: Has.Type { Has.self }
}

extension Predicate.Has where T: StringProtocol {
    @inlinable
    public static func prefix(_ prefix: String) -> Predicate<T> {
        Predicate { $0.hasPrefix(prefix) }
    }

    @inlinable
    public static func suffix(_ suffix: String) -> Predicate<T> {
        Predicate { $0.hasSuffix(suffix) }
    }
}

extension Predicate.Has where T: Collection {
    @inlinable
    public static func count(_ count: Int) -> Predicate<T> {
        Predicate { $0.count == count }
    }
}

extension Predicate.Has where T: Identifiable {
    @inlinable
    public static func id(_ id: T.ID) -> Predicate<T> {
        Predicate { $0.id == id }
    }

    @inlinable
    public static func id<C: Collection>(in ids: C) -> Predicate<T> where C.Element == T.ID {
        Predicate { ids.contains($0.id) }
    }
}

// MARK: - Greater / Less

extension Predicate {
    /// Namespace for "greater" predicates.
    public struct Greater {
        @usableFromInline
        init() {}
    }

    /// Namespace for "less" predicates.
    public struct Less {
        @usableFromInline
        init() {}
    }

    public static var greater: Greater.Type { Greater.self }
    public static var less: Less.Type { Less.self }
}

extension Predicate.Greater where T: Comparable {
    @inlinable
    public static func than(_ value: T) -> Predicate<T> {
        Predicate { $0 > value }
    }

    @inlinable
    public static func thanOrEqualTo(_ value: T) -> Predicate<T> {
        Predicate { $0 >= value }
    }
}

extension Predicate.Less where T: Comparable {
    @inlinable
    public static func than(_ value: T) -> Predicate<T> {
        Predicate { $0 < value }
    }

    @inlinable
    public static func thanOrEqualTo(_ value: T) -> Predicate<T> {
        Predicate { $0 <= value }
    }
}

// MARK: - Equal

extension Predicate {
    /// Namespace for "equal" predicates.
    public struct Equal {
        @usableFromInline
        init() {}
    }

    public static var equal: Equal.Type { Equal.self }
}

extension Predicate.Equal where T: Equatable {
    @inlinable
    public static func to(_ value: T) -> Predicate<T> {
        Predicate { $0 == value }
    }

    @inlinable
    public static func toAny(of values: T...) -> Predicate<T> {
        Predicate { values.contains($0) }
    }

    @inlinable
    public static func toNone(of values: T...) -> Predicate<T> {
        Predicate { !values.contains($0) }
    }
}

// MARK: - Not

extension Predicate {
    /// Namespace for "not" predicates.
    public struct Not {
        @usableFromInline
        init() {}
    }

    public static var not: Not.Type { Not.self }
}

extension Predicate.Not where T: Equatable {
    @inlinable
    public static func equalTo(_ value: T) -> Predicate<T> {
        Predicate { $0 != value }
    }
}

extension Predicate.Not where T: Comparable {
    @inlinable
    public static func inRange(_ range: ClosedRange<T>) -> Predicate<T> {
        Predicate { !range.contains($0) }
    }

    @inlinable
    public static func inRange(_ range: Range<T>) -> Predicate<T> {
        Predicate { !range.contains($0) }
    }
}

extension Predicate.Not where T: Collection {
    @inlinable
    public static var empty: Predicate<T> {
        Predicate { !$0.isEmpty }
    }
}

// MARK: - Contains

extension Predicate {
    /// Namespace for "contains" predicates.
    public struct Contains {
        @usableFromInline
        init() {}
    }

    public static var contains: Contains.Type { Contains.self }
}

extension Predicate.Contains where T: StringProtocol {
    @inlinable
    public static func substring(_ substring: String) -> Predicate<T> {
        Predicate { $0.contains(substring) }
    }

    @available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
    @inlinable
    public static func match(_ regex: Regex<Substring>) -> Predicate<T> {
        Predicate { (try? regex.firstMatch(in: String($0))) != nil }
    }
}

// MARK: - Matches

extension Predicate {
    /// Namespace for "matches" predicates.
    public struct Matches {
        @usableFromInline
        init() {}
    }

    public static var matches: Matches.Type { Matches.self }
}

extension Predicate.Matches where T: StringProtocol {
    @available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
    @inlinable
    public static func regex(_ regex: Regex<Substring>) -> Predicate<T> {
        Predicate { (try? regex.wholeMatch(in: String($0))) != nil }
    }
}

// MARK: - Count (Instance-level quantifiers)

extension Predicate {
    /// Namespace for count-based quantifiers.
    public struct Count {
        @usableFromInline
        let predicate: Predicate

        @usableFromInline
        init(_ predicate: Predicate) {
            self.predicate = predicate
        }
    }

    /// Access count-based quantifiers: `isEven.count.atLeast(2)`.
    @inlinable
    public var count: Count { Count(self) }
}

extension Predicate.Count {
    @inlinable
    public func atLeast(_ n: Int) -> Predicate<[T]> {
        Predicate<[T]> { array in
            var count = 0
            for element in array {
                if self.predicate.evaluate(element) {
                    count += 1
                    if count >= n { return true }
                }
            }
            return false
        }
    }

    @inlinable
    public func atMost(_ n: Int) -> Predicate<[T]> {
        Predicate<[T]> { array in
            var count = 0
            for element in array {
                if self.predicate.evaluate(element) {
                    count += 1
                    if count > n { return false }
                }
            }
            return true
        }
    }

    @inlinable
    public func exactly(_ n: Int) -> Predicate<[T]> {
        Predicate<[T]> { array in
            var count = 0
            for element in array {
                if self.predicate.evaluate(element) {
                    count += 1
                    if count > n { return false }
                }
            }
            return count == n
        }
    }

    @inlinable
    public var zero: Predicate<[T]> { exactly(0) }

    @inlinable
    public var one: Predicate<[T]> { exactly(1) }
}
