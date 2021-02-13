import Foundation

/**
    Adds methods to World to support top-level DSL functions (Swift) and
    macros (Objective-C). These functions map directly to the DSL that test
    writers use in their specs.
*/
extension World {
    internal func beforeSuite(_ closure: @escaping BeforeSuiteClosure) {
        suiteHooks.appendBefore(closure)
    }

    internal func afterSuite(_ closure: @escaping AfterSuiteClosure) {
        suiteHooks.appendAfter(closure)
    }

    internal func sharedExamples(_ name: String, closure: @escaping SharedExampleClosure) {
        registerSharedExample(name, closure: closure)
    }

    internal func describe(_ description: String, flags: FilterFlags, closure: () -> Void) {
        guard currentExampleMetadata == nil else {
            raiseError("'describe' cannot be used inside '\(currentPhase)', 'describe' may only be used inside 'context' or 'describe'.")
        }
        guard currentExampleGroup != nil else {
            // swiftlint:disable:next line_length
            raiseError("Error: example group was not created by its parent QuickSpec spec. Check that describe() or context() was used in QuickSpec.spec() and not a more general context (i.e. an XCTestCase test)")
        }
        let group = ExampleGroup(description: description, flags: flags)
        currentExampleGroup.appendExampleGroup(group)
        performWithCurrentExampleGroup(group, closure: closure)
    }

    internal func context(_ description: String, flags: FilterFlags, closure: () -> Void) {
        guard currentExampleMetadata == nil else {
            raiseError("'context' cannot be used inside '\(currentPhase)', 'context' may only be used inside 'context' or 'describe'.")
        }
        self.describe(description, flags: flags, closure: closure)
    }

    internal func fdescribe(_ description: String, flags: FilterFlags, closure: () -> Void) {
        var focusedFlags = flags
        focusedFlags[Filter.focused] = true
        self.describe(description, flags: focusedFlags, closure: closure)
    }

    internal func xdescribe(_ description: String, flags: FilterFlags, closure: () -> Void) {
        var pendingFlags = flags
        pendingFlags[Filter.pending] = true
        self.describe(description, flags: pendingFlags, closure: closure)
    }

    internal func beforeEach(_ closure: @escaping BeforeExampleClosure) {
        guard currentExampleMetadata == nil else {
            raiseError("'beforeEach' cannot be used inside '\(currentPhase)', 'beforeEach' may only be used inside 'context' or 'describe'.")
        }
        currentExampleGroup.hooks.appendBefore(closure)
    }

#if canImport(Darwin)
    @objc(beforeEachWithMetadata:)
    internal func beforeEach(closure: @escaping BeforeExampleWithMetadataClosure) {
        currentExampleGroup.hooks.appendBefore(closure)
    }
#else
    internal func beforeEach(closure: @escaping BeforeExampleWithMetadataClosure) {
        currentExampleGroup.hooks.appendBefore(closure)
    }
#endif

    internal func afterEach(_ closure: @escaping AfterExampleClosure) {
        guard currentExampleMetadata == nil else {
            raiseError("'afterEach' cannot be used inside '\(currentPhase)', 'afterEach' may only be used inside 'context' or 'describe'.")
        }
        currentExampleGroup.hooks.appendAfter(closure)
    }

#if canImport(Darwin)
    @objc(afterEachWithMetadata:)
    internal func afterEach(closure: @escaping AfterExampleWithMetadataClosure) {
        currentExampleGroup.hooks.appendAfter(closure)
    }
#else
    internal func afterEach(closure: @escaping AfterExampleWithMetadataClosure) {
        currentExampleGroup.hooks.appendAfter(closure)
    }
#endif

    @nonobjc
    internal func it(_ description: String, flags: FilterFlags, file: FileString, line: UInt, closure: @escaping () throws -> Void) {
        if beforesCurrentlyExecuting {
            raiseError("'it' cannot be used inside 'beforeEach', 'it' may only be used inside 'context' or 'describe'.")
        }
        if aftersCurrentlyExecuting {
            raiseError("'it' cannot be used inside 'afterEach', 'it' may only be used inside 'context' or 'describe'.")
        }
        guard currentExampleMetadata == nil else {
            raiseError("'it' cannot be used inside 'it', 'it' may only be used inside 'context' or 'describe'.")
        }
        let callsite = Callsite(file: file, line: line)
        let example = Example(description: description, callsite: callsite, flags: flags, closure: closure)
        currentExampleGroup.appendExample(example)
    }

    @nonobjc
    internal func fit(_ description: String, flags: FilterFlags, file: FileString, line: UInt, closure: @escaping () throws -> Void) {
        var focusedFlags = flags
        focusedFlags[Filter.focused] = true
        self.it(description, flags: focusedFlags, file: file, line: line, closure: closure)
    }

    @nonobjc
    internal func xit(_ description: String, flags: FilterFlags, file: FileString, line: UInt, closure: @escaping () throws -> Void) {
        var pendingFlags = flags
        pendingFlags[Filter.pending] = true
        self.it(description, flags: pendingFlags, file: file, line: line, closure: closure)
    }

    @nonobjc
    internal func itBehavesLike(_ name: String, sharedExampleContext: @escaping SharedExampleContext, flags: FilterFlags, file: FileString, line: UInt) {
        guard currentExampleMetadata == nil else {
            raiseError("'itBehavesLike' cannot be used inside '\(currentPhase)', 'itBehavesLike' may only be used inside 'context' or 'describe'.")
        }
        let callsite = Callsite(file: file, line: line)
        let closure = World.sharedWorld.sharedExample(name)

        let group = ExampleGroup(description: name, flags: flags)
        currentExampleGroup.appendExampleGroup(group)
        performWithCurrentExampleGroup(group) {
            closure(sharedExampleContext)
        }

        group.walkDownExamples { (example: Example) in
            example.isSharedExample = true
            example.callsite = callsite
        }
    }

    @nonobjc
    internal func fitBehavesLike(_ name: String, sharedExampleContext: @escaping SharedExampleContext, flags: FilterFlags, file: FileString, line: UInt) {
        var focusedFlags = flags
        focusedFlags[Filter.focused] = true
        self.itBehavesLike(name, sharedExampleContext: sharedExampleContext, flags: focusedFlags, file: file, line: line)
    }

    internal func itBehavesLike<C>(_ behavior: Behavior<C>.Type, context: @escaping () -> C, flags: FilterFlags, file: FileString, line: UInt) {
        guard currentExampleMetadata == nil else {
            raiseError("'itBehavesLike' cannot be used inside '\(currentPhase)', 'itBehavesLike' may only be used inside 'context' or 'describe'.")
        }
        let callsite = Callsite(file: file, line: line)
        let closure = behavior.spec
        let group = ExampleGroup(description: behavior.name, flags: flags)
        currentExampleGroup.appendExampleGroup(group)
        performWithCurrentExampleGroup(group) {
            closure(context)
        }

        group.walkDownExamples { (example: Example) in
            example.isSharedExample = true
            example.callsite = callsite
        }
    }

    internal func fitBehavesLike<C>(_ behavior: Behavior<C>.Type, context: @escaping () -> C, flags: FilterFlags, file: FileString, line: UInt) {
        var focusedFlags = flags
        focusedFlags[Filter.focused] = true
        self.itBehavesLike(behavior, context: context, flags: focusedFlags, file: file, line: line)
    }

    internal func xitBehavesLike<C>(_ behavior: Behavior<C>.Type, context: @escaping () -> C, flags: FilterFlags, file: FileString, line: UInt) {
        var pendingFlags = flags
        pendingFlags[Filter.pending] = true
        self.itBehavesLike(behavior, context: context, flags: pendingFlags, file: file, line: line)
    }

#if canImport(Darwin) && !SWIFT_PACKAGE
    @objc(itWithDescription:flags:file:line:closure:)
    internal func objc_it(_ description: String, flags: FilterFlags, file: FileString, line: UInt, closure: @escaping () -> Void) {
        it(description, flags: flags, file: file, line: line, closure: closure)
    }

    @objc(fitWithDescription:flags:file:line:closure:)
    internal func objc_fit(_ description: String, flags: FilterFlags, file: FileString, line: UInt, closure: @escaping () -> Void) {
        fit(description, flags: flags, file: file, line: line, closure: closure)
    }

    @objc(xitWithDescription:flags:file:line:closure:)
    internal func objc_xit(_ description: String, flags: FilterFlags, file: FileString, line: UInt, closure: @escaping () -> Void) {
        xit(description, flags: flags, file: file, line: line, closure: closure)
    }

    @objc(itBehavesLikeSharedExampleNamed:sharedExampleContext:flags:file:line:)
    internal func objc_itBehavesLike(_ name: String, sharedExampleContext: @escaping SharedExampleContext, flags: FilterFlags, file: FileString, line: UInt) {
        itBehavesLike(name, sharedExampleContext: sharedExampleContext, flags: flags, file: file, line: line)
    }
#endif

    internal func pending(_ description: String, closure: () -> Void) {
        print("Pending: \(description)")
    }

    private var currentPhase: String {
        if beforesCurrentlyExecuting {
            return "beforeEach"
        } else if aftersCurrentlyExecuting {
            return "afterEach"
        }

        return "it"
    }
}
