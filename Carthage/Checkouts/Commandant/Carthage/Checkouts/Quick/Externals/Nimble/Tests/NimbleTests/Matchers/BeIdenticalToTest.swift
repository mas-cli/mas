import Foundation
import XCTest
@testable import Nimble

final class BeIdenticalToTest: XCTestCase, XCTestCaseProvider {
    static var allTests: [(String, (BeIdenticalToTest) -> () throws -> Void)] {
        return [
            ("testBeIdenticalToPositive", testBeIdenticalToPositive),
            ("testBeIdenticalToNegative", testBeIdenticalToNegative),
            ("testBeIdenticalToPositiveMessage", testBeIdenticalToPositiveMessage),
            ("testBeIdenticalToNegativeMessage", testBeIdenticalToNegativeMessage),
            ("testOperators", testOperators),
            ("testBeAlias", testBeAlias),
        ]
    }

    func testBeIdenticalToPositive() {
        let value = NSDate()
        expect(value).to(beIdenticalTo(value))
    }

    func testBeIdenticalToNegative() {
        expect(NSNumber(value: 1)).toNot(beIdenticalTo(NSString(string: "yo")))
        expect(NSArray(array: [NSNumber(value: 1)])).toNot(beIdenticalTo(NSArray(array: [NSNumber(value: 1)])))
    }

    func testBeIdenticalToPositiveMessage() {
        let num1 = NSNumber(value: 1)
        let num2 = NSNumber(value: 2)
        let message = "expected to be identical to \(identityAsString(num2)), got \(identityAsString(num1))"
        failsWithErrorMessage(message) {
            expect(num1).to(beIdenticalTo(num2))
        }
    }

    func testBeIdenticalToNegativeMessage() {
        let value1 = NSArray(array: [])
        let value2 = value1
        let message = "expected to not be identical to \(identityAsString(value2)), got \(identityAsString(value1))"
        failsWithErrorMessage(message) {
            expect(value1).toNot(beIdenticalTo(value2))
        }
    }

    func testOperators() {
        let value = NSDate()
        expect(value) === value
        expect(NSNumber(value: 1)) !== NSNumber(value: 2)
    }

    func testBeAlias() {
        let value = NSDate()
        expect(value).to(be(value))
        expect(NSNumber(value: 1)).toNot(be(NSString(string: "turtles")))
        #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
            expect([1]).toNot(be([1]))
        #else
            expect(NSArray(array: [NSNumber(value: 1)])).toNot(beIdenticalTo(NSArray(array: [NSNumber(value: 1)])))
        #endif

        let value1 = NSArray(array: [])
        let value2 = value1
        let message = "expected to not be identical to \(identityAsString(value1)), got \(identityAsString(value2))"
        failsWithErrorMessage(message) {
            expect(value1).toNot(be(value2))
        }
    }
}
