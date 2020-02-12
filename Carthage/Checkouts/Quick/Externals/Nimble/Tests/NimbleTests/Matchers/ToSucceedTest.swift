import XCTest
import Nimble

final class ToSucceedTest: XCTestCase, XCTestCaseProvider {
    func testToSucceed() {
        expect({
            return .succeeded
        }).to(succeed())

        expect({
            return .failed(reason: "")
        }).toNot(succeed())

        failsWithErrorMessageForNil("expected a closure, got <nil>") {
            expect(nil as (() -> ToSucceedResult)?).to(succeed())
        }

        failsWithErrorMessage("expected to succeed, got <failed> because <something went wrong>") {
            expect({
                .failed(reason: "something went wrong")
            }).to(succeed())
        }

        failsWithErrorMessage("expected to not succeed, got <succeeded>") {
            expect({
                return .succeeded
            }).toNot(succeed())
        }
    }
}
