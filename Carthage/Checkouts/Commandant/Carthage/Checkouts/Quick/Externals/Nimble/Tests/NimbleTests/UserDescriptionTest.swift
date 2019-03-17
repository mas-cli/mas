import XCTest
import Nimble

final class UserDescriptionTest: XCTestCase, XCTestCaseProvider {
    func testToMatcher_CustomFailureMessage() {
        failsWithErrorMessage(
            """
            These aren't equal!
            expected to match, got <1>
            """
        ) {
            expect(1).to(MatcherFunc { _, _ in false }, description: "These aren't equal!")
        }
    }

    func testNotToMatcher_CustomFailureMessage() {
        failsWithErrorMessage(
            """
            These aren't equal!
            expected to not match, got <1>
            """
        ) {
            expect(1).notTo(MatcherFunc { _, _ in true }, description: "These aren't equal!")
        }
    }

    func testToNotMatcher_CustomFailureMessage() {
        failsWithErrorMessage(
            """
            These aren't equal!
            expected to not match, got <1>
            """
        ) {
            expect(1).toNot(MatcherFunc { _, _ in true }, description: "These aren't equal!")
        }
    }

    func testToEventuallyMatch_CustomFailureMessage() {
        failsWithErrorMessage(
            """
            These aren't eventually equal!
            expected to eventually equal <1>, got <0>
            """
        ) {
            expect { 0 }.toEventually(equal(1), description: "These aren't eventually equal!")
        }
    }

    func testToEventuallyNotMatch_CustomFailureMessage() {
        failsWithErrorMessage(
            """
            These are eventually equal!
            expected to eventually not equal <1>, got <1>
            """
        ) {
            expect { 1 }.toEventuallyNot(equal(1), description: "These are eventually equal!")
        }
    }

    func testToNotEventuallyMatch_CustomFailureMessage() {
        failsWithErrorMessage(
            """
            These are eventually equal!
            expected to eventually not equal <1>, got <1>
            """
        ) {
            expect { 1 }.toEventuallyNot(equal(1), description: "These are eventually equal!")
        }
    }

}
