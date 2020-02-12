import Foundation

// swiftlint:disable:next identifier_name
public let DefaultDelta = 0.0001

internal func isCloseTo(_ actualValue: NMBDoubleConvertible?,
                        expectedValue: NMBDoubleConvertible,
                        delta: Double)
    -> PredicateResult {
        let errorMessage = "be close to <\(stringify(expectedValue))> (within \(stringify(delta)))"
        return PredicateResult(
            bool: actualValue != nil &&
                abs(actualValue!.doubleValue - expectedValue.doubleValue) < delta,
            message: .expectedCustomValueTo(errorMessage, "<\(stringify(actualValue))>")
        )
}

/// A Nimble matcher that succeeds when a value is close to another. This is used for floating
/// point values which can have imprecise results when doing arithmetic on them.
///
/// @see equal
public func beCloseTo(_ expectedValue: Double, within delta: Double = DefaultDelta) -> Predicate<Double> {
    return Predicate.define { actualExpression in
        return isCloseTo(try actualExpression.evaluate(), expectedValue: expectedValue, delta: delta)
    }
}

/// A Nimble matcher that succeeds when a value is close to another. This is used for floating
/// point values which can have imprecise results when doing arithmetic on them.
///
/// @see equal
public func beCloseTo(_ expectedValue: NMBDoubleConvertible, within delta: Double = DefaultDelta) -> Predicate<NMBDoubleConvertible> {
    return Predicate.define { actualExpression in
        return isCloseTo(try actualExpression.evaluate(), expectedValue: expectedValue, delta: delta)
    }
}

#if canImport(Darwin)
public class NMBObjCBeCloseToMatcher: NSObject, NMBMatcher {
    // swiftlint:disable identifier_name
    var _expected: NSNumber
    var _delta: CDouble
    // swiftlint:enable identifier_name
    init(expected: NSNumber, within: CDouble) {
        _expected = expected
        _delta = within
    }

    @objc public func matches(_ actualExpression: @escaping () -> NSObject?, failureMessage: FailureMessage, location: SourceLocation) -> Bool {
        let actualBlock: () -> NMBDoubleConvertible? = ({
            return actualExpression() as? NMBDoubleConvertible
        })
        let expr = Expression(expression: actualBlock, location: location)
        let predicate = beCloseTo(self._expected, within: self._delta)

        do {
            let result = try predicate.satisfies(expr)
            result.message.update(failureMessage: failureMessage)
            return result.toBoolean(expectation: .toMatch)
        } catch let error {
            failureMessage.stringValue = "unexpected error thrown: <\(error)>"
            return false
        }
    }

    @objc public func doesNotMatch(_ actualExpression: @escaping () -> NSObject?, failureMessage: FailureMessage, location: SourceLocation) -> Bool {
        let actualBlock: () -> NMBDoubleConvertible? = ({
            return actualExpression() as? NMBDoubleConvertible
        })
        let expr = Expression(expression: actualBlock, location: location)
        let predicate = beCloseTo(self._expected, within: self._delta)

        do {
            let result = try predicate.satisfies(expr)
            result.message.update(failureMessage: failureMessage)
            return result.toBoolean(expectation: .toNotMatch)
        } catch let error {
            failureMessage.stringValue = "unexpected error thrown: <\(error)>"
            return false
        }
    }

    @objc public var within: (CDouble) -> NMBObjCBeCloseToMatcher {
        return { delta in
            return NMBObjCBeCloseToMatcher(expected: self._expected, within: delta)
        }
    }
}

extension NMBObjCMatcher {
    @objc public class func beCloseToMatcher(_ expected: NSNumber, within: CDouble) -> NMBObjCBeCloseToMatcher {
        return NMBObjCBeCloseToMatcher(expected: expected, within: within)
    }
}
#endif

public func beCloseTo(_ expectedValues: [Double], within delta: Double = DefaultDelta) -> Predicate<[Double]> {
    let errorMessage = "be close to <\(stringify(expectedValues))> (each within \(stringify(delta)))"
    return Predicate.simple(errorMessage) { actualExpression in
        if let actual = try actualExpression.evaluate() {
            if actual.count != expectedValues.count {
                return .doesNotMatch
            } else {
                for (index, actualItem) in actual.enumerated() {
                    if fabs(actualItem - expectedValues[index]) > delta {
                        return .doesNotMatch
                    }
                }
                return .matches
            }
        }
        return .doesNotMatch
    }
}

// MARK: - Operators

infix operator ≈ : ComparisonPrecedence

// swiftlint:disable:next identifier_name
public func ≈(lhs: Expectation<[Double]>, rhs: [Double]) {
    lhs.to(beCloseTo(rhs))
}

// swiftlint:disable:next identifier_name
public func ≈(lhs: Expectation<NMBDoubleConvertible>, rhs: NMBDoubleConvertible) {
    lhs.to(beCloseTo(rhs))
}

// swiftlint:disable:next identifier_name
public func ≈(lhs: Expectation<NMBDoubleConvertible>, rhs: (expected: NMBDoubleConvertible, delta: Double)) {
    lhs.to(beCloseTo(rhs.expected, within: rhs.delta))
}

public func == (lhs: Expectation<NMBDoubleConvertible>, rhs: (expected: NMBDoubleConvertible, delta: Double)) {
    lhs.to(beCloseTo(rhs.expected, within: rhs.delta))
}

// make this higher precedence than exponents so the Doubles either end aren't pulled in
// unexpectantly
precedencegroup PlusMinusOperatorPrecedence {
    higherThan: BitwiseShiftPrecedence
}

infix operator ± : PlusMinusOperatorPrecedence
// swiftlint:disable:next identifier_name
public func ±(lhs: NMBDoubleConvertible, rhs: Double) -> (expected: NMBDoubleConvertible, delta: Double) {
    return (expected: lhs, delta: rhs)
}
