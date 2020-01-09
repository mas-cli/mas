// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "Nimble",
    products: [
        .library(name: "Nimble", targets: ["Nimble"]),
    ],
    targets: [
        .target(
            name: "Nimble", 
            dependencies: []
        ),
        .testTarget(
            name: "NimbleTests", 
            dependencies: ["Nimble"], 
            exclude: ["objc"]
        ),
    ],
    swiftLanguageVersions: [4]
)
