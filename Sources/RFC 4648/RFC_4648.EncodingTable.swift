// RFC_4648.EncodingTable.swift
// swift-rfc-4648
//
// Primitive encoding table structure for RFC 4648 encodings

extension RFC_4648 {
    /// Encoding table pairing encode and decode lookups
    public struct EncodingTable: Sendable {
        /// Encoding lookup table: maps value (0-63 for Base64, 0-31 for Base32, 0-15 for Hex) to ASCII character
        public let encode: [UInt8]

        /// Decoding lookup table: maps ASCII character to value, 255 for invalid characters
        public let decode: [UInt8]

        /// Creates an encoding table with explicit encode and decode tables
        public init(encode: [UInt8], decode: [UInt8]) {
            self.encode = encode
            self.decode = decode
        }

        /// Creates an encoding table, automatically generating decode table from encode table
        /// - Parameter caseInsensitive: If true, maps both uppercase and lowercase letters to same value
        public init(encode: [UInt8], caseInsensitive: Bool = false) {
            self.encode = encode
            var decodeTable = [UInt8](repeating: 255, count: 256)
            for (index, char) in encode.enumerated() {
                decodeTable[Int(char)] = UInt8(index)

                // For case-insensitive encodings, map both cases
                if caseInsensitive {
                    if char >= 0x41, char <= 0x5A {  // A-Z
                        decodeTable[Int(char + 32)] = UInt8(index)  // a-z
                    } else if char >= 0x61, char <= 0x7A {  // a-z
                        decodeTable[Int(char - 32)] = UInt8(index)  // A-Z
                    }
                }
            }
            decode = decodeTable
        }
    }
}
