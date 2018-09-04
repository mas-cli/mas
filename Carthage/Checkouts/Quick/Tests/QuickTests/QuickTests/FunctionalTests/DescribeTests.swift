import XCTest
import Nimble
import Quick

#if (os(macOS) || os(iOS) || os(tvOS) || os(watchOS)) && !SWIFT_PACKAGE

final class DescribeTests: XCTestCase, XCTestCaseProvider {
    static var allTests: [(String, (DescribeTests) -> () throws -> Void)] {
        return [
            ("testDescribeThrowsIfUsedOutsideOfQuickSpec", testDescribeThrowsIfUsedOutsideOfQuickSpec)
        ]
    }

    func testDescribeThrowsIfUsedOutsideOfQuickSpec() {
        expect { describe("this should throw an exception", {}) }.to(raiseException())
    }
}

class QuickDescribeTests: QuickSpec {
    override func spec() {
        describe("Describe") {
            it("should throw an exception if used in an it block") {
                expect {
                    describe("A nested describe that should throw") { }
                }.to(raiseException { (exception: NSException) in
                    expect(exception.name).to(equal(NSExceptionName.internalInconsistencyException))
                    expect(exception.reason).to(equal("'describe' cannot be used inside 'it', 'describe' may only be used inside 'context' or 'describe'. "))
                })
            }
        }
    }
}

#endif
