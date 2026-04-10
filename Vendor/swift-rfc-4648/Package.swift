// swift-tools-version: 6.1
import PackageDescription

// RFC 4648: The Base16, Base32, and Base64 Data Encodings
let package = Package(
    name: "swift-rfc-4648",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
        .tvOS(.v16),
        .watchOS(.v9),
    ],
    products: [
        .library(name: "RFC 4648", targets: ["RFC 4648"]),
        .library(name: "RFC 4648 Foundation", targets: ["RFC 4648 Foundation"]),
    ],
    dependencies: [
        .package(path: "../swift-standards"),
        .package(path: "../swift-incits-4-1986"),
    ],
    targets: [
        .target(
            name: "RFC 4648",
            dependencies: [
                .product(name: "Standards", package: "swift-standards"),
                .product(name: "INCITS 4 1986", package: "swift-incits-4-1986"),
            ]
        ),
        .target(
            name: "RFC 4648 Foundation",
            dependencies: [
                "RFC 4648",
                .product(name: "Standards", package: "swift-standards"),
            ]
        ),
    ]
)
