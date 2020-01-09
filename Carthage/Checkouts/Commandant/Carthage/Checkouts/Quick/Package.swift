// swift-tools-version:3.1

import Foundation
import PackageDescription

var isTesting: Bool {
  guard let value = ProcessInfo.processInfo.environment["SWIFT_PACKAGE_TEST_Quick"] else { return false }
  return NSString(string: value).boolValue
}

var package = Package(
    name: "Quick",
    targets: {
#if os(macOS)
        return [
            Target(name: "QuickSpecBase"),
            Target(name: "Quick", dependencies: [ "QuickSpecBase" ]),
            Target(name: "QuickTests", dependencies: [ "Quick" ]),
        ]
#else
        return [
            Target(name: "Quick"),
            Target(name: "QuickTests", dependencies: [ "Quick" ]),
        ]
#endif
    }(),
    exclude: {
        var excludes = [
            "Sources/QuickObjectiveC",
            "Tests/QuickTests/QuickAfterSuiteTests/AfterSuiteTests+ObjC.m",
            "Tests/QuickTests/QuickFocusedTests/FocusedTests+ObjC.m",
            "Tests/QuickTests/QuickTests/FunctionalTests/ObjC",
            "Tests/QuickTests/QuickTests/Helpers",
            "Tests/QuickTests/QuickTests/QuickConfigurationTests.m",
        ]
#if !os(macOS)
        excludes.append("Sources/QuickSpecBase")
#endif
        return excludes
    }()
)

if isTesting {
  package.dependencies.append(contentsOf: [
    .Package(url: "https://github.com/Quick/Nimble.git", majorVersion: 7),
  ])
}
