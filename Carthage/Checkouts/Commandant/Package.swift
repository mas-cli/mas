// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "Commandant",
    products: [
        .library(name: "Commandant", targets: ["Commandant"]),
    ],
    dependencies: [
        .package(url: "https://github.com/antitypical/Result.git", from: "4.0.0"),
        .package(url: "https://github.com/Quick/Quick.git", from: "2.0.0"),
        .package(url: "https://github.com/Quick/Nimble.git", from: "8.0.0")
    ],
    targets: [
        .target(name: "Commandant", dependencies: ["Result"]),
        .testTarget(name: "CommandantTests", dependencies: ["Commandant", "Quick", "Nimble"])
    ],
    swiftLanguageVersions: [.v4_2, .version("5")]
)
