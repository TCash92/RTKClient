// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "RTKClient",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "RTKClient",
            targets: ["RTKClient"]),
    ],
    dependencies: [
        .package(url: "https://github.com/nga-ml/mgrs-ios.git", from: "1.1.0")
    ],
    targets: [
        .target(
            name: "RTKClient",
            dependencies: [
                .product(name: "mgrs", package: "mgrs-ios")
            ],
            path: "Sources"),
        .testTarget(
            name: "RTKClientTests",
            dependencies: ["RTKClient"],
            path: "Tests")
    ]
)