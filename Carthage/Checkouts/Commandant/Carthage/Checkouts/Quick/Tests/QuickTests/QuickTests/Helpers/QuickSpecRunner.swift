import Foundation
import XCTest
@testable import Quick

#if !canImport(Darwin)
// Based on https://github.com/apple/swift-corelibs-xctest/blob/51afda0bc782b2d6a2f00fbdca58943faf6ccecd/Sources/XCTest/Private/XCTestCaseSuite.swift#L14-L42
private final class TestCaseSuite: XCTestSuite {
    let specClass: QuickSpec.Type

    init(specClass: QuickSpec.Type) {
        self.specClass = specClass
        super.init(name: String(describing: specClass))

        for (testName, testClosure) in specClass.allTests {
            let testCase = specClass.init(name: testName, testClosure: { testCase in
                // swiftlint:disable:next force_cast
                try testClosure(testCase as! QuickSpec)()
            })
            addTest(testCase)
        }
    }

    override func setUp() {
        specClass.setUp()
    }

    override func tearDown() {
        specClass.tearDown()
    }
}
#endif

/**
 Runs an XCTestSuite instance containing only the given QuickSpec subclass.
 Use this to run QuickSpec subclasses from within a set of unit tests.

 Due to implicit dependencies in _XCTFailureHandler, this function raises an
 exception when used in Swift to run a failing test case.

 @param specClass The class of the spec to be run.
 @return An XCTestRun instance that contains information such as the number of failures, etc.
 */
@discardableResult
func qck_runSpec(_ specClass: QuickSpec.Type) -> XCTestRun? {
    return qck_runSpecs([specClass])
}

/**
 Runs an XCTestSuite instance containing the given QuickSpec subclasses, in the order provided.
 See the documentation for `qck_runSpec` for more details.

 @param specClasses An array of QuickSpec classes, in the order they should be run.
 @return An XCTestRun instance that contains information such as the number of failures, etc.
 */
@discardableResult
func qck_runSpecs(_ specClasses: [QuickSpec.Type]) -> XCTestRun? {
    return World.anotherWorld { world -> XCTestRun? in
        QuickConfiguration.configureSubclassesIfNeeded(world: world)

        world.isRunningAdditionalSuites = true
        defer { world.isRunningAdditionalSuites = false }

        #if !SWIFT_PACKAGE
        // Gather examples first
        QuickSpec.enumerateSubclasses(subclasses: specClasses) { specClass in
            // This relies on `_QuickSpecInternal`.
            (specClass as AnyClass).buildExamplesIfNeeded()
        }
        #endif

        let suite = XCTestSuite(name: "MySpecs")
        for specClass in specClasses {
            #if canImport(Darwin)
            let test = specClass.defaultTestSuite
            #else
            let test = TestCaseSuite(specClass: specClass)
            #endif
            suite.addTest(test)
        }

        let result: XCTestRun? = XCTestObservationCenter.shared.qck_suspendObservation {
            suite.run()
            return suite.testRun
        }
        return result
    }
}

#if canImport(Darwin) && !SWIFT_PACKAGE
@objc(QCKSpecRunner)
@objcMembers
class QuickSpecRunner: NSObject {
    static func runSpec(_ specClass: QuickSpec.Type) -> XCTestRun? {
        return qck_runSpec(specClass)
    }

    static func runSpecs(_ specClasses: [QuickSpec.Type]) -> XCTestRun? {
        return qck_runSpecs(specClasses)
    }
}
#endif
