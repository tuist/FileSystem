// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "swift-file-system",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
        .tvOS(.v16),
        .watchOS(.v9),
    ],
    products: [
        .library(name: "File System Primitives", targets: ["File System Primitives"]),
    ],
    dependencies: [
        .package(path: "../swift-system"),
        .package(path: "../swift-standards"),
        .package(path: "../swift-incits-4-1986"),
        .package(path: "../swift-rfc-4648"),
    ],
    targets: [
        .target(
            name: "CFileSystemShims",
            path: "Sources/CFileSystemShims",
            publicHeadersPath: "include"
        ),
        .target(
            name: "File System Primitives",
            dependencies: [
                "CFileSystemShims",
                .product(name: "SystemPackage", package: "swift-system"),
                .product(name: "Binary", package: "swift-standards"),
                .product(name: "StandardTime", package: "swift-standards"),
                .product(name: "INCITS 4 1986", package: "swift-incits-4-1986"),
                .product(name: "RFC 4648", package: "swift-rfc-4648"),
            ],
            path: "Sources/File System Primitives"
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin].contains(target.type) {
    let existing = target.swiftSettings ?? []
    target.swiftSettings = existing + [
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
    ]
}
