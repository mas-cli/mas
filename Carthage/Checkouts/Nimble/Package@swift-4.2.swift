// swift-tools-version:4.2
import PackageDescription

var targets: [Target] = [
    .target(
        name: "Nimble",
        dependencies: {
            #if os(macOS)
            return [
                "NimbleCwlPreconditionTesting",
                "NimbleCwlMachBadInstructionHandler",
            ]
            #else
            return []
            #endif
        }()
    ),
    .testTarget(
        name: "NimbleTests",
        dependencies: ["Nimble"],
        exclude: ["objc"]
    ),
]
#if os(macOS)
targets.append(contentsOf: [
    // https://github.com/Quick/Nimble/blob/8.x-branch/Carthage/Checkouts/CwlPreconditionTesting/Package.swift
    .target(
        name: "NimbleCwlPreconditionTesting",
        dependencies: [
            .target(name: "NimbleCwlMachBadInstructionHandler"),
            .target(name: "NimbleCwlCatchException")
        ],
        path: "Carthage/Checkouts/CwlPreconditionTesting/Sources/CwlPreconditionTesting",
        exclude: [
            "./CwlCatchBadInstructionPosix.swift"
        ]
    ),
    .target(
        name: "NimbleCwlMachBadInstructionHandler",
        path: "Carthage/Checkouts/CwlPreconditionTesting/Sources/CwlMachBadInstructionHandler"
    ),
    // https://github.com/Quick/Nimble/blob/8.x-branch/Carthage/Checkouts/CwlPreconditionTesting/Dependencies/CwlCatchException/Package.swift
    .target(
        name: "NimbleCwlCatchException",
        dependencies: [.target(name: "NimbleCwlCatchExceptionSupport")],
        path: "Carthage/Checkouts/CwlPreconditionTesting/Dependencies/CwlCatchException/Sources/CwlCatchException"
    ),
    .target(
        name: "NimbleCwlCatchExceptionSupport",
        path: "Carthage/Checkouts/CwlPreconditionTesting/Dependencies/CwlCatchException/Sources/CwlCatchExceptionSupport"
    ),
])
#endif

let package = Package(
    name: "Nimble",
    products: [
        .library(name: "Nimble", targets: ["Nimble"]),
    ],
    targets: targets,
    swiftLanguageVersions: [.v4_2]
)
