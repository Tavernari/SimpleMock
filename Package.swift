// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SimpleMock",
    platforms: [.macOS(.v10_15),
                .iOS(.v9),
                .tvOS(.v10),
                .macCatalyst(.v13),
                .watchOS(.v3)],
    products: [
        .library(
            name: "SimpleMock",
            targets: ["SimpleMock"]),
    ],
    targets: [
        .target(
            name: "SimpleMock",
            dependencies: []),
        .testTarget(
            name: "SimpleMockTests",
            dependencies: ["SimpleMock"]),
    ]
)
