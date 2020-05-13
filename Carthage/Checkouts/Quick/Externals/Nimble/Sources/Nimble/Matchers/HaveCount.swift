import Foundation

// The `haveCount` matchers do not print the full string representation of the collection value,
// instead they only print the type name and the expected count. This makes it easier to understand
// the reason for failed expectations. See: https://github.com/Quick/Nimble/issues/308.
// The representation of the collection content is provided in a new line as an `extendedMessage`.

/// A Nimble matcher that succeeds when the actual Collection's count equals
/// the expected value
public func haveCount<T: Collection>(_ expectedValue: Int) -> Predicate<T> {
    return Predicate.define { actualExpression in
        if let actualValue = try actualExpression.evaluate() {
            let message = ExpectationMessage
                .expectedCustomValueTo(
                    "have \(prettyCollectionType(actualValue)) with count \(stringify(expectedValue))",
                    "\(actualValue.count)"
                )
                .appended(details: "Actual Value: \(stringify(actualValue))")

            let result = expectedValue == actualValue.count
            return PredicateResult(bool: result, message: message)
        } else {
            return PredicateResult(status: .fail, message: .fail(""))
        }
    }
}

/// A Nimble matcher that succeeds when the actual collection's count equals
/// the expected value
public func haveCount(_ expectedValue: Int) -> Predicate<NMBCollection> {
    return Predicate { actualExpression in
        if let actualValue = try actualExpression.evaluate() {
            let message = ExpectationMessage
                .expectedCustomValueTo(
                    "have \(prettyCollectionType(actualValue)) with count \(stringify(expectedValue))",
                    "\(actualValue.count)"
                )
                .appended(details: "Actual Value: \(stringify(actualValue))")

            let result = expectedValue == actualValue.count
            return PredicateResult(bool: result, message: message)
        } else {
            return PredicateResult(status: .fail, message: .fail(""))
        }
    }
}

#if canImport(Darwin)
extension NMBObjCMatcher {
    @objc public class func haveCountMatcher(_ expected: NSNumber) -> NMBMatcher {
        return NMBPredicate { actualExpression in
            let location = actualExpression.location
            let actualValue = try actualExpression.evaluate()
            if let value = actualValue as? NMBCollection {
                let expr = Expression(expression: ({ value as NMBCollection}), location: location)
                return try haveCount(expected.intValue).satisfies(expr).toObjectiveC()
            }

            let message: ExpectationMessage
            if let actualValue = actualValue {
                message = ExpectationMessage.expectedCustomValueTo(
                    "get type of NSArray, NSSet, NSDictionary, or NSHashTable",
                    "\(String(describing: type(of: actualValue)))"
                )
            } else {
                message = ExpectationMessage
                    .expectedActualValueTo("have a collection with count \(stringify(expected.intValue))")
                    .appendedBeNilHint()
            }
            return NMBPredicateResult(status: .fail, message: message.toObjectiveC())
        }
    }
}
#endif
