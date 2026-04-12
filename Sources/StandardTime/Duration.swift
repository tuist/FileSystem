// Duration.swift
// StandardTime
//
// Duration type alias for timeline arithmetic

/// Duration for timeline arithmetic
///
/// Type alias for Swift.Duration, used with Instant for timeline operations.
///
/// ## Usage
///
/// ```swift
/// let duration = Duration.seconds(3600)
/// let later = instant + duration
/// ```
@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
public typealias Duration = Swift.Duration
