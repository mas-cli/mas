// swift-tools-version:5.6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "mas",
    platforms: [
        .macOS(.v10_11)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .executable(
            name: "mas",
            targets: ["mas"]
        )
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/Quick/Nimble.git", from: "10.0.0"),
        .package(url: "https://github.com/Quick/Quick.git", from: "5.0.0"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.5.0"),
        .package(url: "https://github.com/mxcl/PromiseKit.git", from: "6.22.1"),
        .package(url: "https://github.com/mxcl/Version.git", from: "2.1.0"),
        .package(url: "https://github.com/sharplet/Regex.git", from: "2.1.1"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .executableTarget(
            name: "mas",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                "PromiseKit",
                "Regex",
                "Version",
            ],
            swiftSettings: [
                .unsafeFlags([
                    "-I", "Sources/PrivateFrameworks/CommerceKit",
                    "-I", "Sources/PrivateFrameworks/StoreFoundation",
                ])
            ],
            linkerSettings: [
                .linkedFramework("CommerceKit"),
                .linkedFramework("StoreFoundation"),
                .unsafeFlags(["-F", "/System/Library/PrivateFrameworks"]),
            ]
        ),
        .testTarget(
            name: "masTests",
            dependencies: ["mas", "Nimble", "Quick"],
            resources: [.copy("JSON")],
            swiftSettings: [
                .unsafeFlags([
                    "-I", "Sources/PrivateFrameworks/CommerceKit",
                    "-I", "Sources/PrivateFrameworks/StoreFoundation",
                ])
            ]
        ),
    ],
    swiftLanguageVersions: [.v5]
)
