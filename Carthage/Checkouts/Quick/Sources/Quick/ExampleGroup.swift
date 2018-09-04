import Foundation

/**
    Example groups are logical groupings of examples, defined with
    the `describe` and `context` functions. Example groups can share
    setup and teardown code.
*/
final public class ExampleGroup: NSObject {
    weak internal var parent: ExampleGroup?
    internal let hooks = ExampleHooks()

    internal var phase: HooksPhase = .nothingExecuted

    private let internalDescription: String
    private let flags: FilterFlags
    private let isInternalRootExampleGroup: Bool
    private var childGroups = [ExampleGroup]()
    private var childExamples = [Example]()

    internal init(description: String, flags: FilterFlags, isInternalRootExampleGroup: Bool = false) {
        self.internalDescription = description
        self.flags = flags
        self.isInternalRootExampleGroup = isInternalRootExampleGroup
    }

    public override var description: String {
        return internalDescription
    }

    /**
        Returns a list of examples that belong to this example group,
        or to any of its descendant example groups.
    */
    public var examples: [Example] {
        return childExamples + childGroups.flatMap { $0.examples }
    }

    internal var name: String? {
        guard let parent = parent else {
            return isInternalRootExampleGroup ? nil : description
        }

        guard let name = parent.name else { return description }
        return "\(name), \(description)"
    }

    internal var filterFlags: FilterFlags {
        var aggregateFlags = flags
        walkUp { group in
            for (key, value) in group.flags {
                aggregateFlags[key] = value
            }
        }
        return aggregateFlags
    }

    internal var befores: [BeforeExampleWithMetadataClosure] {
        var closures = Array(hooks.befores.reversed())
        walkUp { group in
            closures.append(contentsOf: Array(group.hooks.befores.reversed()))
        }
        return Array(closures.reversed())
    }

    internal var afters: [AfterExampleWithMetadataClosure] {
        var closures = hooks.afters
        walkUp { group in
            closures.append(contentsOf: group.hooks.afters)
        }
        return closures
    }

    internal func walkDownExamples(_ callback: (_ example: Example) -> Void) {
        for example in childExamples {
            callback(example)
        }
        for group in childGroups {
            group.walkDownExamples(callback)
        }
    }

    internal func appendExampleGroup(_ group: ExampleGroup) {
        group.parent = self
        childGroups.append(group)
    }

    internal func appendExample(_ example: Example) {
        example.group = self
        childExamples.append(example)
    }

    private func walkUp(_ callback: (_ group: ExampleGroup) -> Void) {
        var group = self
        while let parent = group.parent {
            callback(parent)
            group = parent
        }
    }
}
