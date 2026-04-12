// INCITS_4_1986.swift
// swift-incits-4-1986
//
// INCITS 4-1986 (R2022): Coded Character Sets - 7-Bit American Standard Code for Information Interchange
//
// This namespace contains the authoritative implementations of the INCITS 4-1986 standard.
// Structure follows the specification's table of contents.

/// INCITS 4-1986: US-ASCII Standard
///
/// Authoritative namespace for all US-ASCII definitions and operations.
///
/// ## Overview
///
/// This type serves as the canonical implementation of the INCITS 4-1986 (R2022) standard,
/// also known as US-ASCII (United States - American Standard Code for Information Interchange).
/// All ASCII-related operations and constants throughout this library reference the definitions
/// contained within this namespace, ensuring consistency and standards compliance.
///
/// ## Character Set Structure
///
/// US-ASCII defines a 7-bit character encoding (0x00-0x7F, decimal 0-127) consisting of:
/// - **Control Characters** (0x00-0x1F, 0x7F): 33 non-printing characters for device control and formatting
/// - **Graphic Characters** (0x20-0x7E): 95 printable characters including letters, digits, and symbols
/// - **SPACE** (0x20): Special character with dual interpretation as both graphic and control
///
/// ## Nested Namespaces
///
/// The standard's structure is reflected in nested type namespaces:
/// - ``ControlCharacters``: All 33 control characters (NUL, SOH, STX, ..., DEL)
/// - ``GraphicCharacters``: 94 printable characters (letters, digits, punctuation)
/// - ``SPACE``: The space character (0x20) with its dual nature
///
/// ## Usage
///
/// Access standard definitions directly through the namespace:
///
/// ```swift
/// // Access control characters
/// let lineFeed = INCITS_4_1986.ControlCharacters.lf
/// let carriageReturn = INCITS_4_1986.ControlCharacters.cr
///
/// // Access graphic characters
/// let letterA = INCITS_4_1986.GraphicCharacters.A
/// let digit0 = INCITS_4_1986.GraphicCharacters.zero
///
/// // Use common constants
/// let whitespace = INCITS_4_1986.whitespaces
/// let lineEnding = INCITS_4_1986.ControlCharacters.crlf
/// ```
///
/// ## Conformance
///
/// This implementation strictly conforms to INCITS 4-1986 (Reaffirmed 2022), which supersedes:
/// - ANSI X3.4-1986
/// - ANSI X3.4-1968
/// - ASA X3.4-1963
///
/// The implementation is registered with IANA as the "US-ASCII" character set.
///
/// ## See Also
///
/// - ``ControlCharacters``
/// - ``GraphicCharacters``
/// - ``SPACE``
/// - ``whitespaces``
/// - ``CaseConversion.offset``
/// - ``crlf``
public enum INCITS_4_1986 {}

extension INCITS_4_1986 {
    /// Canonical definition of ASCII whitespace bytes
    ///
    /// Single source of truth for ASCII whitespace per INCITS 4-1986.
    /// Contains exactly four characters:
    /// - 0x20 (SPACE) - Word separator
    /// - 0x09 (HORIZONTAL TAB) - Tabulation
    /// - 0x0A (LINE FEED) - End of line (Unix/macOS)
    /// - 0x0D (CARRIAGE RETURN) - End of line (Internet standards, classic Mac)
    ///
    /// ## Rationale
    ///
    /// These are the only four whitespace characters defined in the 7-bit US-ASCII standard.
    /// This differs from Unicode, which defines additional whitespace characters (e.g., non-breaking space,
    /// various width spaces) that are outside the ASCII range.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let text = "  Hello World  "
    /// let trimmed = text.trimming(.ascii.whitespaces)  // "Hello World"
    ///
    /// let byte: UInt8 = 0x20
    /// if INCITS_4_1986.whitespaces.contains(byte) {
    ///     print("Is whitespace")
    /// }
    /// ```
    ///
    /// ## See Also
    ///
    /// - ``SPACE``
    /// - ``ControlCharacters/htab``
    /// - ``ControlCharacters/lf``
    /// - ``ControlCharacters/cr``
    public static let whitespaces: Set<UInt8> = [
        SPACE.sp,
        ControlCharacters.htab,
        ControlCharacters.lf,
        ControlCharacters.cr,
    ]
}
