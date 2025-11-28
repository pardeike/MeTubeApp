// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MeTube",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "MeTube",
            targets: ["MeTube"]
        ),
    ],
    targets: [
        .target(
            name: "MeTube",
            dependencies: []
        ),
        .testTarget(
            name: "MeTubeTests",
            dependencies: ["MeTube"]
        ),
    ]
)
