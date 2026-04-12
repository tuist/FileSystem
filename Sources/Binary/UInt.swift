// TODO: Investigate if per-type extensions are needed vs FixedWidthInteger extension
// These are commented out pending investigation

// // UInt.swift
// // swift-standards
// //
// // Extensions for Swift standard library UInt
//
// extension UInt {
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
// }
