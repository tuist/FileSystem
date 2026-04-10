// Predicate+(T) -> Bool.swift
// Convenience operators for raw (T) -> Bool closures.

// MARK: - (T) -> Bool Operators

/// Combines two closures using logical AND.
///
/// - Returns: A Predicate that evaluates both closures.
@inlinable
public func && <T>(
    lhs: @escaping (T) -> Bool,
    rhs: @escaping (T) -> Bool
) -> Predicate<T> {
    Predicate(lhs).and(Predicate(rhs))
}

/// Combines two closures using logical OR.
///
/// - Returns: A Predicate that evaluates both closures.
@inlinable
public func || <T>(
    lhs: @escaping (T) -> Bool,
    rhs: @escaping (T) -> Bool
) -> Predicate<T> {
    Predicate(lhs).or(Predicate(rhs))
}

/// Combines two closures using logical XOR.
///
/// - Returns: A Predicate that evaluates both closures.
@inlinable
public func ^ <T>(
    lhs: @escaping (T) -> Bool,
    rhs: @escaping (T) -> Bool
) -> Predicate<T> {
    Predicate(lhs).xor(Predicate(rhs))
}

/// Negates a closure.
///
/// - Returns: A Predicate that negates the closure's result.
@inlinable
public prefix func ! <T>(
    closure: @escaping (T) -> Bool
) -> Predicate<T> {
    Predicate(closure).negated
}

// MARK: - Mixed Operators (Predicate with (T) -> Bool)

extension Predicate {
    /// Combines this predicate with a closure using logical AND.
    @inlinable
    public static func && (lhs: Predicate, rhs: @escaping (T) -> Bool) -> Predicate {
        lhs.and(Predicate(rhs))
    }

    /// Combines a closure with this predicate using logical AND.
    @inlinable
    public static func && (lhs: @escaping (T) -> Bool, rhs: Predicate) -> Predicate {
        Predicate(lhs).and(rhs)
    }

    /// Combines this predicate with a closure using logical OR.
    @inlinable
    public static func || (lhs: Predicate, rhs: @escaping (T) -> Bool) -> Predicate {
        lhs.or(Predicate(rhs))
    }

    /// Combines a closure with this predicate using logical OR.
    @inlinable
    public static func || (lhs: @escaping (T) -> Bool, rhs: Predicate) -> Predicate {
        Predicate(lhs).or(rhs)
    }

    /// Combines this predicate with a closure using logical XOR.
    @inlinable
    public static func ^ (lhs: Predicate, rhs: @escaping (T) -> Bool) -> Predicate {
        lhs.xor(Predicate(rhs))
    }

    /// Combines a closure with this predicate using logical XOR.
    @inlinable
    public static func ^ (lhs: @escaping (T) -> Bool, rhs: Predicate) -> Predicate {
        Predicate(lhs).xor(rhs)
    }
}

// MARK: - Fluent Methods with (T) -> Bools

extension Predicate {
    /// Combines this predicate with a closure using logical AND.
    @inlinable
    public func and(_ closure: @escaping (T) -> Bool) -> Predicate {
        and(Predicate(closure))
    }

    /// Combines this predicate with a closure using logical OR.
    @inlinable
    public func or(_ closure: @escaping (T) -> Bool) -> Predicate {
        or(Predicate(closure))
    }

    /// Combines this predicate with a closure using logical XOR.
    @inlinable
    public func xor(_ closure: @escaping (T) -> Bool) -> Predicate {
        xor(Predicate(closure))
    }

    /// Combines this predicate with a closure using logical NAND.
    @inlinable
    public func nand(_ closure: @escaping (T) -> Bool) -> Predicate {
        nand(Predicate(closure))
    }

    /// Combines this predicate with a closure using logical NOR.
    @inlinable
    public func nor(_ closure: @escaping (T) -> Bool) -> Predicate {
        nor(Predicate(closure))
    }

    /// Creates implication with a closure.
    @inlinable
    public func implies(_ closure: @escaping (T) -> Bool) -> Predicate {
        implies(Predicate(closure))
    }

    /// Creates biconditional with a closure.
    @inlinable
    public func iff(_ closure: @escaping (T) -> Bool) -> Predicate {
        iff(Predicate(closure))
    }

    /// Creates reverse implication with a closure.
    @inlinable
    public func unless(_ closure: @escaping (T) -> Bool) -> Predicate {
        unless(Predicate(closure))
    }
}
