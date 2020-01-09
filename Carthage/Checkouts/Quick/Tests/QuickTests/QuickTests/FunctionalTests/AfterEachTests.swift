import XCTest
import Quick
import Nimble

private enum AfterEachType {
    case outerOne
    case outerTwo
    case outerThree
    case innerOne
    case innerTwo
    case noExamples
}

private var afterEachOrder = [AfterEachType]()

class FunctionalTests_AfterEachSpec: QuickSpec {
    override func spec() {
        describe("afterEach ordering") {
            afterEach { afterEachOrder.append(.outerOne) }
            afterEach { afterEachOrder.append(.outerTwo) }
            afterEach { afterEachOrder.append(.outerThree) }

            it("executes the outer afterEach closures once, but not before this closure [1]") {
                // No examples have been run, so no afterEach will have been run either.
                // The list should be empty.
                expect(afterEachOrder).to(beEmpty())
            }

            it("executes the outer afterEach closures a second time, but not before this closure [2]") {
                // The afterEach for the previous example should have been run.
                // The list should contain the afterEach for that example, executed from top to bottom.
                expect(afterEachOrder).to(equal([.outerOne, .outerTwo, .outerThree]))
            }

            context("when there are nested afterEach") {
                afterEach { afterEachOrder.append(.innerOne) }
                afterEach { afterEachOrder.append(.innerTwo) }

                it("executes the outer and inner afterEach closures, but not before this closure [3]") {
                    // The afterEach for the previous two examples should have been run.
                    // The list should contain the afterEach for those example, executed from top to bottom.
                    expect(afterEachOrder).to(equal([
                        .outerOne, .outerTwo, .outerThree,
                        .outerOne, .outerTwo, .outerThree
                        ]))
                }
            }

            context("when there are nested afterEach without examples") {
                afterEach { afterEachOrder.append(.noExamples) }
            }
        }
#if (os(macOS) || os(iOS) || os(tvOS) || os(watchOS)) && !SWIFT_PACKAGE
        describe("error handling when misusing ordering") {
            it("should throw an exception when including afterEach in it block") {
                expect {
                    afterEach { }
                    }.to(raiseException { (exception: NSException) in
                        expect(exception.name).to(equal(NSExceptionName.internalInconsistencyException))
                        expect(exception.reason).to(equal("'afterEach' cannot be used inside 'it', 'afterEach' may only be used inside 'context' or 'describe'. "))
                        })
            }
        }
#endif
    }
}

final class AfterEachTests: XCTestCase, XCTestCaseProvider {
    static var allTests: [(String, (AfterEachTests) -> () throws -> Void)] {
        return [
            ("testAfterEachIsExecutedInTheCorrectOrder", testAfterEachIsExecutedInTheCorrectOrder)
        ]
    }

    func testAfterEachIsExecutedInTheCorrectOrder() {
        afterEachOrder = []

        qck_runSpec(FunctionalTests_AfterEachSpec.self)
        let expectedOrder: [AfterEachType] = [
            // [1] The outer afterEach closures are executed from top to bottom.
            .outerOne, .outerTwo, .outerThree,
            // [2] The outer afterEach closures are executed from top to bottom.
            .outerOne, .outerTwo, .outerThree,
            // [3] The inner afterEach closures are executed from top to bottom,
            //     then the outer afterEach closures are executed from top to bottom.
            .innerOne, .innerTwo, .outerOne, .outerTwo, .outerThree
        ]
        XCTAssertEqual(afterEachOrder, expectedOrder)

        afterEachOrder = []
    }
}
