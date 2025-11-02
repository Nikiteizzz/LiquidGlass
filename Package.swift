// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "LiquidGlass",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "LiquidGlass",
            targets: ["LiquidGlass"]
        ),
    ],
    targets: [
        .target(
            name: "LiquidGlass",
            dependencies: [],
            path: "Sources",
            linkerSettings: [
                .linkedFramework("SwiftUI"),
                .linkedFramework("Metal")
            ]
        )
    ]
)
