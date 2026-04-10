//
//  Binary.ASCII.Serializable Tests.swift
//  swift-incits-4-1986
//
//  Tests demonstrating the Binary.ASCII.Serializable protocol
//  with both context-free and context-dependent parsing.
//

import INCITS_4_1986
import Testing

// MARK: - Context-Free Type Example

/// A simple token type that requires no parsing context.
/// Demonstrates the standard Serializable conformance pattern.
private struct Token: Sendable, Codable {
    let rawValue: String

    internal init(
        __unchecked: Void,
        rawValue: String
    ) {
        self.rawValue = rawValue
    }

    public init(
        _ value: String
    ) throws(Error) {
        let bytes: [UInt8] = Array(value.utf8)
        guard !bytes.isEmpty else { throw .empty }

        for byte in bytes {
            guard byte.ascii.isAlphanumeric || byte == .ascii.hyphen else {
                throw .invalidCharacter(byte)
            }
        }

        self.init(
            __unchecked: (),
            rawValue: value
        )
    }
}

extension Token {
    enum Error: Swift.Error, Sendable, Equatable {
        case empty
        case invalidCharacter(UInt8)
    }
}

extension Token: Binary.ASCII.Serializable {

    // Context == Void (default), so we implement init(ascii:in:) with Void context
    init<Bytes: Collection>(ascii bytes: Bytes, in context: Void) throws(Error)
    where Bytes.Element == UInt8 {
        try self.init(String(decoding: bytes, as: UTF8.self))
    }

    static func serialize<Buffer>(ascii token: Self, into buffer: inout Buffer)
    where Buffer: RangeReplaceableCollection, Buffer.Element == UInt8 {
        buffer.append(contentsOf: token.rawValue.utf8)
    }
}

extension Token: Hashable {}
extension Token: CustomStringConvertible {}
extension Token: ExpressibleByStringLiteral {}

// MARK: - Context-Dependent Type Example

/// A message type that requires a delimiter to parse.
/// Demonstrates context-dependent Serializable conformance.
struct DelimitedMessage: Sendable, Codable {
    let parts: [String]
    let delimiter: UInt8

    init(__unchecked: Void, parts: [String], delimiter: UInt8) {
        self.parts = parts
        self.delimiter = delimiter
    }
}

extension DelimitedMessage: Binary.ASCII.Serializable {
    //    static func serialize(ascii message: DelimitedMessage) -> [UInt8] {
    //        var result: [UInt8] = []
    //        for (index, part) in message.parts.enumerated() {
    //            if index > 0 {
    //                result.append(message.delimiter)
    //            }
    //            result.append(contentsOf: part.utf8)
    //        }
    //        return result
    //    }

    internal static func serialize<Buffer>(ascii message: Self, into buffer: inout Buffer)
    where Buffer: RangeReplaceableCollection, Buffer.Element == UInt8 {
        for (index, part) in message.parts.enumerated() {
            if index > 0 {
                buffer.append(message.delimiter)
            }
            buffer.append(contentsOf: part.utf8)
        }
    }

    /// Context required for parsing - the delimiter byte
    struct Context: Sendable {
        let delimiter: UInt8
    }

    enum Error: Swift.Error, Sendable, Equatable {
        case empty
    }

    init<Bytes: Collection>(ascii bytes: Bytes, in context: Context) throws(Error)
    where Bytes.Element == UInt8 {
        guard !bytes.isEmpty else { throw .empty }

        // Split on delimiter
        var parts: [String] = []
        var current: [UInt8] = []

        for byte in bytes {
            if byte == context.delimiter {
                parts.append(String(decoding: current, as: UTF8.self))
                current = []
            } else {
                current.append(byte)
            }
        }
        // Add final part
        parts.append(String(decoding: current, as: UTF8.self))

        self.init(__unchecked: (), parts: parts, delimiter: context.delimiter)
    }
}

extension DelimitedMessage: Hashable {}
extension DelimitedMessage: CustomStringConvertible {}

// MARK: - Context-Free Parsing Tests

@Suite("Serializable - Context-Free Types")
struct ContextFreeSerializableTests {
    @Test("Parse from bytes using init(ascii:)")
    func parseFromBytes() throws {
        let bytes: [UInt8] = Array("hello-world".utf8)
        let token: Token = try .init(ascii: bytes)

        #expect(token.rawValue == "hello-world")
    }

    @Test("Parse from bytes using init(ascii:in:) with Void")
    func parseFromBytesWithVoidContext() throws {
        let bytes: [UInt8] = Array("test123".utf8)
        let token: Token = try .init(ascii: bytes, in: ())

        #expect(token.rawValue == "test123")
    }

    @Test("Parse from string using init(_:)")
    func parseFromString() throws {
        let token: Token = try .init("my-token")

        #expect(token.rawValue == "my-token")
    }

    @Test("String literal initialization")
    func stringLiteral() {
        let token: Token = "literal-token"

        #expect(token.rawValue == "literal-token")
    }

    @Test("Serialize to bytes")
    func serializeToBytes() throws {
        let token: Token = try .init("hello")

        #expect(Token.serialize(token) == Array("hello".utf8))
    }

    @Test("Convert to String")
    func convertToString() throws {
        let token: Token = try .init("world")

        #expect(String(token) == "world")
    }

    @Test("Round-trip: bytes → Token → bytes")
    func roundTripBytes() throws {
        let original: [UInt8] = Array("round-trip".utf8)
        let token: Token = try .init(ascii: original)

        #expect(Token.serialize(token) == original)
    }

    @Test("Round-trip: string → Token → string")
    func roundTripString() throws {
        let original = "test-value"
        let token: Token = try .init(original)
        let result = String(token)

        #expect(result == original)
    }

    @Test("Invalid input throws error")
    func invalidInput() {
        let bytes: [UInt8] = Array("hello world".utf8)  // space is invalid

        #expect(throws: Token.Error.self) {
            try Token(ascii: bytes)
        }
    }

    @Test("Empty input throws error")
    func emptyInput() {
        let bytes: [UInt8] = []

        #expect(throws: Token.Error.empty) {
            try Token(ascii: bytes)
        }
    }
}

// MARK: - Context-Dependent Parsing Tests

@Suite("Serializable - Context-Dependent Types")
struct ContextDependentSerializableTests {
    @Test("Parse with context using init(ascii:in:)")
    func parseWithContext() throws {
        let bytes: [UInt8] = Array("foo|bar|baz".utf8)
        let context = DelimitedMessage.Context(delimiter: .ascii.verticalLine)

        let message = try DelimitedMessage(ascii: bytes, in: context)

        #expect(message.parts == ["foo", "bar", "baz"])
        #expect(message.delimiter == .ascii.verticalLine)
    }

    @Test("Different delimiters produce different parses")
    func differentDelimiters() throws {
        let bytes: [UInt8] = Array("a,b|c".utf8)

        // Parse with comma delimiter
        let commaContext = DelimitedMessage.Context(delimiter: .ascii.comma)
        let commaMessage = try DelimitedMessage(ascii: bytes, in: commaContext)
        #expect(commaMessage.parts == ["a", "b|c"])

        // Parse with pipe delimiter
        let pipeContext = DelimitedMessage.Context(delimiter: .ascii.verticalLine)
        let pipeMessage = try DelimitedMessage(ascii: bytes, in: pipeContext)
        #expect(pipeMessage.parts == ["a,b", "c"])
    }

    @Test("Serialize to bytes")
    func serializeToBytes() throws {
        let message = DelimitedMessage(
            __unchecked: (),
            parts: ["hello", "world"],
            delimiter: .ascii.hyphen
        )

        #expect(DelimitedMessage.serialize(message) == Array("hello-world".utf8))
    }

    @Test("Round-trip: bytes → Message → bytes")
    func roundTrip() throws {
        let original: [UInt8] = Array("one:two:three".utf8)
        let context = DelimitedMessage.Context(delimiter: .ascii.colon)

        let message = try DelimitedMessage(ascii: original, in: context)

        #expect(DelimitedMessage.serialize(message) == original)
    }

    @Test("Convert to String via serialize")
    func convertToString() throws {
        let message = DelimitedMessage(
            __unchecked: (),
            parts: ["a", "b", "c"],
            delimiter: .ascii.semicolon
        )

        let string = String(message)

        #expect(string == "a;b;c")
    }

    @Test("Empty input throws error")
    func emptyInput() {
        let bytes: [UInt8] = []
        let context = DelimitedMessage.Context(delimiter: .ascii.comma)

        #expect(throws: DelimitedMessage.Error.empty) {
            try DelimitedMessage(ascii: bytes, in: context)
        }
    }

    @Test("Context-dependent type does NOT have init(_: String)")
    func noStringInit() {
        // This test documents that context-dependent types
        // don't get the automatic init(_: StringProtocol) convenience.
        // The following would not compile:
        // let message = try DelimitedMessage("a,b,c")  // Error: no context!

        // Instead, you must provide context:
        let bytes: [UInt8] = Array("a,b,c".utf8)
        let context = DelimitedMessage.Context(delimiter: .ascii.comma)
        let message = try? DelimitedMessage(ascii: bytes, in: context)

        #expect(message != nil)
    }
}

// MARK: - Category Theory Verification

@Suite("Serializable - Category Theory Properties")
struct CategoryTheoryTests {
    @Test("Void context is the unit type (terminal object)")
    func voidIsTerminal() {
        // In category theory, Void is the terminal object.
        // There's exactly one value: ()
        // A function (Void × A) → B is isomorphic to A → B

        // For context-free types, init(ascii:in:()) ≅ init(ascii:)
        let bytes: [UInt8] = Array("test".utf8)

        // Both should produce identical results:
        let viaConvenience = try? Token(ascii: bytes)
        let viaExplicit = try? Token(ascii: bytes, in: ())

        #expect(viaConvenience == viaExplicit)
    }

    @Test("Serialization is context-free (value is self-describing)")
    func serializationIsContextFree() throws {
        // Even for context-dependent types, serialization doesn't need context.
        // The value itself contains all information needed to serialize.

        let message = DelimitedMessage(
            __unchecked: (),
            parts: ["x", "y"],
            delimiter: .ascii.comma
        )

        // Serialize without needing any context:
        #expect(DelimitedMessage.serialize(message) == Array("x,y".utf8))
    }

    @Test("Parse-serialize round-trip is identity (for well-formed input)")
    func parseSerializeIsIdentity() throws {
        // For well-formed input, parse ∘ serialize = id
        let original: [UInt8] = Array("valid-token".utf8)

        let token: Token = try .init(ascii: original)
        #expect(Token.serialize(token) == original)
    }
}

// MARK: - Binary.Serializable Conformance Tests

/// Example HTML-like element that composes with ASCII.Serializable types.
/// Demonstrates how streaming types can embed RFC/ASCII types seamlessly.
private struct HTMLAnchor: Binary.Serializable {
    let href: Token
    let text: String

    static func serialize<Buffer>(_ anchor: Self, into buffer: inout Buffer)
    where Buffer: RangeReplaceableCollection, Buffer.Element == UInt8 {
        buffer.append(contentsOf: "<a href=\"".utf8)
        anchor.href.ascii.serialize(into: &buffer)  // Token conforms via ASCII.Serializable
        buffer.append(contentsOf: "\">".utf8)
        buffer.append(contentsOf: anchor.text.utf8)
        buffer.append(contentsOf: "</a>".utf8)
    }
}

@Suite("Serializable - Binary.Serializable Conformance")
struct StreamingConformanceTests {

    // MARK: - Automatic Conformance

    @Test("ASCII.Serializable types automatically conform to Binary.Serializable")
    func automaticConformance() throws {
        let token: Token = try .init("my-token")

        // Token conforms to Binary.Serializable via ASCII.Serializable
        var buffer: [UInt8] = []
        token.ascii.serialize(into: &buffer)

        #expect(buffer == Array("my-token".utf8))
    }

    @Test("Context-dependent types also conform to Binary.Serializable")
    func contextDependentConformance() {
        let message = DelimitedMessage(
            __unchecked: (),
            parts: ["a", "b", "c"],
            delimiter: .ascii.comma
        )

        // DelimitedMessage conforms to Binary.Serializable via ASCII.Serializable
        var buffer: [UInt8] = []
        message.ascii.serialize(into: &buffer)

        #expect(buffer == Array("a,b,c".utf8))
    }

    // MARK: - Buffer-Based Serialization

    @Test("Serialize into buffer using serialize(into:)")
    func serializeIntoBuffer() throws {
        let token: Token = try .init("hello-world")

        // Ideal streaming usage pattern
        var buffer: [UInt8] = []
        token.ascii.serialize(into: &buffer)

        #expect(buffer == Array("hello-world".utf8))
    }

    @Test("Get bytes using .bytes property")
    func bytesProperty() throws {
        let token: Token = try .init("swift-token")

        // Convenience property from Binary.Serializable
        let bytes = token.bytes

        #expect(bytes == Array("swift-token".utf8))
    }

    @Test("Append to existing buffer content")
    func appendToExistingBuffer() throws {
        let token: Token = try .init("suffix")

        var buffer: [UInt8] = Array("prefix-".utf8)
        token.ascii.serialize(into: &buffer)

        #expect(buffer == Array("prefix-suffix".utf8))
    }

    // MARK: - Composition with Streaming Types

    @Test("ASCII types compose with pure streaming types")
    func composeWithStreaming() throws {
        let anchor = try HTMLAnchor(
            href: .init("example-link"),
            text: "Click here"
        )

        let result = String(anchor)

        #expect(result == "<a href=\"example-link\">Click here</a>")
    }

    @Test("Multiple ASCII types serialize into shared buffer")
    func multipleTypesIntoBuffer() throws {
        let token1: Token = try .init("first")
        let token2: Token = try .init("second")
        let message = DelimitedMessage(
            __unchecked: (),
            parts: ["a", "b"],
            delimiter: .ascii.colon
        )

        // Accumulate all into one buffer
        var buffer: [UInt8] = []
        token1.ascii.serialize(into: &buffer)
        buffer.append(UInt8(ascii: "-"))
        token2.ascii.serialize(into: &buffer)
        buffer.append(UInt8(ascii: "|"))
        message.ascii.serialize(into: &buffer)

        #expect(buffer == Array("first-second|a:b".utf8))
    }

    @Test("Pre-allocate buffer for efficiency")
    func preAllocatedBuffer() throws {
        let tokens = try (1...10).map { try Token("token-\($0)") }

        var buffer: [UInt8] = []
        buffer.reserveCapacity(200)

        for (index, token) in tokens.enumerated() {
            if index > 0 {
                buffer.append(UInt8(ascii: ","))
            }
            token.ascii.serialize(into: &buffer)
        }

        let result = String(decoding: buffer, as: UTF8.self)
        #expect(result.hasPrefix("token-1,token-2"))
        #expect(result.hasSuffix("token-10"))
    }

    // MARK: - Round-Trip via Streaming

    @Test("Round-trip through buffer produces same result as static serialize")
    func roundTripEquivalence() throws {
        let token: Token = try .init("roundtrip-test")

        // Via static serialize
        let staticBytes: [UInt8] = Token.serialize(token)

        // Via streaming serialize(into:)
        var streamingBuffer: [UInt8] = []
        token.ascii.serialize(into: &streamingBuffer)

        // Via .bytes property
        let propertyBytes = token.bytes

        #expect(staticBytes == streamingBuffer)
        #expect(staticBytes == propertyBytes)
    }
}

// MARK: - API Pattern Demonstrations

@Suite("Serializable - Streaming API Patterns")
struct StreamingAPIPatternTests {

    @Test("Pattern: Direct buffer writing for server response")
    func directBufferWriting() throws {
        // Simulating building an HTTP-like response
        var response: [UInt8] = []

        // Add header
        response.append(contentsOf: "X-Token: ".utf8)
        let token: Token = try .init("auth-token-123")
        token.ascii.serialize(into: &response)
        response.append(contentsOf: "\r\n".utf8)

        let result = String(decoding: response, as: UTF8.self)
        #expect(result == "X-Token: auth-token-123\r\n")
    }

    @Test("Pattern: Building HTML with embedded RFC types")
    func htmlWithRFCTypes() throws {
        let anchor = try HTMLAnchor(
            href: .init("https-link"),
            text: "Visit site"
        )

        // Get bytes for HTTP response
        let bytes = anchor.bytes

        // Or get String for debugging/logging
        let string = String(anchor)

        #expect(bytes == Array(string.utf8))
        #expect(string == "<a href=\"https-link\">Visit site</a>")
    }

    @Test("Pattern: Reusable buffer for batch processing")
    func reusableBufferPattern() throws {
        var buffer: [UInt8] = []
        var results: [[UInt8]] = []

        let inputs = ["alpha", "beta", "gamma"]

        for input in inputs {
            buffer.removeAll(keepingCapacity: true)
            let token: Token = try .init(input)
            token.ascii.serialize(into: &buffer)
            results.append(buffer)
        }

        #expect(results.count == 3)
        #expect(results[0] == Array("alpha".utf8))
        #expect(results[1] == Array("beta".utf8))
        #expect(results[2] == Array("gamma".utf8))
    }

    @Test("Pattern: Streaming type wrapping ASCII type")
    func streamingWrapper() throws {
        // HTMLAnchor is a streaming type that wraps Token (ASCII type)
        struct Document: Binary.Serializable {
            let title: Token
            let links: [HTMLAnchor]

            static func serialize<Buffer>(_ doc: Self, into buffer: inout Buffer)
            where Buffer: RangeReplaceableCollection, Buffer.Element == UInt8 {
                buffer.append(contentsOf: "<html><head><title>".utf8)
                doc.title.ascii.serialize(into: &buffer)
                buffer.append(contentsOf: "</title></head><body>".utf8)
                for link in doc.links {
                    link.serialize(into: &buffer)
                }
                buffer.append(contentsOf: "</body></html>".utf8)
            }
        }

        let doc = try Document(
            title: .init("My-Page"),
            links: [
                HTMLAnchor(href: .init("link1"), text: "First"),
                HTMLAnchor(href: .init("link2"), text: "Second"),
            ]
        )

        let html = String(doc)

        #expect(html.contains("<title>My-Page</title>"))
        #expect(html.contains("<a href=\"link1\">First</a>"))
        #expect(html.contains("<a href=\"link2\">Second</a>"))
    }
}

// MARK: - Infinite Recursion Prevention Tests

/// Example type demonstrating the CORRECT pattern for Binary.ASCII.RawRepresentable
///
/// Types conforming to both `Binary.ASCII.Serializable` and `Binary.ASCII.RawRepresentable`
/// MUST implement `serialize(ascii:into:)` explicitly to avoid infinite recursion.
private struct CorrectEmailAddress: Sendable, Codable, Hashable {
    let localPart: String
    let domain: String

    init(__unchecked: Void, localPart: String, domain: String) {
        self.localPart = localPart
        self.domain = domain
    }
}

extension CorrectEmailAddress: Binary.ASCII.Serializable {
    enum Error: Swift.Error, Sendable, Equatable {
        case empty
        case missingAtSign
    }

    init<Bytes: Collection>(ascii bytes: Bytes, in context: Void) throws(Error)
    where Bytes.Element == UInt8 {
        guard !bytes.isEmpty else { throw .empty }

        let byteArray = Array(bytes)
        guard let atIndex = byteArray.firstIndex(of: .ascii.commercialAt) else {
            throw .missingAtSign
        }

        self.init(
            __unchecked: (),
            localPart: String(decoding: byteArray[..<atIndex], as: UTF8.self),
            domain: String(decoding: byteArray[byteArray.index(after: atIndex)...], as: UTF8.self)
        )
    }

    /// CORRECT: Explicit serialize implementation that does NOT use rawValue
    ///
    /// This is REQUIRED when conforming to Binary.ASCII.RawRepresentable.
    /// Using rawValue here would cause infinite recursion because:
    ///   rawValue → String(ascii: self) → serialize(ascii:into:) → rawValue → ...
    static func serialize<Buffer: RangeReplaceableCollection>(
        ascii email: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == UInt8 {
        buffer.append(contentsOf: email.localPart.utf8)
        buffer.append(.ascii.commercialAt)
        buffer.append(contentsOf: email.domain.utf8)
    }
}

extension CorrectEmailAddress: Binary.ASCII.RawRepresentable {
    typealias RawValue = String
}

extension CorrectEmailAddress: CustomStringConvertible {}

@Suite("Serializable - Infinite Recursion Prevention")
struct InfiniteRecursionPreventionTests {

    // MARK: - Documentation of the Problem

    /// This test documents the infinite recursion problem that occurs when
    /// a type conforms to both Binary.ASCII.Serializable and Binary.ASCII.RawRepresentable
    /// WITHOUT providing an explicit serialize(ascii:into:) implementation.
    ///
    /// ## The Problem Pattern (DO NOT USE)
    ///
    /// ```swift
    /// // WRONG: This causes infinite recursion!
    /// extension MyType: Binary.ASCII.Serializable {
    ///     // Relying on default implementation from RawRepresentable
    /// }
    ///
    /// extension MyType: Binary.ASCII.RawRepresentable {
    ///     typealias RawValue = String
    /// }
    /// ```
    ///
    /// ## Why It Crashes
    ///
    /// 1. `rawValue` getter (from Binary.ASCII.RawRepresentable) calls `String(ascii: self)`
    /// 2. `String(ascii:)` calls `T.serialize(ascii:into:)` to get bytes
    /// 3. Default `serialize(ascii:into:)` for RawRepresentable uses `rawValue.utf8`
    /// 4. This accesses `rawValue` again → INFINITE RECURSION → Stack overflow
    ///
    /// ## The Solution
    ///
    /// Always provide an explicit `serialize(ascii:into:)` that does NOT use `rawValue`:
    ///
    /// ```swift
    /// extension MyType: Binary.ASCII.Serializable {
    ///     static func serialize<Buffer: RangeReplaceableCollection>(
    ///         ascii value: Self,
    ///         into buffer: inout Buffer
    ///     ) where Buffer.Element == UInt8 {
    ///         // Serialize directly from stored properties, NOT from rawValue
    ///         buffer.append(contentsOf: value.someProperty.utf8)
    ///     }
    /// }
    /// ```
    @Test("Correct pattern avoids infinite recursion")
    func correctPatternWorks() throws {
        let email = try CorrectEmailAddress("user@example.com")

        // These should all work without infinite recursion:
        let rawValue = email.rawValue
        let description = email.description
        let bytes = email.bytes

        #expect(rawValue == "user@example.com")
        #expect(description == "user@example.com")
        #expect(bytes == Array("user@example.com".utf8))
    }

    @Test("RawValue is synthesized from serialization")
    func rawValueFromSerialization() throws {
        let email = try CorrectEmailAddress("test@domain.org")

        // rawValue should be derived from serialize(ascii:into:)
        #expect(email.rawValue == "test@domain.org")
    }

    @Test("Round-trip through rawValue")
    func roundTripThroughRawValue() throws {
        let original = try CorrectEmailAddress("hello@world.net")

        // rawValue → String → bytes → parse → compare
        let rawValue = original.rawValue
        let restored = try CorrectEmailAddress(rawValue)

        #expect(original == restored)
    }

    @Test("Serialization does not access rawValue")
    func serializationIndependentOfRawValue() throws {
        let email = try CorrectEmailAddress("direct@serialize.test")

        // serialize(ascii:into:) should work without ever touching rawValue
        var buffer: [UInt8] = []
        CorrectEmailAddress.serialize(ascii: email, into: &buffer)

        #expect(buffer == Array("direct@serialize.test".utf8))
    }

    // MARK: - API Design Guidance

    @Test("Checklist for Binary.ASCII.RawRepresentable conformance")
    func conformanceChecklist() throws {
        // This test serves as documentation for the required pattern:
        //
        // ✅ 1. Implement serialize(ascii:into:) explicitly
        // ✅ 2. Do NOT use rawValue in serialize implementation
        // ✅ 3. Add `typealias RawValue = String` to RawRepresentable conformance
        // ✅ 4. Test that rawValue, description, and bytes all work

        let email = try CorrectEmailAddress("checklist@test.com")

        // All of these should work without recursion:
        #expect(email.rawValue == "checklist@test.com")
        #expect(email.description == "checklist@test.com")
        #expect(String(ascii: email) == "checklist@test.com")
        #expect(email.bytes == Array("checklist@test.com".utf8))

        var buffer: [UInt8] = []
        email.ascii.serialize(into: &buffer)
        #expect(buffer == Array("checklist@test.com".utf8))
    }
}
