import Foundation
import XCTest
import Nimble

#if (os(macOS) || os(iOS) || os(tvOS) || os(watchOS)) && !SWIFT_PACKAGE

private let error: Error = NSError(domain: "test", code: 0, userInfo: nil)

final class ThrowAssertionTest: XCTestCase {
    func testPositiveMatch() {
        expect { () -> Void in fatalError() }.to(throwAssertion())
    }

    func testErrorThrown() {
        expect { throw error }.toNot(throwAssertion())
    }

    func testPostAssertionCodeNotRun() {
        var reachedPoint1 = false
        var reachedPoint2 = false

        expect {
            reachedPoint1 = true
            precondition(false, "condition message")
            reachedPoint2 = true
        }.to(throwAssertion())

        expect(reachedPoint1) == true
        expect(reachedPoint2) == false
    }

    func testNegativeMatch() {
        var reachedPoint1 = false

        expect { reachedPoint1 = true }.toNot(throwAssertion())

        expect(reachedPoint1) == true
    }

    func testPositiveMessage() {
        failsWithErrorMessage("expected to throw an assertion") {
            expect { () -> Void? in return }.to(throwAssertion())
        }

        failsWithErrorMessage("expected to throw an assertion; threw error instead <\(error)>") {
            expect { throw error }.to(throwAssertion())
        }
    }

    func testNegativeMessage() {
        failsWithErrorMessage("expected to not throw an assertion") {
            expect { () -> Void in fatalError() }.toNot(throwAssertion())
        }
    }
}

#endif
