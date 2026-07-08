// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "StackView",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(name: "StackView", targets: ["StackView"])
    ],
    targets: [
        .target(name: "StackView"),
        .testTarget(
            name: "StackViewTests",
            dependencies: ["StackView"]
        )
    ]
)
