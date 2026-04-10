// swift-tools-version: 6.2

import PackageDescription

// INCITS 4-1986 (R2022): Coded Character Sets - 7-Bit American Standard Code for Information Interchange
//
// Implements US-ASCII character set standard
// - Current designation: INCITS 4-1986 (Reaffirmed 2022)
// - Historical names: ANSI X3.4-1986, ANSI X3.4-1968, ASA X3.4-1963
// - IANA charset: US-ASCII
//
// This is a pure Swift implementation with no Foundation dependencies,
// suitable for Swift Embedded and constrained environments.

let package = Package(
    name: "swift-incits-4-1986",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
        .tvOS(.v16),
        .watchOS(.v9),
    ],
    products: [
        .library(
            name: "INCITS 4 1986",
            targets: ["INCITS 4 1986"]
        ),
    ],
    dependencies: [
        .package(path: "../swift-standards"),
    ],
    targets: [
        .target(
            name: "INCITS 4 1986",
            dependencies: [
                .product(name: "Standards", package: "swift-standards"),
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
    target.swiftSettings = existing + [
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
    ]
}
