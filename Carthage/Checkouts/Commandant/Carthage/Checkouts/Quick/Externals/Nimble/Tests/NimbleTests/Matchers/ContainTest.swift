import Foundation
import XCTest
import Nimble

final class ContainTest: XCTestCase, XCTestCaseProvider {
    static var allTests: [(String, (ContainTest) -> () throws -> Void)] {
        return [
            ("testContain", testContain),
            ("testContainSubstring", testContainSubstring),
            ("testContainObjCSubstring", testContainObjCSubstring),
            ("testVariadicArguments", testVariadicArguments),
            ("testCollectionArguments", testCollectionArguments),
        ]
    }

    func testContain() {
        expect([1, 2, 3]).to(contain(1))
        expect([1, 2, 3] as [CInt]).to(contain(1 as CInt))
        expect([1, 2, 3] as [CInt]).toNot(contain(4 as CInt))
        expect(["foo", "bar", "baz"]).to(contain("baz"))
        expect([1, 2, 3]).toNot(contain(4))
        expect(["foo", "bar", "baz"]).toNot(contain("ba"))
#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
        expect(NSArray(array: ["a"])).to(contain(NSString(string: "a")))
        expect(NSArray(array: ["a"])).toNot(contain(NSString(string: "b")))
        expect(NSArray(object: 1) as NSArray?).to(contain(1))
#endif

        failsWithErrorMessage("expected to contain <bar>, got <[a, b, c]>") {
            expect(["a", "b", "c"]).to(contain("bar"))
        }
        failsWithErrorMessage("expected to not contain <b>, got <[a, b, c]>") {
            expect(["a", "b", "c"]).toNot(contain("b"))
        }

        failsWithErrorMessageForNil("expected to contain <bar>, got <nil>") {
            expect(nil as [String]?).to(contain("bar"))
        }
        failsWithErrorMessageForNil("expected to not contain <b>, got <nil>") {
            expect(nil as [String]?).toNot(contain("b"))
        }
    }

    func testContainSubstring() {
        expect("foo").to(contain("o"))
        expect("foo").to(contain("oo"))
        expect("foo").toNot(contain("z"))
        expect("foo").toNot(contain("zz"))

        failsWithErrorMessage("expected to contain <bar>, got <foo>") {
            expect("foo").to(contain("bar"))
        }
        failsWithErrorMessage("expected to not contain <oo>, got <foo>") {
            expect("foo").toNot(contain("oo"))
        }
    }

    func testContainObjCSubstring() {
        let str = NSString(string: "foo")
        expect(str).to(contain(NSString(string: "o")))
        expect(str).to(contain(NSString(string: "oo")))
        expect(str).toNot(contain(NSString(string: "z")))
        expect(str).toNot(contain(NSString(string: "zz")))
    }

    func testVariadicArguments() {
        expect([1, 2, 3]).to(contain(1, 2))
        expect([1, 2, 3]).toNot(contain(1, 4))

        failsWithErrorMessage("expected to contain <a, bar>, got <[a, b, c]>") {
            expect(["a", "b", "c"]).to(contain("a", "bar"))
        }

        failsWithErrorMessage("expected to not contain <b, a>, got <[a, b, c]>") {
            expect(["a", "b", "c"]).toNot(contain("b", "a"))
        }
    }

    func testCollectionArguments() {
        expect([1, 2, 3]).to(contain([1, 2]))
        expect([1, 2, 3]).toNot(contain([1, 4]))

        let collection = Array(1...10)
        let slice = Array(collection[3...5])
        expect(collection).to(contain(slice))

        failsWithErrorMessage("expected to contain <a, bar>, got <[a, b, c]>") {
            expect(["a", "b", "c"]).to(contain(["a", "bar"]))
        }

        failsWithErrorMessage("expected to not contain <b, a>, got <[a, b, c]>") {
            expect(["a", "b", "c"]).toNot(contain(["b", "a"]))
        }
    }
}
