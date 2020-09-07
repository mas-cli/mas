import Foundation
import XCTest
import Nimble

@available(*, deprecated)
final class SynchronousDeprecatedTest: XCTestCase {
    func testToMatchesIfMatcherReturnsTrue() {
        expect(1).to(MatcherFunc { _, _ in true })
        expect {1}.to(MatcherFunc { _, _ in true })

        expect(1).to(MatcherFunc { _, _ in true }.predicate)
        expect {1}.to(MatcherFunc { _, _ in true }.predicate)
    }

    func testToProvidesActualValueExpression() {
        var value: Int?
        expect(1).to(MatcherFunc { expr, _ in value = try expr.evaluate(); return true })
        expect(value).to(equal(1))
    }

    func testToProvidesAMemoizedActualValueExpression() {
        var callCount = 0
        expect { callCount += 1 }.to(MatcherFunc { expr, _ in
            _ = try expr.evaluate()
            _ = try expr.evaluate()
            return true
        })
        expect(callCount).to(equal(1))
    }

    func testToProvidesAMemoizedActualValueExpressionIsEvaluatedAtMatcherControl() {
        var callCount = 0
        expect { callCount += 1 }.to(MatcherFunc { expr, _ in
            expect(callCount).to(equal(0))
            _ = try expr.evaluate()
            return true
        })
        expect(callCount).to(equal(1))
    }

    // repeated tests from to() for toNot()
    func testToNotMatchesIfMatcherReturnsTrue() {
        expect(1).toNot(MatcherFunc { _, _ in false })
        expect {1}.toNot(MatcherFunc { _, _ in false })

        expect(1).toNot(MatcherFunc { _, _ in false }.predicate)
        expect {1}.toNot(MatcherFunc { _, _ in false }.predicate)
    }

    func testToNotProvidesActualValueExpression() {
        var value: Int?
        expect(1).toNot(MatcherFunc { expr, _ in value = try expr.evaluate(); return false })
        expect(value).to(equal(1))
    }

    func testToNotProvidesAMemoizedActualValueExpression() {
        var callCount = 0
        expect { callCount += 1 }.toNot(MatcherFunc { expr, _ in
            _ = try expr.evaluate()
            _ = try expr.evaluate()
            return false
        })
        expect(callCount).to(equal(1))
    }

    func testToNotProvidesAMemoizedActualValueExpressionIsEvaluatedAtMatcherControl() {
        var callCount = 0
        expect { callCount += 1 }.toNot(MatcherFunc { expr, _ in
            expect(callCount).to(equal(0))
            _ = try expr.evaluate()
            return false
        })
        expect(callCount).to(equal(1))
    }

    func testToNegativeMatches() {
        failsWithErrorMessage("expected to match, got <1>") {
            expect(1).to(MatcherFunc { _, _ in false })
        }
        failsWithErrorMessage("expected to match, got <1>") {
            expect(1).to(MatcherFunc { _, _ in false }.predicate)
        }
    }

    func testToNotNegativeMatches() {
        failsWithErrorMessage("expected to not match, got <1>") {
            expect(1).toNot(MatcherFunc { _, _ in true })
        }
        failsWithErrorMessage("expected to not match, got <1>") {
            expect(1).toNot(MatcherFunc { _, _ in true }.predicate)
        }
    }

    func testNotToMatchesLikeToNot() {
        expect(1).notTo(MatcherFunc { _, _ in false })
        expect(1).notTo(MatcherFunc { _, _ in false }.predicate)
    }
}
