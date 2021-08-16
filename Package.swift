// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Synthesis",
    platforms: [
        .iOS(.v13),
        .macOS(.v11),
        .macCatalyst(.v13),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        .library(
            name: "Synthesis",
            targets: ["Synthesis"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Synthesis",
            dependencies: []),
        .testTarget(
            name: "SynthesisTests",
            dependencies: ["Synthesis"]),
    ]
)
