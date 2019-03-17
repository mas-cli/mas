import Foundation
import XCTest
import Quick
import Nimble

class FunctionalTests_SharedExamples_Spec: QuickSpec {
    override func spec() {
        itBehavesLike("a group of three shared examples")
    }
}

class FunctionalTests_SharedExamples_ContextSpec: QuickSpec {
    override func spec() {
        itBehavesLike("shared examples that take a context") { ["callsite": "SharedExamplesSpec"] }
    }
}

#if canImport(Darwin) && !SWIFT_PACKAGE
class FunctionalTests_SharedExamples_ErrorSpec: QuickSpec {
    override func spec() {
        describe("error handling when misusing ordering") {
            it("should throw an exception when including itBehavesLike in it block") {
                expect {
                    itBehavesLike("a group of three shared examples")
                    }.to(raiseException { (exception: NSException) in
                        expect(exception.name).to(equal(NSExceptionName.internalInconsistencyException))
                        expect(exception.reason).to(equal("'itBehavesLike' cannot be used inside 'it', 'itBehavesLike' may only be used inside 'context' or 'describe'. "))
                        })
            }
        }
    }
}
#endif

// Shared examples are defined in QuickTests/Fixtures
final class SharedExamplesTests: XCTestCase, XCTestCaseProvider {
    static var allTests: [(String, (SharedExamplesTests) -> () throws -> Void)] {
        return [
            ("testAGroupOfThreeSharedExamplesExecutesThreeExamples", testAGroupOfThreeSharedExamplesExecutesThreeExamples),
            ("testSharedExamplesWithContextPassContextToExamples", testSharedExamplesWithContextPassContextToExamples)
        ]
    }

    func testAGroupOfThreeSharedExamplesExecutesThreeExamples() {
        let result = qck_runSpec(FunctionalTests_SharedExamples_Spec.self)
        XCTAssert(result!.hasSucceeded)
        XCTAssertEqual(result!.executionCount, 3)
    }

    func testSharedExamplesWithContextPassContextToExamples() {
        let result = qck_runSpec(FunctionalTests_SharedExamples_ContextSpec.self)
        XCTAssert(result!.hasSucceeded)
    }
}
