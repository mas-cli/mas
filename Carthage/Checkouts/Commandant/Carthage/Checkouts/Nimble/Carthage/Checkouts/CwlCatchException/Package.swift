import PackageDescription

let package = Package(
	name: "CwlCatchException",
	targets: [
		Target(name: "CwlCatchException", dependencies: ["CwlCatchExceptionSupport"]),
		Target(name: "CwlCatchExceptionSupport")
	]
)
