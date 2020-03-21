import Foundation

/// A Nimble matcher that succeeds when the actual value is equal to the expected value.
/// Values can support equal by supporting the Equatable protocol.
///
/// @see beCloseTo if you want to match imprecise types (eg - floats, doubles).
public func equal<T: Equatable>(_ expectedValue: T?) -> Predicate<T> {
    return Predicate.define("equal <\(stringify(expectedValue))>") { actualExpression, msg in
        let actualValue = try actualExpression.evaluate()
        switch (expectedValue, actualValue) {
        case (nil, _?):
            return PredicateResult(status: .fail, message: msg.appendedBeNilHint())
        case (nil, nil), (_, nil):
            return PredicateResult(status: .fail, message: msg)
        case (let expected?, let actual?):
            let matches = expected == actual
            return PredicateResult(bool: matches, message: msg)
        }
    }
}

/// A Nimble matcher allowing comparison of collection with optional type
public func equal<T: Equatable>(_ expectedValue: [T?]) -> Predicate<[T?]> {
    return Predicate.define("equal <\(stringify(expectedValue))>") { actualExpression, msg in
        guard let actualValue = try actualExpression.evaluate() else {
            return PredicateResult(
                status: .fail,
                message: msg.appendedBeNilHint()
            )
        }

        let matches = expectedValue == actualValue
        return PredicateResult(bool: matches, message: msg)
    }
}

/// A Nimble matcher that succeeds when the actual set is equal to the expected set.
public func equal<T>(_ expectedValue: Set<T>?) -> Predicate<Set<T>> {
    return equal(expectedValue, stringify: { stringify($0) })
}

/// A Nimble matcher that succeeds when the actual set is equal to the expected set.
public func equal<T: Comparable>(_ expectedValue: Set<T>?) -> Predicate<Set<T>> {
    return equal(expectedValue, stringify: {
        if let set = $0 {
            return stringify(Array(set).sorted { $0 < $1 })
        } else {
            return "nil"
        }
    })
}

private func equal<T>(_ expectedValue: Set<T>?, stringify: @escaping (Set<T>?) -> String) -> Predicate<Set<T>> {
    return Predicate { actualExpression in
        var errorMessage: ExpectationMessage =
            .expectedActualValueTo("equal <\(stringify(expectedValue))>")

        guard let expectedValue = expectedValue else {
            return PredicateResult(
                status: .fail,
                message: errorMessage.appendedBeNilHint()
            )
        }

        guard let actualValue = try actualExpression.evaluate() else {
            return PredicateResult(
                status: .fail,
                message: errorMessage.appendedBeNilHint()
            )
        }

        errorMessage = .expectedCustomValueTo(
            "equal <\(stringify(expectedValue))>",
            "<\(stringify(actualValue))>"
        )

        if expectedValue == actualValue {
            return PredicateResult(
                status: .matches,
                message: errorMessage
            )
        }

        let missing = expectedValue.subtracting(actualValue)
        if missing.count > 0 {
            errorMessage = errorMessage.appended(message: ", missing <\(stringify(missing))>")
        }

        let extra = actualValue.subtracting(expectedValue)
        if extra.count > 0 {
            errorMessage = errorMessage.appended(message: ", extra <\(stringify(extra))>")
        }
        return  PredicateResult(
            status: .doesNotMatch,
            message: errorMessage
        )
    }
}

public func ==<T: Equatable>(lhs: Expectation<T>, rhs: T?) {
    lhs.to(equal(rhs))
}

public func !=<T: Equatable>(lhs: Expectation<T>, rhs: T?) {
    lhs.toNot(equal(rhs))
}

public func ==<T: Equatable>(lhs: Expectation<[T]>, rhs: [T]?) {
    lhs.to(equal(rhs))
}

public func !=<T: Equatable>(lhs: Expectation<[T]>, rhs: [T]?) {
    lhs.toNot(equal(rhs))
}

public func == <T>(lhs: Expectation<Set<T>>, rhs: Set<T>?) {
    lhs.to(equal(rhs))
}

public func != <T>(lhs: Expectation<Set<T>>, rhs: Set<T>?) {
    lhs.toNot(equal(rhs))
}

public func ==<T: Comparable>(lhs: Expectation<Set<T>>, rhs: Set<T>?) {
    lhs.to(equal(rhs))
}

public func !=<T: Comparable>(lhs: Expectation<Set<T>>, rhs: Set<T>?) {
    lhs.toNot(equal(rhs))
}

public func ==<T, C: Equatable>(lhs: Expectation<[T: C]>, rhs: [T: C]?) {
    lhs.to(equal(rhs))
}

public func !=<T, C: Equatable>(lhs: Expectation<[T: C]>, rhs: [T: C]?) {
    lhs.toNot(equal(rhs))
}

#if canImport(Darwin)
extension NMBObjCMatcher {
    @objc public class func equalMatcher(_ expected: NSObject) -> NMBMatcher {
        return NMBPredicate { actualExpression in
            return try equal(expected).satisfies(actualExpression).toObjectiveC()
        }
    }
}
#endif
