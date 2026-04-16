// Binary.Serializable.swift
// Streaming byte serialization protocol.

/// Protocol for types that serialize to byte streams.
///
/// Conforming types can write their byte representation directly into
/// any `RangeReplaceableCollection` of `UInt8`, enabling efficient
/// composition and streaming output.
///
/// ## Design Philosophy
///
/// The protocol is intentionally minimal:
/// - Single requirement: `serialize(_:into:)`
/// - No context parameter (values are self-describing)
/// - No associated error type (serialization is infallible for valid values)
/// - Buffer-agnostic via `RangeReplaceableCollection`
///
/// ## Category Theory
///
/// Streaming serialization is a natural transformation:
/// - **Domain**: Self (structured value)
/// - **Codomain**: Mutation of Buffer (byte sequence)
///
/// The `inout Buffer` pattern represents the state monad:
/// `serialize: Self → (Buffer → Buffer)`
///
/// ## Use Cases
///
/// - HTML document streaming (server-side rendering)
/// - Large structured data (JSON, XML, protocol buffers)
/// - Compositional serialization (nested DOM-like structures)
/// - HTTP chunked transfer encoding
/// - Template rendering engines
///
/// ## Example
///
/// ```swift
/// struct HTMLDiv: Binary.Serializable {
///     let className: String?
///     let children: [any Binary.Serializable]
///
///     static func serialize<Buffer: RangeReplaceableCollection>(
///         _ div: Self,
///         into buffer: inout Buffer
///     ) where Buffer.Element == UInt8 {
///         buffer.append(contentsOf: "<div".utf8)
///         if let className = div.className {
///             buffer.append(contentsOf: " class=\"".utf8)
///             buffer.append(contentsOf: className.utf8)
///             buffer.append(UInt8(ascii: "\""))
///         }
///         buffer.append(UInt8(ascii: ">"))
///
///         for child in div.children {
///             child.serialize(into: &buffer)
///         }
///
///         buffer.append(contentsOf: "</div>".utf8)
///     }
/// }
/// ```
///
extension Binary {
    public protocol Serializable: Sendable {
        /// Serialize this value into a byte buffer.
        ///
        /// Writes the byte representation of this value into the provided buffer.
        /// Implementations should append bytes without clearing existing content.
        ///
        /// ## Implementation Requirements
        ///
        /// - MUST append bytes to buffer (not replace)
        /// - MUST NOT throw (serialization is infallible for valid values)
        /// - SHOULD be deterministic (same value produces same bytes)
        ///
        /// - Parameters:
        ///   - serializable: The value to serialize
        ///   - buffer: The buffer to append bytes to
        static func serialize<Buffer: RangeReplaceableCollection>(
            _ serializable: Self,
            into buffer: inout Buffer
        ) where Buffer.Element == UInt8
    }
}

// MARK: - Convenience Extensions

extension Binary.Serializable {
    /// Serialize to a new byte array.
    ///
    /// Convenience property that creates a new buffer and serializes into it.
    ///
    /// ## Performance Note
    ///
    /// Each call allocates a new array. For repeated serialization,
    /// prefer `serialize(into:)` with a reusable buffer.
    @inlinable
    public var bytes: [UInt8] {
        var buffer: [UInt8] = []
        Self.serialize(self, into: &buffer)
        return buffer
    }

    /// Serialize this value into a byte buffer (instance method).
    ///
    /// Convenience method that delegates to the static `serialize(_:into:)`.
    @inlinable
    public func serialize<Buffer: RangeReplaceableCollection>(
        into buffer: inout Buffer
    ) where Buffer.Element == UInt8 {
        Self.serialize(self, into: &buffer)
    }
}

// MARK: - Static Returning Convenience

extension Binary.Serializable {
    /// Serialize to a new collection (static method).
    ///
    /// Creates a new buffer of the inferred type and serializes into it.
    @inlinable
    public static func serialize<Bytes: RangeReplaceableCollection>(
        _ serializable: Self
    ) -> Bytes where Bytes.Element == UInt8 {
        var buffer = Bytes()
        Self.serialize(serializable, into: &buffer)
        return buffer
    }

    /// Exposes serialized bytes through an unsafe buffer pointer without extra copying.
    @inlinable
    public static func withSerializedBytes<Result, Failure: Error>(
        _ serializable: Self,
        _ body: (UnsafeBufferPointer<UInt8>) throws(Failure) -> Result
    ) throws(Failure) -> Result {
        let bytes = serializable.bytes
        var result: Result?
        var failure: Failure?
        bytes.withUnsafeBufferPointer { buffer in
            do {
                result = try body(buffer)
            } catch let error as Failure {
                failure = error
            } catch {
                fatalError("Unexpected error type: \(error)")
            }
        }
        if let failure {
            throw failure
        }
        return result!
    }
}

// MARK: - RangeReplaceableCollection Append

extension RangeReplaceableCollection<UInt8> {
    /// Appends a serializable value to the collection.
    @inlinable
    public mutating func append<S: Binary.Serializable>(_ serializable: S) {
        S.serialize(serializable, into: &self)
    }
}

// MARK: - Collection Initializers

extension Array where Element == UInt8 {
    /// Create a byte array from a serializable value.
    @inlinable
    public init<S: Binary.Serializable>(_ serializable: S) {
        self = []
        S.serialize(serializable, into: &self)
    }
}

extension ContiguousArray where Element == UInt8 {
    /// Create a contiguous byte array from a serializable value.
    @inlinable
    public init<S: Binary.Serializable>(_ serializable: S) {
        self = []
        S.serialize(serializable, into: &self)
    }
}

// MARK: - String Conversion

extension StringProtocol {
    /// Create a string from a serializable value's UTF-8 output.
    @inlinable
    public init<T: Binary.Serializable>(_ value: T) {
        self = Self(decoding: value.bytes, as: UTF8.self)
    }
}

// MARK: - RawRepresentable Default Implementations

extension Binary.Serializable where Self: RawRepresentable, Self.RawValue: StringProtocol {
    /// Default implementation for string-backed types.
    @inlinable
    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ serializable: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == UInt8 {
        buffer.append(contentsOf: serializable.rawValue.utf8)
    }
}

extension Binary.Serializable where Self: RawRepresentable, Self.RawValue == [UInt8] {
    /// Default implementation for byte-array-backed types.
    @inlinable
    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ serializable: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == UInt8 {
        buffer.append(contentsOf: serializable.rawValue)
    }
}
