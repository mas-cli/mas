import Foundation

// The `haveCount` matchers do not print the full string representation of the collection value,
// instead they only print the type name and the expected count. This makes it easier to understand
// the reason for failed expectations. See: https://github.com/Quick/Nimble/issues/308.
// The representation of the collection content is provided in a new line as an `extendedMessage`.

/// A Nimble matcher that succeeds when the actual Collection's count equals
/// the expected value
public func haveCount<T: Collection>(_ expectedValue: T.IndexDistance) -> Predicate<T> {
    return Predicate.fromDeprecatedClosure { actualExpression, failureMessage in
        if let actualValue = try actualExpression.evaluate() {
            // swiftlint:disable:next line_length
            failureMessage.postfixMessage = "have \(prettyCollectionType(actualValue)) with count \(stringify(expectedValue))"
            let result = expectedValue == actualValue.count
            failureMessage.actualValue = "\(actualValue.count)"
            failureMessage.extendedMessage = "Actual Value: \(stringify(actualValue))"
            return result
        } else {
            return false
        }
    }.requireNonNil
}

/// A Nimble matcher that succeeds when the actual collection's count equals
/// the expected value
public func haveCount(_ expectedValue: Int) -> Predicate<NMBCollection> {
    return Predicate.fromDeprecatedClosure { actualExpression, failureMessage in
        if let actualValue = try actualExpression.evaluate() {
            // swiftlint:disable:next line_length
            failureMessage.postfixMessage = "have \(prettyCollectionType(actualValue)) with count \(stringify(expectedValue))"
            let result = expectedValue == actualValue.count
            failureMessage.actualValue = "\(actualValue.count)"
            failureMessage.extendedMessage = "Actual Value: \(stringify(actualValue))"
            return result
        } else {
            return false
        }
    }
}

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
extension NMBObjCMatcher {
    @objc public class func haveCountMatcher(_ expected: NSNumber) -> NMBObjCMatcher {
        return NMBObjCMatcher(canMatchNil: false) { actualExpression, failureMessage in
            let location = actualExpression.location
            let actualValue = try! actualExpression.evaluate()
            if let value = actualValue as? NMBCollection {
                let expr = Expression(expression: ({ value as NMBCollection}), location: location)
                return try! haveCount(expected.intValue).matches(expr, failureMessage: failureMessage)
            } else if let actualValue = actualValue {
                failureMessage.postfixMessage = "get type of NSArray, NSSet, NSDictionary, or NSHashTable"
                failureMessage.actualValue = "\(String(describing: type(of: actualValue)))"
            }
            return false
        }
    }
}
#endif
