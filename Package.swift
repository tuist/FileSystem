// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

#if os(Windows)
    let zipFoundationDependency: [Package.Dependency] = []
    let zipFoundationTarget: [Target.Dependency] = []
#else
    let zipFoundationDependency: [Package.Dependency] = [
        .package(url: "https://github.com/tuist/ZIPFoundation", .upToNextMajor(from: "0.9.20")),
    ]
    let zipFoundationTarget: [Target.Dependency] = [
        .product(name: "ZIPFoundation", package: "ZIPFoundation"),
    ]
#endif

let package = Package(
    name: "FileSystem",
    platforms: [
        .macOS("26.0"),
        .iOS("26.0"),
    ],
    products: [
        .library(
            name: "FileSystem",
            type: .static,
            targets: ["FileSystem"]
        ),
        .library(
            name: "FileSystemTesting",
            type: .static,
            targets: ["FileSystemTesting"]
        ),
        .library(
            name: "Glob",
            type: .static,
            targets: ["Glob"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/coenttb/swift-file-system", .upToNextMajor(from: "0.6.0")),
        .package(url: "https://github.com/tuist/Path", .upToNextMajor(from: "0.3.8")),
        .package(url: "https://github.com/apple/swift-log", .upToNextMajor(from: "1.10.1")),
    ] + zipFoundationDependency,
    targets: [
        .target(
            name: "FileSystem",
            dependencies: [
                "Glob",
                .product(name: "File System", package: "swift-file-system"),
                .product(name: "Path", package: "Path"),
                .product(name: "Logging", package: "swift-log"),
            ] + zipFoundationTarget,
            swiftSettings: [
                .define("MOCKING", .when(configuration: .debug)),
            ]
        ),
        .testTarget(
            name: "FileSystemTests",
            dependencies: [
                "FileSystem",
            ]
        ),
        .target(
            name: "FileSystemTesting",
            dependencies: [
                "FileSystem",
            ]
        ),
        .testTarget(
            name: "FileSystemTestingTests",
            dependencies: [
                "FileSystem",
                "FileSystemTesting",
            ]
        ),
        .target(
            name: "Glob"
        ),
        .testTarget(
            name: "GlobTests",
            dependencies: [
                "Glob",
            ]
        ),
    ]
)
