// swift-tools-version:5.7.1

import PackageDescription

let package = Package(
    name: "mas",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .executable(
            name: "mas",
            targets: ["mas"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/Quick/Nimble.git", from: "13.7.1"),
        .package(url: "https://github.com/Quick/Quick.git", from: "7.6.2"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.5.0"),
        .package(url: "https://github.com/funky-monkey/IsoCountryCodes.git", from: "1.0.2"),
        .package(url: "https://github.com/mxcl/Version.git", from: "2.1.0"),
        .package(url: "https://github.com/sharplet/Regex.git", from: "2.1.1"),
    ],
    targets: [
        .executableTarget(
            name: "mas",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                "IsoCountryCodes",
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
