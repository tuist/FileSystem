// TODO: Investigate if per-type extensions are needed vs FixedWidthInteger extension
// These are commented out pending investigation

// // Int8.swift
// // swift-standards
// //
// // Extensions for Swift standard library Int8
//
// extension Int8 {
//     /// Creates an integer from its byte representation
//     /// - Parameters:
//     ///   - bytes: Collection of bytes representing the integer
//     ///   - endianness: Byte order (ignored for single-byte integers)
//     /// - Returns: Integer decoded from bytes, or nil if byte count doesn't match size
//     public init?<C: Collection>(bytes: C, endianness: Binary.Endianness = .little)
//     where C.Element == UInt8 {
//         guard bytes.count == MemoryLayout<Self>.size else { return nil }
//         let byteArray: [UInt8] = .init(bytes)
//         self = byteArray.withUnsafeBytes { $0.load(as: Self.self) }
//     }
// }
