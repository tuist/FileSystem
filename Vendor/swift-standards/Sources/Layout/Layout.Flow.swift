// Layout.Flow.swift
// A wrapping layout that flows content to the next line when full.

public import Dimension

extension Layout {
    /// A wrapping layout that flows content to the next line when full.
    ///
    /// Flow arranges items along the primary axis (horizontally), wrapping
    /// to a new line when the available space is exhausted. This is similar
    /// to CSS flexbox with `flex-wrap: wrap`.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let flow: Layout<Double>.Flow<[Tag]> = .init(
    ///     spacing: .init(item: 8.0, line: 12.0),
    ///     alignment: .leading,
    ///     content: tags
    /// )
    /// ```
    ///
    /// ## Visual Example
    ///
    /// Given tags `[A, B, C, D, E]` in a narrow container:
    ///
    /// ```
    /// [A] [B] [C]
    /// [D] [E]
    /// ```
    public struct Flow<Content> {
        /// The spacing between items and lines.
        public var spacing: Gaps

        /// Alignment of items within each line.
        public var alignment: Horizontal.Alignment

        /// Vertical alignment of lines within the container.
        public var line: Line

        /// The content to flow.
        public var content: Content

        /// Create a flow layout with the given configuration.
        @inlinable
        public init(
            spacing: consuming Gaps,
            alignment: consuming Horizontal.Alignment,
            line: consuming Line,
            content: consuming Content
        ) {
            self.spacing = spacing
            self.alignment = alignment
            self.line = line
            self.content = content
        }
    }
}

// MARK: - Gaps

extension Layout.Flow {
    /// Spacing configuration for a flow layout.
    ///
    /// Defines the spacing between items on the same line and between lines.
    public struct Gaps {
        /// Spacing between items on the same line.
        public var item: Spacing

        /// Spacing between lines.
        public var line: Spacing

        /// Create spacing with the given item and line values.
        @inlinable
        public init(item: Spacing, line: Spacing) {
            self.item = item
            self.line = line
        }
    }
}

extension Layout.Flow.Gaps: Sendable where Spacing: Sendable {}
extension Layout.Flow.Gaps: Equatable where Spacing: Equatable {}
extension Layout.Flow.Gaps: Hashable where Spacing: Hashable {}
extension Layout.Flow.Gaps: Codable where Spacing: Codable {}

extension Layout.Flow.Gaps where Spacing: AdditiveArithmetic {
    /// Create uniform spacing (same for items and lines).
    @inlinable
    public static func uniform(_ value: Spacing) -> Self {
        Self(item: value, line: value)
    }
}

// MARK: - Line

extension Layout.Flow {
    /// Line configuration for a flow layout.
    public struct Line: Sendable, Hashable, Codable {
        /// Vertical alignment of lines within the container.
        public var alignment: Vertical.Alignment

        /// Create line configuration with the given alignment.
        @inlinable
        public init(alignment: Vertical.Alignment) {
            self.alignment = alignment
        }
    }
}

extension Layout.Flow.Line {
    /// Top-aligned lines.
    @inlinable
    public static var top: Self { Self(alignment: .top) }

    /// Center-aligned lines.
    @inlinable
    public static var center: Self { Self(alignment: .center) }

    /// Bottom-aligned lines.
    @inlinable
    public static var bottom: Self { Self(alignment: .bottom) }
}

// MARK: - Sendable

extension Layout.Flow: Sendable where Spacing: Sendable, Content: Sendable {}

// MARK: - Equatable

extension Layout.Flow: Equatable where Spacing: Equatable, Content: Equatable {}

// MARK: - Hashable

extension Layout.Flow: Hashable where Spacing: Hashable, Content: Hashable {}

// MARK: - Codable

extension Layout.Flow: Codable where Spacing: Codable, Content: Codable {}

// MARK: - Convenience Initializers

extension Layout.Flow {
    /// Create a flow layout with default alignments.
    @inlinable
    public init(
        spacing: consuming Gaps,
        content: consuming Content
    ) {
        self.init(
            spacing: spacing,
            alignment: .leading,
            line: .top,
            content: content
        )
    }
}

extension Layout.Flow where Spacing: AdditiveArithmetic {
    /// Create a flow layout with uniform spacing.
    @inlinable
    public static func uniform(
        spacing: Spacing,
        alignment: Horizontal.Alignment = .leading,
        content: Content
    ) -> Self {
        Self(
            spacing: .uniform(spacing),
            alignment: alignment,
            line: .top,
            content: content
        )
    }
}

// MARK: - Functorial Map

extension Layout.Flow {
    /// Create a flow by transforming the spacing of another flow.
    @inlinable
    public init<U, E: Error>(
        transforming other: borrowing Layout<U>.Flow<Content>,
        spacing transform: (U) throws(E) -> Spacing
    ) throws(E) {
        self.init(
            spacing: Gaps(
                item: try transform(other.spacing.item),
                line: try transform(other.spacing.line)
            ),
            alignment: other.alignment,
            line: Line(alignment: other.line.alignment),
            content: other.content
        )
    }
}

extension Layout.Flow {
    /// Namespace for functorial map operations.
    @inlinable
    public var map: Map { Map(flow: self) }

    /// Functorial map operations for Flow.
    public struct Map {
        @usableFromInline
        let flow: Layout<Spacing>.Flow<Content>

        @usableFromInline
        init(flow: Layout<Spacing>.Flow<Content>) {
            self.flow = flow
        }

        /// Transform the spacing using the given closure.
        @inlinable
        public func spacing<Result, E: Error>(
            _ transform: (Spacing) throws(E) -> Result
        ) throws(E) -> Layout<Result>.Flow<Content> {
            Layout<Result>.Flow<Content>(
                spacing: Layout<Result>.Flow<Content>.Gaps(
                    item: try transform(flow.spacing.item),
                    line: try transform(flow.spacing.line)
                ),
                alignment: flow.alignment,
                line: Layout<Result>.Flow<Content>.Line(alignment: flow.line.alignment),
                content: flow.content
            )
        }

        /// Transform the content using the given closure.
        @inlinable
        public func content<Result, E: Error>(
            _ transform: (Content) throws(E) -> Result
        ) throws(E) -> Layout<Spacing>.Flow<Result> {
            Layout<Spacing>.Flow<Result>(
                spacing: Layout<Spacing>.Flow<Result>.Gaps(
                    item: flow.spacing.item,
                    line: flow.spacing.line
                ),
                alignment: flow.alignment,
                line: Layout<Spacing>.Flow<Result>.Line(alignment: flow.line.alignment),
                content: try transform(flow.content)
            )
        }
    }
}
