import Foundation

/// A Nimble matcher that succeeds when the actual value is the same instance
/// as the expected instance.
public func beIdenticalTo(_ expected: Any?) -> Predicate<Any> {
    return Predicate.fromDeprecatedClosure { actualExpression, failureMessage in
        #if os(Linux)
            let actual = try actualExpression.evaluate() as? AnyObject
        #else
            let actual = try actualExpression.evaluate() as AnyObject?
        #endif
        failureMessage.actualValue = "\(identityAsString(actual))"
        failureMessage.postfixMessage = "be identical to \(identityAsString(expected))"
        #if os(Linux)
            return actual === (expected as? AnyObject) && actual !== nil
        #else
            return actual === (expected as AnyObject?) && actual !== nil
        #endif
    }.requireNonNil
}

public func === (lhs: Expectation<Any>, rhs: Any?) {
    lhs.to(beIdenticalTo(rhs))
}
public func !== (lhs: Expectation<Any>, rhs: Any?) {
    lhs.toNot(beIdenticalTo(rhs))
}

/// A Nimble matcher that succeeds when the actual value is the same instance
/// as the expected instance.
///
/// Alias for "beIdenticalTo".
public func be(_ expected: Any?) -> Predicate<Any> {
    return beIdenticalTo(expected)
}

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
extension NMBObjCMatcher {
    @objc public class func beIdenticalToMatcher(_ expected: NSObject?) -> NMBObjCMatcher {
        return NMBObjCMatcher(canMatchNil: false) { actualExpression, failureMessage in
            let aExpr = actualExpression.cast { $0 as Any? }
            return try! beIdenticalTo(expected).matches(aExpr, failureMessage: failureMessage)
        }
    }
}
#endif
