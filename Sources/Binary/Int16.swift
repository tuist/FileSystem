// TODO: Investigate if per-type extensions are needed vs FixedWidthInteger extension
// These are commented out pending investigation

// // Int16.swift
// // swift-standards
// //
// // Extensions for Swift standard library Int16
//
// extension Int16 {
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
//     /// - decode: [UInt8] → Int16
//     /// - encode: Int16 → [UInt8]
//     ///
//     /// Category theory: Isomorphism in the category of types where
//     /// encode ∘ decode ≡ id and decode ∘ encode ≡ id (modulo endianness).
//     ///
//     /// - Parameter endianness: Byte order for output bytes (defaults to little-endian)
//     /// - Returns: Byte array representation of the integer
//     ///
//     /// Example:
//     /// ```swift
//     /// Int16(0x1234).bytes(endianness: .little)  // [0x34, 0x12]
//     /// Int16(0x1234).bytes(endianness: .big)     // [0x12, 0x34]
//     /// Int16(-1).bytes(endianness: .little)      // [0xFF, 0xFF]
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
