#if !SWIFT_PACKAGE

import Foundation
import XCTest

/// A dummy protocol for calling the internal `+[QuickSpec buildExamplesIfNeeded]` method
/// which is defined in Objective-C from Swift.
@objc internal protocol _QuickSpecInternal {
    static func buildExamplesIfNeeded()
}

@objc internal final class QuickTestObservation: NSObject, XCTestObservation {
    @objc(sharedInstance)
    static let shared = QuickTestObservation()

    // Quick hooks into this event to compile example groups for each QuickSpec subclasses.
    //
    // If an exception occurs when compiling examples, report it to the user. Chances are they
    // included an expectation outside of a "it", "describe", or "context" block.
    func testBundleWillStart(_ testBundle: Bundle) {
        QuickSpec.enumerateSubclasses { specClass in
            // This relies on `_QuickSpecInternal`.
            (specClass as AnyClass).buildExamplesIfNeeded()
        }
    }
}

// swiftlint:disable:next todo
// TODO: Unify this with QuickConfiguration's equivalent
extension QuickSpec {
    internal static func enumerateSubclasses(
        subclasses: [QuickSpec.Type]? = nil,
        _ block: (QuickSpec.Type) -> Void
    ) {
        let subjects: [QuickSpec.Type]
        if let subclasses = subclasses {
            subjects = subclasses
        } else {
            let classesCount = objc_getClassList(nil, 0)

            guard classesCount > 0 else {
                return
            }

            let classes = UnsafeMutablePointer<AnyClass?>.allocate(capacity: Int(classesCount))
            defer { free(classes) }

            objc_getClassList(AutoreleasingUnsafeMutablePointer(classes), classesCount)

            var specSubclasses: [QuickSpec.Type] = []
            for index in 0..<classesCount {
                guard
                    let subclass = classes[Int(index)],
                    let superclass = class_getSuperclass(subclass),
                    superclass is QuickSpec.Type
                    else { continue }

                // swiftlint:disable:next force_cast
                specSubclasses.append(subclass as! QuickSpec.Type)
            }

            subjects = specSubclasses
        }

        subjects.forEach(block)
    }
}

#endif
