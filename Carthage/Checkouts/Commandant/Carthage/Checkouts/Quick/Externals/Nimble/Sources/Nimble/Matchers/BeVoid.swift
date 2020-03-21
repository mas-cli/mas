import Foundation

/// A Nimble matcher that succeeds when the actual value is Void.
public func beVoid() -> Predicate<()> {
    return Predicate.simpleNilable("be void") { actualExpression in
        let actualValue: ()? = try actualExpression.evaluate()
        return PredicateStatus(bool: actualValue != nil)
    }
}

extension Expectation where T == () {
    public static func == (lhs: Expectation<()>, rhs: ()) {
        lhs.to(beVoid())
    }

    public static func != (lhs: Expectation<()>, rhs: ()) {
        lhs.toNot(beVoid())
    }
}
