/**
 Used by the `toSucceed` matcher.

 This is the return type for the closure.
 */
public enum ToSucceedResult {
    case succeeded
    case failed(reason: String)
}

/**
 A Nimble matcher that takes in a closure for validation.

 Return `.succeeded` when the validation succeeds.
 Return `.failed` with a failure reason when the validation fails.
 */
public func succeed() -> Predicate<() -> ToSucceedResult> {
    return Predicate.define { actualExpression in
        let optActual = try actualExpression.evaluate()
        guard let actual = optActual else {
            return PredicateResult(status: .fail, message: .fail("expected a closure, got <nil>"))
        }

        switch actual() {
        case .succeeded:
            return PredicateResult(
                bool: true,
                message: .expectedCustomValueTo("succeed", "<succeeded>")
            )
        case .failed(let reason):
            return PredicateResult(
                bool: false,
                message: .expectedCustomValueTo("succeed", "<failed> because <\(reason)>")
            )
        }
    }
}
