import Foundation

/// A Nimble matcher that succeeds when the actual value is less than
/// or equal to the expected value.
public func beLessThanOrEqualTo<T: Comparable>(_ expectedValue: T?) -> Predicate<T> {
    return Predicate.fromDeprecatedClosure { actualExpression, failureMessage in
        failureMessage.postfixMessage = "be less than or equal to <\(stringify(expectedValue))>"
        if let actual = try actualExpression.evaluate(), let expected = expectedValue {
            return actual <= expected
        }
        return false
    }.requireNonNil
}

/// A Nimble matcher that succeeds when the actual value is less than
/// or equal to the expected value.
public func beLessThanOrEqualTo<T: NMBComparable>(_ expectedValue: T?) -> Predicate<T> {
    return Predicate.fromDeprecatedClosure { actualExpression, failureMessage in
        failureMessage.postfixMessage = "be less than or equal to <\(stringify(expectedValue))>"
        let actualValue = try actualExpression.evaluate()
        return actualValue != nil && actualValue!.NMB_compare(expectedValue) != ComparisonResult.orderedDescending
    }.requireNonNil
}

public func <=<T: Comparable>(lhs: Expectation<T>, rhs: T) {
    lhs.to(beLessThanOrEqualTo(rhs))
}

public func <=<T: NMBComparable>(lhs: Expectation<T>, rhs: T) {
    lhs.to(beLessThanOrEqualTo(rhs))
}

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
extension NMBObjCMatcher {
    @objc public class func beLessThanOrEqualToMatcher(_ expected: NMBComparable?) -> NMBObjCMatcher {
        return NMBObjCMatcher(canMatchNil: false) { actualExpression, failureMessage in
            let expr = actualExpression.cast { $0 as? NMBComparable }
            return try! beLessThanOrEqualTo(expected).matches(expr, failureMessage: failureMessage)
        }
    }
}
#endif
