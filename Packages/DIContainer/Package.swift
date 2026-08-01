// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DIContainer",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "DIContainer",
            targets: ["DIContainer"]
        ),
    ],
    targets: [
        .target(
            name: "DIContainer"
        ),
        .testTarget(
            name: "DIContainerTests",
            dependencies: ["DIContainer"]
        ),
    ]
)
