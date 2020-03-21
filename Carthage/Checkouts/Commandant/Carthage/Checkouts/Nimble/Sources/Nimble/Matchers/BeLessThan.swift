import Foundation

/// A Nimble matcher that succeeds when the actual value is less than the expected value.
public func beLessThan<T: Comparable>(_ expectedValue: T?) -> Predicate<T> {
    let message = "be less than <\(stringify(expectedValue))>"
    return Predicate.simple(message) { actualExpression in
        if let actual = try actualExpression.evaluate(), let expected = expectedValue {
            return PredicateStatus(bool: actual < expected)
        }
        return .fail
    }
}

/// A Nimble matcher that succeeds when the actual value is less than the expected value.
public func beLessThan(_ expectedValue: NMBComparable?) -> Predicate<NMBComparable> {
    let message = "be less than <\(stringify(expectedValue))>"
    return Predicate.simple(message) { actualExpression in
        let actualValue = try actualExpression.evaluate()
        let matches = actualValue != nil && actualValue!.NMB_compare(expectedValue) == ComparisonResult.orderedAscending
        return PredicateStatus(bool: matches)
    }
}

public func <<T: Comparable>(lhs: Expectation<T>, rhs: T) {
    lhs.to(beLessThan(rhs))
}

public func < (lhs: Expectation<NMBComparable>, rhs: NMBComparable?) {
    lhs.to(beLessThan(rhs))
}

#if canImport(Darwin)
extension NMBObjCMatcher {
    @objc public class func beLessThanMatcher(_ expected: NMBComparable?) -> NMBMatcher {
        return NMBPredicate { actualExpression in
            let expr = actualExpression.cast { $0 as? NMBComparable }
            return try beLessThan(expected).satisfies(expr).toObjectiveC()
        }
    }
}
#endif
