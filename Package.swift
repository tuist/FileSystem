// swift-tools-version: 5.8.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

@preconcurrency import PackageDescription

let package = Package(
    name: "FileSystem",
    platforms: [
        .macOS("13.0"),
        .iOS("16.0"),
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
        .package(url: "https://github.com/tuist/Path", .upToNextMajor(from: "0.3.8")),
        .package(url: "https://github.com/apple/swift-log", .upToNextMajor(from: "1.8.0")),
        .package(url: "https://github.com/tuist/ZIPFoundation", .upToNextMajor(from: "0.9.20")),
        .package(url: "https://github.com/apple/swift-nio", .upToNextMajor(from: "2.92.0")),
    ],
    targets: [
        .target(
            name: "FileSystem",
            dependencies: [
                "Glob",
                .product(name: "Path", package: "Path"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "ZIPFoundation", package: "ZIPFoundation", condition: .when(platforms: [.macOS, .iOS, .tvOS, .watchOS, .linux])),
                .product(name: "_NIOFileSystem", package: "swift-nio", condition: .when(platforms: [.macOS, .iOS, .tvOS, .watchOS, .linux])),
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
            name: "Glob",
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency"),
            ]
        ),
        .testTarget(
            name: "GlobTests",
            dependencies: [
                "Glob",
            ]
        ),
    ]
)
