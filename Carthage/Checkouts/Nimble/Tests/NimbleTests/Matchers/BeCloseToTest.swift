import Foundation
import XCTest
import Nimble

final class BeCloseToTest: XCTestCase, XCTestCaseProvider {
    static var allTests: [(String, (BeCloseToTest) -> () throws -> Void)] {
        return [
            ("testBeCloseTo", testBeCloseTo),
            ("testBeCloseToWithin", testBeCloseToWithin),
            ("testBeCloseToWithNSNumber", testBeCloseToWithNSNumber),
            ("testBeCloseToWithDate", testBeCloseToWithDate),
            ("testBeCloseToWithNSDate", testBeCloseToWithNSDate),
            ("testBeCloseToOperator", testBeCloseToOperator),
            ("testBeCloseToWithinOperator", testBeCloseToWithinOperator),
            ("testPlusMinusOperator", testPlusMinusOperator),
            ("testBeCloseToOperatorWithDate", testBeCloseToOperatorWithDate),
            ("testBeCloseToWithinOperatorWithDate", testBeCloseToWithinOperatorWithDate),
            ("testPlusMinusOperatorWithDate", testPlusMinusOperatorWithDate),
            ("testBeCloseToArray", testBeCloseToArray),
            ("testBeCloseToWithCGFloat", testBeCloseToWithCGFloat),
        ]
    }

    func testBeCloseTo() {
        expect(1.2).to(beCloseTo(1.2001))
        expect(1.2 as CDouble).to(beCloseTo(1.2001))
        expect(1.2 as Float).to(beCloseTo(1.2001))

        failsWithErrorMessage("expected to not be close to <1.2001> (within 0.0001), got <1.2>") {
            expect(1.2).toNot(beCloseTo(1.2001))
        }
    }

    func testBeCloseToWithin() {
        expect(1.2).to(beCloseTo(9.300, within: 10))

        failsWithErrorMessage("expected to not be close to <1.2001> (within 1), got <1.2>") {
            expect(1.2).toNot(beCloseTo(1.2001, within: 1.0))
        }
    }

    func testBeCloseToWithNSNumber() {
        expect(NSNumber(value: 1.2)).to(beCloseTo(9.300, within: 10))
        expect(NSNumber(value: 1.2)).to(beCloseTo(NSNumber(value: 9.300), within: 10))
        expect(1.2).to(beCloseTo(NSNumber(value: 9.300), within: 10))

        failsWithErrorMessage("expected to not be close to <1.2001> (within 1), got <1.2>") {
            expect(NSNumber(value: 1.2)).toNot(beCloseTo(1.2001, within: 1.0))
        }
    }

    func testBeCloseToWithCGFloat() {
        expect(CGFloat(1.2)).to(beCloseTo(1.2001))
        expect(CGFloat(1.2)).to(beCloseTo(CGFloat(1.2001)))

        failsWithErrorMessage("expected to not be close to <1.2001> (within 1), got <1.2>") {
            expect(CGFloat(1.2)).toNot(beCloseTo(1.2001, within: 1.0))
        }
    }

    func testBeCloseToWithDate() {
        expect(Date(dateTimeString: "2015-08-26 11:43:00")).to(beCloseTo(Date(dateTimeString: "2015-08-26 11:43:05"), within: 10))

        failsWithErrorMessage("expected to not be close to <2015-08-26 11:43:00.0050> (within 0.006), got <2015-08-26 11:43:00.0000>") {
            let expectedDate = Date(dateTimeString: "2015-08-26 11:43:00").addingTimeInterval(0.005)
            expect(Date(dateTimeString: "2015-08-26 11:43:00")).toNot(beCloseTo(expectedDate, within: 0.006))
        }
    }

    func testBeCloseToWithNSDate() {
        expect(NSDate(dateTimeString: "2015-08-26 11:43:00")).to(beCloseTo(NSDate(dateTimeString: "2015-08-26 11:43:05"), within: 10))

        failsWithErrorMessage("expected to not be close to <2015-08-26 11:43:00.0050> (within 0.006), got <2015-08-26 11:43:00.0000>") {
            let expectedDate = NSDate(dateTimeString: "2015-08-26 11:43:00").addingTimeInterval(0.005)
            expect(NSDate(dateTimeString: "2015-08-26 11:43:00")).toNot(beCloseTo(expectedDate, within: 0.006))
        }
    }

    func testBeCloseToOperator() {
        expect(1.2) ≈ 1.2001
        expect(1.2 as CDouble) ≈ 1.2001

        failsWithErrorMessage("expected to be close to <1.2002> (within 0.0001), got <1.2>") {
            expect(1.2) ≈ 1.2002
        }
    }

    func testBeCloseToWithinOperator() {
        expect(1.2) ≈ (9.300, 10)
        expect(1.2) == (9.300, 10)

        failsWithErrorMessage("expected to be close to <1> (within 0.1), got <1.2>") {
            expect(1.2) ≈ (1.0, 0.1)
        }
        failsWithErrorMessage("expected to be close to <1> (within 0.1), got <1.2>") {
            expect(1.2) == (1.0, 0.1)
        }
    }

    func testPlusMinusOperator() {
        expect(1.2) ≈ 9.300 ± 10
        expect(1.2) == 9.300 ± 10

        failsWithErrorMessage("expected to be close to <1> (within 0.1), got <1.2>") {
            expect(1.2) ≈ 1.0 ± 0.1
        }
        failsWithErrorMessage("expected to be close to <1> (within 0.1), got <1.2>") {
            expect(1.2) == 1.0 ± 0.1
        }
    }

    func testBeCloseToOperatorWithDate() {
        expect(Date(dateTimeString: "2015-08-26 11:43:00")) ≈ Date(dateTimeString: "2015-08-26 11:43:00")

        failsWithErrorMessage("expected to be close to <2015-08-26 11:43:00.0050> (within 0.0001), got <2015-08-26 11:43:00.0000>") {
            let expectedDate = Date(dateTimeString: "2015-08-26 11:43:00").addingTimeInterval(0.005)
            expect(Date(dateTimeString: "2015-08-26 11:43:00")) ≈ expectedDate
        }
    }

    func testBeCloseToWithinOperatorWithDate() {
        expect(Date(dateTimeString: "2015-08-26 11:43:00")) ≈ (Date(dateTimeString: "2015-08-26 11:43:05"), 10)
        expect(Date(dateTimeString: "2015-08-26 11:43:00")) == (Date(dateTimeString: "2015-08-26 11:43:05"), 10)

        failsWithErrorMessage("expected to be close to <2015-08-26 11:43:00.0050> (within 0.004), got <2015-08-26 11:43:00.0000>") {
            let expectedDate = Date(dateTimeString: "2015-08-26 11:43:00").addingTimeInterval(0.005)
            expect(Date(dateTimeString: "2015-08-26 11:43:00")) ≈ (expectedDate, 0.004)
        }
        failsWithErrorMessage("expected to be close to <2015-08-26 11:43:00.0050> (within 0.004), got <2015-08-26 11:43:00.0000>") {
            let expectedDate = Date(dateTimeString: "2015-08-26 11:43:00").addingTimeInterval(0.005)
            expect(Date(dateTimeString: "2015-08-26 11:43:00")) == (expectedDate, 0.004)
        }
    }

    func testPlusMinusOperatorWithDate() {
        expect(Date(dateTimeString: "2015-08-26 11:43:00")) ≈ Date(dateTimeString: "2015-08-26 11:43:05") ± 10
        expect(Date(dateTimeString: "2015-08-26 11:43:00")) == Date(dateTimeString: "2015-08-26 11:43:05") ± 10

        failsWithErrorMessage("expected to be close to <2015-08-26 11:43:00.0050> (within 0.004), got <2015-08-26 11:43:00.0000>") {
            let expectedDate = Date(dateTimeString: "2015-08-26 11:43:00").addingTimeInterval(0.005)
            expect(Date(dateTimeString: "2015-08-26 11:43:00")) ≈ expectedDate ± 0.004
        }
        failsWithErrorMessage("expected to be close to <2015-08-26 11:43:00.0050> (within 0.004), got <2015-08-26 11:43:00.0000>") {
            let expectedDate = Date(dateTimeString: "2015-08-26 11:43:00").addingTimeInterval(0.005)
            expect(Date(dateTimeString: "2015-08-26 11:43:00")) == expectedDate ± 0.004
        }
    }

    func testBeCloseToArray() {
        expect([0.0, 1.1, 2.2]) ≈ [0.0001, 1.1001, 2.2001]
        expect([0.0, 1.1, 2.2]).to(beCloseTo([0.1, 1.2, 2.3], within: 0.1))

        failsWithErrorMessage("expected to be close to <[0, 1]> (each within 0.0001), got <[0, 1.1]>") {
            expect([0.0, 1.1]) ≈ [0.0, 1.0]
        }
        failsWithErrorMessage("expected to be close to <[0.2, 1.2]> (each within 0.1), got <[0, 1.1]>") {
            expect([0.0, 1.1]).to(beCloseTo([0.2, 1.2], within: 0.1))
        }
    }
}
