import Foundation
import XCTest
import Nimble

final class ElementsEqualTest: XCTestCase {

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

    func testSequenceElementsEqualityUsingPredicateClosure() {
        failsWithErrorMessageForNil("expected to elementsEqual <nil>, got <nil>") {
            expect(nil as [Int]?).to(elementsEqual(nil as [Int]?, by: { $0 == $1 }))
        }
        let sequence = [1, 2]
        failsWithErrorMessageForNil("expected to elementsEqual <[1, 2]>, got <nil>") {
            expect(nil as [Int]?).to(elementsEqual(sequence, by: { $0 == $1 }))
        }

        failsWithErrorMessageForNil("expected to elementsEqual <nil>, got <[1, 2]>") {
            expect(sequence).to(elementsEqual(nil as [Int]?, by: { $0 == $1 }))
        }

        let sequence1 = [1, 2, 3]
        let sequence2 = [1, 2, 3, 4, 5]
        expect(sequence1).toNot(elementsEqual(sequence2, by: { $0 == $1 }))
        expect(sequence1).toNot(elementsEqual([3, 2, 1], by: { $0 == $1 }))
        expect(sequence1).to(elementsEqual([1, 2, 3], by: { $0 == $1 }))
    }

    func testElementsEqualDifferentSequenceTypes() {
        expect(1...3).to(elementsEqual([1, 2, 3]))
        expect(1...3).toNot(elementsEqual([1, 2, 3, 4, 5]))
        expect(1...3).toNot(elementsEqual([3, 2, 1]))

        expect(1...3).to(elementsEqual([1, 2, 3], by: { $0 == $1 }))
        expect(1...3).toNot(elementsEqual([1, 2, 3, 4, 5], by: { $0 == $1 }))
        expect(1...3).toNot(elementsEqual([3, 2, 1], by: { $0 == $1 }))
    }
}
