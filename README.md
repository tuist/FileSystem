# FileSystem

FileSystem is a Swift Package that provides a simple cross-platform API to interact with the file system.

## Documentation

You can find the documentation [here](https://filesystem.tuist.io).

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