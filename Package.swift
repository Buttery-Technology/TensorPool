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
        .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.24.0"),
    ],
    targets: [
        .target(
            name: "TensorPool",
            dependencies: [
                .product(name: "AsyncHTTPClient", package: "async-http-client", condition: .when(platforms: [.linux])),
            ]
        ),
        .testTarget(
            name: "TensorPoolTests",
            dependencies: ["TensorPool"]
        ),
    ]
)
