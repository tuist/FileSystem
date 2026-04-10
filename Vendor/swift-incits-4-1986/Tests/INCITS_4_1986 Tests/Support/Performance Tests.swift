// Performance Tests.swift
// swift-incits-4-1986
//
// Top-level performance test suite with serialized execution.
// All performance tests extend this suite via extension in their respective test files.

import StandardsTestSupport
import Testing

@MainActor
@Suite(
    .serialized
)
struct `Performance Tests` {}
