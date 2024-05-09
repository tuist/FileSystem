// swift-tools-version: 5.8.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

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
        .package(url: "https://github.com/tuist/Path", .upToNextMajor(from: "0.2.0")),
        .package(url: "https://github.com/apple/swift-nio", .upToNextMajor(from: "2.65.0")),
        .package(url: "https://github.com/apple/swift-log", .upToNextMajor(from: "1.5.4")),
    ],
    targets: [
        .target(
            name: "FileSystem",
            dependencies: [
                .product(name: "_NIOFileSystem", package: "swift-nio"),
                .product(name: "Path", package: "Path"),
                .product(name: "Logging", package: "swift-log"),
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
