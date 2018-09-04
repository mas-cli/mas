import Quick

public var FunctionalTests_Configuration_AfterEachWasExecuted = false

class FunctionalTests_Configuration_AfterEach: QuickConfiguration {
    override class func configure(_ configuration: Configuration) {
        configuration.afterEach {
            FunctionalTests_Configuration_AfterEachWasExecuted = true
        }
    }
}
