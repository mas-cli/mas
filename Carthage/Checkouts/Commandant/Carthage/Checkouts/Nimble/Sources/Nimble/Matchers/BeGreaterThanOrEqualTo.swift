import Foundation

/// A Nimble matcher that succeeds when the actual value is greater than
/// or equal to the expected value.
public func beGreaterThanOrEqualTo<T: Comparable>(_ expectedValue: T?) -> Predicate<T> {
    return Predicate.fromDeprecatedClosure { actualExpression, failureMessage in
        failureMessage.postfixMessage = "be greater than or equal to <\(stringify(expectedValue))>"
        let actualValue = try actualExpression.evaluate()
        if let actual = actualValue, let expected = expectedValue {
            return actual >= expected
        }
        return false
    }.requireNonNil
}

/// A Nimble matcher that succeeds when the actual value is greater than
/// or equal to the expected value.
public func beGreaterThanOrEqualTo<T: NMBComparable>(_ expectedValue: T?) -> Predicate<T> {
    return Predicate.fromDeprecatedClosure { actualExpression, failureMessage in
        failureMessage.postfixMessage = "be greater than or equal to <\(stringify(expectedValue))>"
        let actualValue = try actualExpression.evaluate()
        let matches = actualValue != nil && actualValue!.NMB_compare(expectedValue) != ComparisonResult.orderedAscending
        return matches
    }.requireNonNil
}

public func >=<T: Comparable>(lhs: Expectation<T>, rhs: T) {
    lhs.to(beGreaterThanOrEqualTo(rhs))
}

public func >=<T: NMBComparable>(lhs: Expectation<T>, rhs: T) {
    lhs.to(beGreaterThanOrEqualTo(rhs))
}

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
extension NMBObjCMatcher {
    @objc public class func beGreaterThanOrEqualToMatcher(_ expected: NMBComparable?) -> NMBObjCMatcher {
        return NMBObjCMatcher(canMatchNil: false) { actualExpression, failureMessage in
            let expr = actualExpression.cast { $0 as? NMBComparable }
            return try! beGreaterThanOrEqualTo(expected).matches(expr, failureMessage: failureMessage)
        }
    }
}
#endif
