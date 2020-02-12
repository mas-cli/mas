import Foundation
import XCTest
import Nimble

final class BeEmptyTest: XCTestCase, XCTestCaseProvider {
    func testBeEmptyPositive() {
        expect([] as [Int]).to(beEmpty())
        expect([1]).toNot(beEmpty())

        expect([] as [CInt]).to(beEmpty())
        expect([1] as [CInt]).toNot(beEmpty())

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
        expect(NSDictionary() as? [Int: Int]).to(beEmpty())
        expect(NSDictionary(object: 1, forKey: 1 as NSNumber) as? [Int: Int]).toNot(beEmpty())
#endif

        expect([Int: Int]()).to(beEmpty())
        expect(["hi": 1]).toNot(beEmpty())

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
        expect(NSArray() as? [Int]).to(beEmpty())
        expect(NSArray(array: [1]) as? [Int]).toNot(beEmpty())
#endif

        expect(NSSet()).to(beEmpty())
        expect(NSSet(array: [NSNumber(value: 1)])).toNot(beEmpty())

        expect(NSIndexSet()).to(beEmpty())
        expect(NSIndexSet(index: 1)).toNot(beEmpty())

        expect(NSString()).to(beEmpty())
        expect(NSString(string: "hello")).toNot(beEmpty())

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

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
        failsWithErrorMessage("expected to not be empty, got <{()}>") {
            expect(NSSet()).toNot(beEmpty())
        }
        failsWithErrorMessage("expected to be empty, got <{(1)}>") {
            expect(NSSet(object: NSNumber(value: 1))).to(beEmpty())
        }
#endif

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
