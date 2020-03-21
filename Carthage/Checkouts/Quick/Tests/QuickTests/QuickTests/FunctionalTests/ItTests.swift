import XCTest
@testable import Quick
import Nimble

class FunctionalTests_ItSpec: QuickSpec {
    override func spec() {
        var exampleMetadata: ExampleMetadata?
        beforeEach { metadata in exampleMetadata = metadata }

        it("") {
            expect(exampleMetadata!.example.name).to(equal(""))
        }

        it("has a description with セレクター名に使えない文字が入っている 👊💥") {
            let name = "has a description with セレクター名に使えない文字が入っている 👊💥"
            expect(exampleMetadata!.example.name).to(equal(name))
        }

#if canImport(Darwin)
        describe("when an example has a unique name") {
            it("has a unique name") {}

            it("doesn't add multiple selectors for it") {
                let allSelectors = [String](
                    FunctionalTests_ItSpec.allSelectors()
                        .filter { $0.hasPrefix("when_an_example_has_a_unique_name__") })
                    .sorted(by: <)

                expect(allSelectors) == [
                    "when_an_example_has_a_unique_name__doesn_t_add_multiple_selectors_for_it",
                    "when_an_example_has_a_unique_name__has_a_unique_name"
                ]
            }
        }

        describe("when two examples have the exact name") {
            it("has exactly the same name") {}
            it("has exactly the same name") {}

            it("makes a unique name for each of the above") {
                let allSelectors = [String](
                    FunctionalTests_ItSpec.allSelectors()
                        .filter { $0.hasPrefix("when_two_examples_have_the_exact_name__") })
                    .sorted(by: <)

                expect(allSelectors) == [
                    "when_two_examples_have_the_exact_name__has_exactly_the_same_name",
                    "when_two_examples_have_the_exact_name__has_exactly_the_same_name_2",
                    "when_two_examples_have_the_exact_name__makes_a_unique_name_for_each_of_the_above"
                ]
            }

        }

#if !SWIFT_PACKAGE
        describe("error handling when misusing ordering") {
            it("an it") {
                expect {
                    it("will throw an error when it is nested in another it") { }
                    }.to(raiseException { (exception: NSException) in
                        expect(exception.name).to(equal(NSExceptionName.internalInconsistencyException))
                        expect(exception.reason).to(equal("'it' cannot be used inside 'it', 'it' may only be used inside 'context' or 'describe'. "))
                        })
            }

            describe("behavior with an 'it' inside a 'beforeEach'") {
                var exception: NSException?

                beforeEach {
                    let capture = NMBExceptionCapture(handler: ({ e in
                        exception = e
                    }), finally: nil)

                    capture.tryBlock {
                        it("a rogue 'it' inside a 'beforeEach'") { }
                        return
                    }
                }

                it("should have thrown an exception with the correct error message") {
                    expect(exception).toNot(beNil())
                    expect(exception!.reason).to(equal("'it' cannot be used inside 'beforeEach', 'it' may only be used inside 'context' or 'describe'. "))
                }
            }

            describe("behavior with an 'it' inside an 'afterEach'") {
                var exception: NSException?

                afterEach {
                    let capture = NMBExceptionCapture(handler: ({ e in
                        exception = e
                        expect(exception).toNot(beNil())
                        expect(exception!.reason).to(equal("'it' cannot be used inside 'afterEach', 'it' may only be used inside 'context' or 'describe'. "))
                    }), finally: nil)

                    capture.tryBlock {
                        it("a rogue 'it' inside an 'afterEach'") { }
                        return
                    }
                }

                it("should throw an exception with the correct message after this 'it' block executes") {  }
            }
        }
#endif
#endif
    }
}

final class ItTests: XCTestCase, XCTestCaseProvider {
    static var allTests: [(String, (ItTests) -> () throws -> Void)] {
        return [
            ("testAllExamplesAreExecuted", testAllExamplesAreExecuted)
        ]
    }

    func testAllExamplesAreExecuted() {
        let result = qck_runSpec(FunctionalTests_ItSpec.self)
        #if canImport(Darwin)
        #if SWIFT_PACKAGE
        XCTAssertEqual(result?.executionCount, 7)
        #else
        XCTAssertEqual(result?.executionCount, 10)
        #endif
        #else
        XCTAssertEqual(result?.executionCount, 2)
        #endif
    }
}
