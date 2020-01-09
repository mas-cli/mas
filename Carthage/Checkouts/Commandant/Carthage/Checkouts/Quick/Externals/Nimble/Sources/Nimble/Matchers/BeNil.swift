import Foundation

/// A Nimble matcher that succeeds when the actual value is nil.
public func beNil<T>() -> Predicate<T> {
    return Predicate.simpleNilable("be nil") { actualExpression in
        let actualValue = try actualExpression.evaluate()
        return PredicateStatus(bool: actualValue == nil)
    }
}

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
extension NMBObjCMatcher {
    @objc public class func beNilMatcher() -> NMBObjCMatcher {
        return NMBObjCMatcher { actualExpression, failureMessage in
            return try! beNil().matches(actualExpression, failureMessage: failureMessage)
        }
    }
}
#endif
