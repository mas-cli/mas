import XCTest

// NOTE: This file is not intended to be included in the Xcode project or CocoaPods.
//       It is picked up by the Swift Package Manager during its build process.

#if SWIFT_PACKAGE

#if canImport(QuickSpecBase)
import QuickSpecBase

public typealias QuickSpecBase = _QuickSpecBase
#else
public typealias QuickSpecBase = XCTestCase
#endif

open class QuickSpec: QuickSpecBase {
    /// Returns the currently executing spec. Use in specs that require XCTestCase
    /// methods, e.g. expectation(description:).
    public private(set) static var current: QuickSpec!

    private var example: Example? {
        didSet {
            QuickSpec.current = self
        }
    }

    open func spec() {}

#if !canImport(Darwin)
    public required init() {
        super.init(name: "", testClosure: { _ in })
    }
    public required init(name: String, testClosure: @escaping (XCTestCase) throws -> Swift.Void) {
        super.init(name: name, testClosure: testClosure)
    }
#else
    public required override init() {
        super.init()
    }

    /// This method is used as a hook for the following two purposes
    ///
    /// 1. Performing all configurations
    /// 2. Gathering examples for each spec classes
    ///
    /// On Linux, those are done in `LinuxMain.swift` and `Quick.QCKMain`. But
    /// SwiftPM on macOS does not have the mechanism (test cases are automatically
    /// discovered powered by Objective-C runtime), so we needed the alternative
    /// way.
    override open class var defaultTestSuite: XCTestSuite {
        QuickConfiguration.configureSubclassesIfNeeded(world: World.sharedWorld)

        // Let's gather examples for each spec classes. This has the same effect
        // as listing spec classes in `LinuxMain.swift` on Linux.
        gatherExamplesIfNeeded()

        return super.defaultTestSuite
    }

    override open class func _qck_testMethodSelectors() -> [String] {
        let examples = World.sharedWorld.examples(forSpecClass: self)

        var selectorNames = Set<String>()
        return examples.map { example in
            let selector = addInstanceMethod(for: example, classSelectorNames: &selectorNames)
            return NSStringFromSelector(selector)
        }
    }

    private static func addInstanceMethod(for example: Example, classSelectorNames selectorNames : inout Set<String>) -> Selector {
        let block: @convention(block) (QuickSpec) -> Void = { spec in
            spec.example = example
            example.run()
        }
        let implementation = imp_implementationWithBlock(block as Any)

        let originalName = example.name.c99ExtendedIdentifier
        var selectorName = originalName
        var i: UInt = 2

        while selectorNames.contains(selectorName) {
            selectorName = String(format: "%@_%tu", originalName, i)
            i += 1
        }

        selectorNames.insert(selectorName)

        let selector = NSSelectorFromString(selectorName)
        class_addMethod(self, selector, implementation, "v@:")

        return selector
    }
#endif

#if !canImport(Darwin)
    public class var allTests: [(String, (QuickSpec) -> () throws -> Void)] {
        gatherExamplesIfNeeded()

        let examples = World.sharedWorld.examples(forSpecClass: self)
        let result = examples.map { example -> (String, (QuickSpec) -> () throws -> Void) in
            return (example.name, { spec in
                return {
                    spec.example = example
                    example.run()
                }
            })
        }
        return result
    }
#endif

    internal static func gatherExamplesIfNeeded() {
        let world = World.sharedWorld
        let rootExampleGroup = world.rootExampleGroup(forSpecClass: self)
        guard rootExampleGroup.examples.isEmpty else {
            return
        }

        world.performWithCurrentExampleGroup(rootExampleGroup) {
            self.init().spec()
        }
    }
}

#endif
