import XCTest
import Quick
import Nimble

var specBeforeEachExecutedCount = 0
var sharedExamplesBeforeEachExecutedCount = 0

class FunctionalTests_SharedExamples_BeforeEachTests_SharedExamples: QuickConfiguration {
    override class func configure(_ configuration: Configuration) {
        sharedExamples("a group of three shared examples with a beforeEach") {
            beforeEach { sharedExamplesBeforeEachExecutedCount += 1 }
            it("passes once") {}
            it("passes twice") {}
            it("passes three times") {}
        }
    }
}

class FunctionalTests_SharedExamples_BeforeEachSpec: QuickSpec {
    override func spec() {
        beforeEach { specBeforeEachExecutedCount += 1 }
        it("executes the spec beforeEach once") {}
        itBehavesLike("a group of three shared examples with a beforeEach")
    }
}

final class SharedExamples_BeforeEachTests: XCTestCase, XCTestCaseProvider {
    static var allTests: [(String, (SharedExamples_BeforeEachTests) -> () throws -> Void)] {
        return [
            ("testBeforeEachOutsideOfSharedExamplesExecutedOnceBeforeEachExample", testBeforeEachOutsideOfSharedExamplesExecutedOnceBeforeEachExample),
            ("testBeforeEachInSharedExamplesExecutedOnceBeforeEachSharedExample", testBeforeEachInSharedExamplesExecutedOnceBeforeEachSharedExample)
        ]
    }

    func testBeforeEachOutsideOfSharedExamplesExecutedOnceBeforeEachExample() {
        specBeforeEachExecutedCount = 0

        qck_runSpec(FunctionalTests_SharedExamples_BeforeEachSpec.self)
        XCTAssertEqual(specBeforeEachExecutedCount, 4)
    }

    func testBeforeEachInSharedExamplesExecutedOnceBeforeEachSharedExample() {
        sharedExamplesBeforeEachExecutedCount = 0

        qck_runSpec(FunctionalTests_SharedExamples_BeforeEachSpec.self)
        XCTAssertEqual(sharedExamplesBeforeEachExecutedCount, 3)
    }
}
