import XCTest
import Quick
import Nimble

class Configuration_AfterEachSpec: QuickSpec {
    override func spec() {
        beforeEach {
            FunctionalTests_Configuration_AfterEachWasExecuted = false
        }
        it("is executed before the configuration afterEach") {
            expect(FunctionalTests_Configuration_AfterEachWasExecuted).to(beFalsy())
        }
    }
}

final class Configuration_AfterEachTests: XCTestCase, XCTestCaseProvider {
    static var allTests: [(String, (Configuration_AfterEachTests) -> () throws -> Void)] {
        return [
            ("testExampleIsRunAfterTheConfigurationBeforeEachIsExecuted", testExampleIsRunAfterTheConfigurationBeforeEachIsExecuted),
        ]
    }

    func testExampleIsRunAfterTheConfigurationBeforeEachIsExecuted() {
        FunctionalTests_Configuration_AfterEachWasExecuted = false

        qck_runSpec(Configuration_BeforeEachSpec.self)
        XCTAssert(FunctionalTests_Configuration_AfterEachWasExecuted)

        FunctionalTests_Configuration_AfterEachWasExecuted = false
    }
}
