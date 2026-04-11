// swift-tools-version: 5.8.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

@preconcurrency import PackageDescription

struct SystemAvailability {
    var name: String
    var version: String
    var osAvailability: String
    var sourceAvailability: String

    init(
        _ version: String,
        _ osAvailability: String
    ) {
        name = "System"
        self.version = version
        self.osAvailability = osAvailability
        sourceAvailability = "macOS 10.10, iOS 8.0, watchOS 2.0, tvOS 9.0"
    }

    var swiftSetting: SwiftSetting {
        #if SYSTEM_ABI_STABLE
            let availability = osAvailability
        #else
            let availability = sourceAvailability
        #endif
        return .enableExperimentalFeature(
            "AvailabilityMacro=\(name) \(version):\(availability)"
        )
    }
}

let swiftSystemAvailability: [SwiftSetting] = [
    SystemAvailability("0.0.1", "macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0").swiftSetting,
    SystemAvailability("0.0.2", "macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0").swiftSetting,
    SystemAvailability("0.0.3", "macOS 12.3, iOS 15.4, watchOS 8.5, tvOS 15.4").swiftSetting,
    SystemAvailability("1.1.0", "macOS 12.3, iOS 15.4, watchOS 8.5, tvOS 15.4").swiftSetting,
    SystemAvailability("1.1.1", "macOS 14.4, iOS 17.4, watchOS 10.4, tvOS 17.4").swiftSetting,
    SystemAvailability("1.2.0", "macOS 14.4, iOS 17.4, watchOS 10.4, tvOS 17.4").swiftSetting,
    SystemAvailability("1.2.1", "macOS 14.4, iOS 17.4, watchOS 10.4, tvOS 17.4").swiftSetting,
    SystemAvailability("1.3.0", "macOS 14.4, iOS 17.4, watchOS 10.4, tvOS 17.4").swiftSetting,
    SystemAvailability("1.3.1", "macOS 14.4, iOS 17.4, watchOS 10.4, tvOS 17.4").swiftSetting,
    SystemAvailability("1.3.2", "macOS 14.4, iOS 17.4, watchOS 10.4, tvOS 17.4").swiftSetting,
    SystemAvailability("1.4.0", "macOS 14.4, iOS 17.4, watchOS 10.4, tvOS 17.4").swiftSetting,
    SystemAvailability("1.4.1", "macOS 9999, iOS 9999, watchOS 9999, tvOS 9999").swiftSetting,
    SystemAvailability("1.4.2", "macOS 9999, iOS 9999, watchOS 9999, tvOS 9999").swiftSetting,
    SystemAvailability("1.5.0", "macOS 9999, iOS 9999, watchOS 9999, tvOS 9999").swiftSetting,
    SystemAvailability("1.6.0", "macOS 9999, iOS 9999, watchOS 9999, tvOS 9999").swiftSetting,
    SystemAvailability("1.6.1", "macOS 9999, iOS 9999, watchOS 9999, tvOS 9999").swiftSetting,
]

#if SYSTEM_CI
    let swiftSystemCI: [SwiftSetting] = [
        .unsafeFlags(["-require-explicit-availability=error"]),
    ]
#else
    let swiftSystemCI: [SwiftSetting] = []
#endif

let swiftSystemSwiftSettings = swiftSystemAvailability + swiftSystemCI + [
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
    .unsafeFlags(["-package-name", "swift_file_system_vendor"]),
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
            path: "Vendor/swift-system/Sources/CSystem",
            exclude: ["CMakeLists.txt"],
            cSettings: swiftSystemCSettings
        ),
        .target(
            name: "VendoredSystemPackage",
            dependencies: ["VendoredCSystem"],
            path: "Vendor/swift-system/Sources/System",
            exclude: swiftSystemExcludedFiles,
            cSettings: swiftSystemCSettings,
            swiftSettings: swiftSystemSwiftSettings
        ),
        .target(
            name: "StandardLibraryExtensions",
            path: "Vendor/swift-standards/Sources/StandardLibraryExtensions",
            swiftSettings: vendoredSwiftSettings
        ),
        .target(
            name: "Formatting",
            dependencies: ["StandardLibraryExtensions"],
            path: "Vendor/swift-standards/Sources/Formatting",
            swiftSettings: vendoredSwiftSettings
        ),
        .target(
            name: "StandardTime",
            dependencies: ["StandardLibraryExtensions"],
            path: "Vendor/swift-standards/Sources/StandardTime",
            swiftSettings: vendoredSwiftSettings
        ),
        .target(
            name: "Locale",
            dependencies: ["StandardLibraryExtensions"],
            path: "Vendor/swift-standards/Sources/Locale",
            swiftSettings: vendoredSwiftSettings
        ),
        .target(
            name: "Algebra",
            path: "Vendor/swift-standards/Sources/Algebra",
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
            path: "Vendor/swift-standards/Sources/Binary",
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
            path: "Vendor/swift-standards/Sources/Standards",
            swiftSettings: vendoredSwiftSettings
        ),
        .target(
            name: "INCITS 4 1986",
            dependencies: ["Standards"],
            path: "Vendor/swift-incits-4-1986/Sources/INCITS_4_1986",
            swiftSettings: vendoredSwiftSettings
        ),
        .target(
            name: "RFC 4648",
            dependencies: [
                "Standards",
                "INCITS 4 1986",
            ],
            path: "Vendor/swift-rfc-4648/Sources/RFC 4648",
            swiftSettings: vendoredSwiftSettings
        ),
        .target(
            name: "CFileSystemShims",
            path: "Vendor/swift-file-system/Sources/CFileSystemShims",
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
            path: "Vendor/swift-file-system/Sources/File System Primitives",
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
