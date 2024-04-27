import ProjectDescription

let project = Project(name: "FileSystem", targets: [
    .target(
        name: "FileSystem",
        destinations: .macOS,
        product: .staticFramework,
        bundleId: "io.tuist.FileSystem",
        deploymentTargets: .macOS("13.0"),
        sources: [
            "Sources/FileSystem/**/*.swift",
        ],
        dependencies: [
            .external(name: "Logging"),
            .external(name: "Path"),
        ],
        settings: .settings(configurations: [
            .debug(name: .debug, settings: ["SWIFT_ACTIVE_COMPILATION_CONDITIONS": "$(inherited) MOCKING"]),
            .release(name: .release, settings: [:]),
        ])
    ),
    .target(
        name: "FileSystemTests",
        destinations: .macOS,
        product: .unitTests,
        bundleId: "io.tuist.FileSystemTests",
        deploymentTargets: .macOS("13.0"),
        sources: [
            "Tests/FileSystemTests/**/*.swift",
        ],
        dependencies: [
            .target(name: "FileSystem"),
        ]
    ),
])
