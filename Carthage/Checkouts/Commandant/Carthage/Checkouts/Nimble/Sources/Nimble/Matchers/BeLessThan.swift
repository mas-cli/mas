import Foundation

/// A Nimble matcher that succeeds when the actual value is less than the expected value.
public func beLessThan<T: Comparable>(_ expectedValue: T?) -> Predicate<T> {
    return Predicate.fromDeprecatedClosure { actualExpression, failureMessage in
        failureMessage.postfixMessage = "be less than <\(stringify(expectedValue))>"
        if let actual = try actualExpression.evaluate(), let expected = expectedValue {
            return actual < expected
        }
        return false
    }.requireNonNil
}

/// A Nimble matcher that succeeds when the actual value is less than the expected value.
public func beLessThan(_ expectedValue: NMBComparable?) -> Predicate<NMBComparable> {
    return Predicate.fromDeprecatedClosure { actualExpression, failureMessage in
        failureMessage.postfixMessage = "be less than <\(stringify(expectedValue))>"
        let actualValue = try actualExpression.evaluate()
        let matches = actualValue != nil && actualValue!.NMB_compare(expectedValue) == ComparisonResult.orderedAscending
        return matches
    }.requireNonNil
}

public func <<T: Comparable>(lhs: Expectation<T>, rhs: T) {
    lhs.to(beLessThan(rhs))
}

public func < (lhs: Expectation<NMBComparable>, rhs: NMBComparable?) {
    lhs.to(beLessThan(rhs))
}

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
extension NMBObjCMatcher {
    @objc public class func beLessThanMatcher(_ expected: NMBComparable?) -> NMBObjCMatcher {
        return NMBObjCMatcher(canMatchNil: false) { actualExpression, failureMessage in
            let expr = actualExpression.cast { $0 as? NMBComparable }
            return try! beLessThan(expected).matches(expr, failureMessage: failureMessage)
        }
    }
}
#endif
