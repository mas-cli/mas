// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "Commandant",
    products: [
        .library(name: "Commandant", targets: ["Commandant"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Quick/Quick.git", from: "3.1.0"),
        .package(url: "https://github.com/Quick/Nimble.git", from: "9.0.0"),
    ],
    targets: [
        .target(name: "Commandant", dependencies: []),
        .testTarget(name: "CommandantTests", dependencies: ["Commandant", "Quick", "Nimble"]),
    ],
    swiftLanguageVersions: [.v5]
)
