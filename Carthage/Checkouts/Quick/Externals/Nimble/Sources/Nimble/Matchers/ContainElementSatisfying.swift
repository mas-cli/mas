import Foundation

public func containElementSatisfying<S: Sequence, T>(_ predicate: @escaping ((T) -> Bool), _ predicateDescription: String = "") -> Predicate<S> where S.Iterator.Element == T {

    return Predicate.define { actualExpression in
        let message: ExpectationMessage
        if predicateDescription == "" {
            message = .expectedTo("find object in collection that satisfies predicate")
        } else {
            message = .expectedTo("find object in collection \(predicateDescription)")
        }

        if let sequence = try actualExpression.evaluate() {
            for object in sequence {
                if predicate(object) {
                    return PredicateResult(bool: true, message: message)
                }
            }

            return PredicateResult(bool: false, message: message)
        }

        return PredicateResult(status: .fail, message: message)
    }
}

#if canImport(Darwin)
    extension NMBObjCMatcher {
        @objc public class func containElementSatisfyingMatcher(_ predicate: @escaping ((NSObject) -> Bool)) -> NMBMatcher {
            return NMBPredicate { actualExpression in
                let value = try actualExpression.evaluate()
                guard let enumeration = value as? NSFastEnumeration else {
                    let message = ExpectationMessage.fail(
                        "containElementSatisfying must be provided an NSFastEnumeration object"
                    )
                    return NMBPredicateResult(status: .fail, message: message.toObjectiveC())
                }

                let message = ExpectationMessage
                    .expectedTo("find object in collection that satisfies predicate")
                    .toObjectiveC()

                var iterator = NSFastEnumerationIterator(enumeration)
                while let item = iterator.next() {
                    guard let object = item as? NSObject else {
                        continue
                    }

                    if predicate(object) {
                        return NMBPredicateResult(status: .matches, message: message)
                    }
                }

                return NMBPredicateResult(status: .doesNotMatch, message: message)
            }
        }
    }
#endif
