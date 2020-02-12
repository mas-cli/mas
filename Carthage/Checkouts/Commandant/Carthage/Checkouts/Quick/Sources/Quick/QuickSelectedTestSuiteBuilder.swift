#if canImport(Darwin)
import Foundation

/**
 Responsible for building a "Selected tests" suite. This corresponds to a single
 spec, and all its examples.
 */
internal class QuickSelectedTestSuiteBuilder: QuickTestSuiteBuilder {

    /**
     The test spec class to run.
     */
    let testCaseClass: AnyClass!

    /**
     For Objective-C classes, returns the class name. For Swift classes without,
     an explicit Objective-C name, returns a module-namespaced class name
     (e.g., "FooTests.FooSpec").
     */
    var testSuiteClassName: String {
        return NSStringFromClass(testCaseClass)
    }

    /**
     Given a test case name:

        FooSpec/testFoo

     Optionally constructs a test suite builder for the named test case class
     in the running test bundle.

     If no test bundle can be found, or the test case class can't be found,
     initialization fails and returns `nil`.
     */
    init?(forTestCaseWithName name: String) {
        guard let testCaseClass = testCaseClassForTestCaseWithName(name) else {
            self.testCaseClass = nil
            return nil
        }

        self.testCaseClass = testCaseClass
    }

    /**
     Returns a `QuickTestSuite` that runs the associated test case class.
     */
    func buildTestSuite() -> QuickTestSuite {
        return QuickTestSuite(forTestCaseClass: testCaseClass)
    }

}

/**
 Searches `Bundle.allBundles()` for an xctest bundle, then looks up the named
 test case class in that bundle.

 Returns `nil` if a bundle or test case class cannot be found.
 */
private func testCaseClassForTestCaseWithName(_ name: String) -> AnyClass? {
    func extractClassName(_ name: String) -> String? {
        return name.components(separatedBy: "/").first
    }

    guard let className = extractClassName(name) else { return nil }
    guard let bundle = Bundle.currentTestBundle else { return nil }

    if let testCaseClass = bundle.classNamed(className) { return testCaseClass }

    let moduleName = bundle.moduleName

    return NSClassFromString("\(moduleName).\(className)")
}

#endif
