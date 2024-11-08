// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OneNetwork",
    platforms: [
        .macOS(.v11),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        .library(
            name: "OneNetwork",
            targets: ["OneNetwork"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/enhorn/OneLogger.git",
            .upToNextMajor(from: "1.1.0")
        )
    ],
    targets: [
        .target(
            name: "OneNetwork",
            dependencies: ["OneLogger"],
            exclude: ["../../Example"]
        ),
        .testTarget(
            name: "OneNetworkTests",
            dependencies: ["OneNetwork"]
        )
    ]
)
