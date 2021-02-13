// swift-tools-version:5.0
import PackageDescription

let package = Package(
	name: "CwlPreconditionTesting",
	products: [
		.library(name: "CwlPreconditionTesting", targets: ["CwlPreconditionTesting", "CwlMachBadInstructionHandler"]),
		.library(name: "CwlPosixPreconditionTesting", targets: ["CwlPosixPreconditionTesting"])
	],
	dependencies: [
		.package(url: "https://github.com/mattgallagher/CwlCatchException.git", from: "2.0.0")
	],
	targets: [
		.target(
			name: "CwlPreconditionTesting",
			dependencies: [
				.target(name: "CwlMachBadInstructionHandler"),
				.product(name: "CwlCatchException")
			]
		),
		.target(
			name: "CwlPosixPreconditionTesting"
		),
		.target(name: "CwlMachBadInstructionHandler"),
		.testTarget(name: "CwlPreconditionTestingTests", dependencies: ["CwlPreconditionTesting", "CwlPosixPreconditionTesting"])
	]
)
