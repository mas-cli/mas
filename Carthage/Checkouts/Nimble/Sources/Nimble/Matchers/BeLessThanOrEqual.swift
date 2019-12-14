import Foundation

/// A Nimble matcher that succeeds when the actual value is less than
/// or equal to the expected value.
public func beLessThanOrEqualTo<T: Comparable>(_ expectedValue: T?) -> Predicate<T> {
    return Predicate.simple("be less than or equal to <\(stringify(expectedValue))>") { actualExpression in
        if let actual = try actualExpression.evaluate(), let expected = expectedValue {
            return PredicateStatus(bool: actual <= expected)
        }
        return .fail
    }
}

public func <=<T: Comparable>(lhs: Expectation<T>, rhs: T) {
    lhs.to(beLessThanOrEqualTo(rhs))
}

#if canImport(Darwin) || !compiler(>=5.1)
/// A Nimble matcher that succeeds when the actual value is less than
/// or equal to the expected value.
public func beLessThanOrEqualTo<T: NMBComparable>(_ expectedValue: T?) -> Predicate<T> {
    return Predicate.simple("be less than or equal to <\(stringify(expectedValue))>") { actualExpression in
        let actualValue = try actualExpression.evaluate()
        let matches = actualValue.map { $0.NMB_compare(expectedValue) != .orderedDescending } ?? false
        return PredicateStatus(bool: matches)
    }
}

public func <=<T: NMBComparable>(lhs: Expectation<T>, rhs: T) {
    lhs.to(beLessThanOrEqualTo(rhs))
}
#endif

#if canImport(Darwin)
extension NMBObjCMatcher {
    @objc public class func beLessThanOrEqualToMatcher(_ expected: NMBComparable?) -> NMBMatcher {
        return NMBPredicate { actualExpression in
            let expr = actualExpression.cast { $0 as? NMBComparable }
            return try beLessThanOrEqualTo(expected).satisfies(expr).toObjectiveC()
        }
    }
}
#endif
