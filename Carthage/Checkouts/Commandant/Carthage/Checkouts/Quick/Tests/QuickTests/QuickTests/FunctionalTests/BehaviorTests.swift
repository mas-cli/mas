import Foundation
import Quick
import Nimble
import XCTest

class FunctionalTests_BehaviorTests_Spec: QuickSpec {
    override func spec() {
        itBehavesLike(FunctionalTests_BehaviorTests_Behavior2.self) { () -> Void in }
    }
}

class FunctionalTests_BehaviorTests_ContextSpec: QuickSpec {
    override func spec() {
        itBehavesLike(FunctionalTests_BehaviorTests_Behavior.self) {
            "BehaviorSpec"
        }
    }
}

#if canImport(Darwin) && !SWIFT_PACKAGE
class FunctionalTests_BehaviorTests_ErrorSpec: QuickSpec {
    override func spec() {
        describe("error handling when misusing ordering") {
            it("should throw an exception when including itBehavesLike in it block") {
                expect {
                    itBehavesLike(FunctionalTests_BehaviorTests_Behavior2.self) { () }
                }
                    .to(raiseException {(exception: NSException) in
                        expect(exception.name).to(equal(NSExceptionName.internalInconsistencyException))
                        expect(exception.reason).to(equal("'itBehavesLike' cannot be used inside 'it', 'itBehavesLike' may only be used inside 'context' or 'describe'. "))
                })
            }
        }
    }
}
#endif

final class BehaviorTests: XCTestCase, XCTestCaseProvider {

    static var allTests: [(String, (BehaviorTests) -> () throws -> Void)] {
        return [
            ("testBehaviorPassContextToExamples",
             testBehaviorPassContextToExamples),
            ("testBehaviorExecutesThreeExamples",
             testBehaviorExecutesThreeExamples)
        ]
    }

    func testBehaviorExecutesThreeExamples() {
        let result = qck_runSpec(FunctionalTests_BehaviorTests_Spec.self)
        XCTAssert(result!.hasSucceeded)
        XCTAssertEqual(result!.executionCount, 3)
    }

    func testBehaviorPassContextToExamples() {
        let result = qck_runSpec(FunctionalTests_BehaviorTests_ContextSpec.self)
        XCTAssert(result!.hasSucceeded)
    }
}
