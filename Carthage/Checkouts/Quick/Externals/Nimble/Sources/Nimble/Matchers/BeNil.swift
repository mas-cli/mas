/// A Nimble matcher that succeeds when the actual value is nil.
public func beNil<T>() -> Predicate<T> {
    return Predicate.simpleNilable("be nil") { actualExpression in
        let actualValue = try actualExpression.evaluate()
        return PredicateStatus(bool: actualValue == nil)
    }
}

#if canImport(Darwin)
import Foundation

extension NMBPredicate {
    @objc public class func beNilMatcher() -> NMBPredicate {
        return NMBPredicate { actualExpression in
            return try beNil().satisfies(actualExpression).toObjectiveC()
        }
    }
}
#endif
