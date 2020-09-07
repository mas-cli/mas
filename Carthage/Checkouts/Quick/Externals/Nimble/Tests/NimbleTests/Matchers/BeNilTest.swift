import XCTest
import Nimble

final class BeNilTest: XCTestCase {
    func producesNil() -> [Int]? {
        return nil
    }

    func testBeNil() {
        expect(nil as Int?).to(beNil())
        expect(1 as Int?).toNot(beNil())
        expect(self.producesNil()).to(beNil())

        failsWithErrorMessage("expected to not be nil, got <nil>") {
            expect(nil as Int?).toNot(beNil())
        }

        failsWithErrorMessage("expected to be nil, got <1>") {
            expect(1 as Int?).to(beNil())
        }
    }
}
