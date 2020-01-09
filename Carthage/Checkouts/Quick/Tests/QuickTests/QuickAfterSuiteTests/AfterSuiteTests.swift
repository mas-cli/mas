import XCTest
import Quick
import Nimble

var afterSuiteFirstTestExecuted = false
var afterSuiteTestsWasExecuted = false

class AfterSuiteTests: QuickSpec {
    override func spec() {
        afterSuite {
            afterSuiteTestsWasExecuted = true
        }

        it("is executed before afterSuite") {
            expect(afterSuiteTestsWasExecuted).to(beFalsy())
        }
    }

    override class func tearDown() {
        if afterSuiteFirstTestExecuted {
            assert(afterSuiteTestsWasExecuted, "afterSuiteTestsWasExecuted needs to be true")
        } else {
            afterSuiteFirstTestExecuted = true
        }
    }
}
