import XCTest
import Nimble

final class PredicateTest: XCTestCase {
    func testDefineDefaultMessage() {
        failsWithErrorMessage("expected to match, got <1>") {
            expect(1).to(Predicate.define { _, msg in PredicateResult(status: .fail, message: msg) })
        }
    }

    func testDefineNilableDefaultMessage() {
        failsWithErrorMessage("expected to match, got <1>") {
            expect(1).to(Predicate.defineNilable { _, msg in PredicateResult(status: .fail, message: msg) })
        }
    }

    func testSimpleDefaultMessage() {
        failsWithErrorMessage("expected to match, got <1>") {
            expect(1).to(Predicate.simple { _ in .fail })
        }
    }

    func testSimpleNilableDefaultMessage() {
        failsWithErrorMessage("expected to match, got <1>") {
            expect(1).to(Predicate.simpleNilable { _ in .fail })
        }
    }
}
