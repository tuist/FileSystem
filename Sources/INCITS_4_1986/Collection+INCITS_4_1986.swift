// ===----------------------------------------------------------------------===//
//
// Copyright (c) 2025 Coen ten Thije Boonkkamp
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of project contributors
//
// SPDX-License-Identifier: Apache-2.0
//
// ===----------------------------------------------------------------------===//

// Collection+INCITS_4_1986.swift
// swift-incits-4-1986
//
// Stdlib extensions that delegate to authoritative INCITS 4-1986 implementations

extension Collection where Element == UInt8 {
    /// Access to ASCII instance methods for this byte collection
    ///
    /// Provides instance-level access to ASCII validation and transformation methods.
    /// Returns a generic `INCITS_4_1986.ASCII` wrapper that works directly with the
    /// collection without copying.
    ///
    /// ## Performance
    ///
    /// No intermediate array allocation is performed. The wrapper holds a reference
    /// to the original collection:
    ///
    /// ```swift
    /// let slice = bytes[start..<end]
    /// let lower = slice.ascii.lowercased()  // No intermediate Array copy!
    /// ```
    ///
    /// ## See Also
    ///
    /// - ``INCITS_4_1986/ASCII``
    /// - ``INCITS_4_1986``
    @inlinable
    public var ascii: INCITS_4_1986.ASCII<Self> {
        INCITS_4_1986.ASCII(self)
    }
}
