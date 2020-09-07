/// A Nimble matcher that succeeds when the actual value is less than
/// or equal to the expected value.
public func beLessThanOrEqualTo<T: Comparable>(_ expectedValue: T?) -> Predicate<T> {
    return Predicate.simple("be less than or equal to <\(stringify(expectedValue))>") { actualExpression in
        guard let actual = try actualExpression.evaluate(), let expected = expectedValue else { return .fail }

        return PredicateStatus(bool: actual <= expected)
    }
}

public func <=<T: Comparable>(lhs: Expectation<T>, rhs: T) {
    lhs.to(beLessThanOrEqualTo(rhs))
}

#if canImport(Darwin)
import enum Foundation.ComparisonResult

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

extension NMBPredicate {
    @objc public class func beLessThanOrEqualToMatcher(_ expected: NMBComparable?) -> NMBPredicate {
        return NMBPredicate { actualExpression in
            let expr = actualExpression.cast { $0 as? NMBComparable }
            return try beLessThanOrEqualTo(expected).satisfies(expr).toObjectiveC()
        }
    }
}
#endif
