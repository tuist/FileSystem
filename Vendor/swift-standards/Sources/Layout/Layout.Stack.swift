// Layout.Stack.swift
// A sequential arrangement of content along an axis.

public import Dimension
import Geometry

extension Layout {
    /// A sequential arrangement of content along an axis.
    ///
    /// Stack arranges its content sequentially along either the primary (horizontal)
    /// or secondary (vertical) axis. The cross-axis alignment determines how
    /// items are positioned perpendicular to the main axis.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let vstack: Layout<Double>.Stack<[Element]> = .vertical(
    ///     spacing: 10.0,
    ///     alignment: .leading,
    ///     content: elements
    /// )
    ///
    /// let hstack: Layout<Double>.Stack<[Element]> = .horizontal(
    ///     spacing: 8.0,
    ///     alignment: .center,
    ///     content: elements
    /// )
    /// ```
    public struct Stack<Content> {
        /// The axis along which content is arranged.
        ///
        /// - `.primary`: Horizontal arrangement (left to right)
        /// - `.secondary`: Vertical arrangement (top to bottom)
        public var axis: Axis<2>

        /// The spacing between adjacent items.
        public var spacing: Spacing

        /// The alignment along the cross axis.
        ///
        /// For a horizontal stack, this controls vertical alignment.
        /// For a vertical stack, this controls horizontal alignment.
        public var alignment: Cross.Alignment

        /// The content to arrange.
        public var content: Content

        /// Create a stack with the given configuration.
        @inlinable
        public init(
            axis: consuming Axis<2>,
            spacing: consuming Spacing,
            alignment: consuming Cross.Alignment,
            content: consuming Content
        ) {
            self.axis = axis
            self.spacing = spacing
            self.alignment = alignment
            self.content = content
        }
    }
}

// MARK: - Sendable

extension Layout.Stack: Sendable where Spacing: Sendable, Content: Sendable {}

// MARK: - Equatable

extension Layout.Stack: Equatable where Spacing: Equatable, Content: Equatable {}

// MARK: - Hashable

extension Layout.Stack: Hashable where Spacing: Hashable, Content: Hashable {}

// MARK: - Codable

extension Layout.Stack: Codable where Spacing: Codable, Content: Codable {}

// MARK: - Convenience Initializers

extension Layout.Stack {
    /// Create a vertical stack (items arranged top to bottom).
    @inlinable
    public static func vertical(
        spacing: Spacing,
        alignment: Cross.Alignment = .center,
        content: Content
    ) -> Self {
        Self(axis: .secondary, spacing: spacing, alignment: alignment, content: content)
    }

    /// Create a horizontal stack (items arranged leading to trailing).
    @inlinable
    public static func horizontal(
        spacing: Spacing,
        alignment: Cross.Alignment = .center,
        content: Content
    ) -> Self {
        Self(axis: .primary, spacing: spacing, alignment: alignment, content: content)
    }
}

// MARK: - Functorial Map

extension Layout.Stack {
    /// Create a stack by transforming the spacing of another stack.
    @inlinable
    public init<U, E: Error>(
        transforming other: borrowing Layout<U>.Stack<Content>,
        spacing transform: (U) throws(E) -> Spacing
    ) throws(E) {
        self.init(
            axis: other.axis,
            spacing: try transform(other.spacing),
            alignment: other.alignment,
            content: other.content
        )
    }
}

extension Layout.Stack {
    /// Namespace for functorial map operations.
    @inlinable
    public var map: Map { Map(stack: self) }

    /// Functorial map operations for Stack.
    public struct Map {
        @usableFromInline
        let stack: Layout<Spacing>.Stack<Content>

        @usableFromInline
        init(stack: Layout<Spacing>.Stack<Content>) {
            self.stack = stack
        }

        /// Transform the spacing using the given closure.
        @inlinable
        public func spacing<Result, E: Error>(
            _ transform: (Spacing) throws(E) -> Result
        ) throws(E) -> Layout<Result>.Stack<Content> {
            Layout<Result>.Stack<Content>(
                axis: stack.axis,
                spacing: try transform(stack.spacing),
                alignment: stack.alignment,
                content: stack.content
            )
        }

        /// Transform the content using the given closure.
        @inlinable
        public func content<Result, E: Error>(
            _ transform: (Content) throws(E) -> Result
        ) throws(E) -> Layout<Spacing>.Stack<Result> {
            Layout<Spacing>.Stack<Result>(
                axis: stack.axis,
                spacing: stack.spacing,
                alignment: stack.alignment,
                content: try transform(stack.content)
            )
        }
    }
}
