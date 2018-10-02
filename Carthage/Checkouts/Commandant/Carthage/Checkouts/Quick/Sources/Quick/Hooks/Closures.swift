// MARK: Example Hooks

/**
    A closure executed before an example is run.
*/
public typealias BeforeExampleClosure = () -> Void

/**
    A closure executed before an example is run. The closure is given example metadata,
    which contains information about the example that is about to be run.
*/
public typealias BeforeExampleWithMetadataClosure = (_ exampleMetadata: ExampleMetadata) -> Void

/**
    A closure executed after an example is run.
*/
public typealias AfterExampleClosure = BeforeExampleClosure

/**
    A closure executed after an example is run. The closure is given example metadata,
    which contains information about the example that has just finished running.
*/
public typealias AfterExampleWithMetadataClosure = BeforeExampleWithMetadataClosure

// MARK: Suite Hooks

/**
    A closure executed before any examples are run.
*/
public typealias BeforeSuiteClosure = () -> Void

/**
    A closure executed after all examples have finished running.
*/
public typealias AfterSuiteClosure = BeforeSuiteClosure
