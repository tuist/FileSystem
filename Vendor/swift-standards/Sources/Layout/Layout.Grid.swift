// Layout.Grid.swift
// A two-dimensional arrangement of content in rows and columns.

extension Layout {
    /// A two-dimensional arrangement of content in rows and columns.
    ///
    /// Grid arranges content in a regular 2D structure with specified
    /// row and column spacing. Each cell can have its own alignment.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let grid: Layout<Double>.Grid<[[Element]]> = .init(
    ///     spacing: .init(row: 10.0, column: 8.0),
    ///     alignment: .center,
    ///     content: rows
    /// )
    /// ```
    public struct Grid<Content> {
        /// The spacing between rows and columns.
        public var spacing: Gaps

        /// Alignment within each cell.
        public var alignment: Alignment

        /// The grid content (typically `[[Element]]` or similar 2D structure).
        public var content: Content

        /// Create a grid with the given configuration.
        @inlinable
        public init(
            spacing: consuming Gaps,
            alignment: consuming Alignment,
            content: consuming Content
        ) {
            self.spacing = spacing
            self.alignment = alignment
            self.content = content
        }
    }
}

// MARK: - Gaps

extension Layout.Grid {
    /// Spacing configuration for a grid.
    ///
    /// Defines the spacing between rows (vertical) and columns (horizontal).
    public struct Gaps {
        /// Spacing between rows (vertical spacing).
        public var row: Spacing

        /// Spacing between columns (horizontal spacing).
        public var column: Spacing

        /// Create spacing with the given row and column values.
        @inlinable
        public init(row: Spacing, column: Spacing) {
            self.row = row
            self.column = column
        }
    }
}

extension Layout.Grid.Gaps: Sendable where Spacing: Sendable {}
extension Layout.Grid.Gaps: Equatable where Spacing: Equatable {}
extension Layout.Grid.Gaps: Hashable where Spacing: Hashable {}
extension Layout.Grid.Gaps: Codable where Spacing: Codable {}

extension Layout.Grid.Gaps where Spacing: AdditiveArithmetic {
    /// Create uniform spacing (same for rows and columns).
    @inlinable
    public static func uniform(_ value: Spacing) -> Self {
        Self(row: value, column: value)
    }
}

// MARK: - Sendable

extension Layout.Grid: Sendable where Spacing: Sendable, Content: Sendable {}

// MARK: - Equatable

extension Layout.Grid: Equatable where Spacing: Equatable, Content: Equatable {}

// MARK: - Hashable

extension Layout.Grid: Hashable where Spacing: Hashable, Content: Hashable {}

// MARK: - Codable

extension Layout.Grid: Codable where Spacing: Codable, Content: Codable {}

// MARK: - Convenience Initializers

extension Layout.Grid {
    /// Create a grid with default center alignment.
    @inlinable
    public init(
        spacing: consuming Gaps,
        content: consuming Content
    ) {
        self.init(
            spacing: spacing,
            alignment: .center,
            content: content
        )
    }
}

extension Layout.Grid where Spacing: AdditiveArithmetic {
    /// Create a grid with uniform spacing in both directions.
    @inlinable
    public static func uniform(
        spacing: Spacing,
        alignment: Alignment = .center,
        content: Content
    ) -> Self {
        Self(
            spacing: .uniform(spacing),
            alignment: alignment,
            content: content
        )
    }
}

// MARK: - Functorial Map

extension Layout.Grid {
    /// Create a grid by transforming the spacing of another grid.
    @inlinable
    public init<U, E: Error>(
        transforming other: borrowing Layout<U>.Grid<Content>,
        spacing transform: (U) throws(E) -> Spacing
    ) throws(E) {
        self.init(
            spacing: Gaps(
                row: try transform(other.spacing.row),
                column: try transform(other.spacing.column)
            ),
            alignment: other.alignment,
            content: other.content
        )
    }
}

extension Layout.Grid {
    /// Namespace for functorial map operations.
    @inlinable
    public var map: Map { Map(grid: self) }

    /// Functorial map operations for Grid.
    public struct Map {
        @usableFromInline
        let grid: Layout<Spacing>.Grid<Content>

        @usableFromInline
        init(grid: Layout<Spacing>.Grid<Content>) {
            self.grid = grid
        }

        /// Transform the spacing using the given closure.
        @inlinable
        public func spacing<Result, E: Error>(
            _ transform: (Spacing) throws(E) -> Result
        ) throws(E) -> Layout<Result>.Grid<Content> {
            Layout<Result>.Grid<Content>(
                spacing: Layout<Result>.Grid<Content>.Gaps(
                    row: try transform(grid.spacing.row),
                    column: try transform(grid.spacing.column)
                ),
                alignment: grid.alignment,
                content: grid.content
            )
        }

        /// Transform the content using the given closure.
        @inlinable
        public func content<Result, E: Error>(
            _ transform: (Content) throws(E) -> Result
        ) throws(E) -> Layout<Spacing>.Grid<Result> {
            Layout<Spacing>.Grid<Result>(
                spacing: Layout<Spacing>.Grid<Result>.Gaps(
                    row: grid.spacing.row,
                    column: grid.spacing.column
                ),
                alignment: grid.alignment,
                content: try transform(grid.content)
            )
        }
    }
}
