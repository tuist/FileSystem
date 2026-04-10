//
//  Test.swift
//  swift-file-system
//
//  Test suite structure for File System convenience layer tests.
//

import File_System
import Testing

extension Test {
    struct Unit {}
    struct EdgeCase {}
    @Suite(.serialized)
    struct Performance {}
}

extension File.System {
    typealias Test = Testing.Test
}
