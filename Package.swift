// swift-tools-version:5.9

import PackageDescription

let package = Package(
	name: "mas",
	platforms: [
		.macOS(.v10_15),
	],
	products: [
		.executable(
			name: "mas",
			targets: ["mas"]
		),
	],
	dependencies: [
		.package(url: "https://github.com/Quick/Nimble.git", from: "13.7.1"),
		.package(url: "https://github.com/Quick/Quick.git", exact: "7.5.0"),
		.package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.6.1"),
		.package(url: "https://github.com/apple/swift-atomics.git", revision: "239a74d140e0a9dd84fde414260a8c062480550c"),
		.package(url: "https://github.com/funky-monkey/IsoCountryCodes.git", from: "1.0.3"),
		.package(url: "https://github.com/mxcl/Version.git", from: "2.2.0"),
	],
	targets: [
		.executableTarget(
			name: "mas",
			dependencies: [
				.product(name: "ArgumentParser", package: "swift-argument-parser"),
				.product(name: "Atomics", package: "swift-atomics"),
				"IsoCountryCodes",
				"Version",
			],
			swiftSettings: [
				.enableExperimentalFeature("AccessLevelOnImport"),
				.enableExperimentalFeature("StrictConcurrency"),
				.unsafeFlags([
					"-I", "Sources/PrivateFrameworks/CommerceKit",
					"-I", "Sources/PrivateFrameworks/StoreFoundation",
				]),
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
			resources: [.copy("Resources")],
			swiftSettings: [
				.enableExperimentalFeature("AccessLevelOnImport"),
				.enableExperimentalFeature("StrictConcurrency"),
				.unsafeFlags([
					"-I", "Sources/PrivateFrameworks/CommerceKit",
					"-I", "Sources/PrivateFrameworks/StoreFoundation",
				]),
			]
		),
	],
	swiftLanguageVersions: [.v5]
)
