import Foundation

/// A Nimble matcher that succeeds when the actual value is greater than
/// or equal to the expected value.
public func beGreaterThanOrEqualTo<T: Comparable>(_ expectedValue: T?) -> Predicate<T> {
    let message = "be greater than or equal to <\(stringify(expectedValue))>"
    return Predicate.simple(message) { actualExpression in
        let actualValue = try actualExpression.evaluate()
        if let actual = actualValue, let expected = expectedValue {
            return PredicateStatus(bool: actual >= expected)
        }
        return .fail
    }
}

/// A Nimble matcher that succeeds when the actual value is greater than
/// or equal to the expected value.
public func beGreaterThanOrEqualTo<T: NMBComparable>(_ expectedValue: T?) -> Predicate<T> {
    let message = "be greater than or equal to <\(stringify(expectedValue))>"
    return Predicate.simple(message) { actualExpression in
        let actualValue = try actualExpression.evaluate()
        let matches = actualValue != nil && actualValue!.NMB_compare(expectedValue) != ComparisonResult.orderedAscending
        return PredicateStatus(bool: matches)
    }
}

public func >=<T: Comparable>(lhs: Expectation<T>, rhs: T) {
    lhs.to(beGreaterThanOrEqualTo(rhs))
}

public func >=<T: NMBComparable>(lhs: Expectation<T>, rhs: T) {
    lhs.to(beGreaterThanOrEqualTo(rhs))
}

#if canImport(Darwin)
extension NMBObjCMatcher {
    @objc public class func beGreaterThanOrEqualToMatcher(_ expected: NMBComparable?) -> NMBMatcher {
        return NMBPredicate { actualExpression in
            let expr = actualExpression.cast { $0 as? NMBComparable }
            return try beGreaterThanOrEqualTo(expected).satisfies(expr).toObjectiveC()
        }
    }
}
#endif
