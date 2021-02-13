import Foundation
import Nimble
import XCTest

final class BeginWithPrefixTest: XCTestCase {

    func testBeginWithSequencePrefix() {
        failsWithErrorMessageForNil("expected to begin with <nil>, got <nil>") {
            expect(nil as [Int]?).to(beginWith(prefix: nil as [Int]?))
        }

        failsWithErrorMessageForNil("expected to begin with <[1, 2]>, got <nil>") {
            expect(nil as [Int]?).to(beginWith(prefix: [1, 2]))
        }

        failsWithErrorMessageForNil("expected to begin with <nil>, got <[1, 2]>") {
            expect([1, 2]).to(beginWith(prefix: nil as [Int]?))
        }

        let sequence = [1, 2, 3]
        expect(sequence).toNot(beginWith(prefix: [1, 2, 3, 4]))
        expect(sequence).toNot(beginWith(prefix: [2, 3]))

        expect(sequence).to(beginWith(prefix: [1, 2, 3]))
        expect(sequence).to(beginWith(prefix: [1, 2]))
        expect(sequence).to(beginWith(prefix: []))

        expect([]).toNot(beginWith(prefix: [1]))
        expect([]).to(beginWith(prefix: [] as [Int]))
    }

    func testBeginWithSequencePrefixUsingPredicateClosure() {
        failsWithErrorMessageForNil("expected to begin with <nil>, got <nil>") {
            expect(nil as [Int]?).to(beginWith(prefix: nil as [Int]?, by: { $0 == $1 }))
        }

        failsWithErrorMessageForNil("expected to begin with <[1, 2]>, got <nil>") {
            expect(nil as [Int]?).to(beginWith(prefix: [1, 2], by: { $0 == $1 }))
        }

        failsWithErrorMessageForNil("expected to begin with <nil>, got <[1, 2]>") {
            expect([1, 2]).to(beginWith(prefix: nil as [Int]?, by: { $0 == $1 }))
        }

        let sequence = [1, 2, 3]
        expect(sequence).toNot(beginWith(prefix: [1, 2, 3, 4], by: { $0 == $1 }))
        expect(sequence).toNot(beginWith(prefix: [2, 3], by: { $0 == $1 }))

        expect(sequence).to(beginWith(prefix: [1, 2, 3], by: { $0 == $1 }))
        expect(sequence).to(beginWith(prefix: [1, 2], by: { $0 == $1 }))
        expect(sequence).to(beginWith(prefix: [], by: { $0 == $1 }))

        expect([]).toNot(beginWith(prefix: [1], by: { $0 == $1 }))
        expect([]).to(beginWith(prefix: [] as [Int], by: { $0 == $1 }))
    }

    func testBeginWithSequencePrefixWithDifferentSequenceTypes() {
        expect(1...3).to(beginWith(prefix: [1, 2, 3]))
        expect(1...3).toNot(beginWith(prefix: [1, 2, 3, 4, 5]))

        expect(1...3).to(beginWith(prefix: [1, 2, 3], by: { $0 == $1 }))
        expect(1...3).toNot(beginWith(prefix: [1, 2, 3, 4, 5], by: { $0 == $1 }))
    }
}
