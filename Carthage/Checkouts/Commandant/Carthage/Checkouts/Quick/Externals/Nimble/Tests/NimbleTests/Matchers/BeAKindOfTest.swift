import Foundation
import XCTest
import Nimble

private class TestNull: NSNull {}
private protocol TestProtocol {}
private class TestClassConformingToProtocol: TestProtocol {}
private struct TestStructConformingToProtocol: TestProtocol {}

final class BeAKindOfSwiftTest: XCTestCase {
    enum TestEnum {
        case one, two
    }

    func testPositiveMatch() {
        expect(1).to(beAKindOf(Int.self))
        expect(1).toNot(beAKindOf(String.self))
        expect("turtle string").to(beAKindOf(String.self))
        expect("turtle string").toNot(beAKindOf(TestClassConformingToProtocol.self))

        expect(TestEnum.one).to(beAKindOf(TestEnum.self))

        let testProtocolClass = TestClassConformingToProtocol()
        expect(testProtocolClass).to(beAKindOf(TestClassConformingToProtocol.self))
        expect(testProtocolClass).to(beAKindOf(TestProtocol.self))
        expect(testProtocolClass).toNot(beAKindOf(TestStructConformingToProtocol.self))

        let testProtocolStruct = TestStructConformingToProtocol()
        expect(testProtocolStruct).to(beAKindOf(TestStructConformingToProtocol.self))
        expect(testProtocolStruct).to(beAKindOf(TestProtocol.self))
        expect(testProtocolStruct).toNot(beAKindOf(TestClassConformingToProtocol.self))
    }

    func testFailureMessages() {
        failsWithErrorMessage("expected to not be a kind of Int, got <Int instance>") {
            expect(1).toNot(beAKindOf(Int.self))
        }

        let testClass = TestClassConformingToProtocol()
        failsWithErrorMessage("expected to not be a kind of \(String(describing: TestProtocol.self)), got <\(String(describing: TestClassConformingToProtocol.self)) instance>") {
            expect(testClass).toNot(beAKindOf(TestProtocol.self))
        }

        failsWithErrorMessage("expected to be a kind of String, got <Int instance>") {
            expect(1).to(beAKindOf(String.self))
        }
    }
}

final class BeAKindOfObjCTest: XCTestCase {
    func testPositiveMatch() {
        expect(TestNull()).to(beAKindOf(NSNull.self))
        expect(NSObject()).to(beAKindOf(NSObject.self))
        expect(1 as NSNumber).toNot(beAKindOf(NSDate.self))
    }

    func testFailureMessages() {
        failsWithErrorMessageForNil("expected to not be a kind of NSNull, got <nil>") {
            expect(nil as NSNull?).toNot(beAKindOf(NSNull.self))
        }
        failsWithErrorMessageForNil("expected to be a kind of NSString, got <nil>") {
            expect(nil as NSString?).to(beAKindOf(NSString.self))
        }

        #if canImport(Darwin)
        let numberTypeName = "__NSCFNumber"
        #else
        let numberTypeName = "NSNumber"
        #endif
        failsWithErrorMessage("expected to be a kind of NSString, got <\(numberTypeName) instance>") {
            expect(1 as NSNumber).to(beAKindOf(NSString.self))
        }
        failsWithErrorMessage("expected to not be a kind of NSNumber, got <\(numberTypeName) instance>") {
            expect(1 as NSNumber).toNot(beAKindOf(NSNumber.self))
        }
    }
}
