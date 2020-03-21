import Foundation
import XCTest
import Nimble

final class ElementsEqualTest: XCTestCase, XCTestCaseProvider {

    func testSequenceElementsEquality() {
        failsWithErrorMessageForNil("expected to elementsEqual <nil>, got <nil>") {
            expect(nil as [Int]?).to(elementsEqual(nil as [Int]?))
        }
        let sequence = [1, 2]
        failsWithErrorMessageForNil("expected to elementsEqual <[1, 2]>, got <nil>") {
            expect(nil as [Int]?).to(elementsEqual(sequence))
        }

        failsWithErrorMessageForNil("expected to elementsEqual <nil>, got <[1, 2]>") {
            expect(sequence).to(elementsEqual(nil as [Int]?))
        }

        let sequence1 = [1, 2, 3]
        let sequence2 = [1, 2, 3, 4, 5]
        expect(sequence1).toNot(elementsEqual(sequence2))
        expect(sequence1).toNot(elementsEqual([3, 2, 1]))
        expect(sequence1).to(elementsEqual([1, 2, 3]))

    }
}
