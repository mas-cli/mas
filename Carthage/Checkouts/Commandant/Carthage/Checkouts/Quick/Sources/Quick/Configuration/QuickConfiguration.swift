import Foundation
import XCTest

// NOTE: This file is not intended to be included in the Xcode project or CocoaPods.
//       It is picked up by the Swift Package Manager during its build process.

#if SWIFT_PACKAGE

open class QuickConfiguration: NSObject {
    open class func configure(_ configuration: Configuration) {}
}

#if canImport(Darwin)

internal func qck_enumerateSubclasses<T: AnyObject>(_ klass: T.Type, block: (T.Type) -> Void) {
    var classesCount = objc_getClassList(nil, 0)

    guard classesCount > 0 else {
        return
    }

    let classes = UnsafeMutablePointer<AnyClass?>.allocate(capacity: Int(classesCount))
    classesCount = objc_getClassList(AutoreleasingUnsafeMutablePointer(classes), classesCount)

    var subclass: AnyClass!
    for i in 0..<classesCount {
        subclass = classes[Int(i)]

        guard let superclass = class_getSuperclass(subclass), superclass == klass else { continue }

        block(subclass as! T.Type) // swiftlint:disable:this force_cast
    }

    free(classes)
}

#endif

#endif
