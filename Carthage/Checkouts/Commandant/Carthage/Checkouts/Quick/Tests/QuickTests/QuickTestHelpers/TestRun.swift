public struct TestRun {
    public var executionCount: UInt
    public var hasSucceeded: Bool

    public init(executionCount: UInt, hasSucceeded: Bool) {
        self.executionCount = executionCount
        self.hasSucceeded = hasSucceeded
    }
}
