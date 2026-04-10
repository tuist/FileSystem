// swift-tools-version: 6.2

import PackageDescription

// Swift Embedded compatible:
// - No Foundation dependencies
// - No existential types (any Protocol)
// - No reflection or runtime features
// - Pure Swift value types only

let package = Package(
    name: "swift-standards",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
        .tvOS(.v16),
        .watchOS(.v9),
    ],
    products: [
        .library(
            name: "Standards",
            targets: [
                "Standards",
                "StandardLibraryExtensions",
                "Formatting",
                "StandardTime",
                "Locale",
                "Algebra",
                "Binary",
            ]
        ),
        .library(
            name: "StandardLibraryExtensions",
            targets: ["StandardLibraryExtensions"]
        ),
        .library(
            name: "Formatting",
            targets: ["Formatting"]
        ),
        .library(
            name: "StandardTime",
            targets: ["StandardTime"]
        ),
        .library(
            name: "Locale",
            targets: ["Locale"]
        ),
        .library(
            name: "Algebra",
            targets: ["Algebra"]
        ),
        .library(
            name: "Binary",
            targets: ["Binary"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Standards",
            dependencies: [
                "StandardLibraryExtensions",
                "Formatting",
                "StandardTime",
                "Locale",
                "Algebra",
                "Binary",
            ]
        ),
        .target(
            name: "StandardLibraryExtensions"
        ),
        .target(
            name: "Formatting",
            dependencies: [
                "StandardLibraryExtensions"
            ]
        ),
        .target(
            name: "StandardTime",
            dependencies: [
                "StandardLibraryExtensions"
            ]
        ),
        .target(
            name: "Locale",
            dependencies: [
                "StandardLibraryExtensions"
            ]
        ),
        .target(
            name: "Algebra",
            exclude: [
                "Bool+XOR.swift",
                "Bound.swift",
                "Boundary.swift",
                "Comparison.swift",
                "Enumerable.swift",
                "Enumeration.swift",
                "Endpoint.swift",
                "Gradient.swift",
                "Monotonicity.swift",
                "Ordinal.swift",
                "Parity.swift",
                "Phase.swift",
                "Polarity.swift",
                "Sign.swift",
                "Ternary.swift",
            ],
            sources: [
                "Algebra.swift",
                "Bit.swift",
                "Tagged.swift",
            ]
        ),
        .target(
            name: "Binary",
            dependencies: [
                "Algebra",
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

extension String {
    var tests: Self { self + " Tests" }
    var foundation: Self { self + " Foundation" }
}

for target in package.targets where ![.system, .binary, .plugin].contains(target.type) {
    let existing = target.swiftSettings ?? []
    target.swiftSettings =
        existing + [
            .enableUpcomingFeature("ExistentialAny"),
            .enableUpcomingFeature("InternalImportsByDefault"),
            .enableUpcomingFeature("MemberImportVisibility"),
        ]
}
