// LocaleTests.swift
// Locale Tests

import StandardLibraryExtensions
import Testing

@testable import Locale

@Suite
struct `Locale Foundation Tests` {

    @Test
    func `Placeholder test`() {
        let locale = Locale()
        #expect(locale == locale)
    }
}
