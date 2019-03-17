import Foundation
import XCTest
import Nimble

final class BeGreaterThanOrEqualToTest: XCTestCase, XCTestCaseProvider {
    func testGreaterThanOrEqualTo() {
        expect(10).to(beGreaterThanOrEqualTo(10))
        expect(10).to(beGreaterThanOrEqualTo(2))
        expect(1).toNot(beGreaterThanOrEqualTo(2))
        expect(NSNumber(value: 1)).toNot(beGreaterThanOrEqualTo(2))
        expect(NSNumber(value: 2)).to(beGreaterThanOrEqualTo(NSNumber(value: 2)))
#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
        expect(1).to(beGreaterThanOrEqualTo(NSNumber(value: 0)))
#endif

        failsWithErrorMessage("expected to be greater than or equal to <2>, got <0>") {
            expect(0).to(beGreaterThanOrEqualTo(2))
            return
        }
        failsWithErrorMessage("expected to not be greater than or equal to <1>, got <1>") {
            expect(1).toNot(beGreaterThanOrEqualTo(1))
            return
        }
        failsWithErrorMessageForNil("expected to be greater than or equal to <-2>, got <nil>") {
            expect(nil as Int?).to(beGreaterThanOrEqualTo(-2))
        }
        failsWithErrorMessageForNil("expected to not be greater than or equal to <1>, got <nil>") {
            expect(nil as Int?).toNot(beGreaterThanOrEqualTo(1))
        }
    }

    func testGreaterThanOrEqualToOperator() {
        expect(0) >= 0
        expect(1) >= 0
        expect(NSNumber(value: 1)) >= 1
        expect(NSNumber(value: 1)) >= NSNumber(value: 1)
        expect(2.5) >= 2.5
        expect(2.5) >= 2
        expect(Float(2.5)) >= Float(2.5)
        expect(Float(2.5)) >= 2

        failsWithErrorMessage("expected to be greater than or equal to <2>, got <1>") {
            expect(1) >= 2
            return
        }
    }
}
