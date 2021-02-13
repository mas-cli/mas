/// A Nimble matcher that succeeds when the actual value is the same instance
/// as the expected instance.
public func beIdenticalTo(_ expected: Any?) -> Predicate<Any> {
    return Predicate.define { actualExpression in
        let actual = try actualExpression.evaluate() as AnyObject?

        let bool = actual === (expected as AnyObject?) && actual !== nil
        return PredicateResult(
            bool: bool,
            message: .expectedCustomValueTo(
                "be identical to \(identityAsString(expected))",
                actual: "\(identityAsString(actual))"
            )
        )
    }
}

extension Expectation where T == Any {
    public static func === (lhs: Expectation, rhs: Any?) {
        lhs.to(beIdenticalTo(rhs))
    }

    public static func !== (lhs: Expectation, rhs: Any?) {
        lhs.toNot(beIdenticalTo(rhs))
    }
}

/// A Nimble matcher that succeeds when the actual value is the same instance
/// as the expected instance.
///
/// Alias for "beIdenticalTo".
public func be(_ expected: Any?) -> Predicate<Any> {
    return beIdenticalTo(expected)
}

#if canImport(Darwin)
import class Foundation.NSObject

extension NMBPredicate {
    @objc public class func beIdenticalToMatcher(_ expected: NSObject?) -> NMBPredicate {
        return NMBPredicate { actualExpression in
            let aExpr = actualExpression.cast { $0 as Any? }
            return try beIdenticalTo(expected).satisfies(aExpr).toObjectiveC()
        }
    }
}
#endif
