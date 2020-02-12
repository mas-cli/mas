import Foundation

/// A Nimble matcher that succeeds when the actual sequence contains the expected values.
public func contain<S: Sequence, T: Equatable>(_ items: T...) -> Predicate<S>
    where S.Element == T {
    return contain(items)
}

/// A Nimble matcher that succeeds when the actual sequence contains the expected values.
public func contain<S: Sequence, T: Equatable>(_ items: [T]) -> Predicate<S>
    where S.Element == T {
    return Predicate.simple("contain <\(arrayAsString(items))>") { actualExpression in
        if let actual = try actualExpression.evaluate() {
            let matches = items.allSatisfy {
                return actual.contains($0)
            }
            return PredicateStatus(bool: matches)
        }
        return .fail
    }
}

/// A Nimble matcher that succeeds when the actual set contains the expected values.
public func contain<S: SetAlgebra, T: Equatable>(_ items: T...) -> Predicate<S>
    where S.Element == T {
        return contain(items)
}

/// A Nimble matcher that succeeds when the actual set contains the expected values.
public func contain<S: SetAlgebra, T: Equatable>(_ items: [T]) -> Predicate<S>
    where S.Element == T {
        return Predicate.simple("contain <\(arrayAsString(items))>") { actualExpression in
            if let actual = try actualExpression.evaluate() {
                let matches = items.allSatisfy {
                    return actual.contains($0)
                }
                return PredicateStatus(bool: matches)
            }
            return .fail
        }
}

/// A Nimble matcher that succeeds when the actual set contains the expected values.
public func contain<S: Sequence & SetAlgebra, T: Equatable>(_ items: T...) -> Predicate<S>
    where S.Element == T {
        return contain(items)
}

/// A Nimble matcher that succeeds when the actual set contains the expected values.
public func contain<S: Sequence & SetAlgebra, T: Equatable>(_ items: [T]) -> Predicate<S>
    where S.Element == T {
        return Predicate.simple("contain <\(arrayAsString(items))>") { actualExpression in
            if let actual = try actualExpression.evaluate() {
                let matches = items.allSatisfy {
                    return actual.contains($0)
                }
                return PredicateStatus(bool: matches)
            }
            return .fail
        }
}

/// A Nimble matcher that succeeds when the actual string contains the expected substring.
public func contain(_ substrings: String...) -> Predicate<String> {
    return contain(substrings)
}

public func contain(_ substrings: [String]) -> Predicate<String> {
    return Predicate.simple("contain <\(arrayAsString(substrings))>") { actualExpression in
        if let actual = try actualExpression.evaluate() {
            let matches = substrings.allSatisfy {
                let range = actual.range(of: $0)
                return range != nil && !range!.isEmpty
            }
            return PredicateStatus(bool: matches)
        }
        return .fail
    }
}

/// A Nimble matcher that succeeds when the actual string contains the expected substring.
public func contain(_ substrings: NSString...) -> Predicate<NSString> {
    return contain(substrings)
}

public func contain(_ substrings: [NSString]) -> Predicate<NSString> {
    return Predicate.simple("contain <\(arrayAsString(substrings))>") { actualExpression in
        if let actual = try actualExpression.evaluate() {
            let matches = substrings.allSatisfy { actual.range(of: $0.description).length != 0 }
            return PredicateStatus(bool: matches)
        }
        return .fail
    }
}

/// A Nimble matcher that succeeds when the actual collection contains the expected object.
public func contain(_ items: Any?...) -> Predicate<NMBContainer> {
    return contain(items)
}

public func contain(_ items: [Any?]) -> Predicate<NMBContainer> {
    return Predicate.simple("contain <\(arrayAsString(items))>") { actualExpression in
        guard let actual = try actualExpression.evaluate() else { return .fail }
        let matches = items.allSatisfy { item in
            return item.map { actual.contains($0) } ?? false
        }
        return PredicateStatus(bool: matches)
    }
}

#if canImport(Darwin)
extension NMBObjCMatcher {
    @objc public class func containMatcher(_ expected: [NSObject]) -> NMBMatcher {
        return NMBPredicate { actualExpression in
            let location = actualExpression.location
            let actualValue = try actualExpression.evaluate()
            if let value = actualValue as? NMBContainer {
                let expr = Expression(expression: ({ value as NMBContainer }), location: location)

                // A straightforward cast on the array causes this to crash, so we have to cast the individual items
                let expectedOptionals: [Any?] = expected.map({ $0 as Any? })
                return try contain(expectedOptionals).satisfies(expr).toObjectiveC()
            } else if let value = actualValue as? NSString {
                let expr = Expression(expression: ({ value as String }), location: location)
                // swiftlint:disable:next force_cast
                return try contain(expected as! [String]).satisfies(expr).toObjectiveC()
            }

            let message: ExpectationMessage
            if actualValue != nil {
                message = ExpectationMessage.expectedActualValueTo(
                    // swiftlint:disable:next line_length
                    "contain <\(arrayAsString(expected))> (only works for NSArrays, NSSets, NSHashTables, and NSStrings)"
                )
            } else {
                message = ExpectationMessage
                    .expectedActualValueTo("contain <\(arrayAsString(expected))>")
                    .appendedBeNilHint()
            }
            return NMBPredicateResult(status: .fail, message: message.toObjectiveC())
        }
    }
}
#endif
