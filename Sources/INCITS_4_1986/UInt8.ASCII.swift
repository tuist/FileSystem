//
//  File.swift
//  swift-incits-4-1986
//
//  Created by Coen ten Thije Boonkkamp on 28/11/2025.
//

public import Binary
import Standards

// MARK: - ASCII Namespace Access

extension UInt8 {
    // MARK: - Namespace Access

    /// Access to ASCII type-level constants and methods
    ///
    /// Provides static access to all ASCII character constants and static utility methods.
    /// Use this to access ASCII byte values without needing to specify the full namespace.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let letterA = UInt8.ascii.A        // 0x41
    /// let space = UInt8.ascii.sp         // 0x20
    /// let tab = UInt8.ascii.htab         // 0x09
    /// ```
    ///
    /// ## See Also
    ///
    /// - ``ASCII``
    /// - ``INCITS_4_1986``
    public static var ascii: Binary.ASCII.Type {
        Binary.ASCII.self
    }

    /// Access to ASCII instance methods for this byte
    ///
    /// Provides instance-level access to ASCII character classification and manipulation methods.
    /// Use this to query properties of a byte or perform ASCII-specific operations.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let byte: UInt8 = 0x41
    /// byte.ascii.isLetter      // true
    /// byte.ascii.isUppercase   // true
    /// byte.ascii(case: .lower) // 0x61 ('a')
    ///
    /// UInt8.ascii.sp.ascii.isWhitespace  // true
    /// ```
    ///
    /// ## See Also
    ///
    /// - ``ASCII``
    /// - ``INCITS_4_1986``
    public var ascii: Binary.ASCII {
        Binary.ASCII(byte: self)
    }
}

extension Binary {

    /// ASCII operations namespace for UInt8
    ///
    /// Provides all ASCII character classification, manipulation, and constant access methods
    /// for byte-level operations per INCITS 4-1986 (US-ASCII standard).
    ///
    /// ## Overview
    ///
    /// The `ASCII` struct serves as a namespace for ASCII-related operations on bytes, providing:
    /// - **Character classification**: Test if bytes are whitespace, digits, letters, etc.
    /// - **Numeric parsing**: Convert ASCII digits to numeric values
    /// - **Case conversion**: Transform ASCII letters between upper and lower case
    /// - **Direct constant access**: All 128 ASCII character constants (0x00-0x7F)
    ///
    /// ## Performance
    ///
    /// Methods are marked `@_transparent` or `@inlinable` for optimal performance.
    /// Character classification uses direct byte comparisons rather than Set lookups.
    ///
    /// ## Access Patterns
    ///
    /// Access methods in two ways:
    /// - **Static**: `UInt8.ascii.A` - For constants and static methods
    /// - **Instance**: `byte.ascii.isLetter` - For instance classification
    ///
    /// ## See Also
    ///
    /// - ``INCITS_4_1986``
    /// - ``INCITS_4_1986/ControlCharacters``
    /// - ``INCITS_4_1986/GraphicCharacters``
    public struct ASCII {
        /// The wrapped byte value
        public let byte: UInt8
    }
}
