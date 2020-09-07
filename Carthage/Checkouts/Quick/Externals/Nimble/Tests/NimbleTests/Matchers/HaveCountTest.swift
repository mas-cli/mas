import XCTest
import Nimble

final class HaveCountTest: XCTestCase {
    func testHaveCountForArray() {
        expect([1, 2, 3]).to(haveCount(3))
        expect([1, 2, 3]).notTo(haveCount(1))

        failsWithErrorMessage(
            """
            expected to have Array<Int> with count 1, got 3
            Actual Value: [1, 2, 3]
            """
        ) {
            expect([1, 2, 3]).to(haveCount(1))
        }

        failsWithErrorMessage(
            """
            expected to not have Array<Int> with count 3, got 3
            Actual Value: [1, 2, 3]
            """
        ) {
            expect([1, 2, 3]).notTo(haveCount(3))
        }
    }

    func testHaveCountForDictionary() {
        let dictionary = ["1": 1, "2": 2, "3": 3]
        expect(dictionary).to(haveCount(3))
        expect(dictionary).notTo(haveCount(1))

        failsWithErrorMessage(
            """
            expected to have Dictionary<String, Int> with count 1, got 3
            Actual Value: \(stringify(dictionary))
            """
        ) {
            expect(dictionary).to(haveCount(1))
        }

        failsWithErrorMessage(
            """
            expected to not have Dictionary<String, Int> with count 3, got 3
            Actual Value: \(stringify(dictionary))
            """
        ) {
            expect(dictionary).notTo(haveCount(3))
        }
    }

    func testHaveCountForSet() {
        let set = Set([1, 2, 3])
        expect(set).to(haveCount(3))
        expect(set).notTo(haveCount(1))

        failsWithErrorMessage(
            """
            expected to have Set<Int> with count 1, got 3
            Actual Value: \(stringify(set))
            """
        ) {
            expect(set).to(haveCount(1))
        }

        failsWithErrorMessage(
            """
            expected to not have Set<Int> with count 3, got 3
            Actual Value: \(stringify(set))
            """
        ) {
            expect(set).notTo(haveCount(3))
        }
    }
}
