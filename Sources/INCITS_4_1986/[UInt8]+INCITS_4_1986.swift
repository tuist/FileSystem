// [UInt8]+INCITS_4_1986.swift
// swift-incits-4-1986
//
// Convenient namespaced access to INCITS 4-1986 (US-ASCII) constants

import Standards

// MARK: - [UInt8] ASCII Namespace

extension [UInt8] {
    /// Access to ASCII type-level constants and methods
    ///
    /// Provides static access to ASCII byte array constants and static utility methods.
    /// Use this to create byte arrays from ASCII strings or access common byte sequences.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let bytes = [UInt8](ascii: "Hello")   // [72, 101, 108, 108, 111]
    /// let crlf = [UInt8].ascii.crlf         // [0x0D, 0x0A]
    /// let lf = [UInt8](ascii: .lf)          // [0x0A]
    /// ```
    ///
    /// ## See Also
    ///
    /// - ``ASCII``
    /// - ``INCITS_4_1986``
    public static var ascii: ASCII.Type {
        ASCII.self
    }

    /// Access to ASCII instance methods for this byte array
    ///
    /// Provides instance-level access to ASCII validation and transformation methods.
    /// Returns a generic `INCITS_4_1986.ASCII` wrapper that works with the array directly.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let bytes: [UInt8] = [72, 101, 108, 108, 111]
    /// bytes.ascii.isAllASCII  // true
    ///
    /// let upper = bytes.ascii.uppercased()  // [72, 69, 76, 76, 79]
    /// ```
    ///
    /// ## See Also
    ///
    /// - ``INCITS_4_1986/ASCII``
    /// - ``INCITS_4_1986``
    @inlinable
    public var ascii: INCITS_4_1986.ASCII<Self> {
        INCITS_4_1986.ASCII(self)
    }

    /// ASCII static operations namespace for byte arrays
    ///
    /// Provides static ASCII-related operations for creating and working with byte arrays
    /// per INCITS 4-1986 (US-ASCII standard).
    ///
    /// ## Overview
    ///
    /// The `ASCII` enum serves as a namespace for static ASCII-related operations, providing:
    /// - **Common sequences**: Access standard byte sequences like CRLF and whitespace
    /// - **Creation**: Convert strings to ASCII byte arrays with validation
    ///
    /// For instance methods (validation, case conversion), see `INCITS_4_1986.ASCII<C>`.
    ///
    /// ## See Also
    ///
    /// - ``INCITS_4_1986/ASCII``
    /// - ``INCITS_4_1986``
    public enum ASCII {}
}

// MARK: - [UInt8] Initializers

extension [UInt8] {
    /// Creates ASCII byte array from a string with validation
    ///
    /// Converts a Swift `String` to an array of ASCII bytes, returning `nil` if any character
    /// is outside the ASCII range (U+0000 to U+007F). This method validates that all characters
    /// fit within the 7-bit US-ASCII encoding before conversion.
    ///
    /// ## Validation
    ///
    /// The method validates that all characters in the string are valid ASCII (0x00-0x7F).
    /// If any character requires more than 7 bits to encode, the method returns `nil`:
    /// - Accented letters → `nil`
    /// - Emoji → `nil`
    /// - Extended Unicode → `nil`
    ///
    /// ## Performance
    ///
    /// This method performs O(n) validation by checking each character before conversion.
    /// For known-ASCII strings, use ``ascii(unchecked:)`` to skip validation.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// // Valid ASCII strings
    /// [UInt8](ascii: "hello")       // [104, 101, 108, 108, 111]
    /// [UInt8](ascii: "Hello World") // [72, 101, 108, 108, 111, 32, 87, 111, 114, 108, 100]
    /// [UInt8](ascii: "123")         // [49, 50, 51]
    ///
    /// // Non-ASCII strings
    /// [UInt8](ascii: "hello🌍")     // nil (contains emoji)
    /// [UInt8](ascii: "café")        // nil (contains é)
    /// ```
    ///
    /// - Parameter ascii: The string to convert to ASCII bytes
    /// - Returns: Array of ASCII bytes if all characters are valid ASCII, `nil` otherwise
    ///
    /// ## See Also
    ///
    /// - ``ascii(unchecked:)``
    /// - ``String/init(ascii:)``
    public init?(ascii s: some StringProtocol) {
        guard s.allSatisfy({ $0.isASCII }) else { return nil }
        self = Array(s.utf8)
    }

    /// Creates byte array from a line ending constant
    ///
    /// Transforms a line ending enumeration value into its corresponding
    /// byte sequence. This is useful when you need line ending bytes for network protocols
    /// or file formatting.
    ///
    /// ## Line Ending Byte Sequences
    ///
    /// - **`.lf`**: Returns `[0x0A]` (Line Feed) - Unix/Linux/macOS
    /// - **`.cr`**: Returns `[0x0D]` (Carriage Return) - Classic Mac OS
    /// - **`.crlf`**: Returns `[0x0D, 0x0A]` (CR + LF) - Windows, Internet protocols
    ///
    /// ## Usage
    ///
    /// ```swift
    /// // Get line ending byte sequences
    /// let unix = [UInt8](ascii: .lf)      // [0x0A]
    /// let mac = [UInt8](ascii: .cr)       // [0x0D]
    /// let windows = [UInt8](ascii: .crlf) // [0x0D, 0x0A]
    ///
    /// // Build byte arrays with line endings
    /// var bytes: [UInt8] = [UInt8](ascii: "Line 1")!
    /// bytes += [UInt8](ascii: .crlf)
    /// bytes += [UInt8](ascii: "Line 2")!
    /// ```
    ///
    /// - Parameter ascii: The line ending style to convert to bytes
    /// - Returns: Byte array containing the line ending sequence
    ///
    /// ## See Also
    ///
    /// - ``String/LineEnding``
    /// - ``INCITS_4_1986/crlf``
    /// - ``ASCII/crlf``
    public init(ascii lineEnding: INCITS_4_1986.FormatEffectors.LineEnding) {
        switch lineEnding {
        case .lf: self = [UInt8.ascii.lf]
        case .cr: self = [UInt8.ascii.cr]
        case .crlf: self = [UInt8].ascii.crlf
        }
    }
}

// MARK: - [UInt8].ASCII Static Methods

extension [UInt8].ASCII {
    /// Creates ASCII byte array from a string without validation
    ///
    /// Converts a Swift `String` to an array of bytes, assuming all characters are valid ASCII
    /// without validation. This method provides optimal performance when the caller can guarantee
    /// ASCII validity.
    ///
    /// ## Safety
    ///
    /// **Important**: This method does not validate the input. If the string contains non-ASCII
    /// characters, the resulting byte array will contain multi-byte UTF-8 sequences, which is
    /// likely not what you want.
    ///
    /// ## Performance
    ///
    /// This method skips the O(n) ASCII validation check, making it more efficient than ``ascii(_:)``
    /// when you know all characters are ASCII.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// // When you know the string is ASCII
    /// [UInt8].ascii.unchecked("hello")  // [104, 101, 108, 108, 111]
    /// [UInt8].ascii.unchecked("World")  // [87, 111, 114, 108, 100]
    ///
    /// // Using with string literals (known ASCII)
    /// let greeting = [UInt8].ascii.unchecked("Hi there!")
    /// ```
    ///
    /// - Parameter string: The string to convert to bytes (assumed ASCII, no validation)
    /// - Returns: Array of bytes representing the string's UTF-8 encoding
    ///
    /// ## See Also
    ///
    /// - ``ascii(_:)``
    /// - ``String/ascii(unchecked:)``
    public static func unchecked(_ s: some StringProtocol) -> [UInt8] {
        Array(s.utf8)
    }

    /// CRLF line ending (0x0D 0x0A)
    ///
    /// The canonical two-byte sequence for line endings in Internet protocols.
    /// Consists of CARRIAGE RETURN (0x0D) followed by LINE FEED (0x0A).
    ///
    /// ## Protocol Requirements
    ///
    /// CRLF is **required** by many Internet protocols per their RFCs:
    /// - HTTP (RFC 9112)
    /// - SMTP (RFC 5321)
    /// - FTP (RFC 959)
    /// - MIME (RFC 2045)
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let crlf = [UInt8].ascii.crlf  // [0x0D, 0x0A]
    ///
    /// // Build HTTP response
    /// var response: [UInt8] = [UInt8](ascii: "HTTP/1.1 200 OK")!
    /// response += [UInt8].ascii.crlf
    /// response += [UInt8](ascii: "Content-Type: text/plain")!
    /// response += [UInt8].ascii.crlf
    /// ```
    ///
    /// ## See Also
    ///
    /// - ``INCITS_4_1986/crlf``
    /// - ``ascii(lineEnding:)``
    public static var crlf: [UInt8] {
        INCITS_4_1986.ControlCharacters.crlf
    }

    /// ASCII whitespace bytes
    ///
    /// Set containing the four ASCII whitespace characters defined in INCITS 4-1986:
    /// - **0x20** (SPACE): Word separator
    /// - **0x09** (HORIZONTAL TAB): Tabulation
    /// - **0x0A** (LINE FEED): End of line (Unix/macOS)
    /// - **0x0D** (CARRIAGE RETURN): End of line (classic Mac, Internet protocols)
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let ws = [UInt8].ascii.whitespaces
    ///
    /// // Check if byte is whitespace
    /// if ws.contains(0x20) {
    ///     print("Is whitespace")  // Executes
    /// }
    ///
    /// // Filter whitespace from byte array
    /// let bytes: [UInt8] = [72, 101, 32, 108, 108, 111]  // "He llo"
    /// let filtered = bytes.filter { !ws.contains($0) }   // [72, 101, 108, 108, 111]
    /// ```
    ///
    /// ## See Also
    ///
    /// - ``INCITS_4_1986/whitespaces``
    /// - ``UInt8/ASCII/isWhitespace``
    public static var whitespaces: Set<UInt8> {
        INCITS_4_1986.whitespaces
    }
}
