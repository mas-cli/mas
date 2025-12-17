// swift-tools-version:6.0

private import PackageDescription

private let swiftSettings = [
	SwiftSetting
	.enableUpcomingFeature("ExistentialAny"), // swiftformat:disable:this indent
	.enableUpcomingFeature("ImmutableWeakCaptures"),
	.enableUpcomingFeature("InferIsolatedConformances"),
	.enableUpcomingFeature("InternalImportsByDefault"),
	.enableUpcomingFeature("MemberImportVisibility"),
	.enableUpcomingFeature("NonisolatedNonsendingByDefault"),
	.unsafeFlags(["-warnings-as-errors"]),
]

_ = Package(
	name: "mas",
	platforms: [.macOS(.v10_15)],
	products: [.executable(name: "mas", targets: ["mas"])],
	dependencies: [
		.package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.6.2"),
		.package(url: "https://github.com/apple/swift-atomics.git", from: "1.3.0"),
		.package(url: "https://github.com/apple/swift-collections.git", from: "1.3.0"),
		.package(url: "https://github.com/mxcl/Version.git", from: "2.2.0"),
	],
	targets: [
		.plugin(name: "MASBuildToolPlugin", capability: .buildTool()),
		.target(name: "PrivateFrameworks"),
		.executableTarget(
			name: "mas",
			dependencies: [
				.product(name: "ArgumentParser", package: "swift-argument-parser"),
				.product(name: "Atomics", package: "swift-atomics"),
				.product(name: "OrderedCollections", package: "swift-collections"),
				"PrivateFrameworks",
				"Version",
			],
			swiftSettings: swiftSettings,
			linkerSettings: [.unsafeFlags(["-F", "/System/Library/PrivateFrameworks"])],
			plugins: [.plugin(name: "MASBuildToolPlugin")]
		),
		.testTarget(
			name: "MASTests",
			dependencies: ["mas"],
			resources: [.process("Resources")],
			swiftSettings: swiftSettings
		),
	],
	swiftLanguageModes: [.v6]
)
