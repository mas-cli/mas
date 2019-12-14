import Foundation
import XCTest
import Nimble

final class BeLessThanOrEqualToTest: XCTestCase, XCTestCaseProvider {
    func testLessThanOrEqualTo() {
        expect(10).to(beLessThanOrEqualTo(10))
        expect(2).to(beLessThanOrEqualTo(10))
        expect(2).toNot(beLessThanOrEqualTo(1))

        expect(NSNumber(value: 2)).to(beLessThanOrEqualTo(10))
        expect(NSNumber(value: 2)).toNot(beLessThanOrEqualTo(1))
        expect(2).to(beLessThanOrEqualTo(NSNumber(value: 10)))
        expect(2).toNot(beLessThanOrEqualTo(NSNumber(value: 1)))

        failsWithErrorMessage("expected to be less than or equal to <0>, got <2>") {
            expect(2).to(beLessThanOrEqualTo(0))
            return
        }
        failsWithErrorMessage("expected to not be less than or equal to <0>, got <0>") {
            expect(0).toNot(beLessThanOrEqualTo(0))
            return
        }
        failsWithErrorMessageForNil("expected to be less than or equal to <2>, got <nil>") {
            expect(nil as Int?).to(beLessThanOrEqualTo(2))
            return
        }
        failsWithErrorMessageForNil("expected to not be less than or equal to <-2>, got <nil>") {
            expect(nil as Int?).toNot(beLessThanOrEqualTo(-2))
            return
        }
    }

    func testLessThanOrEqualToOperator() {
        expect(0) <= 1
        expect(1) <= 1

        failsWithErrorMessage("expected to be less than or equal to <1>, got <2>") {
            expect(2) <= 1
            return
        }
    }
}
