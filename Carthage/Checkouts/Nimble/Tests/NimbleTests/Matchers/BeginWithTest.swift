import Foundation
import XCTest
import Nimble

final class BeginWithTest: XCTestCase, XCTestCaseProvider {
    func testPositiveMatches() {
        expect([1, 2, 3]).to(beginWith(1))
        expect([1, 2, 3]).toNot(beginWith(2))

        expect("foobar").to(beginWith("foo"))
        expect("foobar").toNot(beginWith("oo"))

        expect("foobarfoo").to(beginWith("foo"))

        expect(NSString(string: "foobar").description).to(beginWith("foo"))
        expect(NSString(string: "foobar").description).toNot(beginWith("oo"))

        expect(NSArray(array: ["a", "b"])).to(beginWith("a"))
        expect(NSArray(array: ["a", "b"])).toNot(beginWith("b"))
    }

    func testNegativeMatches() {
        failsWithErrorMessageForNil("expected to begin with <b>, got <nil>") {
            expect(nil as NSArray?).to(beginWith(NSString(string: "b")))
        }
        failsWithErrorMessageForNil("expected to not begin with <b>, got <nil>") {
            expect(nil as NSArray?).toNot(beginWith(NSString(string: "b")))
        }

        failsWithErrorMessage("expected to begin with <2>, got <[1, 2, 3]>") {
            expect([1, 2, 3]).to(beginWith(2))
        }
        failsWithErrorMessage("expected to not begin with <1>, got <[1, 2, 3]>") {
            expect([1, 2, 3]).toNot(beginWith(1))
        }
        failsWithErrorMessage("expected to begin with <atm>, got <batman>") {
            expect("batman").to(beginWith("atm"))
        }
        failsWithErrorMessage("expected to not begin with <bat>, got <batman>") {
            expect("batman").toNot(beginWith("bat"))
        }
    }

}
