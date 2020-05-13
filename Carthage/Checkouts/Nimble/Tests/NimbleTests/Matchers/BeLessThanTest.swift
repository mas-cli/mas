import Foundation
import XCTest
import Nimble

final class BeLessThanTest: XCTestCase, XCTestCaseProvider {
    func testLessThan() {
        expect(2).to(beLessThan(10))
        expect(2).toNot(beLessThan(1))
#if SUPPORT_IMPLICIT_BRIDGING_CONVERSION
        expect(NSNumber(value: 2)).to(beLessThan(10))
        expect(NSNumber(value: 2)).toNot(beLessThan(1))

        expect(2).to(beLessThan(NSNumber(value: 10)))
        expect(2).toNot(beLessThan(NSNumber(value: 1)))
#else
        expect(NSNumber(value: 2)).to(beLessThan(10 as NSNumber))
        expect(NSNumber(value: 2)).toNot(beLessThan(1 as NSNumber))

        expect(2 as NSNumber).to(beLessThan(NSNumber(value: 10)))
        expect(2 as NSNumber).toNot(beLessThan(NSNumber(value: 1)))
#endif

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
#if SUPPORT_IMPLICIT_BRIDGING_CONVERSION
        expect(NSNumber(value: 0)) < 1
#else
        expect(NSNumber(value: 0)) < 1 as NSNumber
#endif
        failsWithErrorMessage("expected to be less than <1>, got <2>") {
            expect(2) < 1
            return
        }
    }
}
