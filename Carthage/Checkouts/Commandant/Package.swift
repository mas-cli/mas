// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "Commandant",
    products: [
        .library(name: "Commandant", targets: ["Commandant"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Quick/Quick.git", from: "2.0.0"),
        .package(url: "https://github.com/Quick/Nimble.git", from: "8.0.0"),
    ],
    targets: [
        .target(name: "Commandant", dependencies: []),
        .testTarget(name: "CommandantTests", dependencies: ["Commandant", "Quick", "Nimble"]),
    ],
    swiftLanguageVersions: [.v5]
)
