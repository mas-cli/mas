import Foundation

/**
    A closure that temporarily exposes a Configuration object within
    the scope of the closure.
*/
public typealias QuickConfigurer = (_ configuration: Configuration) -> Void

/**
    A closure that, given metadata about an example, returns a boolean value
    indicating whether that example should be run.
*/
public typealias ExampleFilter = (_ example: Example) -> Bool

/**
    A configuration encapsulates various options you can use
    to configure Quick's behavior.
*/
final public class Configuration: NSObject {
    internal let exampleHooks = ExampleHooks()
    internal let suiteHooks = SuiteHooks()
    internal var exclusionFilters: [ExampleFilter] = [ { example in
        if let pending = example.filterFlags[Filter.pending] {
            return pending
        } else {
            return false
        }
    }]
    internal var inclusionFilters: [ExampleFilter] = [ { example in
        if let focused = example.filterFlags[Filter.focused] {
            return focused
        } else {
            return false
        }
    }]

    /**
        Run all examples if none match the configured filters. True by default.
    */
    public var runAllWhenEverythingFiltered = true

    /**
        Registers an inclusion filter.

        All examples are filtered using all inclusion filters.
        The remaining examples are run. If no examples remain, all examples are run.

        - parameter filter: A filter that, given an example, returns a value indicating
                       whether that example should be included in the examples
                       that are run.
    */
    public func include(_ filter: @escaping ExampleFilter) {
        inclusionFilters.append(filter)
    }

    /**
        Registers an exclusion filter.

        All examples that remain after being filtered by the inclusion filters are
        then filtered via all exclusion filters.

        - parameter filter: A filter that, given an example, returns a value indicating
                       whether that example should be excluded from the examples
                       that are run.
    */
    public func exclude(_ filter: @escaping ExampleFilter) {
        exclusionFilters.append(filter)
    }

    /**
        Identical to Quick.Configuration.beforeEach, except the closure is
        provided with metadata on the example that the closure is being run
        prior to.
    */
#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
    @objc(beforeEachWithMetadata:)
    public func beforeEach(_ closure: @escaping BeforeExampleWithMetadataClosure) {
        exampleHooks.appendBefore(closure)
    }
#else
    public func beforeEach(_ closure: @escaping BeforeExampleWithMetadataClosure) {
        exampleHooks.appendBefore(closure)
    }
#endif

    /**
        Like Quick.DSL.beforeEach, this configures Quick to execute the
        given closure before each example that is run. The closure
        passed to this method is executed before each example Quick runs,
        globally across the test suite. You may call this method multiple
        times across mulitple +[QuickConfigure configure:] methods in order
        to define several closures to run before each example.

        Note that, since Quick makes no guarantee as to the order in which
        +[QuickConfiguration configure:] methods are evaluated, there is no
        guarantee as to the order in which beforeEach closures are evaluated
        either. Mulitple beforeEach defined on a single configuration, however,
        will be executed in the order they're defined.

        - parameter closure: The closure to be executed before each example
                        in the test suite.
    */
    public func beforeEach(_ closure: @escaping BeforeExampleClosure) {
        exampleHooks.appendBefore(closure)
    }

    /**
        Identical to Quick.Configuration.afterEach, except the closure
        is provided with metadata on the example that the closure is being
        run after.
    */
#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
    @objc(afterEachWithMetadata:)
    public func afterEach(_ closure: @escaping AfterExampleWithMetadataClosure) {
        exampleHooks.appendAfter(closure)
    }
#else
    public func afterEach(_ closure: @escaping AfterExampleWithMetadataClosure) {
        exampleHooks.appendAfter(closure)
    }
#endif

    /**
        Like Quick.DSL.afterEach, this configures Quick to execute the
        given closure after each example that is run. The closure
        passed to this method is executed after each example Quick runs,
        globally across the test suite. You may call this method multiple
        times across mulitple +[QuickConfigure configure:] methods in order
        to define several closures to run after each example.

        Note that, since Quick makes no guarantee as to the order in which
        +[QuickConfiguration configure:] methods are evaluated, there is no
        guarantee as to the order in which afterEach closures are evaluated
        either. Mulitple afterEach defined on a single configuration, however,
        will be executed in the order they're defined.

        - parameter closure: The closure to be executed before each example
                        in the test suite.
    */
    public func afterEach(_ closure: @escaping AfterExampleClosure) {
        exampleHooks.appendAfter(closure)
    }

    /**
        Like Quick.DSL.beforeSuite, this configures Quick to execute
        the given closure prior to any and all examples that are run.
        The two methods are functionally equivalent.
    */
    public func beforeSuite(_ closure: @escaping BeforeSuiteClosure) {
        suiteHooks.appendBefore(closure)
    }

    /**
        Like Quick.DSL.afterSuite, this configures Quick to execute
        the given closure after all examples have been run.
        The two methods are functionally equivalent.
    */
    public func afterSuite(_ closure: @escaping AfterSuiteClosure) {
        suiteHooks.appendAfter(closure)
    }
}
