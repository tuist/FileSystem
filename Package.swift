// swift-tools-version: 5.8.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

@preconcurrency import PackageDescription

#if os(Windows)
    let zipFoundationDependency: [Package.Dependency] = []
    let zipFoundationTarget: [Target.Dependency] = []
    let swiftNioDependency: [Package.Dependency] = []
    let swiftNioTarget: [Target.Dependency] = []
#else
    let zipFoundationDependency: [Package.Dependency] = [
        .package(url: "https://github.com/tuist/ZIPFoundation", .upToNextMajor(from: "0.9.20")),
    ]
    let zipFoundationTarget: [Target.Dependency] = [
        .product(name: "ZIPFoundation", package: "ZIPFoundation"),
    ]
    let swiftNioDependency: [Package.Dependency] = [
        .package(url: "https://github.com/apple/swift-nio", .upToNextMajor(from: "2.92.0")),
    ]
    let swiftNioTarget: [Target.Dependency] = [
        .product(name: "_NIOFileSystem", package: "swift-nio"),
    ]
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
        .package(url: "https://github.com/apple/swift-log", .upToNextMajor(from: "1.9.1")),
    ] + zipFoundationDependency + swiftNioDependency,
    targets: [
        .target(
            name: "FileSystem",
            dependencies: [
                "Glob",
                .product(name: "Path", package: "Path"),
                .product(name: "Logging", package: "swift-log"),
            ] + zipFoundationTarget + swiftNioTarget,
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
