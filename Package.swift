// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SimpleMock",
    platforms: [.macOS(.v10_15), .driverKit(.v19), .iOS(.v11), .macCatalyst(.v13),.tvOS(.v11),.watchOS(.v4)],
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
