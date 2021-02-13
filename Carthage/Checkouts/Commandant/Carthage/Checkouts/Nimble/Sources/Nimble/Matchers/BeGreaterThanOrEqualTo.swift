/// A Nimble matcher that succeeds when the actual value is greater than
/// or equal to the expected value.
public func beGreaterThanOrEqualTo<T: Comparable>(_ expectedValue: T?) -> Predicate<T> {
    let message = "be greater than or equal to <\(stringify(expectedValue))>"
    return Predicate.simple(message) { actualExpression in
        guard let actual = try actualExpression.evaluate(), let expected = expectedValue else { return .fail }

        return PredicateStatus(bool: actual >= expected)
    }
}

public func >=<T: Comparable>(lhs: Expectation<T>, rhs: T) {
    lhs.to(beGreaterThanOrEqualTo(rhs))
}

#if canImport(Darwin)
import enum Foundation.ComparisonResult

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

public func >=<T: NMBComparable>(lhs: Expectation<T>, rhs: T) {
    lhs.to(beGreaterThanOrEqualTo(rhs))
}

extension NMBPredicate {
    @objc public class func beGreaterThanOrEqualToMatcher(_ expected: NMBComparable?) -> NMBPredicate {
        return NMBPredicate { actualExpression in
            let expr = actualExpression.cast { $0 as? NMBComparable }
            return try beGreaterThanOrEqualTo(expected).satisfies(expr).toObjectiveC()
        }
    }
}
#endif
