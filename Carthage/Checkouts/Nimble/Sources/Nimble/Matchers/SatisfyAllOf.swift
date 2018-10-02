import Foundation

/// A Nimble matcher that succeeds when the actual value matches with all of the matchers
/// provided in the variable list of matchers.
public func satisfyAllOf<T, U>(_ matchers: U...) -> Predicate<T>
    where U: Matcher, U.ValueType == T {
        return satisfyAllOf(matchers.map { $0.predicate })
}

internal func satisfyAllOf<T>(_ predicates: [Predicate<T>]) -> Predicate<T> {
	return Predicate.define { actualExpression in
        var postfixMessages = [String]()
        var matches = true
        for predicate in predicates {
            let result = try predicate.satisfies(actualExpression)
            if result.toBoolean(expectation: .toNotMatch) {
                matches = false
            }
            postfixMessages.append("{\(result.message.expectedMessage)}")
        }

        var msg: ExpectationMessage
        if let actualValue = try actualExpression.evaluate() {
            msg = .expectedCustomValueTo(
                "match all of: " + postfixMessages.joined(separator: ", and "),
                "\(actualValue)"
            )
        } else {
            msg = .expectedActualValueTo(
                "match all of: " + postfixMessages.joined(separator: ", and ")
            )
        }

        return PredicateResult(bool: matches, message: msg)
    }
}

public func && <T>(left: Predicate<T>, right: Predicate<T>) -> Predicate<T> {
    return satisfyAllOf(left, right)
}

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
extension NMBObjCMatcher {
    @objc public class func satisfyAllOfMatcher(_ matchers: [NMBMatcher]) -> NMBPredicate {
        return NMBPredicate { actualExpression in
            if matchers.isEmpty {
                return NMBPredicateResult(
                    status: NMBPredicateStatus.fail,
                    message: NMBExpectationMessage(
                        fail: "satisfyAllOf must be called with at least one matcher"
                    )
                )
            }

            var elementEvaluators = [Predicate<NSObject>]()
            for matcher in matchers {
                let elementEvaluator = Predicate<NSObject> { expression in
                    if let predicate = matcher as? NMBPredicate {
                        // swiftlint:disable:next line_length
                        return predicate.satisfies({ try expression.evaluate() }, location: actualExpression.location).toSwift()
                    } else {
                        let failureMessage = FailureMessage()
                        // swiftlint:disable:next line_length
                        let success = matcher.matches({ try! expression.evaluate() }, failureMessage: failureMessage, location: actualExpression.location)
                        return PredicateResult(bool: success, message: failureMessage.toExpectationMessage())
                    }
                }

                elementEvaluators.append(elementEvaluator)
            }

            return try satisfyAllOf(elementEvaluators).satisfies(actualExpression).toObjectiveC()
        }
    }
}
#endif
