import Foundation

/// A Nimble matcher that succeeds when the actual value is equal to the expected value.
/// Values can support equal by supporting the Equatable protocol.
///
/// @see beCloseTo if you want to match imprecise types (eg - floats, doubles).
public func equal<T: Equatable>(_ expectedValue: T?) -> Predicate<T> {
    return Predicate.define("equal <\(stringify(expectedValue))>") { actualExpression, msg in
        let actualValue = try actualExpression.evaluate()
        let matches = actualValue == expectedValue && expectedValue != nil
        if expectedValue == nil || actualValue == nil {
            if expectedValue == nil && actualValue != nil {
                return PredicateResult(
                    status: .fail,
                    message: msg.appendedBeNilHint()
                )
            }
            return PredicateResult(status: .fail, message: msg)
        }
        return PredicateResult(status: PredicateStatus(bool: matches), message: msg)
    }
}

/// A Nimble matcher that succeeds when the actual value is equal to the expected value.
/// Values can support equal by supporting the Equatable protocol.
///
/// @see beCloseTo if you want to match imprecise types (eg - floats, doubles).
public func equal<T, C: Equatable>(_ expectedValue: [T: C]?) -> Predicate<[T: C]> {
    return Predicate.define("equal <\(stringify(expectedValue))>") { actualExpression, msg in
        let actualValue = try actualExpression.evaluate()
        if expectedValue == nil || actualValue == nil {
            if expectedValue == nil && actualValue != nil {
                return PredicateResult(
                    status: .fail,
                    message: msg.appendedBeNilHint()
                )
            }
            return PredicateResult(status: .fail, message: msg)
        }
        return PredicateResult(
            status: PredicateStatus(bool: expectedValue! == actualValue!),
            message: msg
        )
    }
}

/// A Nimble matcher that succeeds when the actual collection is equal to the expected collection.
/// Items must implement the Equatable protocol.
public func equal<T: Equatable>(_ expectedValue: [T]?) -> Predicate<[T]> {
    return Predicate.define("equal <\(stringify(expectedValue))>") { actualExpression, msg in
        let actualValue = try actualExpression.evaluate()
        if expectedValue == nil || actualValue == nil {
            if expectedValue == nil && actualValue != nil {
                return PredicateResult(
                    status: .fail,
                    message: msg.appendedBeNilHint()
                )
            }
            return PredicateResult(
                status: .fail,
                message: msg
            )
        }
        return PredicateResult(
            bool: expectedValue! == actualValue!,
            message: msg
        )
    }
}

/// A Nimble matcher allowing comparison of collection with optional type
public func equal<T: Equatable>(_ expectedValue: [T?]) -> Predicate<[T?]> {
    return Predicate.define("equal <\(stringify(expectedValue))>") { actualExpression, msg in
        if let actualValue = try actualExpression.evaluate() {
            let doesNotMatch = PredicateResult(
                status: .doesNotMatch,
                message: msg
            )

            if expectedValue.count != actualValue.count {
                return doesNotMatch
            }

            for (index, item) in actualValue.enumerated() {
                let otherItem = expectedValue[index]
                if item == nil && otherItem == nil {
                    continue
                } else if item == nil && otherItem != nil {
                    return doesNotMatch
                } else if item != nil && otherItem == nil {
                    return doesNotMatch
                } else if item! != otherItem! {
                    return doesNotMatch
                }
            }

            return PredicateResult(
                status: .matches,
                message: msg
            )
        } else {
            return PredicateResult(
                status: .fail,
                message: msg.appendedBeNilHint()
            )
        }
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

        if let expectedValue = expectedValue {
            if let actualValue = try actualExpression.evaluate() {
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
            return PredicateResult(
                status: .fail,
                message: errorMessage.appendedBeNilHint()
            )
        } else {
            return PredicateResult(
                status: .fail,
                message: errorMessage.appendedBeNilHint()
            )
        }
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

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
extension NMBObjCMatcher {
    @objc public class func equalMatcher(_ expected: NSObject) -> NMBMatcher {
        return NMBPredicate { actualExpression in
            return try equal(expected).satisfies(actualExpression).toObjectiveC()
        }
    }
}
#endif
