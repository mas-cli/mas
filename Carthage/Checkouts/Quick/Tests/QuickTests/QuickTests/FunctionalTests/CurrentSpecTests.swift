import Quick
import Nimble

#if !SWIFT_PACKAGE

class CurrentSpecTests: QuickSpec {
    override func spec() {
        it("returns the currently executing spec") {
            expect(QuickSpec.current?.name).to(match("currently_executing_spec"))
        }

        let currentSpecDuringSpecSetup = QuickSpec.current
        it("returns nil when no spec is executing") {
            expect(currentSpecDuringSpecSetup).to(beNil())
        }

        it("supports XCTest expectations") {
            let expectation = QuickSpec.current.expectation(description: "great expectation")
            DispatchQueue.main.async(execute: expectation.fulfill)
            QuickSpec.current.waitForExpectations(timeout: 1)
        }
    }
}

#endif
