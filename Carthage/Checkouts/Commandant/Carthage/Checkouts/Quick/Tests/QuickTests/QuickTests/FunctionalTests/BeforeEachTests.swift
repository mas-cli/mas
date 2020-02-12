import XCTest
import Quick
import Nimble

private enum BeforeEachType {
    case outerOne
    case outerTwo
    case innerOne
    case innerTwo
    case innerThree
    case noExamples
}

private var beforeEachOrder = [BeforeEachType]()

class FunctionalTests_BeforeEachSpec: QuickSpec {
    override func spec() {

        describe("beforeEach ordering") {
            beforeEach { beforeEachOrder.append(.outerOne) }
            beforeEach { beforeEachOrder.append(.outerTwo) }

            it("executes the outer beforeEach closures once [1]") {}
            it("executes the outer beforeEach closures a second time [2]") {}

            context("when there are nested beforeEach") {
                beforeEach { beforeEachOrder.append(.innerOne) }
                beforeEach { beforeEachOrder.append(.innerTwo) }
                beforeEach { beforeEachOrder.append(.innerThree) }

                it("executes the outer and inner beforeEach closures [3]") {}
            }

            context("when there are nested beforeEach without examples") {
                beforeEach { beforeEachOrder.append(.noExamples) }
            }
        }
#if canImport(Darwin) && !SWIFT_PACKAGE
        describe("error handling when misusing ordering") {
            it("should throw an exception when including beforeEach in it block") {
                expect {
                    beforeEach { }
                    }.to(raiseException { (exception: NSException) in
                        expect(exception.name).to(equal(NSExceptionName.internalInconsistencyException))
                        expect(exception.reason).to(equal("'beforeEach' cannot be used inside 'it', 'beforeEach' may only be used inside 'context' or 'describe'. "))
                        })
            }
        }
#endif
    }
}

final class BeforeEachTests: XCTestCase, XCTestCaseProvider {
    static var allTests: [(String, (BeforeEachTests) -> () throws -> Void)] {
        return [
            ("testBeforeEachIsExecutedInTheCorrectOrder", testBeforeEachIsExecutedInTheCorrectOrder)
        ]
    }

    func testBeforeEachIsExecutedInTheCorrectOrder() {
        beforeEachOrder = []

        qck_runSpec(FunctionalTests_BeforeEachSpec.self)
        let expectedOrder: [BeforeEachType] = [
            // [1] The outer beforeEach closures are executed from top to bottom.
            .outerOne, .outerTwo,
            // [2] The outer beforeEach closures are executed from top to bottom.
            .outerOne, .outerTwo,
            // [3] The outer beforeEach closures are executed from top to bottom,
            //     then the inner beforeEach closures are executed from top to bottom.
            .outerOne, .outerTwo, .innerOne, .innerTwo, .innerThree
        ]
        XCTAssertEqual(beforeEachOrder, expectedOrder)
    }
}
