import Foundation
import XCTest
import Nimble

final class EndWithTest: XCTestCase, XCTestCaseProvider {
    static var allTests: [(String, (EndWithTest) -> () throws -> Void)] {
        return [
            ("testEndWithPositives", testEndWithPositives),
            ("testEndWithNegatives", testEndWithNegatives),
        ]
    }

    func testEndWithPositives() {
        expect([1, 2, 3]).to(endWith(3))
        expect([1, 2, 3]).toNot(endWith(2))
        expect([]).toNot(endWith(1))
        expect(["a", "b", "a"]).to(endWith("a"))

        expect("foobar").to(endWith("bar"))
        expect("foobar").toNot(endWith("oo"))
        expect("foobarfoo").to(endWith("foo"))

        expect(NSString(string: "foobar").description).to(endWith("bar"))
        expect(NSString(string: "foobar").description).toNot(endWith("oo"))

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
        expect(NSArray(array: ["a", "b"])).to(endWith("b"))
        expect(NSArray(array: ["a", "b"])).toNot(endWith("a"))
        expect(NSArray(array: [])).toNot(endWith("a"))
        expect(NSArray(array: ["a", "b", "a"])).to(endWith("a"))
#endif
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
