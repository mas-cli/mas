import Foundation

/// A Nimble matcher that succeeds when the actual value matches with any of the matchers
/// provided in the variable list of matchers. 
public func satisfyAnyOf<T, U>(_ matchers: U...) -> Predicate<T>
    where U: Matcher, U.ValueType == T {
    return satisfyAnyOf(matchers)
}

/// Deprecated. Please use `satisfyAnyOf<T>(_) -> Predicate<T>` instead.
internal func satisfyAnyOf<T, U>(_ matchers: [U]) -> Predicate<T>
    where U: Matcher, U.ValueType == T {
        return NonNilMatcherFunc<T> { actualExpression, failureMessage in
            let postfixMessages = NSMutableArray()
            var matches = false
            for matcher in matchers {
                if try matcher.matches(actualExpression, failureMessage: failureMessage) {
                    matches = true
                }
                postfixMessages.add(NSString(string: "{\(failureMessage.postfixMessage)}"))
            }

            failureMessage.postfixMessage = "match one of: " + postfixMessages.componentsJoined(by: ", or ")
            if let actualValue = try actualExpression.evaluate() {
                failureMessage.actualValue = "\(actualValue)"
            }

            return matches
        }.predicate
}

internal func satisfyAnyOf<T>(_ predicates: [Predicate<T>]) -> Predicate<T> {
        return Predicate { actualExpression in
            var postfixMessages = [String]()
            var matches = false
            for predicate in predicates {
                let result = try predicate.satisfies(actualExpression)
                if result.toBoolean(expectation: .toMatch) {
                    matches = true
                }
                postfixMessages.append("{\(result.message.expectedMessage)}")
            }

            var msg: ExpectationMessage
            if let actualValue = try actualExpression.evaluate() {
                msg = .expectedCustomValueTo(
                    "match one of: " + postfixMessages.joined(separator: ", or "),
                    "\(actualValue)"
                )
            } else {
                msg = .expectedActualValueTo(
                    "match one of: " + postfixMessages.joined(separator: ", or ")
                )
            }

            return PredicateResult(
                status: PredicateStatus(bool: matches),
                message: msg
            )
        }.requireNonNil
}

public func || <T>(left: Predicate<T>, right: Predicate<T>) -> Predicate<T> {
        return satisfyAnyOf(left, right)
}

public func || <T>(left: NonNilMatcherFunc<T>, right: NonNilMatcherFunc<T>) -> Predicate<T> {
    return satisfyAnyOf(left, right)
}

public func || <T>(left: MatcherFunc<T>, right: MatcherFunc<T>) -> Predicate<T> {
    return satisfyAnyOf(left, right)
}

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
extension NMBObjCMatcher {
    @objc public class func satisfyAnyOfMatcher(_ matchers: [NMBMatcher]) -> NMBPredicate {
        return NMBPredicate { actualExpression in
            if matchers.isEmpty {
                return NMBPredicateResult(
                    status: NMBPredicateStatus.fail,
                    message: NMBExpectationMessage(
                        fail: "satisfyAnyOf must be called with at least one matcher"
                    )
                )
            }

            var elementEvaluators = [Predicate<NSObject>]()
            for matcher in matchers {
                let elementEvaluator = Predicate<NSObject> { expression in
                    if let predicate = matcher as? NMBPredicate {
                        // swiftlint:disable:next line_length
                        return predicate.satisfies({ try! expression.evaluate() }, location: actualExpression.location).toSwift()
                    } else {
                        let failureMessage = FailureMessage()
                        // swiftlint:disable:next line_length
                        let success = matcher.matches({ try! expression.evaluate() }, failureMessage: failureMessage, location: actualExpression.location)
                        return PredicateResult(bool: success, message: failureMessage.toExpectationMessage())
                    }
                }

                elementEvaluators.append(elementEvaluator)
            }

            return try! satisfyAnyOf(elementEvaluators).satisfies(actualExpression).toObjectiveC()
        }
    }
}
#endif
