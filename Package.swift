// swift-tools-version: 5.8.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

#if TUIST
    import ProjectDescription

    let packageSettings = PackageSettings(
        baseSettings: .settings(base: ["SWIFT_STRICT_CONCURRENCY": "complete"])
    )
#endif

let package = Package(
    name: "FileSystem",
    platforms: [.macOS("12.0")],
    products: [
        .library(
            name: "FileSystem",
            type: .static,
            targets: ["FileSystem"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/tuist/Path", .upToNextMajor(from: "0.3.8")),
        .package(url: "https://github.com/apple/swift-nio", .upToNextMajor(from: "2.76.0")),
        .package(url: "https://github.com/apple/swift-log", .upToNextMajor(from: "1.6.1")),
        .package(url: "https://github.com/weichsel/ZIPFoundation", .upToNextMajor(from: "0.9.19")),
        // We're depending on a fork until the following PR is merged: https://github.com/davbeck/swift-glob/pull/14
        .package(url: "https://github.com/tuist/swift-glob", .upToNextMajor(from: "0.2.2")),
    ],
    targets: [
        .target(
            name: "FileSystem",
            dependencies: [
                .product(name: "_NIOFileSystem", package: "swift-nio"),
                .product(name: "Path", package: "Path"),
                .product(name: "Glob", package: "swift-glob"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "ZIPFoundation", package: "ZIPFoundation"),
            ],
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
    ]
)
