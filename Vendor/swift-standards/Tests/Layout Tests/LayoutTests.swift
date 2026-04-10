// LayoutTests.swift

import Testing

@testable import Dimension
@testable import Geometry
@testable import Layout
@testable import Positioning

// MARK: - Test Spacing Type

/// A custom spacing type for testing
struct TestSpacing: AdditiveArithmetic, Comparable, Codable, Hashable,
    ExpressibleByIntegerLiteral, ExpressibleByFloatLiteral
{
    let value: Double

    init(_ value: Double) {
        self.value = value
    }

    init(integerLiteral value: Int) {
        self.value = Double(value)
    }

    init(floatLiteral value: Double) {
        self.value = value
    }

    static var zero: TestSpacing { TestSpacing(0) }

    static func + (lhs: TestSpacing, rhs: TestSpacing) -> TestSpacing {
        TestSpacing(lhs.value + rhs.value)
    }

    static func - (lhs: TestSpacing, rhs: TestSpacing) -> TestSpacing {
        TestSpacing(lhs.value - rhs.value)
    }

    static func < (lhs: TestSpacing, rhs: TestSpacing) -> Bool {
        lhs.value < rhs.value
    }
}

// MARK: - Horizontal Alignment Tests

@Suite
struct HorizontalAlignmentTests {
    @Test
    func `Horizontal Alignment cases`() {
        let leading: Horizontal.Alignment = .leading
        let center: Horizontal.Alignment = .center
        let trailing: Horizontal.Alignment = .trailing

        #expect(leading != center)
        #expect(center != trailing)
        #expect(leading != trailing)
    }

    @Test
    func `Horizontal Alignment CaseIterable`() {
        #expect(Horizontal.Alignment.allCases.count == 3)
    }

    @Test
    func `Horizontal Alignment Hashable`() {
        let set: Set<Horizontal.Alignment> = [.leading, .center, .trailing, .leading]
        #expect(set.count == 3)
    }
}

// MARK: - Vertical Alignment Tests

@Suite
struct VerticalAlignmentTests {
    @Test
    func `Vertical Alignment cases`() {
        let top: Vertical.Alignment = .top
        let center: Vertical.Alignment = .center
        let bottom: Vertical.Alignment = .bottom
        let first: Vertical.Alignment = .firstBaseline
        let last: Vertical.Alignment = .lastBaseline

        #expect(top != center)
        #expect(center != bottom)
        #expect(first != last)
    }

    @Test
    func `Vertical Alignment CaseIterable`() {
        #expect(Vertical.Alignment.allCases.count == 5)
    }
}

// MARK: - Alignment Tests

@Suite
struct AlignmentTests {
    @Test
    func `Alignment presets`() {
        let topLeading: Alignment = .topLeading
        #expect(topLeading.horizontal == .leading)
        #expect(topLeading.vertical == .top)

        let center: Alignment = .center
        #expect(center.horizontal == .center)
        #expect(center.vertical == .center)

        let bottomTrailing: Alignment = .bottomTrailing
        #expect(bottomTrailing.horizontal == .trailing)
        #expect(bottomTrailing.vertical == .bottom)
    }

    @Test
    func `Alignment custom`() {
        let custom: Alignment = .init(horizontal: .trailing, vertical: .top)
        #expect(custom.horizontal == .trailing)
        #expect(custom.vertical == .top)
    }

    @Test
    func `Alignment Equatable`() {
        let a: Alignment = .center
        let b: Alignment = .init(horizontal: .center, vertical: .center)
        #expect(a == b)
    }
}

// MARK: - Distribution Tests

@Suite
struct DistributionTests {
    @Test
    func `Distribution cases`() {
        let fill: Distribution = .fill
        let between: Distribution = .spaceBetween
        let around: Distribution = .spaceAround
        let evenly: Distribution = .spaceEvenly

        #expect(fill != between)
        #expect(around != evenly)
    }

    @Test
    func `Distribution CaseIterable`() {
        #expect(Distribution.allCases.count == 4)
    }
}

// MARK: - Cross Alignment Tests

@Suite
struct CrossAlignmentTests {
    @Test
    func `Cross Alignment cases`() {
        let leading: Cross.Alignment = .leading
        let center: Cross.Alignment = .center
        let trailing: Cross.Alignment = .trailing
        let fill: Cross.Alignment = .fill

        #expect(leading != center)
        #expect(trailing != fill)
    }

    @Test
    func `Cross Alignment CaseIterable`() {
        #expect(Cross.Alignment.allCases.count == 4)
    }
}

// MARK: - Stack Tests

@Suite
struct StackTests {
    @Test
    func `Stack vertical convenience`() {
        let stack: Layout<Double>.Stack<[Int]> = .vertical(
            spacing: 10.0,
            alignment: .leading,
            content: [1, 2, 3]
        )

        #expect(stack.axis == .secondary)
        #expect(stack.spacing == 10.0)
        #expect(stack.alignment == .leading)
        #expect(stack.content == [1, 2, 3])
    }

    @Test
    func `Stack horizontal convenience`() {
        let stack: Layout<Double>.Stack<[Int]> = .horizontal(
            spacing: 8.0,
            alignment: .center,
            content: [1, 2, 3]
        )

        #expect(stack.axis == .primary)
        #expect(stack.spacing == 8.0)
        #expect(stack.alignment == .center)
    }

    @Test
    func `Stack default alignment`() {
        let stack: Layout<Double>.Stack<[Int]> = .vertical(
            spacing: 10.0,
            content: [1, 2, 3]
        )

        #expect(stack.alignment == .center)
    }

    @Test
    func `Stack with custom spacing type`() {
        let stack: Layout<TestSpacing>.Stack<[String]> = .vertical(
            spacing: TestSpacing(10),
            alignment: .trailing,
            content: ["a", "b", "c"]
        )

        #expect(stack.spacing == TestSpacing(10))
    }

    @Test
    func `Stack Equatable`() {
        let a: Layout<Double>.Stack<[Int]> = .vertical(spacing: 10, content: [1, 2])
        let b: Layout<Double>.Stack<[Int]> = .vertical(spacing: 10, content: [1, 2])
        let c: Layout<Double>.Stack<[Int]> = .vertical(spacing: 20, content: [1, 2])

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func `Stack map spacing`() throws {
        let stack: Layout<Double>.Stack<[Int]> = .vertical(
            spacing: 10.0,
            content: [1, 2, 3]
        )

        let mapped: Layout<TestSpacing>.Stack<[Int]> = try stack.map.spacing { TestSpacing($0) }
        #expect(mapped.spacing == TestSpacing(10))
        #expect(mapped.content == [1, 2, 3])
    }

    @Test
    func `Stack map content`() throws {
        let stack: Layout<Double>.Stack<[Int]> = .vertical(
            spacing: 10.0,
            content: [1, 2, 3]
        )

        let mapped: Layout<Double>.Stack<[String]> = try stack.map.content { $0.map { String($0) } }
        #expect(mapped.content == ["1", "2", "3"])
        #expect(mapped.spacing == 10.0)
    }
}

// MARK: - Grid Tests

@Suite
struct GridTests {
    @Test
    func `Grid basic creation`() {
        let grid: Layout<Double>.Grid<[[Int]]> = .init(
            spacing: .init(row: 10.0, column: 8.0),
            alignment: .center,
            content: [[1, 2], [3, 4]]
        )

        #expect(grid.spacing.row == 10.0)
        #expect(grid.spacing.column == 8.0)
        #expect(grid.alignment == .center)
    }

    @Test
    func `Grid uniform convenience`() {
        let grid: Layout<Double>.Grid<[[Int]]> = .uniform(
            spacing: 10.0,
            content: [[1, 2], [3, 4]]
        )

        #expect(grid.spacing.row == 10.0)
        #expect(grid.spacing.column == 10.0)
    }

    @Test
    func `Grid default alignment`() {
        let grid: Layout<Double>.Grid<[[Int]]> = .init(
            spacing: .init(row: 10.0, column: 8.0),
            content: [[1, 2], [3, 4]]
        )

        #expect(grid.alignment == .center)
    }

    @Test
    func `Grid Equatable`() {
        let a: Layout<Double>.Grid<[[Int]]> = .uniform(spacing: 10, content: [[1, 2]])
        let b: Layout<Double>.Grid<[[Int]]> = .uniform(spacing: 10, content: [[1, 2]])
        let c: Layout<Double>.Grid<[[Int]]> = .uniform(spacing: 20, content: [[1, 2]])

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func `Grid map spacing`() throws {
        let grid: Layout<Double>.Grid<[[Int]]> = .uniform(spacing: 10, content: [[1, 2]])

        let mapped: Layout<TestSpacing>.Grid<[[Int]]> = try grid.map.spacing { TestSpacing($0) }
        #expect(mapped.spacing.row == TestSpacing(10))
        #expect(mapped.spacing.column == TestSpacing(10))
    }
}

// MARK: - Flow Tests

@Suite
struct FlowTests {
    @Test
    func `Flow basic creation`() {
        let flow: Layout<Double>.Flow<[String]> = .init(
            spacing: .init(item: 8.0, line: 12.0),
            alignment: .leading,
            line: .top,
            content: ["a", "b", "c"]
        )

        #expect(flow.spacing.item == 8.0)
        #expect(flow.spacing.line == 12.0)
        #expect(flow.alignment == .leading)
        #expect(flow.line.alignment == .top)
    }

    @Test
    func `Flow default alignments`() {
        let flow: Layout<Double>.Flow<[String]> = .init(
            spacing: .init(item: 8.0, line: 12.0),
            content: ["a", "b", "c"]
        )

        #expect(flow.alignment == .leading)
        #expect(flow.line.alignment == .top)
    }

    @Test
    func `Flow uniform convenience`() {
        let flow: Layout<Double>.Flow<[String]> = .uniform(
            spacing: 10.0,
            content: ["a", "b", "c"]
        )

        #expect(flow.spacing.item == 10.0)
        #expect(flow.spacing.line == 10.0)
    }

    @Test
    func `Flow Equatable`() {
        let a: Layout<Double>.Flow<[String]> = .uniform(spacing: 10, content: ["a"])
        let b: Layout<Double>.Flow<[String]> = .uniform(spacing: 10, content: ["a"])
        let c: Layout<Double>.Flow<[String]> = .uniform(spacing: 20, content: ["a"])

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func `Flow map spacing`() throws {
        let flow: Layout<Double>.Flow<[String]> = .uniform(spacing: 10, content: ["a"])

        let mapped: Layout<TestSpacing>.Flow<[String]> = try flow.map.spacing { TestSpacing($0) }
        #expect(mapped.spacing.item == TestSpacing(10))
        #expect(mapped.spacing.line == TestSpacing(10))
    }
}

// MARK: - Protocol Conformance Tests

@Suite
struct LayoutProtocolConformanceTests {
    @Test
    func `Stack is Sendable`() {
        let stack: Layout<Double>.Stack<[Int]> = .vertical(spacing: 10, content: [1, 2])
        let _: any Sendable = stack
    }

    @Test
    func `Grid is Sendable`() {
        let grid: Layout<Double>.Grid<[[Int]]> = .uniform(spacing: 10, content: [[1, 2]])
        let _: any Sendable = grid
    }

    @Test
    func `Flow is Sendable`() {
        let flow: Layout<Double>.Flow<[String]> = .uniform(spacing: 10, content: ["a"])
        let _: any Sendable = flow
    }

    @Test
    func `Stack is Hashable`() {
        let stack: Layout<Double>.Stack<[Int]> = .vertical(spacing: 10, content: [1, 2])
        var set = Set<Layout<Double>.Stack<[Int]>>()
        set.insert(stack)
        #expect(set.count == 1)
    }
}
