// TODO: Investigate if per-type extensions are needed vs FixedWidthInteger extension
// These are commented out pending investigation

// // UInt64.swift
// // swift-standards
// //
// // Extensions for Swift standard library UInt64
//
// extension UInt64 {
//     /// Creates an integer from its byte representation
//     /// - Parameters:
//     ///   - bytes: Collection of bytes representing the integer
//     ///   - endianness: Byte order of the input bytes (defaults to little-endian)
//     /// - Returns: Integer decoded from bytes, or nil if byte count doesn't match size
//     public init?<C: Collection>(bytes: C, endianness: Binary.Endianness = .little)
//     where C.Element == UInt8 {
//         guard bytes.count == MemoryLayout<Self>.size else { return nil }
//         let byteArray: [UInt8] = .init(bytes)
//         let value = byteArray.withUnsafeBytes { $0.load(as: Self.self) }
//         switch endianness {
//         case .little:
//             self = Self(littleEndian: value)
//         case .big:
//             self = Self(bigEndian: value)
//         }
//     }
//
//     /// Encodes integer to byte representation
//     ///
//     /// Completes the isomorphism between FixedWidthInteger and [UInt8].
//     /// Together with init(bytes:endianness:), forms a bijection:
//     /// - decode: [UInt8] → UInt64
//     /// - encode: UInt64 → [UInt8]
//     ///
//     /// Category theory: Isomorphism in the category of types where
//     /// encode ∘ decode ≡ id and decode ∘ encode ≡ id (modulo endianness).
//     ///
//     /// - Parameter endianness: Byte order for output bytes (defaults to little-endian)
//     /// - Returns: Byte array representation of the integer
//     ///
//     /// Example:
//     /// ```swift
//     /// UInt64(0x123456789ABCDEF0).bytes(endianness: .little)  // [0xF0, 0xDE, 0xBC, 0x9A, 0x78, 0x56, 0x34, 0x12]
//     /// UInt64(0x123456789ABCDEF0).bytes(endianness: .big)     // [0x12, 0x34, 0x56, 0x78, 0x9A, 0xBC, 0xDE, 0xF0]
//     /// ```
//     @inlinable
//     public func bytes(endianness: Binary.Endianness = .little) -> [UInt8] {
//         let value: Self
//         switch endianness {
//         case .little:
//             value = self.littleEndian
//         case .big:
//             value = self.bigEndian
//         }
//         return withUnsafeBytes(of: value, Array.init)
//     }
// }
