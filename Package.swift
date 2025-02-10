// swift-tools-version: 5.8.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

@preconcurrency import PackageDescription

#if TUIST
    import ProjectDescription

    let packageSettings = PackageSettings(
        baseSettings: .settings(base: ["SWIFT_STRICT_CONCURRENCY": "complete"])
    )
#endif

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
    ],
    dependencies: [
        .package(url: "https://github.com/tuist/Path", .upToNextMajor(from: "0.3.8")),
        .package(url: "https://github.com/apple/swift-nio", .upToNextMajor(from: "2.81.0")),
        .package(url: "https://github.com/apple/swift-log", .upToNextMajor(from: "1.6.2")),
        .package(url: "https://github.com/tuist/ZIPFoundation", .upToNextMajor(from: "0.9.20")),
    ],
    targets: [
        .target(
            name: "FileSystem",
            dependencies: [
                "Glob",
                .product(name: "_NIOFileSystem", package: "swift-nio"),
                .product(name: "Path", package: "Path"),
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
