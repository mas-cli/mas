import Foundation
import XCTest
import Nimble

final class BeEmptyTest: XCTestCase {
    func testBeEmptyPositive() {
        expect([] as [Int]).to(beEmpty())
        expect([1]).toNot(beEmpty())

        expect([] as [CInt]).to(beEmpty())
        expect([1] as [CInt]).toNot(beEmpty())

        expect([] as Set<Int>).to(beEmpty())
        expect([1] as Set<Int>).toNot(beEmpty())

        expect(NSDictionary() as? [Int: Int]).to(beEmpty())
        expect(([1: 1] as NSDictionary) as? [Int: Int]).toNot(beEmpty())

        expect([Int: Int]()).to(beEmpty())
        expect(["hi": 1]).toNot(beEmpty())

        expect(NSArray() as? [Int]).to(beEmpty())
        expect(([1] as NSArray) as? [Int]).toNot(beEmpty())

        expect(NSSet()).to(beEmpty())
        expect(NSSet(array: [1 as NSNumber])).toNot(beEmpty())

        expect(NSIndexSet()).to(beEmpty())
        expect(NSIndexSet(index: 1)).toNot(beEmpty())

        expect(NSString()).to(beEmpty())
        expect("hello" as NSString).toNot(beEmpty())

        expect("").to(beEmpty())
        expect("foo").toNot(beEmpty())

        expect([] as TestOptionSet).to(beEmpty())
        expect(TestOptionSet.one).toNot(beEmpty())
    }

    func testBeEmptyNegative() {
        failsWithErrorMessage("expected to not be empty, got <()>") {
            expect(NSArray()).toNot(beEmpty())
        }
        failsWithErrorMessage("expected to be empty, got <[1]>") {
            expect([1]).to(beEmpty())
        }

        failsWithErrorMessage("expected to not be empty, got <Set([])>") {
            expect([] as Set<Int>).toNot(beEmpty())
        }
        failsWithErrorMessage("expected to be empty, got <Set([1])>") {
            expect([1] as Set<Int>).to(beEmpty())
        }

        failsWithErrorMessage("expected to not be empty, got <{()}>") {
            expect(NSSet()).toNot(beEmpty())
        }
        failsWithErrorMessage("expected to be empty, got <{(1)}>") {
            expect(NSSet(object: 1 as NSNumber)).to(beEmpty())
        }

        failsWithErrorMessage("expected to not be empty, got <()>") {
            expect(NSIndexSet()).toNot(beEmpty())
        }
        failsWithErrorMessage("expected to be empty, got <(1)>") {
            expect(NSIndexSet(index: 1)).to(beEmpty())
        }

        failsWithErrorMessage("expected to not be empty, got <>") {
            expect("").toNot(beEmpty())
        }
        failsWithErrorMessage("expected to be empty, got <foo>") {
            expect("foo").to(beEmpty())
        }

        failsWithErrorMessage("expected to not be empty, got <TestOptionSet(rawValue: 0)>") {
            expect([] as TestOptionSet).toNot(beEmpty())
        }
        failsWithErrorMessage("expected to be empty, got <TestOptionSet(rawValue: 1)>") {
            expect(TestOptionSet.one).to(beEmpty())
        }
    }

    func testNilMatches() {
        failsWithErrorMessageForNil("expected to be empty, got <nil>") {
            expect(nil as String?).to(beEmpty())
        }
        failsWithErrorMessageForNil("expected to not be empty, got <nil>") {
            expect(nil as String?).toNot(beEmpty())
        }

        failsWithErrorMessageForNil("expected to be empty, got <nil>") {
            expect(nil as NSString?).to(beEmpty())
        }
        failsWithErrorMessageForNil("expected to not be empty, got <nil>") {
            expect(nil as NSString?).toNot(beEmpty())
        }

        failsWithErrorMessageForNil("expected to be empty, got <nil>") {
            expect(nil as [CInt]?).to(beEmpty())
        }
        failsWithErrorMessageForNil("expected to not be empty, got <nil>") {
            expect(nil as [CInt]?).toNot(beEmpty())
        }

        failsWithErrorMessageForNil("expected to be empty, got <nil>") {
            expect(nil as Set<Int>?).to(beEmpty())
        }
        failsWithErrorMessageForNil("expected to not be empty, got <nil>") {
            expect(nil as Set<Int>?).toNot(beEmpty())
        }

        failsWithErrorMessageForNil("expected to be empty, got <nil>") {
            expect(nil as TestOptionSet?).to(beEmpty())
        }
        failsWithErrorMessageForNil("expected to not be empty, got <nil>") {
            expect(nil as TestOptionSet?).toNot(beEmpty())
        }
    }
}

private struct TestOptionSet: OptionSet, CustomStringConvertible {
    let rawValue: Int

    static let one = TestOptionSet(rawValue: 1 << 0)

    init(rawValue: Int) {
        self.rawValue = rawValue
    }

    var description: String {
        return "TestOptionSet(rawValue: \(rawValue))"
    }
}
