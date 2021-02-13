/// A Nimble matcher that succeeds when the actual string satisfies the regular expression
/// described by the expected string.
public func match(_ expectedValue: String?) -> Predicate<String> {
    return Predicate.simple("match <\(stringify(expectedValue))>") { actualExpression in
        guard let actual = try actualExpression.evaluate(), let regexp = expectedValue else { return .fail }

        let bool = actual.range(of: regexp, options: .regularExpression) != nil
        return PredicateStatus(bool: bool)
    }
}

#if canImport(Darwin)
import class Foundation.NSString

extension NMBPredicate {
    @objc public class func matchMatcher(_ expected: NSString) -> NMBPredicate {
        return NMBPredicate { actualExpression in
            let actual = actualExpression.cast { $0 as? String }
            return try match(expected.description).satisfies(actual).toObjectiveC()
        }
    }
}
#endif
