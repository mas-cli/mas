// swift-tools-version:6.0

private import Foundation
private import PackageDescription

private let privateFrameworkNames =
	try FileManager.default // swiftformat:disable:this indent
	.contentsOfDirectory(
		at: URL(fileURLWithPath: #filePath, isDirectory: false)
		.deletingLastPathComponent() // swiftformat:disable:this indent
		.appendingPathComponent("Sources/PrivateFrameworks", isDirectory: true), // swiftformat:disable:this indent
		includingPropertiesForKeys: [.isDirectoryKey]
	)
	.filter(\.hasDirectoryPath)
	.map(\.lastPathComponent)

private let swiftSettings = [
	SwiftSetting.enableUpcomingFeature("InternalImportsByDefault"),
	.enableUpcomingFeature("MemberImportVisibility"),
	.unsafeFlags(privateFrameworkNames.flatMap { ["-I", "Sources/PrivateFrameworks/\($0)"] }),
]

_ = Package(
	name: "mas",
	platforms: [.macOS(.v10_15)],
	products: [.executable(name: "mas", targets: ["mas"])],
	dependencies: [
		.package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.6.1"),
		.package(url: "https://github.com/apple/swift-atomics.git", from: "1.3.0"),
		.package(url: "https://github.com/apple/swift-collections.git", from: "1.2.1"),
		.package(url: "https://github.com/mxcl/Version.git", from: "2.2.0"),
	],
	targets: [
		.plugin(name: "MASBuildToolPlugin", capability: .buildTool()),
		.executableTarget(
			name: "mas",
			dependencies: [
				.product(name: "ArgumentParser", package: "swift-argument-parser"),
				.product(name: "Atomics", package: "swift-atomics"),
				.product(name: "Collections", package: "swift-collections"),
				"Version",
			],
			swiftSettings: swiftSettings,
			linkerSettings: privateFrameworkNames.map { .linkedFramework($0) }
			+ [.unsafeFlags(["-F", "/System/Library/PrivateFrameworks"])], // swiftformat:disable:this indent
			plugins: [.plugin(name: "MASBuildToolPlugin")]
		),
		.testTarget(
			name: "masTests",
			dependencies: ["mas"],
			resources: [.copy("Resources")],
			swiftSettings: swiftSettings
		),
	],
	swiftLanguageModes: [.v6]
)
