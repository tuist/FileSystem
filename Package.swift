// swift-tools-version: 5.8.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

@preconcurrency import PackageDescription

// swift-system source files use `@available(System X.Y.Z, *)` via the
// `AvailabilityMacro` experimental feature. Because we vendor the sources
// (not the ABI-stable OS version of `System`), every macro resolves to the
// original source-level availability, matching what swift-system itself does
// in non-ABI-stable builds.
let swiftSystemAvailability: [SwiftSetting] = [
    "0.0.1", "0.0.2", "1.1.0", "1.2.0", "1.4.0",
].map { version in
    .enableExperimentalFeature(
        "AvailabilityMacro=System \(version):macOS 10.10, iOS 8.0, watchOS 2.0, tvOS 9.0"
    )
}

let swiftSystemSwiftSettings: [SwiftSetting] = swiftSystemAvailability + [
    .define(
        "SYSTEM_PACKAGE_DARWIN",
        .when(platforms: [.macOS, .macCatalyst, .iOS, .watchOS, .tvOS])
    ),
    .define("SYSTEM_PACKAGE"),
    .define("ENABLE_MOCKING", .when(configuration: .debug)),
    .enableExperimentalFeature("Lifetimes"),
]

let swiftSystemCSettings: [CSetting] = [
    .define("_CRT_SECURE_NO_WARNINGS", .when(platforms: [.windows])),
]

let vendoredSwiftSettings: [SwiftSetting] = [
    .enableUpcomingFeature("ExistentialAny"),
    .enableUpcomingFeature("InternalImportsByDefault"),
    .enableUpcomingFeature("MemberImportVisibility"),
]

#if os(Linux)
    let swiftSystemExcludedFiles = ["CMakeLists.txt"]
#else
    let swiftSystemExcludedFiles = ["CMakeLists.txt", "IORing"]
#endif

#if os(Windows)
    let zipFoundationDependency: [Package.Dependency] = []
    let zipFoundationTarget: [Target.Dependency] = []
    let swiftNioDependency: [Package.Dependency] = []
    let swiftNioTarget: [Target.Dependency] = []
    let swiftFileSystemTarget: [Target.Dependency] = []
    let swiftFileSystemTargets: [Target] = []
#else
    let zipFoundationDependency: [Package.Dependency] = [
        .package(url: "https://github.com/tuist/ZIPFoundation", .upToNextMajor(from: "0.9.21")),
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
    let swiftFileSystemTarget: [Target.Dependency] = [
        "File System Primitives",
    ]
    let swiftFileSystemTargets: [Target] = [
        .target(
            name: "VendoredCSystem",
            dependencies: [],
            path: "Sources/CSystem",
            exclude: ["CMakeLists.txt"],
            cSettings: swiftSystemCSettings
        ),
        .target(
            name: "VendoredSystemPackage",
            dependencies: ["VendoredCSystem"],
            path: "Sources/System",
            exclude: swiftSystemExcludedFiles,
            cSettings: swiftSystemCSettings,
            swiftSettings: swiftSystemSwiftSettings
        ),
        .target(
            name: "StandardLibraryExtensions",
            path: "Sources/StandardLibraryExtensions",
            swiftSettings: vendoredSwiftSettings
        ),
        .target(
            name: "Formatting",
            dependencies: ["StandardLibraryExtensions"],
            path: "Sources/Formatting",
            swiftSettings: vendoredSwiftSettings
        ),
        .target(
            name: "StandardTime",
            dependencies: ["StandardLibraryExtensions"],
            path: "Sources/StandardTime",
            swiftSettings: vendoredSwiftSettings
        ),
        .target(
            name: "Locale",
            dependencies: ["StandardLibraryExtensions"],
            path: "Sources/Locale",
            swiftSettings: vendoredSwiftSettings
        ),
        .target(
            name: "Algebra",
            path: "Sources/Algebra",
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
            ],
            swiftSettings: vendoredSwiftSettings
        ),
        .target(
            name: "Binary",
            dependencies: ["Algebra"],
            path: "Sources/Binary",
            swiftSettings: vendoredSwiftSettings
        ),
        .target(
            name: "Standards",
            dependencies: [
                "StandardLibraryExtensions",
                "Formatting",
                "StandardTime",
                "Locale",
                "Algebra",
                "Binary",
            ],
            path: "Sources/Standards",
            swiftSettings: vendoredSwiftSettings
        ),
        .target(
            name: "INCITS 4 1986",
            dependencies: ["Standards"],
            path: "Sources/INCITS_4_1986",
            swiftSettings: vendoredSwiftSettings
        ),
        .target(
            name: "RFC 4648",
            dependencies: [
                "Standards",
                "INCITS 4 1986",
            ],
            path: "Sources/RFC 4648",
            swiftSettings: vendoredSwiftSettings
        ),
        .target(
            name: "CFileSystemShims",
            path: "Sources/CFileSystemShims",
            publicHeadersPath: "include"
        ),
        .target(
            name: "File System Primitives",
            dependencies: [
                "CFileSystemShims",
                "VendoredSystemPackage",
                "Binary",
                "StandardTime",
                "INCITS 4 1986",
                "RFC 4648",
            ],
            path: "Sources/File System Primitives",
            swiftSettings: vendoredSwiftSettings
        ),
    ]
#endif

let packageProducts: [Product] = [
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
]

let packageDependencies: [Package.Dependency] = [
    .package(url: "https://github.com/tuist/Path", .upToNextMajor(from: "0.3.8")),
    .package(url: "https://github.com/apple/swift-log", .upToNextMajor(from: "1.11.0")),
] + zipFoundationDependency + swiftNioDependency

let fileSystemTargetDependencies: [Target.Dependency] = [
    "Glob",
    .product(name: "Path", package: "Path"),
    .product(name: "Logging", package: "swift-log"),
] + zipFoundationTarget + swiftNioTarget + swiftFileSystemTarget

let packageTargets: [Target] = [
    .target(
        name: "FileSystem",
        dependencies: fileSystemTargetDependencies,
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
] + swiftFileSystemTargets

let package = Package(
    name: "FileSystem",
    platforms: [
        .macOS("13.0"),
        .iOS("16.0"),
    ],
    products: packageProducts,
    dependencies: packageDependencies,
    targets: packageTargets
)
