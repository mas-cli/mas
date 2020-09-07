import XCTest
import Quick
import Nimble

var oneExampleBeforeEachExecutedCount = 0
var onlyPendingExamplesBeforeEachExecutedCount = 0

class FunctionalTests_PendingSpec_Behavior: Behavior<Void> {
    override static func spec(_ aContext: @escaping () -> Void) {
        it("an example that will not run") {
            expect(true).to(beFalsy())
        }
    }
}
class FunctionalTests_PendingSpec: QuickSpec {
    override func spec() {
        xit("an example that will not run") {
            expect(true).to(beFalsy())
        }
        xitBehavesLike(FunctionalTests_PendingSpec_Behavior.self) { () -> Void in }
        describe("a describe block containing only one enabled example") {
            beforeEach { oneExampleBeforeEachExecutedCount += 1 }
            it("an example that will run") {}
            pending("an example that will not run") {}
        }

        describe("a describe block containing only pending examples") {
            beforeEach { onlyPendingExamplesBeforeEachExecutedCount += 1 }
            pending("an example that will not run") {}
        }
        describe("a describe block with a disabled context that will not run") {
            xcontext("these examples will not run") {
               it("does not run") {
                  fail()
               }
            }
        }
        xdescribe("a describe block that will not run") {
            it("does not run") {
               fail()
            }
        }
    }
}

final class PendingTests: XCTestCase, XCTestCaseProvider {
    static var allTests: [(String, (PendingTests) -> () throws -> Void)] {
        return [
            ("testAnOtherwiseFailingExampleWhenMarkedPendingDoesNotCauseTheSuiteToFail", testAnOtherwiseFailingExampleWhenMarkedPendingDoesNotCauseTheSuiteToFail),
            ("testBeforeEachOnlyRunForEnabledExamples", testBeforeEachOnlyRunForEnabledExamples),
            ("testBeforeEachDoesNotRunForContextsWithOnlyPendingExamples", testBeforeEachDoesNotRunForContextsWithOnlyPendingExamples),
        ]
    }

    func testAnOtherwiseFailingExampleWhenMarkedPendingDoesNotCauseTheSuiteToFail() {
        let result = qck_runSpec(FunctionalTests_PendingSpec.self)
        XCTAssertTrue(result!.hasSucceeded)
    }

    func testBeforeEachOnlyRunForEnabledExamples() {
        oneExampleBeforeEachExecutedCount = 0

        qck_runSpec(FunctionalTests_PendingSpec.self)
        XCTAssertEqual(oneExampleBeforeEachExecutedCount, 1)
    }

    func testBeforeEachDoesNotRunForContextsWithOnlyPendingExamples() {
        onlyPendingExamplesBeforeEachExecutedCount = 0

        qck_runSpec(FunctionalTests_PendingSpec.self)
        XCTAssertEqual(onlyPendingExamplesBeforeEachExecutedCount, 0)
    }
}
