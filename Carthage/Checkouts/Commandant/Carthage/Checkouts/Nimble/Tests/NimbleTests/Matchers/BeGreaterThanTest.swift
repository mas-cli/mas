import Foundation
import XCTest
import Nimble

final class BeGreaterThanTest: XCTestCase, XCTestCaseProvider {
    static var allTests: [(String, (BeGreaterThanTest) -> () throws -> Void)] {
        return [
            ("testGreaterThan", testGreaterThan),
            ("testGreaterThanOperator", testGreaterThanOperator),
        ]
    }

    func testGreaterThan() {
        expect(10).to(beGreaterThan(2))
        expect(1).toNot(beGreaterThan(2))
#if SUPPORT_IMPLICIT_BRIDGING_CONVERSION
        expect(NSNumber(value: 3)).to(beGreaterThan(2))
#else
        expect(NSNumber(value: 3)).to(beGreaterThan(2 as NSNumber))
#endif
        expect(NSNumber(value: 1)).toNot(beGreaterThan(NSNumber(value: 2)))

        failsWithErrorMessage("expected to be greater than <2>, got <0>") {
            expect(0).to(beGreaterThan(2))
        }
        failsWithErrorMessage("expected to not be greater than <0>, got <1>") {
            expect(1).toNot(beGreaterThan(0))
        }
        failsWithErrorMessageForNil("expected to be greater than <-2>, got <nil>") {
            expect(nil as Int?).to(beGreaterThan(-2))
        }
        failsWithErrorMessageForNil("expected to not be greater than <0>, got <nil>") {
            expect(nil as Int?).toNot(beGreaterThan(0))
        }
    }

    func testGreaterThanOperator() {
        expect(1) > 0
        expect(NSNumber(value: 1)) > NSNumber(value: 0)
#if SUPPORT_IMPLICIT_BRIDGING_CONVERSION
        expect(NSNumber(value: 1)) > 0
#else
        expect(NSNumber(value: 1)) > 0 as NSNumber
#endif
        expect(2.5) > 1.5
        expect(Float(2.5)) > Float(1.5)

        failsWithErrorMessage("expected to be greater than <2>, got <1>") {
            expect(1) > 2
            return
        }
    }
}
