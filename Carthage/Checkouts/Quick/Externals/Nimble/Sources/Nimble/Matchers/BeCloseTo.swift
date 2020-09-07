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
            message: .expectedCustomValueTo(errorMessage, actual: "<\(stringify(actualValue))>")
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
public class NMBObjCBeCloseToPredicate: NMBPredicate {
    private let _expected: NSNumber

    fileprivate init(expected: NSNumber, within: CDouble) {
        _expected = expected

        let predicate = beCloseTo(expected, within: within)
        let predicateBlock: PredicateBlock = { actualExpression in
            let expr = actualExpression.cast { $0 as? NMBDoubleConvertible }
            return try predicate.satisfies(expr).toObjectiveC()
        }
        super.init(predicate: predicateBlock)
    }

    @objc public var within: (CDouble) -> NMBObjCBeCloseToPredicate {
        let expected = _expected
        return { delta in
            return NMBObjCBeCloseToPredicate(expected: expected, within: delta)
        }
    }
}

extension NMBPredicate {
    @objc public class func beCloseToMatcher(_ expected: NSNumber, within: CDouble) -> NMBObjCBeCloseToPredicate {
        return NMBObjCBeCloseToPredicate(expected: expected, within: within)
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

extension Expectation where T == [Double] {
    // swiftlint:disable:next identifier_name
    public static func ≈(lhs: Expectation, rhs: [Double]) {
        lhs.to(beCloseTo(rhs))
    }
}

extension Expectation where T == NMBDoubleConvertible {
    // swiftlint:disable:next identifier_name
    public static func ≈(lhs: Expectation, rhs: NMBDoubleConvertible) {
        lhs.to(beCloseTo(rhs))
    }

    // swiftlint:disable:next identifier_name
    public static func ≈(lhs: Expectation, rhs: (expected: NMBDoubleConvertible, delta: Double)) {
        lhs.to(beCloseTo(rhs.expected, within: rhs.delta))
    }

    public static func == (lhs: Expectation, rhs: (expected: NMBDoubleConvertible, delta: Double)) {
        lhs.to(beCloseTo(rhs.expected, within: rhs.delta))
    }
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
