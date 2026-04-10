//
//  Test.swift
//  swift-file-system
//
//  Created by Coen ten Thije Boonkkamp on 18/12/2025.
//

import File_System_Async
import Testing

extension Test {
    struct Unit {}
    struct EdgeCase {}
    @Suite(.serialized)
    struct Performance {}
}

extension File.IO {
    typealias Test = Testing.Test
}
