// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TensorPool",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "TensorPool",
            targets: ["TensorPool"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/jonnyholland/ComposableArchitecturePattern.git", from: "1.4.0"),
    ],
    targets: [
        .target(
            name: "TensorPool",
            dependencies: [
                .product(name: "CAP", package: "ComposableArchitecturePattern"),
            ]
        ),
        .testTarget(
            name: "TensorPoolTests",
            dependencies: ["TensorPool"]
        ),
    ]
)
