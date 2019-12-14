import Foundation

/// A Nimble matcher that succeeds when a value is "empty". For collections, this
/// means the are no items in that collection. For strings, it is an empty string.
public func beEmpty<S: Sequence>() -> Predicate<S> {
    return Predicate.simple("be empty") { actualExpression in
        guard let actual = try actualExpression.evaluate() else {
            return .fail
        }
        var generator = actual.makeIterator()
        return PredicateStatus(bool: generator.next() == nil)
    }
}

/// A Nimble matcher that succeeds when a value is "empty". For collections, this
/// means the are no items in that collection. For strings, it is an empty string.
public func beEmpty<S: SetAlgebra>() -> Predicate<S> {
    return Predicate.simple("be empty") { actualExpression in
        guard let actual = try actualExpression.evaluate() else {
            return .fail
        }
        return PredicateStatus(bool: actual.isEmpty)
    }
}

/// A Nimble matcher that succeeds when a value is "empty". For collections, this
/// means the are no items in that collection. For strings, it is an empty string.
public func beEmpty<S: Sequence & SetAlgebra>() -> Predicate<S> {
    return Predicate.simple("be empty") { actualExpression in
        guard let actual = try actualExpression.evaluate() else {
            return .fail
        }
        return PredicateStatus(bool: actual.isEmpty)
    }
}

/// A Nimble matcher that succeeds when a value is "empty". For collections, this
/// means the are no items in that collection. For strings, it is an empty string.
public func beEmpty() -> Predicate<String> {
    return Predicate.simple("be empty") { actualExpression in
        let actualString = try actualExpression.evaluate()
        return PredicateStatus(bool: actualString == nil || NSString(string: actualString!).length  == 0)
    }
}

/// A Nimble matcher that succeeds when a value is "empty". For collections, this
/// means the are no items in that collection. For NSString instances, it is an empty string.
public func beEmpty() -> Predicate<NSString> {
    return Predicate.simple("be empty") { actualExpression in
        let actualString = try actualExpression.evaluate()
        return PredicateStatus(bool: actualString == nil || actualString!.length == 0)
    }
}

// Without specific overrides, beEmpty() is ambiguous for NSDictionary, NSArray,
// etc, since they conform to Sequence as well as NMBCollection.

/// A Nimble matcher that succeeds when a value is "empty". For collections, this
/// means the are no items in that collection. For strings, it is an empty string.
public func beEmpty() -> Predicate<NSDictionary> {
	return Predicate.simple("be empty") { actualExpression in
		let actualDictionary = try actualExpression.evaluate()
        return PredicateStatus(bool: actualDictionary == nil || actualDictionary!.count == 0)
	}
}

/// A Nimble matcher that succeeds when a value is "empty". For collections, this
/// means the are no items in that collection. For strings, it is an empty string.
public func beEmpty() -> Predicate<NSArray> {
	return Predicate.simple("be empty") { actualExpression in
		let actualArray = try actualExpression.evaluate()
        return PredicateStatus(bool: actualArray == nil || actualArray!.count == 0)
	}
}

/// A Nimble matcher that succeeds when a value is "empty". For collections, this
/// means the are no items in that collection. For strings, it is an empty string.
public func beEmpty() -> Predicate<NMBCollection> {
    return Predicate.simple("be empty") { actualExpression in
        let actual = try actualExpression.evaluate()
        return PredicateStatus(bool: actual == nil || actual!.count == 0)
    }
}

#if canImport(Darwin)
extension NMBObjCMatcher {
    @objc public class func beEmptyMatcher() -> NMBPredicate {
        return NMBPredicate { actualExpression in
            let location = actualExpression.location
            let actualValue = try actualExpression.evaluate()

            if let value = actualValue as? NMBCollection {
                let expr = Expression(expression: ({ value as NMBCollection }), location: location)
                return try beEmpty().satisfies(expr).toObjectiveC()
            } else if let value = actualValue as? NSString {
                let expr = Expression(expression: ({ value as String }), location: location)
                return try beEmpty().satisfies(expr).toObjectiveC()
            } else if let actualValue = actualValue {
                // swiftlint:disable:next line_length
                let badTypeErrorMsg = "be empty (only works for NSArrays, NSSets, NSIndexSets, NSDictionaries, NSHashTables, and NSStrings)"
                return NMBPredicateResult(
                    status: NMBPredicateStatus.fail,
                    message: NMBExpectationMessage(
                        expectedActualValueTo: badTypeErrorMsg,
                        customActualValue: "\(String(describing: type(of: actualValue))) type"
                    )
                )
            }
            return NMBPredicateResult(
                status: NMBPredicateStatus.fail,
                message: NMBExpectationMessage(expectedActualValueTo: "be empty").appendedBeNilHint()
            )
        }
    }
}
#endif
