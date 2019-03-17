import XCTest

// NOTE: This file is not intended to be included in the Xcode project or CocoaPods.
//       It is picked up by the Swift Package Manager during its build process.

#if SWIFT_PACKAGE && !canImport(Darwin)

/// When using Quick with swift-corelibs-xctest, automatic discovery of specs and
/// configurations is not available. Instead, you should create a standalone
/// executable and call this function from its main.swift file. This will execute
/// the specs and then terminate the process with an exit code of 0 if the tests
/// passed, or 1 if there were any failures.
///
/// Quick is known to work with the DEVELOPMENT-SNAPSHOT-2016-02-08-a Swift toolchain.
///
/// - parameter specs: An array of QuickSpec subclasses to run
/// - parameter configurations: An array QuickConfiguration subclasses for setting up
//                              global suite configuration (optional)
/// - parameter testCases: An array of XCTestCase test cases, just as would be passed
///                        info `XCTMain` if you were using swift-corelibs-xctest directly.
///                        This allows for mixing Quick specs and XCTestCase tests in one run.
public func QCKMain(_ specs: [QuickSpec.Type],
                    configurations: [QuickConfiguration.Type] = [],
                    testCases: [XCTestCaseEntry] = []) -> Never {
    let world = World.sharedWorld

    // Perform all configurations (ensures that shared examples have been discovered)
    world.configure { configuration in
        for configurationClass in configurations {
            configurationClass.configure(configuration)
        }
    }
    world.finalizeConfiguration()

    XCTMain(specs.compactMap { testCase($0.allTests) } + testCases)
}

#endif
