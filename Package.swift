// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SimpleMock",
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
