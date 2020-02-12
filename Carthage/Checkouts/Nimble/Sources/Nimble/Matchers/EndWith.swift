import Foundation

/// A Nimble matcher that succeeds when the actual sequence's last element
/// is equal to the expected value.
public func endWith<S: Sequence, T: Equatable>(_ endingElement: T) -> Predicate<S>
    where S.Iterator.Element == T {
    return Predicate.simple("end with <\(endingElement)>") { actualExpression in
        if let actualValue = try actualExpression.evaluate() {
            var actualGenerator = actualValue.makeIterator()
            var lastItem: T?
            var item: T?
            repeat {
                lastItem = item
                item = actualGenerator.next()
            } while(item != nil)

            return PredicateStatus(bool: lastItem == endingElement)
        }
        return .fail
    }
}

/// A Nimble matcher that succeeds when the actual collection's last element
/// is equal to the expected object.
public func endWith(_ endingElement: Any) -> Predicate<NMBOrderedCollection> {
    return Predicate.simple("end with <\(endingElement)>") { actualExpression in
        guard let collection = try actualExpression.evaluate() else { return .fail }
        guard collection.count > 0 else { return PredicateStatus(bool: false) }
        #if os(Linux)
            guard let collectionValue = collection.object(at: collection.count - 1) as? NSObject else {
                return .fail
            }
        #else
            let collectionValue = collection.object(at: collection.count - 1) as AnyObject
        #endif

        return PredicateStatus(bool: collectionValue.isEqual(endingElement))
    }
}

/// A Nimble matcher that succeeds when the actual string contains the expected substring
/// where the expected substring's location is the actual string's length minus the
/// expected substring's length.
public func endWith(_ endingSubstring: String) -> Predicate<String> {
    return Predicate.simple("end with <\(endingSubstring)>") { actualExpression in
        if let collection = try actualExpression.evaluate() {
            return PredicateStatus(bool: collection.hasSuffix(endingSubstring))
        }
        return .fail
    }
}

#if canImport(Darwin)
extension NMBObjCMatcher {
    @objc public class func endWithMatcher(_ expected: Any) -> NMBMatcher {
        return NMBPredicate { actualExpression in
            let actual = try actualExpression.evaluate()
            if actual is String {
                let expr = actualExpression.cast { $0 as? String }
                // swiftlint:disable:next force_cast
                return try endWith(expected as! String).satisfies(expr).toObjectiveC()
            } else {
                let expr = actualExpression.cast { $0 as? NMBOrderedCollection }
                return try endWith(expected).satisfies(expr).toObjectiveC()
            }
        }
    }
}
#endif
