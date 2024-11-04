import ProjectDescription

let project = Project(
    name: "FileSystem",
    settings: .settings(base: ["SWIFT_STRICT_CONCURRENCY": "complete"]),
    targets: [
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
                .target(name: "Glob"),
                .external(name: "_NIOFileSystem"),
                .external(name: "Logging"),
                .external(name: "Path"),
                .external(name: "ZIPFoundation"),
            ],
            settings: .settings(
                base: ["GENERATE_MASTER_OBJECT_FILE": "YES", "OTHER_LDFLAGS": "$(inherited) -ObjC"],
                configurations: [
                    .debug(name: .debug, settings: [
                        "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "$(inherited) MOCKING",
                    ]),
                    .release(name: .release, settings: [:]),
                ]
            )
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
            ],
            settings: .settings(base: ["GENERATE_MASTER_OBJECT_FILE": "YES", "OTHER_LDFLAGS": "$(inherited) -ObjC"])
        ),
        .target(
            name: "Glob",
            destinations: .macOS,
            product: .staticFramework,
            bundleId: "io.tuist.Glob",
            deploymentTargets: .macOS("13.0"),
            sources: [
                "Sources/Glob/**/*.swift",
            ],
            settings: .settings(base: [
                "GENERATE_MASTER_OBJECT_FILE": "YES",
                "OTHER_LDFLAGS": "$(inherited) -ObjC",
                "SWIFT_STRICT_CONCURRENCY": "complete",
            ])
        ),
        .target(
            name: "GlobTests",
            destinations: .macOS,
            product: .unitTests,
            bundleId: "io.tuist.FileSystemTests",
            deploymentTargets: .macOS("13.0"),
            sources: [
                "Tests/GlobTests/**/*.swift",
            ],
            dependencies: [
                .target(name: "Glob"),
            ]
        ),
    ]
)
