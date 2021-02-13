import Foundation
import XCTest
@testable import Nimble

final class BeIdenticalToTest: XCTestCase {
    func testBeIdenticalToPositive() {
        let value = NSDate()
        expect(value).to(beIdenticalTo(value))
    }

    func testBeIdenticalToNegative() {
        expect(1 as NSNumber).toNot(beIdenticalTo("yo" as NSString))
        expect([1 as NSNumber] as NSArray).toNot(beIdenticalTo([1 as NSNumber] as NSArray))
    }

    func testBeIdenticalToPositiveMessage() {
        let num1 = 1 as NSNumber
        let num2 = 2 as NSNumber
        let message = "expected to be identical to \(identityAsString(num2)), got \(identityAsString(num1))"
        failsWithErrorMessage(message) {
            expect(num1).to(beIdenticalTo(num2))
        }
    }

    func testBeIdenticalToNegativeMessage() {
        let value1 = NSArray()
        let value2 = value1
        let message = "expected to not be identical to \(identityAsString(value2)), got \(identityAsString(value1))"
        failsWithErrorMessage(message) {
            expect(value1).toNot(beIdenticalTo(value2))
        }
    }

    func testOperators() {
        let value = NSDate()
        expect(value) === value
        expect(1 as NSNumber) !== 2 as NSNumber
    }

    func testBeAlias() {
        let value = NSDate()
        expect(value).to(be(value))
        expect(1 as NSNumber).toNot(be("turtles" as NSString))
        expect([1]).toNot(be([1]))
        expect([1 as NSNumber] as NSArray).toNot(be([1 as NSNumber] as NSArray))

        let value1 = NSArray()
        let value2 = value1
        let message = "expected to not be identical to \(identityAsString(value1)), got \(identityAsString(value2))"
        failsWithErrorMessage(message) {
            expect(value1).toNot(be(value2))
        }
    }
}
