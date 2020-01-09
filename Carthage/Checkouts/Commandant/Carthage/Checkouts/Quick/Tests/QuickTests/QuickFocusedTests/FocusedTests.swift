import Quick
import Nimble
import XCTest

class FunctionalTests_FocusedSpec_SharedExamplesConfiguration: QuickConfiguration {
    override class func configure(_ configuration: Configuration) {
        sharedExamples("two passing shared examples") {
            it("has an example that passes (4)") {}
            it("has another example that passes (5)") {}
        }
    }
}

class FunctionalTests_FocusedSpec_Behavior: Behavior<Void> {
    override static func spec(_ aContext: @escaping () -> Void) {
        it("pass once") { expect(true).to(beTruthy()) }
        it("pass twice") { expect(true).to(beTruthy()) }
        it("pass three times") { expect(true).to(beTruthy()) }
    }
}

// The following `QuickSpec`s will be run in a same test suite with other specs
// on SwiftPM. We must avoid that the focused flags below affect other specs, so
// the examples of the two specs must be gathered lastly. That is the reason why
// the two specs have underscore prefix (and are listed at the bottom of `QCKMain`s
// `specs` array).

class _FunctionalTests_FocusedSpec_Focused: QuickSpec {
    override func spec() {
        it("has an unfocused example that fails, but is never run") { fail() }
        fit("has a focused example that passes (1)") {}

        fdescribe("a focused example group") {
            it("has an example that is not focused, but will be run, and passes (2)") {}
            fit("has a focused example that passes (3)") {}
        }

        fitBehavesLike("two passing shared examples")
        fitBehavesLike(FunctionalTests_FocusedSpec_Behavior.self) { () -> Void in }
    }
}

class _FunctionalTests_FocusedSpec_Unfocused: QuickSpec {
    override func spec() {
        it("has an unfocused example that fails, but is never run") { fail() }

        describe("an unfocused example group that is never run") {
            beforeEach { assert(false) }
            it("has an example that fails, but is never run") { fail() }
        }
    }
}

final class FocusedTests: XCTestCase, XCTestCaseProvider {
    static var allTests: [(String, (FocusedTests) -> () throws -> Void)] {
        return [
            ("testOnlyFocusedExamplesAreExecuted", testOnlyFocusedExamplesAreExecuted)
        ]
    }

    func testOnlyFocusedExamplesAreExecuted() {
        let result = qck_runSpecs([
            _FunctionalTests_FocusedSpec_Focused.self,
            _FunctionalTests_FocusedSpec_Unfocused.self
        ])
        XCTAssertEqual(result?.executionCount, 8)
    }
}
