import Foundation
import XCTest
import Nimble

final class EndWithTest: XCTestCase {
    func testEndWithPositives() {
        expect([1, 2, 3]).to(endWith(3))
        expect([1, 2, 3]).toNot(endWith(2))
        expect([]).toNot(endWith(1))
        expect(["a", "b", "a"]).to(endWith("a"))

        expect("foobar").to(endWith("bar"))
        expect("foobar").toNot(endWith("oo"))
        expect("foobarfoo").to(endWith("foo"))

        expect(("foobar" as NSString).description).to(endWith("bar"))
        expect(("foobar" as NSString).description).toNot(endWith("oo"))

        expect(["a", "b"] as NSArray).to(endWith("b"))
        expect(["a", "b"] as NSArray).toNot(endWith("a"))
        expect([] as NSArray).toNot(endWith("a"))
        expect(["a", "b", "a"] as NSArray).to(endWith("a"))
    }

    func testEndWithNegatives() {
        failsWithErrorMessageForNil("expected to end with <2>, got <nil>") {
            expect(nil as [Int]?).to(endWith(2))
        }
        failsWithErrorMessageForNil("expected to not end with <2>, got <nil>") {
            expect(nil as [Int]?).toNot(endWith(2))
        }

        failsWithErrorMessage("expected to end with <2>, got <[1, 2, 3]>") {
            expect([1, 2, 3]).to(endWith(2))
        }
        failsWithErrorMessage("expected to not end with <3>, got <[1, 2, 3]>") {
            expect([1, 2, 3]).toNot(endWith(3))
        }
        failsWithErrorMessage("expected to end with <atm>, got <batman>") {
            expect("batman").to(endWith("atm"))
        }
        failsWithErrorMessage("expected to not end with <man>, got <batman>") {
            expect("batman").toNot(endWith("man"))
        }
    }

}
