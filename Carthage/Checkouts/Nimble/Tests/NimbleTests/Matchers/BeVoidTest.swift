import XCTest
import Nimble

final class BeVoidTest: XCTestCase, XCTestCaseProvider {
    static var allTests: [(String, (BeVoidTest) -> () throws -> Void)] {
        return [
            ("testBeVoid", testBeVoid),
        ]
    }

    func testBeVoid() {
        expect(()).to(beVoid())
        expect(() as ()?).to(beVoid())
        expect(nil as ()?).toNot(beVoid())

        expect(()) == ()
        expect(() as ()?) == ()
        expect(nil as ()?) != ()

        failsWithErrorMessage("expected to not be void, got <()>") {
            expect(()).toNot(beVoid())
        }

        failsWithErrorMessage("expected to not be void, got <()>") {
            expect(() as ()?).toNot(beVoid())
        }

        failsWithErrorMessage("expected to be void, got <nil>") {
            expect(nil as ()?).to(beVoid())
        }
    }
}
