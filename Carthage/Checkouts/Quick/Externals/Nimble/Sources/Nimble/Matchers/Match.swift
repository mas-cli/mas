import Foundation

/// A Nimble matcher that succeeds when the actual string satisfies the regular expression
/// described by the expected string.
public func match(_ expectedValue: String?) -> Predicate<String> {
    return Predicate.simple("match <\(stringify(expectedValue))>") { actualExpression in
        if let actual = try actualExpression.evaluate() {
            if let regexp = expectedValue {
                let bool = actual.range(of: regexp, options: .regularExpression) != nil
                return PredicateStatus(bool: bool)
            }
        }

        return .fail
    }
}

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)

extension NMBObjCMatcher {
    @objc public class func matchMatcher(_ expected: NSString) -> NMBMatcher {
        return NMBPredicate { actualExpression in
            let actual = actualExpression.cast { $0 as? String }
            return try! match(expected.description).satisfies(actual).toObjectiveC()
        }
    }
}

#endif
