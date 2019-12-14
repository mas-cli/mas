import Foundation
import XCTest
import Nimble

final class ContainTest: XCTestCase, XCTestCaseProvider {
    func testContainSequence() {
        expect([1, 2, 3]).to(contain(1))
        expect([1, 2, 3]).toNot(contain(4))
        expect([1, 2, 3] as [CInt]).to(contain(1 as CInt))
        expect([1, 2, 3] as [CInt]).toNot(contain(4 as CInt))
        expect(["foo", "bar", "baz"]).to(contain("baz"))
        expect(["foo", "bar", "baz"]).toNot(contain("ba"))
#if canImport(Darwin)
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

    func testContainSetAlgebra() {
        expect([.a, .b, .c] as TestOptionSet).to(contain(.a))
        expect([.a, .b, .c] as TestOptionSet).toNot(contain(.d))

        failsWithErrorMessage("expected to contain <8>, got <7>") {
            expect([.a, .b, .c] as TestOptionSet).to(contain(.d))
        }
        failsWithErrorMessage("expected to not contain <2>, got <7>") {
            expect([.a, .b, .c] as TestOptionSet).toNot(contain(.b))
        }

        failsWithErrorMessageForNil("expected to contain <1>, got <nil>") {
            expect(nil as TestOptionSet?).to(contain(.a))
        }
        failsWithErrorMessageForNil("expected to not contain <1>, got <nil>") {
            expect(nil as TestOptionSet?).toNot(contain(.a))
        }
    }

    func testContainSequenceAndSetAlgebra() {
        let set = [1, 2, 3] as Set<Int>

        expect(set).to(contain(1))
        expect(set).toNot(contain(4))

        failsWithErrorMessage("expected to contain <4>, got <\(set.debugDescription)>") {
            expect(set).to(contain(4))
        }
        failsWithErrorMessage("expected to not contain <2>, got <\(set.debugDescription)>") {
            expect(set).toNot(contain(2))
        }

        failsWithErrorMessageForNil("expected to contain <1>, got <nil>") {
            expect(nil as Set<Int>?).to(contain(1))
        }
        failsWithErrorMessageForNil("expected to not contain <1>, got <nil>") {
            expect(nil as Set<Int>?).toNot(contain(1))
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

private struct TestOptionSet: OptionSet, CustomStringConvertible {
    let rawValue: Int

    // swiftlint:disable identifier_name
    static let a = TestOptionSet(rawValue: 1 << 0)
    static let b = TestOptionSet(rawValue: 1 << 1)
    static let c = TestOptionSet(rawValue: 1 << 2)
    static let d = TestOptionSet(rawValue: 1 << 3)
    static let e = TestOptionSet(rawValue: 1 << 4)
    // swiftlint:enable identifier_name

    init(rawValue: Int) {
        self.rawValue = rawValue
    }

    var description: String {
        return "\(rawValue)"
    }
}
