// swift-tools-version:6.0

private import Foundation
private import PackageDescription

private let swiftSettings = [
	SwiftSetting.enableUpcomingFeature("InternalImportsByDefault"),
	.enableUpcomingFeature("MemberImportVisibility"),
	.unsafeFlags(
		try FileManager.default
		.contentsOfDirectory( // swiftformat:disable indent
			at: URL(fileURLWithPath: #filePath, isDirectory: false)
			.deletingLastPathComponent()
			.appendingPathComponent("Sources/PrivateFrameworks", isDirectory: true),
			includingPropertiesForKeys: [.isDirectoryKey]
		)
		.filter(\.hasDirectoryPath)
		.flatMap { privateFrameworkFolderURL in
			[
				"-I",
				privateFrameworkFolderURL.pathComponents.suffix(3).joined(separator: "/"),
				"-Xcc",
				"-fmodule-map-file=\(privateFrameworkFolderURL.path)/module.modulemap",
			]
		}
	), // swiftformat:enable indent
]

_ = Package(
	name: "MAS",
	platforms: [.macOS(.v10_15)],
	products: [.executable(name: "mas", targets: ["MAS"])],
	dependencies: [
		.package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.6.1"),
		.package(url: "https://github.com/apple/swift-atomics.git", from: "1.3.0"),
		.package(url: "https://github.com/apple/swift-collections.git", from: "1.2.1"),
		.package(url: "https://github.com/mxcl/Version.git", from: "2.2.0"),
	],
	targets: [
		.plugin(name: "MASBuildToolPlugin", capability: .buildTool()),
		.executableTarget(
			name: "MAS",
			dependencies: [
				.product(name: "ArgumentParser", package: "swift-argument-parser"),
				.product(name: "Atomics", package: "swift-atomics"),
				.product(name: "Collections", package: "swift-collections"),
				"Version",
			],
			swiftSettings: swiftSettings,
			linkerSettings: [.unsafeFlags(["-F", "/System/Library/PrivateFrameworks"])],
			plugins: [.plugin(name: "MASBuildToolPlugin")]
		),
		.testTarget(
			name: "MASTests",
			dependencies: ["MAS"],
			resources: [.copy("Resources")],
			swiftSettings: swiftSettings
		),
	],
	swiftLanguageModes: [.v6]
)
