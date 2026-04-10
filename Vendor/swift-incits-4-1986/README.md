# INCITS 4-1986

[![CI](https://github.com/swift-standards/swift-incits-4-1986/workflows/CI/badge.svg)](https://github.com/swift-standards/swift-incits-4-1986/actions/workflows/ci.yml)
![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

Swift implementation of INCITS 4-1986 (R2022): Coded Character Sets - 7-Bit American Standard Code for Information Interchange (US-ASCII).

## Overview

This package provides a complete implementation of the US-ASCII character set standard. The implementation follows INCITS 4-1986 (Reaffirmed 2022), offering character classification, case conversion, string validation, and byte-level operations for all 128 ASCII characters (0x00-0x7F).

Pure Swift implementation with no Foundation dependencies, suitable for Swift Embedded and constrained environments.

## Features

- 128 ASCII character constants (0x00-0x7F) organized by standard sections
- Character classification predicates (whitespace, digits, letters, alphanumeric, hex digits)
- ASCII namespace pattern for String, Substring, Character, UInt8, and `[UInt8]` types
- String and Substring character classification (isAllASCII, isAllDigits, isAllLetters, etc.)
- String and Substring case validation (isAllLowercase, isAllUppercase)
- String and Substring line ending detection and constants
- ASCII-only case conversion for strings, substrings, and byte arrays
- String trimming with optimized UTF-8 fast path for ASCII whitespace
- Line ending normalization (LF, CR, CRLF) for cross-platform text processing
- Bidirectional String ⟷ `[UInt8]` conversion with ASCII validation
- Cross-module inlining via `@inlinable` and `@_transparent` for zero-cost abstractions
- 513 tests covering edge cases, performance, and standards compliance

## Installation

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/swift-standards/swift-incits-4-1986.git", from: "0.1.0")
]
```

Then add the dependency to your target:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "INCITS 4 1986", package: "swift-incits-4-1986")
    ]
)
```

## Quick Start

```swift
import INCITS_4_1986

// Character classification
let byte: UInt8 = 0x41  // 'A'
byte.ascii.isLetter      // true
byte.ascii.isUppercase   // true

// Case conversion
"Hello World".ascii(case: .upper)  // "HELLO WORLD"

// String ⟷ bytes conversion
let bytes = [UInt8](ascii: "hello")  // [104, 101, 108, 108, 111]
let text = String(ascii: bytes)      // "hello"

// String trimming
"  Hello  ".trimming(.ascii.whitespaces)  // "Hello"
```

## Usage Examples

### Character Constants

Direct access to all 128 ASCII characters:

```swift
import INCITS_4_1986

// Control characters (0x00-0x1F, 0x7F)
UInt8.ascii.nul    // 0x00 (NULL)
UInt8.ascii.htab   // 0x09 (HORIZONTAL TAB)
UInt8.ascii.lf     // 0x0A (LINE FEED)
UInt8.ascii.cr     // 0x0D (CARRIAGE RETURN)
UInt8.ascii.esc    // 0x1B (ESCAPE)
UInt8.ascii.del    // 0x7F (DELETE)

// SPACE (0x20) - dual nature character
UInt8.ascii.sp     // 0x20 (SPACE)

// Graphic characters (0x21-0x7E)
UInt8.ascii.exclamationPoint  // 0x21 (!)
UInt8.ascii.0    // 0x30 (digit 0)
UInt8.ascii.A    // 0x41 (capital A)
UInt8.ascii.a    // 0x61 (lowercase a)
UInt8.ascii.tilde  // 0x7E (~)

// Common sequences
let crlf = INCITS_4_1986.ControlCharacters.crlf  // [0x0D, 0x0A]
let whitespaces = INCITS_4_1986.whitespaces  // {0x20, 0x09, 0x0A, 0x0D}
```

### Byte-Level Classification

Test character properties at the byte level:

```swift
let byte: UInt8 = 0x41  // 'A'

// Character type classification
byte.ascii.isWhitespace    // false
byte.ascii.isControl       // false
byte.ascii.isPrintable     // true
byte.ascii.isVisible       // true

// Letter and digit classification
byte.ascii.isDigit         // false
byte.ascii.isLetter        // true
byte.ascii.isAlphanumeric  // true
byte.ascii.isHexDigit      // true (A-F are hex)

// Case classification
byte.ascii.isUppercase     // true
byte.ascii.isLowercase     // false

// Whitespace examples
UInt8.ascii.sp.ascii.isWhitespace    // true (SPACE)
UInt8.ascii.htab.ascii.isWhitespace  // true (TAB)
UInt8.ascii.lf.ascii.isWhitespace    // true (LF)
UInt8.ascii.cr.ascii.isWhitespace    // true (CR)
```

### Byte-Level Case Conversion

Convert individual bytes between cases:

```swift
// Uppercase to lowercase
let upper: UInt8 = 0x41  // 'A'
let lower = upper.ascii(case: .lower)  // 0x61 ('a')

// Lowercase to uppercase
let a: UInt8 = 0x61  // 'a'
let A = a.ascii(case: .upper)  // 0x41 ('A')

// Non-letters unchanged
let digit: UInt8 = 0x30  // '0'
digit.ascii(case: .upper)  // 0x30 (unchanged)
```

### Numeric Value Parsing

Extract numeric values from ASCII digit bytes:

```swift
// Decimal digits
let five: UInt8 = 0x35  // '5'
UInt8.ascii(digit: five)  // 5

// Hexadecimal digits
UInt8.ascii(hexDigit: 0x41)  // 10 ('A')
UInt8.ascii(hexDigit: 0x61)  // 10 ('a')
UInt8.ascii(hexDigit: 0x46)  // 15 ('F')
UInt8.ascii(hexDigit: 0x66)  // 15 ('f')
```

### String to Bytes Conversion

Convert strings to ASCII byte arrays with validation:

```swift
// Valid ASCII string
let bytes = [UInt8](ascii: "Hello")
// [72, 101, 108, 108, 111]

// With validation
if let asciiBytes = [UInt8](ascii: "Hello World") {
    // All characters are valid ASCII
}

// Non-ASCII returns nil
[UInt8](ascii: "Hello🌍")  // nil (emoji not ASCII)
[UInt8](ascii: "café")     // nil (é not ASCII)

// Unchecked conversion (no validation)
let bytes = [UInt8].ascii.unchecked("Hello")
// Use only when you know string is ASCII
```

### Bytes to String Conversion

Convert ASCII byte arrays to strings:

```swift
// With validation
let text = String(ascii: [72, 101, 108, 108, 111])  // "Hello"

// Invalid ASCII returns nil
String(ascii: [0xFF])  // nil (not valid 7-bit ASCII)
String(ascii: [0x80])  // nil (high bit set)

// Unchecked conversion (no validation)
let text = String.ascii.unchecked([72, 105])  // "Hi"
// Use only when you know bytes are ASCII
```

### Byte Array Validation

Check if all bytes in an array are valid ASCII:

```swift
let hello: [UInt8] = [72, 101, 108, 108, 111]
hello.ascii.isAllASCII  // true

let mixed: [UInt8] = [72, 101, 0xFF, 108, 111]
mixed.ascii.isAllASCII  // false (0xFF > 0x7F)

let empty: [UInt8] = []
empty.ascii.isAllASCII  // true (empty array is valid)

// Collection predicates (symmetric with StringProtocol)
let digits = [UInt8](ascii: "12345")!
digits.ascii.isAllDigits      // true
digits.ascii.isAllLetters     // false

let letters = [UInt8](ascii: "Hello")!
letters.ascii.isAllLetters    // true
letters.ascii.isAllUppercase  // false (mixed case)
letters.ascii.isAllLowercase  // false (mixed case)

let upperOnly = [UInt8](ascii: "HELLO")!
upperOnly.ascii.isAllUppercase  // true
```

### Byte Array Case Conversion

Convert all ASCII letters in a byte array:

```swift
let hello = [UInt8](ascii: "Hello World")!

// Elegant case conversion
hello.ascii(case: .upper)
// [72, 69, 76, 76, 79, 32, 87, 79, 82, 76, 68] ("HELLO WORLD")

hello.ascii(case: .lower)
// [104, 101, 108, 108, 111, 32, 119, 111, 114, 108, 100] ("hello world")

// Non-letters unchanged
let mixed = [UInt8](ascii: "Test123!")!
mixed.ascii(case: .upper)
// [84, 69, 83, 84, 49, 50, 51, 33] ("TEST123!")

// Validation via callAsFunction
let valid: [UInt8] = [0x48, 0x69]
valid.ascii()  // Optional([0x48, 0x69])

let invalid: [UInt8] = [0x48, 0xFF]
invalid.ascii()  // nil
```

### String Case Conversion

Convert ASCII letters in strings (Unicode-safe):

```swift
// Basic case conversion
"Hello World".ascii(case: .upper)  // "HELLO WORLD"
"Hello World".ascii(case: .lower)  // "hello world"

// Unicode safety - non-ASCII preserved
"hello🌍".ascii(case: .upper)  // "HELLO🌍"
"café".ascii(case: .upper)     // "CAFé" (only ASCII 'c', 'a', 'f' converted)

// Only ASCII letters affected
"Test123!".ascii(case: .upper)  // "TEST123!"

// Convenience methods on .ascii namespace
"hello".ascii.uppercased()  // "HELLO"
"WORLD".ascii.lowercased()  // "world"
```

### String Character Classification

Test string-level character properties:

```swift
let str = "Hello123"

// ASCII validation
str.ascii.isAllASCII          // true
"Hello🌍".ascii.isAllASCII    // false

// Content classification
"123456".ascii.isAllDigits           // true
"abc".ascii.isAllLetters             // true
"abc123".ascii.isAllAlphanumeric     // true
"  \t\n".ascii.isAllWhitespace       // true
"\t\n\r".ascii.isAllControl          // true
"ABC123!".ascii.isAllVisible         // true
"hello world".ascii.isAllPrintable   // true

// Contains checks
"hello".ascii.containsNonASCII       // false
"café".ascii.containsNonASCII        // true
"DEADBEEF".ascii.containsHexDigit    // true
```

### String Case Validation

Validate case of ASCII letters in strings:

```swift
// Case validation (non-letters ignored)
"hello world".ascii.isAllLowercase   // true
"HELLO WORLD".ascii.isAllUppercase   // true
"Hello World".ascii.isAllLowercase   // false

// Numbers and symbols don't affect validation
"hello123!".ascii.isAllLowercase     // true
"HELLO123!".ascii.isAllUppercase     // true
```

### String Line Ending Detection

Detect and analyze line ending styles:

```swift
// Line ending constants
String.ascii.lf     // "\n"
String.ascii.cr     // "\r"
String.ascii.crlf   // "\r\n"

// Detection
"A\nB\rC".ascii.containsMixedLineEndings  // true (has both LF and CR)
"A\r\nB\r\n".ascii.containsMixedLineEndings  // false (only CRLF)

// Detect line ending type
"Hello\nWorld".ascii.detectedLineEnding()     // .lf
"Hello\r\nWorld".ascii.detectedLineEnding()   // .crlf
"Hello\rWorld".ascii.detectedLineEnding()     // .cr
"Hello World".ascii.detectedLineEnding()      // nil (no line endings)
```

### Substring Operations

All INCITS_4_1986.ASCII operations available on Substring:

```swift
let str = "  Hello World  "
let sub = str[...]

// Character classification
sub.ascii.isAllASCII
sub.ascii.isAllLetters
sub.ascii.containsNonASCII

// Case validation and conversion
sub.ascii.isAllLowercase
sub.ascii(case: .upper)
sub.ascii.uppercased()
sub.ascii.lowercased()

// Line ending detection
sub.ascii.containsMixedLineEndings
sub.ascii.detectedLineEnding()

// Trimming
sub.trimming(.ascii.whitespaces)  // "Hello World"
```

### String Trimming

Remove characters from both ends of strings:

```swift
// Trim ASCII whitespace
let text = "  Hello World  "
text.trimming(.ascii.whitespaces)  // "Hello World"

// Static method
String.trimming(text, of: .ascii.whitespaces)  // "Hello World"

// Trim custom characters
let padded = "***important***"
padded.trimming(["*"])  // "important"

let quoted = "\"hello\""
quoted.trimming(["\""])  // "hello"

// Only edges are trimmed
let spaced = "  Hello  World  "
spaced.trimming(.ascii.whitespaces)  // "Hello  World"
```

### Line Ending Normalization

Normalize line endings for cross-platform compatibility:

```swift
// Normalize to CRLF (Windows, Internet protocols)
let text = "line1\nline2\rline3\r\nline4"
text.normalized(to: .crlf)
// "line1\r\nline2\r\nline3\r\nline4"

// Normalize to LF (Unix, Linux, macOS)
let windows = "Hello\r\nWorld\r\n"
windows.normalized(to: .lf)  // "Hello\nWorld\n"

// Normalize to CR (Classic Mac OS)
let unix = "Hello\nWorld\n"
unix.normalized(to: .cr)  // "Hello\rWorld\r"

// Handles mixed line endings
let mixed = "A\nB\rC\r\nD"
mixed.normalized(to: .lf)  // "A\nB\nC\nD"
```

### Line Ending Byte Sequences

Get line ending bytes for network protocols:

```swift
// String line endings
let lf = String(ascii: .lf)      // "\n"
let cr = String(ascii: .cr)      // "\r"
let crlf = String(ascii: .crlf)  // "\r\n"

// Byte array line endings
let lfBytes = [UInt8](ascii: .lf)      // [0x0A]
let crBytes = [UInt8](ascii: .cr)      // [0x0D]
let crlfBytes = [UInt8](ascii: .crlf)  // [0x0D, 0x0A]

// Use in protocol implementation
var httpResponse: [UInt8] = [UInt8](ascii: "HTTP/1.1 200 OK")!
httpResponse += [UInt8].ascii.crlf
httpResponse += [UInt8](ascii: "Content-Type: text/plain")!
httpResponse += [UInt8].ascii.crlf
```

### Character-Level Operations

Swift `Character` extensions for ASCII operations:

```swift
let char: Character = "A"

// Classification
char.ascii.isWhitespace    // false
char.ascii.isDigit         // false
char.ascii.isLetter        // true
char.ascii.isAlphanumeric  // true
char.ascii.isHexDigit      // true
char.ascii.isUppercase     // true
char.ascii.isLowercase     // false

// Character set operations
let whitespace: Set<Character> = .ascii.whitespaces  // {' ', '\t', '\n', '\r'}
whitespace.contains(" ")  // true
whitespace.contains("\t")  // true
```

### Authoritative API

Direct access to the INCITS 4-1986 namespace:

```swift
// Access character constants
let space = INCITS_4_1986.SPACE.sp          // 0x20
let tab = INCITS_4_1986.ControlCharacters.htab     // 0x09
let letterA = INCITS_4_1986.GraphicCharacters.A    // 0x41

// Common byte sequences
let crlf = INCITS_4_1986.ControlCharacters.crlf  // [0x0D, 0x0A]

// Whitespace set
let whitespaces = INCITS_4_1986.whitespaces
// {0x20, 0x09, 0x0A, 0x0D}

// Case conversion offset
let offset = INCITS_4_1986.CaseConversion.offset  // 0x20
// 'A' (0x41) + 0x20 = 'a' (0x61)
```

## Performance

Benchmarked on Apple Silicon (M-series):

### Throughput
- **ASCII validation**: 17.3 MB/sec (1M bytes in ~58ms)
- **Case conversion**: 2.5 MB/sec (1M bytes in ~400ms)
- **String normalization**: 2 MB/sec (1M bytes in ~500ms)
- **String trimming**: 5 MB/sec (1M spaces in ~200ms)

### Linear Scaling
All operations scale linearly with input size:
- 1K bytes → 10K bytes: 10× time increase
- 10K bytes → 100K bytes: 10× time increase
- 100K bytes → 1M bytes: 10× time increase

### Optimizations
- Zero-copy UTF-8 fast path for ASCII operations
- Direct byte-level comparisons instead of Set lookups
- Cross-module inlining for zero-cost abstractions
- Minimal memory allocations (often zero for hot paths)

## Standards Compliance

Conforms to **INCITS 4-1986 (Reaffirmed 2022)**:

- **Character set**: 7-bit ASCII (0x00-0x7F, 128 characters)
- **Control characters** (Section 4.1): 33 characters (0x00-0x1F, 0x7F)
- **SPACE** (Section 4.2): Dual-nature character (0x20)
- **Graphic characters** (Section 4.3): 94 printable characters (0x21-0x7E)

### Historical Designations
- **Current**: INCITS 4-1986 (R2022)
- **Previous**: ANSI X3.4-1986
- **Original**: ANSI X3.4-1968, ASA X3.4-1963
- **IANA**: US-ASCII

### Special Values
- **Whitespace**: SPACE (0x20), HORIZONTAL TAB (0x09), LINE FEED (0x0A), CARRIAGE RETURN (0x0D)
- **CRLF**: Required line ending for HTTP, SMTP, FTP, MIME per their RFCs
- **Case conversion**: Offset of 0x20 between uppercase and lowercase letters

## Testing

Test suite: 513 tests in 164 suites

Coverage:
- Character classification for all 128 ASCII bytes
- String and Substring character classification and validation
- String and Substring case validation and conversion
- String and Substring line ending detection
- Case conversion (upper, lower, round-trip)
- String ⟷ byte array conversion (valid, invalid, empty)
- Line ending normalization (LF, CR, CRLF, mixed)
- String trimming (whitespace, custom sets)
- Edge cases (empty arrays, control characters, non-ASCII)
- Performance benchmarks at multiple scales
- Linear scaling validation

Run tests:

```bash
swift test
```

Run specific test suites:

```bash
swift test --filter "Character Classification"
swift test --filter "Linear Scaling"
```

## Requirements

- Swift 6.0 or later
- macOS 15.0+ / iOS 18.0+ / tvOS 18.0+ / watchOS 11.0+
- No Foundation dependencies (Swift Embedded compatible)

## Related Packages

- [swift-standards](https://github.com/swift-standards/swift-standards) - Foundation utilities for standards implementations

## License

This package is licensed under the Apache License 2.0. See [LICENSE.md](LICENSE.md) for details.

## Contributing

Contributions are welcome. Please ensure all tests pass and new features include test coverage.
