import Quick
import Nimble
import Dispatch

class CurrentSpecTests: QuickSpec {
    override func spec() {
        it("returns the currently executing spec") {
            let name: String = {
                let result = QuickSpec.current.name
                #if canImport(Darwin)
                return result.replacingOccurrences(of: "_", with: " ")
                #else
                return result
                #endif
            }()
            expect(name).to(match("returns the currently executing spec"))
        }

        let currentSpecDuringSpecSetup = QuickSpec.current
        it("returns nil when no spec is executing") {
            expect(currentSpecDuringSpecSetup).to(beNil())
        }

        it("supports XCTest expectations") {
            let expectation = QuickSpec.current.expectation(description: "great expectation")
            let fulfill: () -> Void
            #if canImport(Darwin)
            fulfill = expectation.fulfill
            #else
            // https://github.com/apple/swift-corelibs-xctest/blob/51afda0bc782b2d6a2f00fbdca58943faf6ccecd/Sources/XCTest/Public/Asynchronous/XCTestExpectation.swift#L233-L253
            fulfill = { expectation.fulfill() }
            #endif
            DispatchQueue.main.async(execute: fulfill)
            QuickSpec.current.waitForExpectations(timeout: 1)
        }
    }
}
