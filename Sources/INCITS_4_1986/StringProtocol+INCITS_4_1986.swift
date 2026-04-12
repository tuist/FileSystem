//
//  StringProtocol+INCITS_4_1986.swift
//  swift-incits-4-1986
//
//  Created by Coen ten Thije Boonkkamp on 22/11/2025.
//

public import Binary

extension StringProtocol {
    public typealias ASCII = INCITS_4_1986.ASCII<Self>

    /// Access to ASCII type-level constants and methods
    public static var ascii: ASCII.Type {
        ASCII.self
    }

    /// Access to ASCII instance methods for this string
    ///
    /// Provides instance-level access to ASCII validation and transformation methods.
    /// Returns a generic `INCITS_4_1986.ASCII` wrapper that works directly with the
    /// string without copying.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// "hello".ascii.isAllASCII     // true
    /// "hello".ascii.uppercased()   // "HELLO"
    /// "HELLO🌍".ascii.lowercased() // "hello🌍"
    /// ```
    ///
    /// ## See Also
    ///
    /// - ``INCITS_4_1986/ASCII``
    @inlinable
    public var ascii: ASCII {
        INCITS_4_1986.ASCII(self)
    }
}

extension StringProtocol {
    /// Normalizes ASCII line endings in string to the specified style
    ///
    /// Convenience method that delegates to byte-level `normalized(_:to:)`.
    ///
    /// Example:
    /// ```swift
    /// INCITS_4_1986.normalized("line1\nline2\r\nline3", to: .crlf)
    /// // "line1\r\nline2\r\nline3"
    /// ```
    public static func normalized<S: StringProtocol>(
        _ s: S,
        to lineEnding: INCITS_4_1986.FormatEffectors.LineEnding
    ) -> S {
        return .init(decoding: INCITS_4_1986.normalized([UInt8](s.utf8), to: lineEnding), as: UTF8.self)
    }

    /// Normalizes ASCII line endings to the specified style
    ///
    /// Converts all line endings to a consistent format. Recognizes and normalizes
    /// all common ASCII line ending styles: LF (`\n`), CR (`\r`), and CRLF (`\r\n`).
    ///
    /// ## Usage
    ///
    /// ```swift
    /// // Works with String
    /// "line1\nline2\r\n".normalized(to: .crlf)
    ///
    /// // Works with Substring
    /// "Hello\r\nWorld"[...].normalized(to: .lf)
    /// ```
    ///
    /// - Parameters:
    ///   - lineEnding: Target line ending style (`.lf`, `.cr`, or `.crlf`)
    ///   - encoding: Unicode encoding to use (defaults to UTF-8)
    /// - Returns: New string with all line endings normalized to the specified style
    ///
    /// ## See Also
    ///
    /// - ``INCITS_4_1986/normalized(_:to:as:)``
    public func normalized(
        to lineEnding: INCITS_4_1986.FormatEffectors.LineEnding
    ) -> Self {
        Self.normalized(self, to: lineEnding)
    }
}

extension StringProtocol {
    /// Creates some StringProtocol from a line ending constant
    ///
    /// Transforms a line ending enumeration value into its corresponding
    /// string representation. This is useful when you need the actual line ending characters
    /// as a string rather than as byte arrays.
    ///
    /// ## Line Ending Values
    ///
    /// - **`.lf`**: Returns `"\n"` (Line Feed, 0x0A)
    /// - **`.cr`**: Returns `"\r"` (Carriage Return, 0x0D)
    /// - **`.crlf`**: Returns `"\r\n"` (Carriage Return + Line Feed, 0x0D 0x0A)
    ///
    /// ## Usage
    ///
    /// ```swift
    /// // Get line ending strings
    /// let unix = String(ascii: .lf)      // "\n"
    /// let mac = String(ascii: .cr)       // "\r"
    /// let windows = String(ascii: .crlf) // "\r\n"
    ///
    /// // Use in string concatenation
    /// let line1 = "First line"
    /// let line2 = "Second line"
    /// let text = line1 + String(ascii: .crlf) + line2
    /// // "First line\r\nSecond line"
    ///
    /// // Build multi-line text with consistent endings
    /// let lines = ["Header", "Content", "Footer"]
    /// let document = lines.joined(separator: String(ascii: .crlf))
    /// ```
    ///
    /// - Parameter ascii: The line ending style to convert to some StringProtocol
    /// - Returns: String containing the line ending character(s)
    ///
    /// ## See Also
    ///
    /// - ``LineEnding``
    /// - ``INCITS_4_1986/crlf``
    /// - ``normalized(to:as:)``
    public init(ascii lineEnding: INCITS_4_1986.FormatEffectors.LineEnding) {
        self.init(decoding: [UInt8](ascii: lineEnding), as: UTF8.self)
    }
}

extension StringProtocol {
    /// Creates a string from ASCII bytes with validation
    ///
    /// Constructs a String from a byte array, returning `nil` if any byte is outside the valid
    /// US-ASCII range (0x00-0x7F). This method ensures that only valid 7-bit ASCII data is
    /// converted to a string.
    ///
    /// ## Validation
    ///
    /// The method validates that all bytes fall within the ASCII range before decoding.
    /// Any byte with the high bit set (>= 0x80) will cause validation to fail and return `nil`.
    ///
    /// ## Performance
    ///
    /// This method performs O(n) validation before string construction. For known-valid ASCII data,
    /// use ``String/ascii/unchecked(_:)`` to skip validation and improve performance.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// // Valid ASCII bytes
    /// let hello = String(ascii: [104, 101, 108, 108, 111])  // "hello"
    ///
    /// // Using INCITS constants
    /// let bytes: [UInt8] = [
    ///     INCITS_4_1986.GraphicCharacters.H,
    ///     INCITS_4_1986.GraphicCharacters.i
    /// ]
    /// let text = String(ascii: bytes)  // "Hi"
    ///
    /// // Invalid ASCII bytes
    /// String(ascii: [255])  // nil (0xFF is not valid 7-bit ASCII)
    /// String(ascii: [0x80]) // nil (high bit set)
    /// ```
    ///
    /// - Parameter ascii: Array of bytes to validate and decode as ASCII
    /// - Returns: String if all bytes are valid ASCII (0x00-0x7F), `nil` otherwise
    ///
    /// ## See Also
    ///
    /// - ``String/ascii/unchecked(_:)``
    /// - ``INCITS_4_1986``
    public init?(ascii bytes: [UInt8]) {
        guard bytes.ascii.isAllASCII else { return nil }
        self.init(decoding: bytes, as: UTF8.self)
    }

    /// Creates a single-character string from an ASCII byte with validation
    ///
    /// Returns `nil` if the byte is outside the valid ASCII range (0x00-0x7F).
    ///
    /// ## Usage
    ///
    /// ```swift
    /// String(ascii: 0x41)  // "A"
    /// String(ascii: 0x20)  // " "
    /// String(ascii: 0xFF)  // nil (not ASCII)
    /// ```
    ///
    /// - Parameter byte: The byte to validate and decode as ASCII
    /// - Returns: Single-character string if byte is valid ASCII, `nil` otherwise
    public init?(ascii byte: UInt8) {
        guard byte.ascii.isASCII else { return nil }
        self.init(decoding: CollectionOfOne(byte), as: UTF8.self)
    }
}

extension StringProtocol {
    /// String representation of an ASCII-serializable value
    ///
    /// Composes through canonical byte representation for academic correctness.
    ///
    /// ## Category Theory
    ///
    /// String display composes as:
    /// ```
    /// Serializable → [UInt8] (ASCII) → String (UTF-8 interpretation)
    /// ```
    ///
    /// ## Example
    ///
    /// ```swift
    /// let value: RFC_5322.EmailAddress = ...
    /// let string = String(value)  // Uses this initializer
    /// ```
    ///
    /// - Parameter value: Any type conforming to Binary.ASCII.Serializable
    @_transparent
    public init<T: Binary.ASCII.Serializable>(_ value: T) {
        self = Self(decoding: value.bytes, as: UTF8.self)
    }
}
