#if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)

import XCTest

/**
 This protocol defines the role of an object that builds test suites.
 */
internal protocol QuickTestSuiteBuilder {

    /**
     Construct a `QuickTestSuite` instance with the appropriate test cases added as tests.

     Subsequent calls to this method should return equivalent test suites.
     */
    func buildTestSuite() -> QuickTestSuite

}

/**
 A base class for a class cluster of Quick test suites, that should correctly
 build dynamic test suites for XCTest to execute.
 */
public class QuickTestSuite: XCTestSuite {

    private static var builtTestSuites: Set<String> = Set()

    /**
     Construct a test suite for a specific, selected subset of test cases (rather
     than the default, which as all test cases).

     If this method is called multiple times for the same test case class, e.g..

        FooSpec/testFoo
        FooSpec/testBar

     It is expected that the first call should return a valid test suite, and
     all subsequent calls should return `nil`.
     */
    @objc
    public static func selectedTestSuite(forTestCaseWithName name: String) -> QuickTestSuite? {
        guard let builder = QuickSelectedTestSuiteBuilder(forTestCaseWithName: name) else { return nil }

        let (inserted, _) = builtTestSuites.insert(builder.testSuiteClassName)
        if inserted {
            return builder.buildTestSuite()
        } else {
            return nil
        }
    }
}

#endif
