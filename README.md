# FileSystem

FileSystem is a Swift Package that provides a simple cross-platform API to interact with the file system.

## Motivation
Why build a Swift Package for interacting with the file system if there's already `FileManager`? Here are the motivations:

- Providing human-friendly errors that are ok to present to the user.
- Integrating with [swift-log](https://github.com/apple/swift-log) to give consumers the ability to log file system operations.
- Embracing Swift's structured concurrency with async/await.
- Providing an API where paths are always absolute, makes it easier to reason about the file system operations.

> [!NOTE]
> FileSystem powers [Tuist](https://tuist.io), a toolchain to build better apps faster.

## Add it to your project

### Swift Package Manager

You can edit your project's `Package.swift` and add `FileSystem` as a dependency:

```swift
import PackageDescription

let package = Package(
  name: "MyProject",
  dependencies: [
    .package(url: "https://github.com/tuist/FileSystem.git", .upToNextMajor(from: "0.1.0"))
  ],
  targets: [
    .target(name: "MyProject", 
            dependencies: ["FileSystem", .product(name: "FileSystem", package: "FileSystem")]),
  ]
)
```

### Tuist

First, you'll have to add the `FileSystem` package to your project's `Package.swift` file:

```swift
import PackageDescription

let package = Package(
  name: "MyProject",
  dependencies: [
    .package(url: "https://github.com/tuist/FileSystem.git", .upToNextMajor(from: "0.1.0"))
  ]
)
```

And then declare it as a dependency of one of your project's targets:

```swift
// Project.swift
import ProjectDescription

let project = Project(
    name: "App",
    organizationName: "tuist.io",
    targets: [
        .target(
            name: "App",
            destinations: [.iPhone],
            product: .app,
            bundleId: "io.tuist.app",
            deploymentTargets: .iOS("13.0"),
            infoPlist: .default,
            sources: ["Targets/App/Sources/**"],
            dependencies: [
                .external(name: "FileSystem"),
            ]
        ),
    ]
)
```

## Development

### Using Tuist

1. Clone the repository: `git clone https://github.com/tuist/FileSystem.git`
2. Generate the project: `tuist generate`


### Using Swift Package Manager

1. Clone the repository: `git clone https://github.com/tuist/FileSystem.git`
2. Open the `Package.swift` with Xcode