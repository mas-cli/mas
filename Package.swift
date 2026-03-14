// swift-tools-version:6.2

private import PackageDescription

private let swiftSettings = [
	SwiftSetting
	.enableUpcomingFeature("ExistentialAny"), // swiftformat:disable:this indent
	.enableUpcomingFeature("ImmutableWeakCaptures"),
	.enableUpcomingFeature("InferIsolatedConformances"),
	.enableUpcomingFeature("InternalImportsByDefault"),
	.enableUpcomingFeature("MemberImportVisibility"),
	.enableUpcomingFeature("NonisolatedNonsendingByDefault"),
	.strictMemorySafety(),
	.treatAllWarnings(as: .error),
]

_ = Package(
	name: "mas",
	platforms: [.macOS(.v13)],
	products: [.executable(name: "mas", targets: ["mas"])],
	dependencies: [
		.package(url: "https://github.com/KittyMac/Sextant.git", from: "0.4.39"),
		.package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.7.1"),
		.package(url: "https://github.com/apple/swift-atomics.git", from: "1.3.0"),
		.package(url: "https://github.com/apple/swift-collections.git", from: "1.4.1"),
		.package(url: "https://github.com/attaswift/BigInt.git", from: "5.7.0"),
		.package(url: "https://github.com/mas-cli/swift-json.git", from: "3.3.0"),
		.package(url: "https://github.com/scinfu/SwiftSoup.git", from: "2.13.4"),
	],
	targets: [
		.plugin(name: "MASBuildToolPlugin", capability: .buildTool()),
		.target(name: "PrivateFrameworks"),
		.executableTarget(
			name: "mas",
			dependencies: [
				.product(name: "ArgumentParser", package: "swift-argument-parser"),
				.product(name: "Atomics", package: "swift-atomics"),
				.product(name: "JSON", package: "swift-json"),
				.product(name: "OrderedCollections", package: "swift-collections"),
				"BigInt",
				"PrivateFrameworks",
				"Sextant",
				"SwiftSoup",
			],
			swiftSettings: swiftSettings,
			linkerSettings: [.unsafeFlags(["-F", "/System/Library/PrivateFrameworks"])],
			plugins: [.plugin(name: "MASBuildToolPlugin")],
		),
		.testTarget(
			name: "MASTests",
			dependencies: ["mas"],
			resources: [.process("Resources")],
			swiftSettings: swiftSettings,
		),
	],
	swiftLanguageModes: [.v6],
)
