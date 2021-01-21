import Foundation

/// A Nimble matcher that succeeds when the actual sequence's first element
/// is equal to the expected value.
public func beginWith<S: Sequence>(_ startingElement: S.Element) -> Predicate<S> where S.Element: Equatable {
    return Predicate.simple("begin with <\(startingElement)>") { actualExpression in
        guard let actualValue = try actualExpression.evaluate() else { return .fail }

        var actualGenerator = actualValue.makeIterator()
        return PredicateStatus(bool: actualGenerator.next() == startingElement)
    }
}

/// A Nimble matcher that succeeds when the actual collection's first element
/// is equal to the expected object.
public func beginWith(_ startingElement: Any) -> Predicate<NMBOrderedCollection> {
    return Predicate.simple("begin with <\(startingElement)>") { actualExpression in
        guard let collection = try actualExpression.evaluate() else { return .fail }
        guard collection.count > 0 else { return .doesNotMatch }
        #if os(Linux)
            guard let collectionValue = collection.object(at: 0) as? NSObject else {
                return .fail
            }
        #else
            let collectionValue = collection.object(at: 0) as AnyObject
        #endif
        return PredicateStatus(bool: collectionValue.isEqual(startingElement))
    }
}

/// A Nimble matcher that succeeds when the actual string contains expected substring
/// where the expected substring's location is zero.
public func beginWith(_ startingSubstring: String) -> Predicate<String> {
    return Predicate.simple("begin with <\(startingSubstring)>") { actualExpression in
        guard let actual = try actualExpression.evaluate() else { return .fail }

        return PredicateStatus(bool: actual.hasPrefix(startingSubstring))
    }
}

#if canImport(Darwin)
extension NMBPredicate {
    @objc public class func beginWithMatcher(_ expected: Any) -> NMBPredicate {
        return NMBPredicate { actualExpression in
            let actual = try actualExpression.evaluate()
            if actual is String {
                let expr = actualExpression.cast { $0 as? String }
                // swiftlint:disable:next force_cast
                return try beginWith(expected as! String).satisfies(expr).toObjectiveC()
            } else {
                let expr = actualExpression.cast { $0 as? NMBOrderedCollection }
                return try beginWith(expected).satisfies(expr).toObjectiveC()
            }
        }
    }
}
#endif
