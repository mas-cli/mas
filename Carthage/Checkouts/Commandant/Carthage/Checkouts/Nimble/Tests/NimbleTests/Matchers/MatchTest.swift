import XCTest
import Nimble

final class MatchTest: XCTestCase, XCTestCaseProvider {
    func testMatchPositive() {
        expect("11:14").to(match("\\d{2}:\\d{2}"))
    }

    func testMatchNegative() {
        expect("hello").toNot(match("\\d{2}:\\d{2}"))
    }

    func testMatchPositiveMessage() {
        let message = "expected to match <\\d{2}:\\d{2}>, got <hello>"
        failsWithErrorMessage(message) {
            expect("hello").to(match("\\d{2}:\\d{2}"))
        }
    }

    func testMatchNegativeMessage() {
        let message = "expected to not match <\\d{2}:\\d{2}>, got <11:14>"
        failsWithErrorMessage(message) {
            expect("11:14").toNot(match("\\d{2}:\\d{2}"))
        }
    }

    func testMatchNils() {
        failsWithErrorMessageForNil("expected to match <\\d{2}:\\d{2}>, got <nil>") {
            expect(nil as String?).to(match("\\d{2}:\\d{2}"))
        }

        failsWithErrorMessageForNil("expected to not match <\\d{2}:\\d{2}>, got <nil>") {
            expect(nil as String?).toNot(match("\\d{2}:\\d{2}"))
        }
    }
}
