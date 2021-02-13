import Foundation
import XCTest
import Nimble

final class BeLessThanTest: XCTestCase {
    func testLessThan() {
        expect(2).to(beLessThan(10))
        expect(2).toNot(beLessThan(1))
        expect(2 as NSNumber).to(beLessThan(10 as NSNumber))
        expect(2 as NSNumber).toNot(beLessThan(1 as NSNumber))

        failsWithErrorMessage("expected to be less than <0>, got <2>") {
            expect(2).to(beLessThan(0))
        }
        failsWithErrorMessage("expected to not be less than <1>, got <0>") {
            expect(0).toNot(beLessThan(1))
        }

        failsWithErrorMessageForNil("expected to be less than <2>, got <nil>") {
            expect(nil as Int?).to(beLessThan(2))
        }
        failsWithErrorMessageForNil("expected to not be less than <-1>, got <nil>") {
            expect(nil as Int?).toNot(beLessThan(-1))
        }
    }

    func testLessThanOperator() {
        expect(0) < 1
        expect(0 as NSNumber) < 1 as NSNumber
        failsWithErrorMessage("expected to be less than <1>, got <2>") {
            expect(2) < 1
            return
        }
    }
}
