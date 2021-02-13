import Foundation
import XCTest
import Nimble

private let error: Error = NSError(domain: "test", code: 0, userInfo: nil)

final class ThrowAssertionTest: XCTestCase {
    func testPositiveMatch() {
        #if canImport(Darwin)
        expect { () -> Void in fatalError() }.to(throwAssertion())
        #endif
    }

    func testErrorThrown() {
        #if canImport(Darwin)
        expect { throw error }.toNot(throwAssertion())
        #endif
    }

    func testPostAssertionCodeNotRun() {
        #if canImport(Darwin)
        var reachedPoint1 = false
        var reachedPoint2 = false

        expect {
            reachedPoint1 = true
            precondition(false, "condition message")
            reachedPoint2 = true
        }.to(throwAssertion())

        expect(reachedPoint1) == true
        expect(reachedPoint2) == false
        #endif
    }

    func testNegativeMatch() {
        #if canImport(Darwin)
        var reachedPoint1 = false

        expect { reachedPoint1 = true }.toNot(throwAssertion())

        expect(reachedPoint1) == true
        #endif
    }

    func testPositiveMessage() {
        #if canImport(Darwin)
        failsWithErrorMessage("expected to throw an assertion") {
            expect { () -> Void? in return }.to(throwAssertion())
        }

        failsWithErrorMessage("expected to throw an assertion; threw error instead <\(error)>") {
            expect { throw error }.to(throwAssertion())
        }
        #endif
    }

    func testNegativeMessage() {
        #if canImport(Darwin)
        failsWithErrorMessage("expected to not throw an assertion") {
            expect { () -> Void in fatalError() }.toNot(throwAssertion())
        }
        #endif
    }

    func testNonVoidClosure() {
        #if canImport(Darwin)
        expect { () -> Int in fatalError() }.to(throwAssertion())
        #endif
    }

    func testChainOnThrowAssertion() {
        #if canImport(Darwin)
        expect { () -> Int in return 5 }.toNot(throwAssertion()).to(equal(5))
        #endif
    }
}
