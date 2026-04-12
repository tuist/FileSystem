// Format.BinaryInteger.swift
// Formatting for BinaryInteger types.

extension Format {
    /// A format for formatting BinaryInteger values.
    ///
    /// This categorical format works for all BinaryInteger types (Int, UInt, Int8, etc.).
    /// Provides decimal, binary, and octal representations.
    ///
    /// For hexadecimal formatting, use RFC 4648:
    /// ```swift
    /// import RFC_4648
    /// String(hex: 255)  // "0xff"
    /// ```
    ///
    /// Use static properties to access predefined formats:
    ///
    /// ```swift
    /// 42.formatted(.binary)  // "0b101010"
    /// 63.formatted(.octal)   // "0o77"
    /// 42.formatted(.decimal) // "42"
    /// ```
    ///
    /// Chain methods to configure the format:
    ///
    /// ```swift
    /// 42.formatted(.binary.sign(strategy: .always))  // "+0b101010"
    /// 5.formatted(.decimal.zeroPadded(width: 3))     // "005"
    /// ```
    public struct BinaryInteger: Sendable {
        let radix: Int
        let prefix: String
        public let signStrategy: SignDisplayStrategy
        public let minWidth: Int?

        private init(
            radix: Int,
            prefix: String,
            signStrategy: SignDisplayStrategy,
            minWidth: Int? = nil
        ) {
            self.radix = radix
            self.prefix = prefix
            self.signStrategy = signStrategy
            self.minWidth = minWidth
        }

        public init(signStrategy: SignDisplayStrategy = .automatic, minWidth: Int? = nil) {
            self.radix = 10
            self.prefix = ""
            self.signStrategy = signStrategy
            self.minWidth = minWidth
        }
    }
}

// MARK: - Format.BinaryInteger.SignDisplayStrategy

extension Format.BinaryInteger {
    public struct SignDisplayStrategy: Sendable {
        private let _shouldAlwaysShowSign: @Sendable () -> Bool

        private init(shouldAlwaysShowSign: @escaping @Sendable () -> Bool) {
            self._shouldAlwaysShowSign = shouldAlwaysShowSign
        }

        fileprivate var shouldAlwaysShowSign: Bool {
            _shouldAlwaysShowSign()
        }
    }
}

// MARK: - Format.BinaryInteger.SignDisplayStrategy Static Properties

extension Format.BinaryInteger.SignDisplayStrategy {
    /// Shows sign only for negative numbers.
    public static var automatic: Self {
        .init { false }
    }

    /// Always shows sign for positive and negative numbers.
    public static var always: Self {
        .init { true }
    }
}

// MARK: - Format.BinaryInteger Format Method

extension Format.BinaryInteger {
    /// Formats a binary integer value.
    ///
    /// This is a generic method that works across all BinaryInteger types.
    public func format<T: Swift.BinaryInteger>(_ value: T) -> String {
        let absValue = value.magnitude
        var digits = String(absValue, radix: radix)

        // Apply zero-padding if minWidth is specified
        if let minWidth = minWidth {
            let padding = max(0, minWidth - digits.count)
            digits = String(repeating: "0", count: padding) + digits
        }

        var result = prefix + digits

        // Handle sign
        if value < 0 {
            result = "-" + result
        } else if signStrategy.shouldAlwaysShowSign {
            result = "+" + result
        }

        return result
    }
}

// MARK: - Format.BinaryInteger Static Properties

extension Format.BinaryInteger {
    /// Formats the binary integer as a number (decimal, base 10).
    ///
    /// This is the default numeric format, equivalent to `.decimal`.
    ///
    /// ```swift
    /// 42.formatted(.number)  // "42"
    /// ```
    public static var number: Self {
        .decimal
    }

    /// Formats the binary integer as decimal (base 10).
    public static var decimal: Self {
        .init(radix: 10, prefix: "", signStrategy: .automatic, minWidth: nil)
    }

    /// Formats the binary integer as binary (base 2).
    /// Binary is not defined by any RFC - this is a general-purpose formatter.
    public static var binary: Self {
        .init(radix: 2, prefix: "0b", signStrategy: .automatic, minWidth: nil)
    }

    /// Formats the binary integer as octal (base 8).
    /// Octal is not defined by any RFC - this is a general-purpose formatter.
    public static var octal: Self {
        .init(radix: 8, prefix: "0o", signStrategy: .automatic, minWidth: nil)
    }
}

// MARK: - Format.BinaryInteger Chaining Methods

extension Format.BinaryInteger {
    /// Configures the sign display strategy.
    ///
    /// ```swift
    /// 42.formatted(Format.BinaryInteger.decimal.sign(strategy: .always))  // "+42"
    /// (-42).formatted(Format.BinaryInteger.decimal.sign(strategy: .always))  // "-42"
    /// ```
    public func sign(strategy: SignDisplayStrategy) -> Self {
        .init(radix: radix, prefix: prefix, signStrategy: strategy, minWidth: minWidth)
    }

    /// Pads the number with leading zeros to reach the specified width.
    ///
    /// ```swift
    /// 5.formatted(.decimal.zeroPadded(width: 2))   // "05"
    /// 42.formatted(.decimal.zeroPadded(width: 4))  // "0042"
    /// ```
    public func zeroPadded(width: Int) -> Self {
        .init(radix: radix, prefix: prefix, signStrategy: signStrategy, minWidth: width)
    }
}

// MARK: - BinaryInteger Extension

extension Swift.BinaryInteger {
    /// Formats this binary integer using the specified format.
    ///
    /// Use this method with static format properties:
    ///
    /// ```swift
    /// let result = 42.formatted(.binary)           // "0b101010"
    /// let result = 63.formatted(.octal)            // "0o77"
    /// let result = 42.formatted(.decimal)          // "42"
    /// ```
    ///
    /// For hexadecimal, use RFC 4648:
    /// ```swift
    /// import RFC_4648
    /// let result = String(hex: 255)  // "0xff"
    /// ```
    ///
    /// - Parameter format: The binary integer format to use.
    /// - Returns: The formatted representation of this binary integer.
    public func formatted(_ format: Format.BinaryInteger) -> String {
        format.format(self)
    }
}
