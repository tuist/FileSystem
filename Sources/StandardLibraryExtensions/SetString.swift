//
//  File.swift
//  swift-standards
//
//  Created by Coen ten Thije Boonkkamp on 20/11/2025.
//

extension Set<String> {
    /// Swift keywords that need to be escaped with backticks when used as identifiers
    public static let swiftKeywords: Set<String> = [
        "as", "break", "case", "catch", "class", "continue", "default", "defer",
        "do", "else", "enum", "extension", "fallthrough", "false", "fileprivate",
        "for", "func", "guard", "if", "import", "in", "init", "inout", "internal",
        "is", "let", "nil", "operator", "private", "protocol", "public", "repeat",
        "return", "self", "Self", "static", "struct", "subscript", "super", "switch",
        "throw", "throws", "true", "try", "typealias", "var", "where", "while",
    ]
}
