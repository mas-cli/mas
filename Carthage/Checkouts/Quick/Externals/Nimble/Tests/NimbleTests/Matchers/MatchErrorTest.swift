import Foundation
import XCTest
import Nimble

final class MatchErrorTest: XCTestCase, XCTestCaseProvider {
    func testMatchErrorPositive() {
        expect(NimbleError.laugh).to(matchError(NimbleError.laugh))
        expect(NimbleError.laugh).to(matchError(NimbleError.self))
        expect(EquatableError.parameterized(x: 1)).to(matchError(EquatableError.parameterized(x: 1)))

        expect(NimbleError.laugh as Error).to(matchError(NimbleError.laugh))
    }

    func testMatchErrorNegative() {
        expect(NimbleError.laugh).toNot(matchError(NimbleError.cry))
        expect(NimbleError.laugh as Error).toNot(matchError(NimbleError.cry))
        expect(NimbleError.laugh).toNot(matchError(EquatableError.self))
        expect(EquatableError.parameterized(x: 1)).toNot(matchError(EquatableError.parameterized(x: 2)))
    }

    func testMatchNSErrorPositive() {
#if canImport(Darwin)
        let error1 = NSError(domain: "err", code: 0, userInfo: nil)
        let error2 = NSError(domain: "err", code: 0, userInfo: nil)

        expect(error1).to(matchError(error2))
#endif
    }

    func testMatchNSErrorNegative() {
        let error1 = NSError(domain: "err", code: 0, userInfo: nil)
        let error2 = NSError(domain: "err", code: 1, userInfo: nil)

        expect(error1).toNot(matchError(error2))
    }

    func testMatchPositiveMessage() {
        failsWithErrorMessage("expected to match error <parameterized(x: 2)>, got <parameterized(x: 1)>") {
            expect(EquatableError.parameterized(x: 1)).to(matchError(EquatableError.parameterized(x: 2)))
        }
        failsWithErrorMessage("expected to match error <cry>, got <laugh>") {
            expect(NimbleError.laugh).to(matchError(NimbleError.cry))
        }
        failsWithErrorMessage("expected to match error <code=1>, got <code=0>") {
            expect(CustomDebugStringConvertibleError.a).to(matchError(CustomDebugStringConvertibleError.b))
        }

#if canImport(Darwin)
        failsWithErrorMessage("expected to match error <Error Domain=err Code=1 \"(null)\">, got <Error Domain=err Code=0 \"(null)\">") {
            let error1 = NSError(domain: "err", code: 0, userInfo: nil)
            let error2 = NSError(domain: "err", code: 1, userInfo: nil)
            expect(error1).to(matchError(error2))
        }
#endif
    }

    func testMatchNegativeMessage() {
        failsWithErrorMessage("expected to not match error <laugh>, got <laugh>") {
            expect(NimbleError.laugh).toNot(matchError(NimbleError.laugh))
        }

        failsWithErrorMessage("expected to match error from type <EquatableError>, got <laugh>") {
            expect(NimbleError.laugh).to(matchError(EquatableError.self))
        }
    }

    func testDoesNotMatchNils() {
        failsWithErrorMessageForNil("expected to match error <laugh>, got no error") {
            expect(nil as Error?).to(matchError(NimbleError.laugh))
        }

        failsWithErrorMessageForNil("expected to not match error <laugh>, got no error") {
            expect(nil as Error?).toNot(matchError(NimbleError.laugh))
        }
    }
}
