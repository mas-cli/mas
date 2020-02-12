import Foundation
import XCTest

#if SWIFT_PACKAGE

open class QuickConfiguration: NSObject {
    open class func configure(_ configuration: Configuration) {}
}

#endif

extension QuickConfiguration {
    #if !canImport(Darwin)
    private static var configurationSubclasses: [QuickConfiguration.Type] = []
    #endif

    /// Finds all direct subclasses of QuickConfiguration and passes them to the block provided.
    /// The classes are iterated over in the order that objc_getClassList returns them.
    ///
    /// - parameter block: A block that takes a QuickConfiguration.Type.
    ///                    This block will be executed once for each subclass of QuickConfiguration.
    private static func enumerateSubclasses(_ block: (QuickConfiguration.Type) -> Void) {
        #if canImport(Darwin)
        var classesCount = objc_getClassList(nil, 0)

        guard classesCount > 0 else {
            return
        }

        let classes = UnsafeMutablePointer<AnyClass?>.allocate(capacity: Int(classesCount))
        defer { free(classes) }

        classesCount = objc_getClassList(AutoreleasingUnsafeMutablePointer(classes), classesCount)

        var configurationSubclasses: [QuickConfiguration.Type] = []
        for i in 0..<classesCount {
            guard
                let subclass = classes[Int(i)],
                let superclass = class_getSuperclass(subclass),
                superclass == QuickConfiguration.self
                else { continue }

            // swiftlint:disable:next force_cast
            configurationSubclasses.append(subclass as! QuickConfiguration.Type)
        }
        #endif

        configurationSubclasses.forEach(block)
    }

    #if canImport(Darwin)
    @objc
    static func configureSubclassesIfNeeded(world: World) {
        _configureSubclassesIfNeeded(world: world)
    }
    #else
    static func configureSubclassesIfNeeded(_ configurationSubclasses: [QuickConfiguration.Type]? = nil, world: World) {
        // Storing subclasses for later use (will be used when running additional test suites)
        if let configurationSubclasses = configurationSubclasses {
            self.configurationSubclasses = configurationSubclasses
        }

        _configureSubclassesIfNeeded(world: world)
    }
    #endif

    private static func _configureSubclassesIfNeeded(world: World) {
        if world.isConfigurationFinalized { return }

        // Perform all configurations (ensures that shared examples have been discovered)
        world.configure { configuration in
            enumerateSubclasses { configurationClass in
                configurationClass.configure(configuration)
            }
        }
        world.finalizeConfiguration()
    }
}
