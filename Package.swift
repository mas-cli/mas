// swift-tools-version:5.3
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
        ),
        .library(
            name: "MasKit",
            targets: ["MasKit"]
        ),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/Carthage/Commandant.git", from: "0.18.0"),
        .package(url: "https://github.com/Quick/Nimble.git", from: "9.2.1"),
        .package(url: "https://github.com/Quick/Quick.git", from: "4.0.0"),
        .package(url: "https://github.com/mxcl/PromiseKit.git", from: "6.16.2"),
        .package(url: "https://github.com/mxcl/Version.git", from: "2.0.1"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "mas",
            dependencies: ["MasKit"],
            swiftSettings: [
                .unsafeFlags([
                    "-I", "Sources/PrivateFrameworks/CommerceKit",
                    "-I", "Sources/PrivateFrameworks/StoreFoundation",
                ])
            ]
        ),
        .target(
            name: "MasKit",
            dependencies: ["Commandant", "PromiseKit", "Version"],
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
            name: "MasKitTests",
            dependencies: ["MasKit", "Nimble", "Quick"],
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

// https://github.com/apple/swift-format#matching-swift-format-to-your-swift-version
#if compiler(>=5.6)
    package.dependencies += [
        .package(url: "https://github.com/apple/swift-format", .branch("release/5.6"))
    ]
#elseif compiler(>=5.5)
    package.dependencies += [
        .package(url: "https://github.com/apple/swift-format", .branch("swift-5.5-branch"))
    ]
#elseif compiler(>=5.4)
    package.dependencies += [
        .package(url: "https://github.com/apple/swift-format", .branch("swift-5.4-branch"))
    ]
#elseif compiler(>=5.3)
    package.dependencies += [
        .package(url: "https://github.com/apple/swift-format", .branch("swift-5.3-branch"))
    ]
#endif
