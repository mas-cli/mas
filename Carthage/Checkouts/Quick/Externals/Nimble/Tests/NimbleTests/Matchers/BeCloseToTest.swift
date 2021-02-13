import Foundation
import XCTest
import Nimble

final class BeCloseToTest: XCTestCase {
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

        failsWithErrorMessage("expected to not be close to <1.2001> (within 1.1), got <1.2>") {
            expect(1.2).toNot(beCloseTo(1.2001, within: 1.1))
        }
    }

    func testBeCloseToWithNSNumber() {
        expect(1.2 as NSNumber).to(beCloseTo(9.300, within: 10))
        expect(1.2 as NSNumber).to(beCloseTo(9.300 as NSNumber, within: 10))
        expect(1.2).to(beCloseTo(9.300 as NSNumber, within: 10))

        failsWithErrorMessage("expected to not be close to <1.2001> (within 1.1), got <1.2>") {
            expect(1.2 as NSNumber).toNot(beCloseTo(1.2001, within: 1.1))
        }
    }

    func testBeCloseToWithCGFloat() {
        expect(CGFloat(1.2)).to(beCloseTo(1.2001))
        expect(CGFloat(1.2)).to(beCloseTo(CGFloat(1.2001)))

        failsWithErrorMessage("expected to not be close to <1.2001> (within 1.1), got <1.2>") {
            expect(CGFloat(1.2)).toNot(beCloseTo(1.2001, within: 1.1))
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
            // Cast to NSDate is needed for Linux (swift-corelibs-foundation) compatibility.
            let expectedDate = NSDate(dateTimeString: "2015-08-26 11:43:00").addingTimeInterval(0.005) as NSDate
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

        failsWithErrorMessage("expected to be close to <1.1> (within 0.1), got <1.3>") {
            expect(1.3) ≈ (1.1, 0.1)
        }
        failsWithErrorMessage("expected to be close to <1.1> (within 0.1), got <1.3>") {
            expect(1.3) == (1.1, 0.1)
        }
    }

    func testPlusMinusOperator() {
        expect(1.2) ≈ 9.300 ± 10
        expect(1.2) == 9.300 ± 10

        failsWithErrorMessage("expected to be close to <1.1> (within 0.1), got <1.3>") {
            expect(1.3) ≈ 1.1 ± 0.1
        }
        failsWithErrorMessage("expected to be close to <1.1> (within 0.1), got <1.3>") {
            expect(1.3) == 1.1 ± 0.1
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

        failsWithErrorMessage("expected to be close to <[0.1, 1.1]> (each within 0.0001), got <[0.1, 1.2]>") {
            expect([0.1, 1.2]) ≈ [0.1, 1.1]
        }
        failsWithErrorMessage("expected to be close to <[0.3, 1.3]> (each within 0.1), got <[0.1, 1.2]>") {
            expect([0.1, 1.2]).to(beCloseTo([0.3, 1.3], within: 0.1))
        }
    }

    // https://github.com/Quick/Nimble/issues/831
    func testCombinationWithAllPass() {
        let values: [NSNumber] = [0]
        expect(values).to(allPass(beCloseTo(0)))
    }
}
