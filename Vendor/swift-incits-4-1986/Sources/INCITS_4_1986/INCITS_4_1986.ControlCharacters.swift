// INCITS_4_1986.ControlCharacters.swift
// swift-incits-4-1986
//
// Section 4.1: Control Characters (INCITS 4-1986)

extension INCITS_4_1986 {
    /// Section 4.1: Control Characters (0x00-0x1F, 0x7F)
    ///
    /// Namespace for the 33 non-printing control characters defined in US-ASCII.
    ///
    /// ## Overview
    ///
    /// Control characters are non-printing characters used for device control, data transmission,
    /// and text formatting. US-ASCII defines 33 control characters: 32 in the range 0x00-0x1F,
    /// plus DELETE (0x7F).
    ///
    /// These characters historically controlled teletypes, printers, and other communication devices.
    /// While many are obsolete, several remain essential for modern text processing (LF, CR, TAB)
    /// and data transmission (ESC for ANSI escape sequences).
    ///
    /// ## Categories
    ///
    /// Per INCITS 4-1986 Section 4.1, control characters are classified into six categories:
    ///
    /// **Transmission Control Characters** - Manage data transmission protocols:
    /// - SOH, STX, ETX, EOT (frame boundaries)
    /// - ENQ (request), ACK (acknowledge), NAK (negative acknowledge)
    /// - DLE (data link escape), SYN (synchronization)
    /// - ETB (end of transmission block)
    ///
    /// **Format Effectors** - Control physical positioning:
    /// - BS (backspace), HT (horizontal tab), LF (line feed)
    /// - VT (vertical tab), FF (form feed), CR (carriage return)
    ///
    /// **Code Extension** - Switch between character sets:
    /// - SO (shift out), SI (shift in)
    /// - ESC (escape to alternate interpretation)
    ///
    /// **Device Control** - Hardware device commands:
    /// - DC1 (XON - resume transmission)
    /// - DC2, DC3 (XOFF - pause transmission), DC4
    ///
    /// **Information Separators** - Hierarchical data delimiters:
    /// - FS (file separator), GS (group separator)
    /// - RS (record separator), US (unit separator)
    ///
    /// **Other Control Characters**:
    /// - NUL (null), BEL (alert), CAN (cancel)
    /// - EM (end of medium), SUB (substitute), DEL (delete)
    ///
    /// ## Usage
    ///
    /// ```swift
    /// // Common line endings
    /// let lineFeed = INCITS_4_1986.ControlCharacters.lf      // Unix/macOS
    /// let carriageReturn = INCITS_4_1986.ControlCharacters.cr // Classic Mac
    ///
    /// // Formatting
    /// let tab = INCITS_4_1986.ControlCharacters.htab
    ///
    /// // Transmission control
    /// let escape = INCITS_4_1986.ControlCharacters.esc  // ANSI escape sequences
    ///
    /// // Check if byte is a control character
    /// let byte: UInt8 = 0x0A
    /// let isControl = (byte <= 0x1F) || (byte == 0x7F)  // true for LF
    /// ```
    ///
    /// ## See Also
    ///
    /// - ``INCITS_4_1986/whitespaces``
    /// - ``INCITS_4_1986/crlf``
    public enum ControlCharacters {}
}

extension INCITS_4_1986.ControlCharacters {
    /// NULL character (0x00)
    public static let nul: UInt8 = 0x00
}

extension INCITS_4_1986.ControlCharacters {
    /// START OF HEADING (0x01)
    public static let soh: UInt8 = 0x01

    /// START OF TEXT (0x02)
    public static let stx: UInt8 = 0x02

    /// END OF TEXT (0x03)
    public static let etx: UInt8 = 0x03

    /// END OF TRANSMISSION (0x04)
    public static let eot: UInt8 = 0x04

    /// ENQUIRY (0x05)
    public static let enq: UInt8 = 0x05

    /// ACKNOWLEDGE (0x06)
    public static let ack: UInt8 = 0x06

    /// DATA LINK ESCAPE (0x10)
    public static let dle: UInt8 = 0x10

    /// NEGATIVE ACKNOWLEDGE (0x15)
    public static let nak: UInt8 = 0x15

    /// SYNCHRONOUS IDLE (0x16)
    public static let syn: UInt8 = 0x16

    /// END OF TRANSMISSION BLOCK (0x17)
    public static let etb: UInt8 = 0x17
}

extension INCITS_4_1986.ControlCharacters {
    /// BACKSPACE (0x08)
    public static let bs: UInt8 = 0x08

    /// HORIZONTAL TAB (0x09)
    public static let htab: UInt8 = 0x09

    /// LINE FEED (0x0A)
    public static let lf: UInt8 = 0x0A

    /// VERTICAL TAB (0x0B)
    public static let vtab: UInt8 = 0x0B

    /// FORM FEED (0x0C)
    public static let ff: UInt8 = 0x0C

    /// CARRIAGE RETURN (0x0D)
    public static let cr: UInt8 = 0x0D
}

extension INCITS_4_1986.ControlCharacters {
    /// SHIFT OUT (0x0E)
    public static let so: UInt8 = 0x0E

    /// SHIFT IN (0x0F)
    public static let si: UInt8 = 0x0F

    /// ESCAPE (0x1B)
    public static let esc: UInt8 = 0x1B
}

extension INCITS_4_1986.ControlCharacters {
    /// DEVICE CONTROL ONE (0x11) - XON in flow control
    public static let dc1: UInt8 = 0x11

    /// DEVICE CONTROL TWO (0x12)
    public static let dc2: UInt8 = 0x12

    /// DEVICE CONTROL THREE (0x13) - XOFF in flow control
    public static let dc3: UInt8 = 0x13

    /// DEVICE CONTROL FOUR (0x14)
    public static let dc4: UInt8 = 0x14
}

extension INCITS_4_1986.ControlCharacters {
    /// FILE SEPARATOR (0x1C)
    public static let fs: UInt8 = 0x1C

    /// GROUP SEPARATOR (0x1D)
    public static let gs: UInt8 = 0x1D

    /// RECORD SEPARATOR (0x1E)
    public static let rs: UInt8 = 0x1E

    /// UNIT SEPARATOR (0x1F)
    public static let us: UInt8 = 0x1F
}

extension INCITS_4_1986.ControlCharacters {
    /// BELL (0x07)
    public static let bel: UInt8 = 0x07

    /// CANCEL (0x18)
    public static let can: UInt8 = 0x18

    /// END OF MEDIUM (0x19)
    public static let em: UInt8 = 0x19

    /// SUBSTITUTE (0x1A)
    public static let sub: UInt8 = 0x1A

    /// DELETE (0x7F)
    public static let del: UInt8 = 0x7F
}

extension INCITS_4_1986.ControlCharacters {
    /// CRLF line ending (0x0D 0x0A)
    ///
    /// The canonical line ending sequence consisting of CARRIAGE RETURN (0x0D) followed by LINE FEED (0x0A).
    ///
    /// ## Protocol Requirements
    ///
    /// CRLF is the **required** line ending for many Internet protocols per their RFCs:
    /// - HTTP (RFC 9112)
    /// - SMTP (RFC 5321)
    /// - FTP (RFC 959)
    /// - MIME (RFC 2045)
    /// - Telnet (RFC 854)
    ///
    /// This requirement stems from the need for consistent, cross-platform text representation
    /// in network communications, regardless of the originating platform's native line ending.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// // Normalize text to CRLF for network transmission
    /// let text = "Line 1\nLine 2\nLine 3"
    /// let normalized = text.normalized(to: .crlf)
    ///
    /// // Access the CRLF bytes directly
    /// let lineEnding = INCITS_4_1986.ControlCharacters.crlf  // [0x0D, 0x0A]
    ///
    /// // Append CRLF to byte array
    /// var bytes: [UInt8] = [0x48, 0x69]  // "Hi"
    /// bytes += INCITS_4_1986.ControlCharacters.crlf
    /// ```
    ///
    /// ## See Also
    ///
    /// - ``ControlCharacters/cr``
    /// - ``ControlCharacters/lf``
    /// - ``String/LineEnding``
    public static let crlf: [UInt8] = [
        INCITS_4_1986.ControlCharacters.cr,
        INCITS_4_1986.ControlCharacters.lf,
    ]
}
